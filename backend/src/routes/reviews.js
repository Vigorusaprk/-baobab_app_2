const express = require('express');
const pool = require('../db/pool');

const router = express.Router();

// Récupérer les avis d'un commerce
router.get('/businesses/:businessId/reviews', async (req, res) => {
  console.log(`✅ GET /businesses/${req.params.businessId}/reviews`);
  const { businessId } = req.params;
  try {
    const result = await pool.query(
      `SELECT r.id,
              r.business_id,
              r.user_id,
              r.rating,
              r.comment,
              r.created_at,
              r.updated_at,
              u.name AS user_name,
              u.img_url AS user_avatar
       FROM reviews r
       LEFT JOIN users u ON r.user_id = u.id
       WHERE r.business_id = $1
       ORDER BY r.created_at DESC`,
      [businessId]
    );
    res.json(result.rows);
  } catch (err) {
    console.error('Erreur récupération reviews:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// Soumettre un avis
router.post('/reviews', async (req, res) => {
  console.log(`✅ POST /reviews`, req.body);
  const { business_id, user_id, rating, comment } = req.body;
  if (!business_id || !user_id || rating == null) {
    return res.status(400).json({ error: 'business_id, user_id et rating sont requis' });
  }
  try {
    const result = await pool.query(
      `INSERT INTO reviews (business_id, user_id, rating, comment, created_at, updated_at)
       VALUES ($1, $2, $3, $4, NOW(), NOW())
       RETURNING *`,
      [business_id, user_id, rating, comment]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Erreur création review:', err.message);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;