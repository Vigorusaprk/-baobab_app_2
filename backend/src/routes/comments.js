const express = require('express');
const pool = require('../db/pool');

const router = express.Router();

// ==================== COMMENTS ====================
// Récupérer tous les commentaires
router.get('/', async (req, res) => {
  console.log('Requête reçue pour /api/comments'); // Log ajouté pour débogage
  try {
    const result = await pool.query('SELECT * FROM comments ORDER BY created_at DESC');
    console.log('Résultat de la requête SQL:', result.rows); // Log des résultats SQL
    res.json(result.rows);
  } catch (err) {
    console.error('Erreur lors de la récupération des commentaires:', err.message); // Log des erreurs
    res.status(500).json({ error: err.message });
  }
});

// Ajouter un commentaire
router.post('/', async (req, res) => {
  const { user_id, post_id, content } = req.body;
  console.log('Données reçues pour POST /api/comments:', req.body); // Log des données reçues
  try {
    const result = await pool.query(
      `INSERT INTO comments (user_id, post_id, content, created_at)
       VALUES ($1, $2, $3, NOW()) RETURNING *`,
      [user_id, post_id, content]
    );
    console.log('Commentaire ajouté:', result.rows[0]); // Log du commentaire ajouté
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Erreur lors de l\'ajout d\'un commentaire:', err.message); // Log des erreurs
    res.status(500).json({ error: err.message });
  }
});

// Supprimer un commentaire
router.delete('/:id', async (req, res) => {
  const { id } = req.params;
  console.log('ID reçu pour DELETE /api/comments:', id); // Log de l'ID reçu
  try {
    const result = await pool.query('DELETE FROM comments WHERE id = $1 RETURNING id', [id]);
    if (result.rowCount === 0) {
      console.log('Commentaire non trouvé pour suppression:', id); // Log si non trouvé
      return res.status(404).json({ error: "Commentaire non trouvé" });
    }
    console.log('Commentaire supprimé:', result.rows[0].id); // Log du commentaire supprimé
    res.json({ message: "Commentaire supprimé", id: result.rows[0].id });
  } catch (err) {
    console.error('Erreur lors de la suppression d\'un commentaire:', err.message); // Log des erreurs
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;