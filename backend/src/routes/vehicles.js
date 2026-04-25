const express = require('express');

function createVehiclesRouter({ pool }) {
  const router = express.Router();

  // ==================== GET VEHICLES ====================
  router.get('/api/businesses/:businessId/vehicles', async (req, res) => {
    const { businessId } = req.params;

    try {
      const result = await pool.query(
        `SELECT * FROM vehicles WHERE business_id = $1 ORDER BY name`,
        [businessId]
      );

      const vehicles = result.rows.map(v => ({
        ...v,
        features: v.features || [],
      }));

      res.json(vehicles);
    } catch (err) {
      console.error('Erreur GET véhicules:', err.message);
      res.status(500).json({ error: err.message });
    }
  });

  // ==================== GET SINGLE VEHICLE ====================
  router.get('/api/vehicles/:vehicleId', async (req, res) => {
    const { vehicleId } = req.params;

    try {
      const result = await pool.query(
        `SELECT * FROM vehicles WHERE id = $1`,
        [vehicleId]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({ error: 'Véhicule non trouvé' });
      }

      res.json(result.rows[0]);
    } catch (err) {
      console.error('Erreur GET véhicule:', err.message);
      res.status(500).json({ error: err.message });
    }
  });

  // ==================== CREATE VEHICLE ====================
  router.post('/api/vehicles', async (req, res) => {
    const { businessId, name, type, dailyPrice, features, imageUrl, availableQuantity } = req.body;

    if (!businessId || !name || !type || !dailyPrice) {
      return res.status(400).json({ error: 'Champs requis manquants' });
    }

    const id = `veh_${Date.now()}`;

    try {
      await pool.query(
        `INSERT INTO vehicles (id, business_id, name, type, daily_price, features, image_url, available_quantity)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
        [id, businessId, name, type, dailyPrice, JSON.stringify(features || []), imageUrl || '', availableQuantity || 1]
      );

      res.status(201).json({ id, message: 'Véhicule créé' });
    } catch (err) {
      console.error('Erreur CREATE véhicule:', err.message);
      res.status(500).json({ error: err.message });
    }
  });

  // ==================== UPDATE VEHICLE ====================
  router.put('/api/vehicles/:vehicleId', async (req, res) => {
    const { vehicleId } = req.params;
    const { name, type, dailyPrice, features, imageUrl, availableQuantity } = req.body;

    const updates = [];
    const values = [];
    let paramCount = 1;

    if (name !== undefined) {
      updates.push(`name = $${paramCount++}`);
      values.push(name);
    }
    if (type !== undefined) {
      updates.push(`type = $${paramCount++}`);
      values.push(type);
    }
    if (dailyPrice !== undefined) {
      updates.push(`daily_price = $${paramCount++}`);
      values.push(dailyPrice);
    }
    if (features !== undefined) {
      updates.push(`features = $${paramCount++}`);
      values.push(JSON.stringify(features));
    }
    if (imageUrl !== undefined) {
      updates.push(`image_url = $${paramCount++}`);
      values.push(imageUrl);
    }
    if (availableQuantity !== undefined) {
      updates.push(`available_quantity = $${paramCount++}`);
      values.push(availableQuantity);
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'Aucun champ à mettre à jour' });
    }

    updates.push(`updated_at = NOW()`);
    values.push(vehicleId);

    try {
      await pool.query(
        `UPDATE vehicles SET ${updates.join(', ')} WHERE id = $${paramCount}`,
        values
      );

      res.json({ message: 'Véhicule mis à jour' });
    } catch (err) {
      console.error('Erreur UPDATE véhicule:', err.message);
      res.status(500).json({ error: err.message });
    }
  });

  // ==================== DELETE VEHICLE ====================
  router.delete('/api/vehicles/:vehicleId', async (req, res) => {
    const { vehicleId } = req.params;

    try {
      const result = await pool.query(
        `DELETE FROM vehicles WHERE id = $1 RETURNING id`,
        [vehicleId]
      );

      if (result.rowCount === 0) {
        return res.status(404).json({ error: 'Véhicule non trouvé' });
      }

      res.json({ message: 'Véhicule supprimé' });
    } catch (err) {
      console.error('Erreur DELETE véhicule:', err.message);
      res.status(500).json({ error: err.message });
    }
  });

  return router;
}

module.exports = createVehiclesRouter;
