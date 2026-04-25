const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

function createAuthRouter({ pool, jwtSecret }) {
  const router = express.Router();
  const refreshSecret = process.env.REFRESH_TOKEN_SECRET || jwtSecret;
  const accessTokenExpiresIn = process.env.ACCESS_TOKEN_EXPIRES_IN || '15m';
  const refreshTokenExpiresIn = process.env.REFRESH_TOKEN_EXPIRES_IN || '7d';

  /**
   * Créer un token d'accès (short-lived)
   */
  function signAccessToken(user) {
    return jwt.sign(
      { 
        id: user.id, 
        email: user.email, 
        businessId: user.business_id ?? null, 
        type: 'access' 
      },
      jwtSecret,
      { expiresIn: accessTokenExpiresIn }
    );
  }

  /**
   * Créer un refresh token (long-lived)
   */
  function signRefreshToken(userId) {
    return jwt.sign(
      { 
        sub: userId, 
        type: 'refresh' 
      },
      refreshSecret,
      { expiresIn: refreshTokenExpiresIn }
    );
  }

  /**
   * Générer la paire de tokens
   */
  function issueTokenPair(user) {
    const accessToken = signAccessToken(user);
    const refreshToken = signRefreshToken(user.id);
    return { accessToken, refreshToken };
  }

  /**
   * Extraire le token du header Authorization
   */
  function extractBearerToken(req) {
    const authHeader = req.headers.authorization;
    if (!authHeader) return null;
    return authHeader.split(' ')[1];
  }

  // ==================== SIGNUP ====================
  router.post('/api/auth/signup', async (req, res) => {
    const { name, email, password, phone } = req.body;
    
    if (!name || !email || !password) {
      return res.status(400).json({ error: 'Tous les champs sont requis' });
    }

    try {
      // Vérifier si l'email existe déjà
      const existing = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
      if (existing.rows.length > 0) {
        return res.status(409).json({ error: 'Email déjà utilisé' });
      }

      // Hasher le mot de passe
      const hashedPassword = await bcrypt.hash(password, 10);
      const id = Date.now().toString();

      // Insérer le nouvel utilisateur
      await pool.query(
        `INSERT INTO users (id, name, email, password, phone, img_url, created_at)
         VALUES ($1, $2, $3, $4, $5, $6, NOW())`,
        [id, name, email, hashedPassword, phone || null, '']
      );

      const user = { id, name, email, img_url: '', business_id: null };
      const { accessToken, refreshToken } = issueTokenPair(user);

      res.status(201).json({
        id,
        name,
        email,
        token: accessToken,
        accessToken,
        refreshToken,
        businessId: null,
      });
    } catch (err) {
      console.error('❌ Erreur signup:', err);
      res.status(500).json({ error: err.message });
    }
  });

  // ==================== LOGIN ====================
  router.post('/api/auth/login', async (req, res) => {
    const { email, password } = req.body;
    
    if (!email || !password) {
      return res.status(400).json({ error: 'Email et mot de passe requis' });
    }

    try {
      // Récupérer l'utilisateur
      const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
      
      if (result.rows.length === 0) {
        return res.status(401).json({ error: 'Email ou mot de passe incorrect' });
      }

      const user = result.rows[0];

      // Vérifier le mot de passe
      const valid = await bcrypt.compare(password, user.password);
      if (!valid) {
        return res.status(401).json({ error: 'Email ou mot de passe incorrect' });
      }

      // Mettre à jour last_login
      await pool.query('UPDATE users SET last_login = NOW() WHERE id = $1', [user.id]);

      // Générer les tokens
      const { accessToken, refreshToken } = issueTokenPair(user);

      res.json({
        id: user.id,
        name: user.name,
        email: user.email,
        imgUrl: user.img_url ?? '',
        token: accessToken,
        accessToken,
        refreshToken,
        businessId: user.business_id,
      });
    } catch (err) {
      console.error('❌ Erreur login:', err);
      res.status(500).json({ error: err.message });
    }
  });

  // ==================== REFRESH TOKEN ====================
  router.post('/api/auth/refresh', async (req, res) => {
    const { refreshToken } = req.body;
    
    if (!refreshToken) {
      return res.status(400).json({ error: 'refreshToken requis' });
    }

    try {
      // Vérifier le refresh token
      const payload = jwt.verify(refreshToken, refreshSecret);
      
      if (payload.type !== 'refresh' || !payload.sub) {
        return res.status(401).json({ error: 'Refresh token invalide' });
      }

      // Récupérer les infos de l'utilisateur
      const userResult = await pool.query(
        'SELECT id, name, email, img_url, business_id FROM users WHERE id = $1',
        [payload.sub]
      );

      if (userResult.rows.length === 0) {
        return res.status(404).json({ error: 'Utilisateur non trouvé' });
      }

      const user = userResult.rows[0];

      // Générer une nouvelle paire de tokens
      const { accessToken, refreshToken: newRefreshToken } = issueTokenPair(user);

      res.json({
        id: user.id,
        name: user.name,
        email: user.email,
        imgUrl: user.img_url ?? '',
        token: accessToken,
        accessToken,
        refreshToken: newRefreshToken,
        businessId: user.business_id,
      });
    } catch (err) {
      if (err.name === 'TokenExpiredError') {
        return res.status(401).json({ error: 'Refresh token expiré' });
      }
      console.error('❌ Erreur refresh:', err);
      res.status(401).json({ error: 'Refresh token invalide' });
    }
  });

  // ==================== VÉRIFIER L'AUTHENTIFICATION ====================
  router.post('/api/auth/verify', async (req, res) => {
    const token = extractBearerToken(req);
    
    if (!token) {
      return res.status(401).json({ error: 'Token manquant' });
    }

    try {
      const payload = jwt.verify(token, jwtSecret);
      res.json({ valid: true, user: payload });
    } catch (err) {
      res.status(401).json({ error: 'Token invalide' });
    }
  });

  // ==================== GET CURRENT USER ====================
  router.get('/api/auth/me', async (req, res) => {
    const token = extractBearerToken(req);
    if (!token) return res.status(401).json({ error: 'Token manquant' });
    try {
      const decoded = jwt.verify(token, jwtSecret);
      const result = await pool.query(
        'SELECT id, name, email, img_url, business_id FROM users WHERE id = $1',
        [decoded.id]
      );

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

  // ==================== LOGOUT ====================
  router.post('/api/auth/logout', (req, res) => {
    // Avec JWT, le logout est géré côté client en supprimant le token
    res.json({ message: 'Déconnecté' });
  });

  return router;
}

module.exports = createAuthRouter;
