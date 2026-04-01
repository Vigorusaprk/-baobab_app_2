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

// --- Business ---
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
    // Si c'est un mall, récupérer ses boutiques
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

// --- Films
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

// --- Chambres d'hôtel
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

// --- Réservations
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
      'SELECT * FROM reservations WHERE user_id = $1 ORDER BY reservation_date DESC',
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

// --- Commandes
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

// --- Authentification
app.post('/api/auth/signup', async (req, res) => {
  console.log('Signup body reçu:', req.body); // Log pour debug
  const { name, email, password, imgUrl } = req.body;
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
      `INSERT INTO users (id, name, email, password, img_url, created_at)
       VALUES ($1, $2, $3, $4, $5, NOW())`,
      [id, name, email, hashedPassword, imgUrl || '']
    );

    const token = jwt.sign({ id, email }, JWT_SECRET, { expiresIn: '2h' });

    res.status(201).json({
      id,
      name,
      email,
      imgUrl: imgUrl ?? '',
      token,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/auth/login', async (req, res) => {
  console.log('Login body reçu:', req.body);
  const { email, password } = req.body;
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

    const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, { expiresIn: '2h' });

    res.json({
      id: user.id,
      name: user.name,
      email: user.email,
      imgUrl: user.img_url ?? '',
      token,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/auth/me', async (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.status(401).json({ error: 'Token manquant' });
  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    const result = await pool.query('SELECT id, name, email, img_url FROM users WHERE id = $1', [decoded.id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Utilisateur non trouvé' });
    const user = result.rows[0];
    res.json({
      id: user.id,
      name: user.name,
      email: user.email,
      imgUrl: user.img_url ?? '',
    });
  } catch (err) {
    return res.status(401).json({ error: 'Token invalide' });
  }
});

app.listen(PORT, () => {
  console.log(`🚀 Serveur prêt sur http://localhost:${PORT}`);
});