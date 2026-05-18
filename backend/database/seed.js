const { pool, query } = require('../src/config/database');
const bcryptjs = require('bcryptjs');

async function seedDatabase() {
  console.log('🌱 Seeding database...');

  try {
    // Clear existing data - only from tables that exist
    try {
      await query('DELETE FROM audit_log', []);
    } catch (e) { /* ignore if table doesn't exist */ }
    try {
      await query('DELETE FROM pembayaran', []);
    } catch (e) { /* ignore if table doesn't exist */ }
    try {
      await query('DELETE FROM resep_detail', []);
    } catch (e) { /* ignore if table doesn't exist */ }
    try {
      await query('DELETE FROM resep', []);
    } catch (e) { /* ignore if table doesn't exist */ }
    try {
      await query('DELETE FROM rekam_medis', []);
    } catch (e) { /* ignore if table doesn't exist */ }
    try {
      await query('DELETE FROM antrian', []);
    } catch (e) { /* ignore if table doesn't exist */ }
    try {
      await query('DELETE FROM pasien', []);
    } catch (e) { /* ignore if table doesn't exist */ }
    try {
      await query('DELETE FROM stok_obat', []);
    } catch (e) { /* ignore if table doesn't exist */ }
    try {
      await query('DELETE FROM users', []);
    } catch (e) { /* ignore if table doesn't exist */ }

    console.log('🧹 Cleared existing data');

    // Seed users
    const hashedPassword = await bcryptjs.hash('admin123', 10);
    await query(`
      INSERT INTO users (nama, email, password_hash, role, nip, spesialisasi, is_active, created_at, updated_at) VALUES
      ('Administrator', 'admin@klinik.com', $1, 'admin', 'ADM001', NULL, TRUE, NOW(), NOW()),
      ('Dr. Ahmad Santoso', 'ahmad@klinik.com', $2, 'dokter', 'DKT001', 'Dokter Umum', TRUE, NOW(), NOW()),
      ('Dr. Siti Nurhaliza', 'siti@klinik.com', $3, 'dokter', 'DKT002', 'Dokter Anak', TRUE, NOW(), NOW()),
      ('Perawat Ani', 'ani@klinik.com', $4, 'perawat', 'PRW001', NULL, TRUE, NOW(), NOW())
    `, [hashedPassword, hashedPassword, hashedPassword, hashedPassword]);

    console.log('👥 Seeded users data');

    // Seed stok_obat (instead of obat)
    await query(`
      INSERT INTO stok_obat (kode_obat, nama_generik, nama_dagang, kategori, satuan, stok_tersedia, stok_minimum, harga_jual, created_at, updated_at) VALUES
      ('PRC001', 'Paracetamol', 'Paracetamol 500mg', 'analgesik', 'tablet', 100, 10, 500, NOW(), NOW()),
      ('AMX001', 'Amoxicillin', 'Amoxicillin 500mg', 'antibiotik', 'kapsul', 50, 5, 1500, NOW(), NOW()),
      ('IBP001', 'Ibuprofen', 'Ibuprofen 400mg', 'antiinflamasi', 'tablet', 75, 8, 800, NOW(), NOW()),
      ('VIT001', 'Vitamin C', 'Vitamin C 500mg', 'suplemen', 'tablet', 200, 20, 300, NOW(), NOW()),
      ('ANT001', 'Antasida', 'Antasida', 'gastrointestinal', 'sirup', 30, 5, 25000, NOW(), NOW()),
      ('SAL001', 'Salbutamol', 'Salbutamol Inhaler', 'bronkodilator', 'inhaler', 15, 3, 150000, NOW(), NOW())
    `, []);

    console.log('💊 Seeded stok_obat data');

    // Seed pasien
    await query(`
      INSERT INTO pasien (no_rm, nama, nik, tanggal_lahir, jenis_kelamin, alamat, no_telepon, email, created_at, updated_at) VALUES
      ('RM001', 'Ahmad Rahman', '1234567890123456', '1985-03-15', 'L', 'Jl. Sudirman No. 123, Jakarta', '081234567890', 'ahmad@email.com', NOW(), NOW()),
      ('RM002', 'Siti Aminah', '1234567890123457', '1990-07-22', 'P', 'Jl. Thamrin No. 456, Jakarta', '081234567891', 'siti@email.com', NOW(), NOW()),
      ('RM003', 'Budi Santoso', '1234567890123458', '1978-11-08', 'L', 'Jl. Gatot Subroto No. 789, Jakarta', '081234567892', 'budi@email.com', NOW(), NOW()),
      ('RM004', 'Maya Sari', '1234567890123459', '1995-01-30', 'P', 'Jl. Sudirman No. 321, Jakarta', '081234567893', 'maya@email.com', NOW(), NOW()),
      ('RM005', 'Rudi Hartono', '1234567890123460', '1982-09-12', 'L', 'Jl. MH Thamrin No. 654, Jakarta', '081234567894', 'rudi@email.com', NOW(), NOW())
    `, []);

    console.log('👤 Seeded pasien data');

    console.log('✅ Database seeding completed successfully!');
  } catch (error) {
    console.error('❌ Error seeding database:', error);
    throw error;
  } finally {
    pool.end();
  }
}

// Run seeding
seedDatabase().catch(console.error);