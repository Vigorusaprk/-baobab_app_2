const express = require('express');

function createReservationsRouter({ pool, isBusinessOwner }) {
  const router = express.Router();

  router.post('/api/reservations', async (req, res) => {
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
      res.status(201).json({ message: 'Réservation enregistrée' });
    } catch (err) {
      await client.query('ROLLBACK');
      console.error(err.message);
      res.status(500).json({ error: err.message });
    } finally {
      client.release();
    }
  });

  router.get('/api/reservations', async (req, res) => {
    const { user_id } = req.query;
    if (!user_id) return res.status(400).json({ error: 'user_id requis' });
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

  router.delete('/api/reservations/:id', async (req, res) => {
    const { id } = req.params;
    try {
      const result = await pool.query('DELETE FROM reservations WHERE id = $1 RETURNING id', [id]);
      if (result.rowCount === 0) return res.status(404).json({ error: 'Réservation non trouvée' });
      res.json({ message: 'Réservation supprimée', id: result.rows[0].id });
    } catch (err) {
      console.error(err.message);
      res.status(500).json({ error: err.message });
    }
  });

  router.get('/api/businesses/:businessId/reservations', isBusinessOwner, async (req, res) => {
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

  return router;
}

module.exports = createReservationsRouter;
