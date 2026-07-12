const express = require('express');

function createOrdersRouter({ pool, isBusinessOwner }) {
  const router = express.Router();

  router.post('/api/orders', async (req, res) => {
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

  router.get('/api/orders', async (req, res) => {
    const { user_id } = req.query;
    if (!user_id) return res.status(400).json({ error: 'user_id requis' });
    try {
      const orders = await pool.query(
        `SELECT o.*, b.name AS establishment_name,
                json_build_object(
                  'id', u.id,
                  'name', u.name,
                  'email', u.email,
                  'phone', u.phone
                ) AS customer,
                json_agg(json_build_object(
                  'menu_item_id', oi.menu_item_id,
                  'name', mi.item_name,
                  'unit_price', oi.unit_price,
                  'quantity', oi.quantity,
                  'special_instructions', oi.special_instructions
                )) as items
         FROM orders o
         LEFT JOIN business b ON o.business_id = b.id
         LEFT JOIN users u ON o.user_id = u.id
         LEFT JOIN order_items oi ON oi.order_id = o.id
         LEFT JOIN menu_items mi ON oi.menu_item_id = mi.id
         WHERE o.user_id = $1
         GROUP BY o.id, b.name, u.id, u.name, u.email, u.phone
         ORDER BY o.created_at DESC`,
        [user_id]
      );
      res.json(orders.rows);
    } catch (err) {
      console.error(err.message);
      res.status(500).json({ error: err.message });
    }
  });

  router.patch('/api/orders/:id', async (req, res) => {
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

  router.get('/api/businesses/:businessId/orders', isBusinessOwner, async (req, res) => {
    const { businessId } = req.params;
    const { status, page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;
    try {
      let query = `SELECT o.*, json_build_object('id', u.id, 'name', u.name, 'email', u.email, 'phone', u.phone) AS customer
                   FROM orders o
                   LEFT JOIN users u ON o.user_id = u.id
                   WHERE o.business_id = $1`;
      const params = [businessId];
      if (status) {
        query += ' AND o.status = $2';
        params.push(status);
      }
      query += ' ORDER BY o.created_at DESC LIMIT $' + (params.length + 1) + ' OFFSET $' + (params.length + 2);
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

  router.patch('/api/orders/:id/status', isBusinessOwner, async (req, res) => {
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

  return router;
}

module.exports = createOrdersRouter;
