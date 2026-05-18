const fs = require('fs');
const path = require('path');
const { pool } = require('../src/config/database');
require('dotenv').config();

const migrate = async () => {
  console.log('--- Starting Database Migration (Supabase PostgreSQL) ---');
  try {
    // Membaca file postgres (schema.sql)
    const schemaPath = path.join(__dirname, 'schema.sql');
    if (!fs.existsSync(schemaPath)) throw new Error(`Schema file not found at: ${schemaPath}`);
    
    const sql = fs.readFileSync(schemaPath, 'utf8');
    console.log(`Executing PostgreSQL schema from: ${schemaPath}`);
    
    // Menjalankan syntax DDL di postgresql
    await pool.query(sql);
    
    console.log('--- Migration Completed Successfully ---');
  } catch (err) {
    console.error('--- Migration Failed (Fatal) ---');
    console.error(err.message);
  } finally {
    pool.end();
  }
};

migrate();
