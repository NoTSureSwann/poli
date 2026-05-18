// NOTE: Jika ada file `backend/database/db.js` (better-sqlite3 langsung), file tersebut sudah DEPRECATED dan bisa dihapus.

const { Pool } = require('pg');
require('dotenv').config();

// Konfigurasi koneksi pool untuk Supabase PostgreSQL
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false, // Wajib untuk Supabase
  },
  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Tes koneksi database pada saat start
pool.connect((err, client, release) => {
  if (err) {
    console.error('❌ Error acquiring client from pool:', err.stack);
  } else {
    console.log('✅ Connected to Supabase PostgreSQL Database');
    release();
  }
});

pool.on('error', (err, client) => {
  console.error('Unexpected error on idle PostgreSQL client', err);
  process.exit(-1);
});

// Graceful shutdown
const shutdown = () => {
  console.log('Shutting down Supabase database connection pool...');
  pool.end(() => {
    console.log('Database pool has been closed.');
    process.exit(0);
  });
};

process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);

// Signature function dipertahankan agar controller tidak perlu diubah
const query = (sql, params = []) => {
  return new Promise((resolve, reject) => {
    pool.query(sql, params, (err, res) => {
      if (err) {
        reject(err);
        return;
      }
      resolve({
        rows: res.rows,
        rowCount: res.rowCount,
        // PostgreSQL mengembalikan inserted array di res.rows jika memakai RETURNING clause
        lastID: res.rows.length > 0 ? res.rows[0].id : null,
      });
    });
  });
};

module.exports = { pool, query };
