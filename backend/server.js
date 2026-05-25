// ==================== IMPORTATIONS ====================
const express = require('express');
const cors = require('cors');
require('dotenv').config();
const pool = require('./src/db/pool');
const isBusinessOwner = require('./src/middleware/isBusinessOwner');
const createOrdersRouter = require('./src/routes/orders');
const createAuthRouter = require('./src/routes/auth');
const createVehiclesRouter = require('./src/routes/vehicles');
const dashboardRoutes = require('./src/routes/sales_by_product');
const reviewRoutes = require('./src/routes/reviews');

// ==================== CONFIGURATION ====================
const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) {
  throw new Error('JWT_SECRET manquant. Définissez-le dans les variables d\'environnement.');
}
const app = express();
const PORT = parseInt(process.env.PORT, 10) || 3000;

// ==================== MIDDLEWARES ====================
app.use(cors());
app.use(express.json());

// ==================== ROUTES ====================
// Routes principales
app.use(createOrdersRouter({ pool, isBusinessOwner }));
app.use(createAuthRouter({ pool, jwtSecret: JWT_SECRET }));
app.use(createVehiclesRouter({ pool }));

// Routes businesses
const businessRoutes = require('./src/routes/businesses');
app.use('/api/businesses', businessRoutes);

// Routes reservations
const reservationRoutes = require('./src/routes/reservations');
app.use('/api/reservations', reservationRoutes);

// Routes comments
const commentsRoutes = require('./src/routes/comments');
app.use('/api/comments', commentsRoutes);

// Routes reviews
const reviewsRoutes = require('./src/routes/reviews');
app.use('/api', reviewsRoutes);

// ==================== Dashborad ====================
app.use('/api/businesses', dashboardRoutes);

// ==================== GESTION DES ERREURS ====================
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Une erreur interne est survenue.' });
});


// ==================== DÉMARRAGE ====================
app.listen(PORT, () => {
  console.log(`🚀 Serveur prêt sur http://localhost:${PORT}`);
});