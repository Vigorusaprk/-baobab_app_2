const fs = require('fs');
const path = require('path');
const pool = require('./db/pool');

/**
 * Exécute tous les fichiers SQL de migration dans l'ordre
 */
async function runMigrations() {
  const sqlDir = path.join(__dirname, '..', 'sql');
  
  try {
    // Récupérer tous les fichiers SQL triés par nom
    const files = fs.readdirSync(sqlDir)
      .filter(file => file.endsWith('.sql'))
      .sort();

    console.log(`📦 Exécution de ${files.length} migrations...`);

    for (const file of files) {
      const filePath = path.join(sqlDir, file);
      const sql = fs.readFileSync(filePath, 'utf-8');
      
      try {
        await pool.query(sql);
        console.log(`✅ Migration ${file} exécutée avec succès`);
      } catch (err) {
        console.error(`❌ Erreur lors de ${file}:`, err.message);
        throw err;
      }
    }

    console.log('✨ Toutes les migrations sont complètes!');
  } catch (err) {
    console.error('❌ Erreur durant les migrations:', err);
    process.exit(1);
  }
}

module.exports = runMigrations;
