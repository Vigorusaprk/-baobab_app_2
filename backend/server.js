const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const JWT_SECRET = 'votre_secret_jwt';

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'baobabe_db',
  password: 'admin123',
  port: 5432,
});

// ==================== MIDDLEWARE ====================
function isBusinessOwner(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.status(401).json({ error: 'Token manquant' });
  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    if (!decoded.businessId) {
      return res.status(403).json({ error: 'Accès réservé aux commerçants' });
    }
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Token invalide' });
  }
}

// ==================== BUSINESS ====================
app.get('/api/businesses', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM business');
    res.json(result.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/businesses/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const businessResult = await pool.query('SELECT * FROM business WHERE id = $1', [id]);
    if (businessResult.rows.length === 0) return res.status(404).json({ error: "Non trouvé" });
    const business = businessResult.rows[0];
    if (business.type === 'mall') {
      const storesResult = await pool.query(
        `SELECT b.* FROM business b
         JOIN mall_stores ms ON ms.store_id = b.id
         WHERE ms.mall_id = $1`,
        [id]
      );
      business.stores = storesResult.rows;
    }
    res.json(business);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/businesses/:id/menu', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(
      'SELECT * FROM menu_items WHERE business_id = $1 ORDER BY item_category, item_name',
      [id]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/businesses/:id/movies', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(
      `SELECT m.*, json_agg(json_build_object(
        'id', s.id,
        'start_time', s.start_time,
        'room', s.room,
        'price', s.price,
        'available_seats', s.available_seats
      )) as showtimes
       FROM movies m
       LEFT JOIN showtimes s ON s.movie_id = m.id
       WHERE m.business_id = $1
       GROUP BY m.id
       ORDER BY m.release_date DESC`,
      [id]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/businesses/:id/rooms', async (req, res) => {
  const { id } = req.params;
  const { check_in, check_out, rooms } = req.query;
  try {
    const roomsResult = await pool.query('SELECT * FROM rooms WHERE business_id = $1', [id]);
    let roomsList = roomsResult.rows;
    if (check_in && check_out) {
      const checkInDate = new Date(check_in);
      const checkOutDate = new Date(check_out);
      for (let i = 0; i < roomsList.length; i++) {
        const room = roomsList[i];
        const bookings = await pool.query(
          `SELECT COUNT(*) FROM reservations
           WHERE details->>'room_id' = $1
             AND reservation_date >= $2
             AND reservation_date < $3`,
          [room.id.toString(), checkInDate.toISOString(), checkOutDate.toISOString()]
        );
        const bookedCount = parseInt(bookings.rows[0].count);
        const requestedRooms = parseInt(rooms) || 1;
        if (room.available_quantity - bookedCount < requestedRooms) {
          roomsList.splice(i, 1);
          i--;
        }
      }
    }
    res.json(roomsList);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: err.message });
  }
});

// ==================== RÉSERVATIONS ====================
app.post('/api/reservations', async (req, res) => {
  const { business_id, user_id, type, reservation_date, total_amount, details } = req.body;
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    if (type === 'hotel' && details.room_id) {
      const room = await client.query(
        'SELECT available_quantity FROM rooms WHERE id = $1 FOR UPDATE',
        [details.room_id]
      );
      if (room.rows.length === 0 || room.rows[0].available_quantity < 1) {
        throw new Error('Chambre non disponible');
      }
      await client.query(
        'UPDATE rooms SET available_quantity = available_quantity - 1 WHERE id = $1',
        [details.room_id]
      );
    }
    await client.query(
      `INSERT INTO reservations (business_id, user_id, type, reservation_date, total_amount, details)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [business_id, user_id, type, reservation_date, total_amount, JSON.stringify(details)]
    );
    await client.query('COMMIT');
    res.status(201).json({ message: "Réservation enregistrée" });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error(err.message);
    res.status(500).json({ error: err.message });
  } finally {
    client.release();
  }
});

app.get('/api/reservations', async (req, res) => {
  const { user_id } = req.query;
  if (!user_id) return res.status(400).json({ error: "user_id requis" });
  try {
    const result = await pool.query(
      `SELECT r.*, b.name AS establishment_name
       FROM reservations r
       INNER JOIN business b ON r.business_id = b.id
       WHERE r.user_id = $1
       ORDER BY r.reservation_date DESC`,
      [user_id]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/reservations/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('DELETE FROM reservations WHERE id = $1 RETURNING id', [id]);
    if (result.rowCount === 0) return res.status(404).json({ error: "Réservation non trouvée" });
    res.json({ message: "Réservation supprimée", id: result.rows[0].id });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: err.message });
  }
});

// ==================== COMMANDES ====================
app.post('/api/orders', async (req, res) => {
  const { user_id, business_id, items, delivery_address, delivery_fee, payment_method, notes } = req.body;
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    let total = 0;
    for (const item of items) {
      const menuRes = await client.query('SELECT price FROM menu_items WHERE id = $1', [item.menu_item_id]);
      if (menuRes.rows.length === 0) throw new Error(`Item ${item.menu_item_id} introuvable`);
      total += menuRes.rows[0].price * item.quantity;
    }
    total += delivery_fee || 0;

    const orderRes = await client.query(
      `INSERT INTO orders (user_id, business_id, status, total_amount, delivery_address, delivery_fee, payment_method, notes)
       VALUES ($1, $2, 'pending', $3, $4, $5, $6, $7) RETURNING id`,
      [user_id, business_id, total, delivery_address, delivery_fee || 0, payment_method, notes]
    );
    const orderId = orderRes.rows[0].id;

    for (const item of items) {
      const menuRes = await client.query('SELECT price FROM menu_items WHERE id = $1', [item.menu_item_id]);
      const unitPrice = menuRes.rows[0].price;
      await client.query(
        `INSERT INTO order_items (order_id, menu_item_id, quantity, unit_price, special_instructions)
         VALUES ($1, $2, $3, $4, $5)`,
        [orderId, item.menu_item_id, item.quantity, unitPrice, item.special_instructions]
      );
    }
    await client.query('COMMIT');
    res.status(201).json({ id: orderId, message: 'Commande créée' });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error(err.message);
    res.status(500).json({ error: err.message });
  } finally {
    client.release();
  }
});

app.get('/api/orders', async (req, res) => {
  const { user_id } = req.query;
  if (!user_id) return res.status(400).json({ error: 'user_id requis' });
  try {
    const orders = await pool.query(
      `SELECT o.*, b.name AS establishment_name,
              json_agg(json_build_object(
                'menu_item_id', oi.menu_item_id,
                'name', mi.item_name,
                'unit_price', oi.unit_price,
                'quantity', oi.quantity,
                'special_instructions', oi.special_instructions
              )) as items
       FROM orders o
       LEFT JOIN business b ON o.business_id = b.id
       LEFT JOIN order_items oi ON oi.order_id = o.id
       LEFT JOIN menu_items mi ON oi.menu_item_id = mi.id
       WHERE o.user_id = $1
       GROUP BY o.id, b.name
       ORDER BY o.created_at DESC`,
      [user_id]
    );
    res.json(orders.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: err.message });
  }
});

app.patch('/api/orders/:id', async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  try {
    const result = await pool.query(
      'UPDATE orders SET status = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 RETURNING id',
      [status, id]
    );
    if (result.rowCount === 0) return res.status(404).json({ error: 'Commande non trouvée' });
    res.json({ message: 'Statut mis à jour', id: result.rows[0].id });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: err.message });
  }
});

// ==================== ROUTES BUSINESS (commerçants) ====================
app.get('/api/businesses/:businessId/orders', isBusinessOwner, async (req, res) => {
  const { businessId } = req.params;
  const { status, page = 1, limit = 20 } = req.query;
  const offset = (page - 1) * limit;
  try {
    let query = 'SELECT * FROM orders WHERE business_id = $1';
    const params = [businessId];
    if (status) {
      query += ' AND status = $2';
      params.push(status);
    }
    query += ' ORDER BY created_at DESC LIMIT $' + (params.length + 1) + ' OFFSET $' + (params.length + 2);
    params.push(limit, offset);
    const result = await pool.query(query, params);
    const countResult = await pool.query('SELECT COUNT(*) FROM orders WHERE business_id = $1', [businessId]);
    res.json({
      orders: result.rows,
      total: parseInt(countResult.rows[0].count),
      page: parseInt(page),
      limit: parseInt(limit),
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: err.message });
  }
});

app.patch('/api/orders/:id/status', isBusinessOwner, async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  const validStatus = ['pending', 'confirmed', 'preparing', 'ready', 'delivered', 'cancelled'];
  if (!validStatus.includes(status)) {
    return res.status(400).json({ error: 'Statut invalide' });
  }
  try {
    const order = await pool.query('SELECT business_id FROM orders WHERE id = $1', [id]);
    if (order.rows.length === 0) return res.status(404).json({ error: 'Commande non trouvée' });
    if (order.rows[0].business_id !== req.user.businessId) {
      return res.status(403).json({ error: 'Non autorisé' });
    }
    await pool.query('UPDATE orders SET status = $1, updated_at = NOW() WHERE id = $2', [status, id]);
    res.json({ message: 'Statut mis à jour' });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/businesses/:businessId/reservations', isBusinessOwner, async (req, res) => {
  const { businessId } = req.params;
  const { type, page = 1, limit = 20 } = req.query;
  const offset = (page - 1) * limit;
  try {
    let query = 'SELECT * FROM reservations WHERE business_id = $1';
    const params = [businessId];
    if (type) {
      query += ' AND type = $2';
      params.push(type);
    }
    query += ' ORDER BY reservation_date DESC LIMIT $' + (params.length + 1) + ' OFFSET $' + (params.length + 2);
    params.push(limit, offset);
    const result = await pool.query(query, params);
    const countResult = await pool.query('SELECT COUNT(*) FROM reservations WHERE business_id = $1', [businessId]);
    res.json({
      reservations: result.rows,
      total: parseInt(countResult.rows[0].count),
      page: parseInt(page),
      limit: parseInt(limit),
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/businesses/:id/menu', isBusinessOwner, async (req, res) => {
  const { id } = req.params;
  const { items } = req.body;
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await client.query('DELETE FROM menu_items WHERE business_id = $1', [id]);
    for (const item of items) {
      await client.query(
        `INSERT INTO menu_items (business_id, item_name, item_category, price, description, image_url, ingredients)
         VALUES ($1, $2, $3, $4, $5, $6, $7)`,
        [id, item.name, item.category, item.price, item.description, item.imageUrl, item.ingredients]
      );
    }
    await client.query('COMMIT');
    res.json({ message: 'Menu mis à jour' });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error(err.message);
    res.status(500).json({ error: err.message });
  } finally {
    client.release();
  }
});

app.patch('/api/businesses/:id/rooms/:roomId', isBusinessOwner, async (req, res) => {
  const { id, roomId } = req.params;
  const { available_quantity } = req.body;
  try {
    await pool.query(
      'UPDATE rooms SET available_quantity = $1 WHERE id = $2 AND business_id = $3',
      [available_quantity, roomId, id]
    );
    res.json({ message: 'Disponibilité mise à jour' });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: err.message });
  }
});

// ==================== AUTHENTIFICATION ====================
// ==================== AUTHENTIFICATION ====================
// Inscription
app.post('/api/auth/signup', async (req, res) => {
  console.log('Signup body reçu:', req.body);
  const { name, email, password, phone } = req.body;
  if (!name || !email || !password) {
    return res.status(400).json({ error: 'Tous les champs sont requis' });
  }
  try {
    const existing = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
    if (existing.rows.length > 0) {
      return res.status(409).json({ error: 'Email déjà utilisé' });
    }
    const hashedPassword = await bcrypt.hash(password, 10);
    const id = Date.now().toString();
    await pool.query(
      `INSERT INTO users (id, name, email, password, phone, img_url, created_at)
       VALUES ($1, $2, $3, $4, $5, $6, NOW())`,
      [id, name, email, hashedPassword, phone || null, '']
    );
    const token = jwt.sign({ id, email, businessId: null }, JWT_SECRET, { expiresIn: '2h' });
    res.status(201).json({
      id,
      name,
      email,
      token,
      businessId: null,        // ← Ajouté
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// Connexion
app.post('/api/auth/login', async (req, res) => {
  const { email, password, rememberMe } = req.body;
  console.log('Login body reçu:', req.body);
  if (!email || !password) {
    return res.status(400).json({ error: 'Email et mot de passe requis' });
  }
  try {
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Email ou mot de passe incorrect' });
    }
    const user = result.rows[0];
    const valid = await bcrypt.compare(password, user.password);
    if (!valid) {
      return res.status(401).json({ error: 'Email ou mot de passe incorrect' });
    }
    await pool.query('UPDATE users SET last_login = NOW() WHERE id = $1', [user.id]);
    const expiresIn = rememberMe ? '7d' : '2h';
    const token = jwt.sign(
      { id: user.id, email: user.email, businessId: user.business_id },
      JWT_SECRET,
      { expiresIn }
    );
    res.json({
      id: user.id,
      name: user.name,
      email: user.email,
      imgUrl: user.img_url ?? '',
      token,
      businessId: user.business_id,    // ← Ajouté
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// Obtenir l'utilisateur courant
app.get('/api/auth/me', async (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.status(401).json({ error: 'Token manquant' });
  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    const result = await pool.query('SELECT id, name, email, img_url, business_id FROM users WHERE id = $1', [decoded.id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Utilisateur non trouvé' });
    const user = result.rows[0];
    res.json({
      id: user.id,
      name: user.name,
      email: user.email,
      imgUrl: user.img_url ?? '',
      businessId: user.business_id,
    });
  } catch (err) {
    return res.status(401).json({ error: 'Token invalide' });
  }
});

// ==================== STATISTIQUES ====================
app.get('/api/businesses/:businessId/stats', isBusinessOwner, async (req, res) => {
  const { businessId } = req.params;
  try {
    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);
    const todayStr = today.toISOString().slice(0, 10);
    const yesterdayStr = yesterday.toISOString().slice(0, 10);

    // Commandes aujourd'hui
    const ordersToday = await pool.query(
      `SELECT COUNT(*) as count, COALESCE(SUM(total_amount), 0) as revenue
       FROM orders WHERE business_id = $1 AND DATE(created_at) = $2`,
      [businessId, todayStr]
    );
    // Commandes hier
    const ordersYesterday = await pool.query(
      `SELECT COUNT(*) as count, COALESCE(SUM(total_amount), 0) as revenue
       FROM orders WHERE business_id = $1 AND DATE(created_at) = $2`,
      [businessId, yesterdayStr]
    );

    // Réservations aujourd'hui
    const reservationsToday = await pool.query(
      `SELECT COUNT(*) as count
       FROM reservations WHERE business_id = $1 AND DATE(reservation_date) = $2`,
      [businessId, todayStr]
    );
    // Réservations hier
    const reservationsYesterday = await pool.query(
      `SELECT COUNT(*) as count
       FROM reservations WHERE business_id = $1 AND DATE(reservation_date) = $2`,
      [businessId, yesterdayStr]
    );

    // Commandes en attente
    const pendingOrders = await pool.query(
      `SELECT COUNT(*) as count FROM orders WHERE business_id = $1 AND status = 'pending'`,
      [businessId]
    );
    // Réservations en attente
    const pendingReservations = await pool.query(
      `SELECT COUNT(*) as count FROM reservations WHERE business_id = $1 AND status = 'pending'`,
      [businessId]
    );

    // Revenus mensuels (12 derniers mois) – 1 seule requête groupée
    const monthlyQuery = `
      SELECT
        DATE_TRUNC('month', created_at) as month,
        COALESCE(SUM(total_amount), 0) as revenue
      FROM orders
      WHERE business_id = $1
        AND created_at >= (DATE_TRUNC('month', NOW()) - INTERVAL '11 months')
      GROUP BY month
      ORDER BY month ASC
    `;
    const monthlyResult = await pool.query(monthlyQuery, [businessId]);

    // Initialiser un tableau de 12 mois à 0
    const monthlyRevenues = Array(12).fill(0);
    const now = new Date();
    for (const row of monthlyResult.rows) {
      const monthIndex = (row.month.getMonth() + 12 - now.getMonth()) % 12;
      monthlyRevenues[monthIndex] = parseFloat(row.revenue);
    }

    res.json({
      todayOrders: parseInt(ordersToday.rows[0].count),
      todayReservations: parseInt(reservationsToday.rows[0].count),
      todayRevenue: parseFloat(ordersToday.rows[0].revenue),
      pendingOrders: parseInt(pendingOrders.rows[0].count),
      pendingReservations: parseInt(pendingReservations.rows[0].count),
      previousTodayOrders: parseInt(ordersYesterday.rows[0].count),
      previousTodayReservations: parseInt(reservationsYesterday.rows[0].count),
      previousTodayRevenue: parseFloat(ordersYesterday.rows[0].revenue),
      monthlyRevenues: monthlyRevenues,
    });
  } catch (err) {
    console.error('Erreur stats:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// ==================== CLIENTS (version simple) ====================
app.get('/api/businesses/:businessId/customers', isBusinessOwner, async (req, res) => {
  const { businessId } = req.params;
  const { page = 1, limit = 20 } = req.query;
  const offset = (page - 1) * limit;
  try {
    // Récupère tous les utilisateurs (sans condition sur commandes/réservations)
    const query = `
      SELECT id, name, email, img_url
      FROM users
      ORDER BY created_at DESC
      LIMIT $1 OFFSET $2
    `;
    const result = await pool.query(query, [limit, offset]);

    // Total d'utilisateurs
    const totalResult = await pool.query('SELECT COUNT(*) as total FROM users');
    const total = parseInt(totalResult.rows[0].total);

    res.json({
      customers: result.rows,
      total: total,
      page: parseInt(page),
      limit: parseInt(limit),
    });
  } catch (err) {
    console.error('Erreur route /customers :', err);
    res.status(500).json({ error: err.message });
  }
});

// ==================== GESTION DU MENU (items individuels) ====================
// Ajouter un nouvel article
app.post('/api/businesses/:businessId/menu/items', isBusinessOwner, async (req, res) => {
  const { businessId } = req.params;
  const { item_name, item_category, price, description, image_url, ingredients } = req.body;
  try {
    const result = await pool.query(
      `INSERT INTO menu_items (business_id, item_name, item_category, price, description, image_url, ingredients, is_available)
       VALUES ($1, $2, $3, $4, $5, $6, $7, true)
       RETURNING id`,
      [businessId, item_name, item_category, price, description, image_url, ingredients]
    );
    res.status(201).json({ id: result.rows[0].id, message: 'Article ajouté' });
  } catch (err) {
    console.error('Erreur ajout item:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// Modifier un article (prix ou disponibilité)
app.patch('/api/businesses/:businessId/menu/:itemId', isBusinessOwner, async (req, res) => {
  const { businessId, itemId } = req.params;
  const { is_available, price } = req.body;
  try {
    let updateQuery = 'UPDATE menu_items SET ';
    const updates = [];
    const values = [];
    if (is_available !== undefined) {
      updates.push(`is_available = $${updates.length + 1}`);
      values.push(is_available);
    }
    if (price !== undefined) {
      updates.push(`price = $${updates.length + 1}`);
      values.push(price);
    }
    if (updates.length === 0) {
      return res.status(400).json({ error: 'Rien à mettre à jour' });
    }
    updateQuery += updates.join(', ') + ` WHERE id = $${values.length + 1} AND business_id = $${values.length + 2}`;
    values.push(itemId, businessId);
    await pool.query(updateQuery, values);
    res.json({ message: 'Article mis à jour' });
  } catch (err) {
    console.error('Erreur modification item:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// ==================== AJOUTER UN ARTICLE AU MENU ====================
app.post('C', isBusinessOwner, async (req, res) => {
  const { businessId } = req.params;
  const { item_name, price, item_category } = req.body;
  console.log('📝 Ajout article reçu:', { businessId, item_name, price, item_category });
  try {
    const result = await pool.query(
      `INSERT INTO menu_items (business_id, item_name, price, item_category, is_available)
       VALUES ($1, $2, $3, $4, true)
       RETURNING id`,
      [businessId, item_name, price, item_category]
    );
    res.status(201).json({ id: result.rows[0].id, message: 'Article ajouté' });
  } catch (err) {
    console.error('❌ Erreur ajout:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// ==================== DÉMARRAGE ====================
app.listen(PORT, () => {
  console.log(`🚀 Serveur prêt sur http://localhost:${PORT}`);
});