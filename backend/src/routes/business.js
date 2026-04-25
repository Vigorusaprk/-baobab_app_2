const express = require('express');

function createBusinessRouter({ pool, isBusinessOwner }) {
  const router = express.Router();

  router.get('/api/businesses', async (req, res) => {
    try {
      const result = await pool.query('SELECT * FROM business');
      res.json(result.rows);
    } catch (err) {
      console.error(err.message);
      res.status(500).json({ error: err.message });
    }
  });

  router.get('/api/businesses/:id', async (req, res) => {
    const { id } = req.params;
    try {
      const businessResult = await pool.query('SELECT * FROM business WHERE id = $1', [id]);
      if (businessResult.rows.length === 0) return res.status(404).json({ error: 'Non trouvé' });
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

  router.get('/api/businesses/:id/menu', async (req, res) => {
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

  router.get('/api/businesses/:id/movies', async (req, res) => {
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

  router.get('/api/businesses/:id/rooms', async (req, res) => {
    const { id } = req.params;
    const { check_in, check_out, rooms } = req.query;
    try {
      const roomsResult = await pool.query('SELECT * FROM rooms WHERE business_id = $1', [id]);
      let roomsList = roomsResult.rows;
      if (check_in && check_out) {
        const checkInDate = new Date(check_in);
        const checkOutDate = new Date(check_out);
        for (let i = 0; i < roomsList.length; i += 1) {
          const room = roomsList[i];
          const bookings = await pool.query(
            `SELECT COUNT(*) FROM reservations
             WHERE details->>'room_id' = $1
               AND reservation_date >= $2
               AND reservation_date < $3`,
            [room.id.toString(), checkInDate.toISOString(), checkOutDate.toISOString()]
          );
          const bookedCount = parseInt(bookings.rows[0].count, 10);
          const requestedRooms = parseInt(rooms, 10) || 1;
          if (room.available_quantity - bookedCount < requestedRooms) {
            roomsList.splice(i, 1);
            i -= 1;
          }
        }
      }
      res.json(roomsList);
    } catch (err) {
      console.error(err.message);
      res.status(500).json({ error: err.message });
    }
  });

  router.put('/api/businesses/:id/menu', isBusinessOwner, async (req, res) => {
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

  router.patch('/api/businesses/:id/rooms/:roomId', isBusinessOwner, async (req, res) => {
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

  router.get('/api/businesses/:businessId/stats', isBusinessOwner, async (req, res) => {
    const { businessId } = req.params;
    try {
      const today = new Date();
      const yesterday = new Date(today);
      yesterday.setDate(yesterday.getDate() - 1);
      const todayStr = today.toISOString().slice(0, 10);
      const yesterdayStr = yesterday.toISOString().slice(0, 10);

      const ordersToday = await pool.query(
        `SELECT COUNT(*) as count, COALESCE(SUM(total_amount), 0) as revenue
         FROM orders WHERE business_id = $1 AND DATE(created_at) = $2`,
        [businessId, todayStr]
      );
      const ordersYesterday = await pool.query(
        `SELECT COUNT(*) as count, COALESCE(SUM(total_amount), 0) as revenue
         FROM orders WHERE business_id = $1 AND DATE(created_at) = $2`,
        [businessId, yesterdayStr]
      );
      const reservationsToday = await pool.query(
        `SELECT COUNT(*) as count
         FROM reservations WHERE business_id = $1 AND DATE(reservation_date) = $2`,
        [businessId, todayStr]
      );
      const reservationsYesterday = await pool.query(
        `SELECT COUNT(*) as count
         FROM reservations WHERE business_id = $1 AND DATE(reservation_date) = $2`,
        [businessId, yesterdayStr]
      );
      const pendingOrders = await pool.query(
        `SELECT COUNT(*) as count FROM orders WHERE business_id = $1 AND status = 'pending'`,
        [businessId]
      );
      const pendingReservations = await pool.query(
        `SELECT COUNT(*) as count FROM reservations WHERE business_id = $1 AND status = 'pending'`,
        [businessId]
      );

      const monthlyResult = await pool.query(
        `SELECT
          DATE_TRUNC('month', created_at) as month,
          COALESCE(SUM(total_amount), 0) as revenue
         FROM orders
         WHERE business_id = $1
           AND created_at >= (DATE_TRUNC('month', NOW()) - INTERVAL '11 months')
         GROUP BY month
         ORDER BY month ASC`,
        [businessId]
      );

      const monthlyRevenues = Array(12).fill(0);
      const now = new Date();
      for (const row of monthlyResult.rows) {
        const monthIndex = (row.month.getMonth() + 12 - now.getMonth()) % 12;
        monthlyRevenues[monthIndex] = parseFloat(row.revenue);
      }

      res.json({
        todayOrders: parseInt(ordersToday.rows[0].count, 10),
        todayReservations: parseInt(reservationsToday.rows[0].count, 10),
        todayRevenue: parseFloat(ordersToday.rows[0].revenue),
        pendingOrders: parseInt(pendingOrders.rows[0].count, 10),
        pendingReservations: parseInt(pendingReservations.rows[0].count, 10),
        previousTodayOrders: parseInt(ordersYesterday.rows[0].count, 10),
        previousTodayReservations: parseInt(reservationsYesterday.rows[0].count, 10),
        previousTodayRevenue: parseFloat(ordersYesterday.rows[0].revenue),
        monthlyRevenues,
      });
    } catch (err) {
      console.error('Erreur stats:', err.message);
      res.status(500).json({ error: err.message });
    }
  });

  router.get('/api/businesses/:businessId/customers', isBusinessOwner, async (req, res) => {
    const { page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;
    try {
      const result = await pool.query(
        `SELECT id, name, email, img_url
         FROM users
         ORDER BY created_at DESC
         LIMIT $1 OFFSET $2`,
        [limit, offset]
      );
      const totalResult = await pool.query('SELECT COUNT(*) as total FROM users');
      const total = parseInt(totalResult.rows[0].total, 10);

      res.json({
        customers: result.rows,
        total,
        page: parseInt(page, 10),
        limit: parseInt(limit, 10),
      });
    } catch (err) {
      console.error('Erreur route /customers :', err);
      res.status(500).json({ error: err.message });
    }
  });

  router.post('/api/businesses/:businessId/menu/items', isBusinessOwner, async (req, res) => {
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

  router.patch('/api/businesses/:businessId/menu/:itemId', isBusinessOwner, async (req, res) => {
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

  return router;
}

module.exports = createBusinessRouter;
