const express = require('express');
const cors = require('cors');
require('dotenv').config();
const pool = require('./src/db/pool');
const isBusinessOwner = require('./src/middleware/isBusinessOwner');
const createOrdersRouter = require('./src/routes/orders');
const createAuthRouter = require('./src/routes/auth');
const createVehiclesRouter = require('./src/routes/vehicles');

const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) {
  throw new Error('JWT_SECRET manquant. Définissez-le dans les variables d\'environnement.');
}

const app = express();
const PORT = parseInt(process.env.PORT, 10) || 3000;

app.use(cors());
app.use(express.json());
app.use(createOrdersRouter({ pool, isBusinessOwner }));
app.use(createAuthRouter({ pool, jwtSecret: JWT_SECRET }));
app.use(createVehiclesRouter({ pool }));

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

// ==================== ROUTES BUSINESS (commerçants) ====================

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

// ==================== DÉMARRAGE ====================
app.listen(PORT, () => {
  console.log(`🚀 Serveur prêt sur http://localhost:${PORT}`);
});