const fs = require('fs');
const path = require('path');
const { pool } = require('../src/config/database');
require('dotenv').config();

const migrate = async () => {
  console.log('--- Starting Database Migration ---');
  
  try {
    const schemaPath = path.join(__dirname, 'schema.sql');
    const sql = fs.readFileSync(schemaPath, 'utf8');

    console.log(`Executing schema from: ${schemaPath}`);
    
    // Split by semicollons but carefully (simple implementation)
    // For schema.sql, running the whole block is usually fine if it handles DROP TABLE etc.
    await pool.query(sql);
    
    console.log('--- Migration Completed Successfully ---');
  } catch (err) {
    console.error('--- Migration Failed ---');
    console.error(err);
  } finally {
    await pool.end();
  }
};

migrate();
