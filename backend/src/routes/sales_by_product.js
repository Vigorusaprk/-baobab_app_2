const express = require('express');
const router = express.Router();
const pool = require('../db/pool');
const isBusinessOwner = require('../middleware/isBusinessOwner'); // ✅ Chemin correct

// Route des ventes par produit
router.get('/:businessId/stats/products', isBusinessOwner, async (req, res) => {
  const { businessId } = req.params;
  try {
    const result = await pool.query(`
      SELECT
        mi.item_name as product_name,
        SUM(oi.quantity) as quantity,
        SUM(oi.quantity * oi.unit_price) as revenue
      FROM order_items oi
      JOIN menu_items mi ON oi.menu_item_id = mi.id
      JOIN orders o ON oi.order_id = o.id
      WHERE o.business_id = $1
      GROUP BY mi.id
      ORDER BY revenue DESC
      LIMIT 10
    `, [businessId]);
    res.json(result.rows);
  } catch (err) {
    console.error('Erreur ventes par produit:', err.message);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;