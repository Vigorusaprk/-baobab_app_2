const jwt = require('jsonwebtoken');

function isBusinessOwner(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.status(401).json({ error: 'Token manquant' });

  const token = authHeader.split(' ')[1];
  const jwtSecret = process.env.JWT_SECRET;

  if (!jwtSecret) {
    return res.status(500).json({ error: 'Configuration serveur invalide' });
  }

  try {
    const decoded = jwt.verify(token, jwtSecret);
    if (!decoded.businessId) {
      return res.status(403).json({ error: 'Accès réservé aux commerçants' });
    }

    req.user = decoded;
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Token invalide' });
  }
}

module.exports = isBusinessOwner;
