const db = require('./db');
const bcrypt = require('bcryptjs');

try {
  const hash = bcrypt.hashSync('admin123', 10);
  const hashKasir = bcrypt.hashSync('kasir123', 10);
  const hashPasien = bcrypt.hashSync('pasien123', 10);

  db.exec('BEGIN TRANSACTION');

  const insertUser = db.prepare('INSERT OR IGNORE INTO users (id, nama, email, password, role) VALUES (?, ?, ?, ?, ?)');
  insertUser.run(1, 'Admin Klinik', 'admin@klinik.com', hash, 'admin');
  insertUser.run(2, 'Kasir Utama', 'kasir@klinik.com', hashKasir, 'admin');
  insertUser.run(3, 'Budi Santoso', 'budi@gmail.com', hashPasien, 'pasien');
  insertUser.run(4, 'Sari Dewi', 'sari@gmail.com', hashPasien, 'pasien');

  const insertPoli = db.prepare('INSERT OR IGNORE INTO poli (id, nama_poli) VALUES (?, ?)');
  const polis = ['Poli Umum', 'Poli Gigi & Mulut', 'Poli Anak (Pediatri)', 'Poli Kandungan (Obgyn)', 'Poli Dalam (Interna)', 'Poli Kulit & Kelamin'];
  polis.forEach((p, i) => insertPoli.run(i+1, p));

  const insertDokter = db.prepare('INSERT OR IGNORE INTO dokter (id, nama, tipe, spesialisasi, poli_id, harga_konsultasi, jadwal) VALUES (?, ?, ?, ?, ?, ?, ?)');
  insertDokter.run(1, 'dr. Heri Purnomo', 'umum', null, 1, 50000, 'Senin-Sabtu 08:00-14:00');
  insertDokter.run(2, 'dr. Rina Sari', 'umum', null, 1, 50000, 'Senin-Jumat 14:00-20:00');
  insertDokter.run(3, 'drg. Fitri Handayani', 'poli', 'Gigi', 2, 100000, 'Senin-Sabtu 09:00-15:00');
  insertDokter.run(4, 'dr. Maya Kusuma, Sp.A', 'spesialis', 'Anak', 3, 150000, 'Selasa-Kamis 10:00-14:00');
  insertDokter.run(5, 'dr. Andi Wijaya, Sp.PD', 'spesialis', 'Dalam', 5, 150000, 'Senin-Rabu 09:00-13:00');
  insertDokter.run(6, 'dr. Lina Marlina, Sp.OG', 'spesialis', 'Kandungan', 4, 175000, 'Rabu-Jumat 10:00-15:00');
  insertDokter.run(7, 'dr. Budi Rahman, Sp.KK', 'spesialis', 'Kulit', 6, 150000, 'Senin-Jumat 13:00-17:00');
  insertDokter.run(8, 'dr. Citra Dewi, Sp.JP', 'spesialis', 'Jantung', 5, 200000, 'Selasa-Kamis 14:00-18:00');
  insertDokter.run(9, 'dr. Eko Prasetyo, Sp.B', 'spesialis', 'Bedah', 1, 200000, 'Senin-Rabu 07:00-12:00');
  insertDokter.run(10, 'drg. Ahmad Fauzi, Sp.KG', 'spesialis', 'Konservasi Gigi', 2, 175000, 'Kamis-Sabtu 09:00-14:00');

  const insertLayanan = db.prepare('INSERT OR IGNORE INTO layanan (id, nama_layanan, kategori, harga) VALUES (?, ?, ?, ?)');
  insertLayanan.run(1, 'Pemeriksaan Umum', 'pemeriksaan', 50000);
  insertLayanan.run(2, 'Pemeriksaan Gigi Dasar', 'pemeriksaan', 75000);
  insertLayanan.run(3, 'Konsultasi Dokter Spesialis', 'pemeriksaan', 150000);
  insertLayanan.run(4, 'Pemeriksaan Fisik Lengkap', 'pemeriksaan', 125000);
  insertLayanan.run(5, 'Rawat Luka Kecil', 'tindakan', 75000);
  insertLayanan.run(6, 'Cabut Gigi Dewasa', 'tindakan', 150000);
  insertLayanan.run(7, 'Pasang Tambal Gigi', 'tindakan', 200000);
  insertLayanan.run(8, 'Suntik', 'tindakan', 25000);
  insertLayanan.run(9, 'Rawat Inap Kelas III', 'tindakan', 75000);
  insertLayanan.run(10, 'Rawat Inap Kelas II', 'tindakan', 150000);
  insertLayanan.run(11, 'Rawat Inap Kelas I', 'tindakan', 300000);
  insertLayanan.run(12, 'Cek Darah Lengkap', 'laboratorium', 85000);
  insertLayanan.run(13, 'Cek Gula Darah', 'laboratorium', 35000);
  insertLayanan.run(14, 'Cek Kolesterol', 'laboratorium', 45000);
  insertLayanan.run(15, 'Cek Urine Lengkap', 'laboratorium', 55000);
  insertLayanan.run(16, 'Rapid Test', 'laboratorium', 65000);
  insertLayanan.run(17, 'Foto Rontgen', 'radiologi', 125000);
  insertLayanan.run(18, 'USG Abdomen', 'radiologi', 175000);
  insertLayanan.run(19, 'USG Kandungan', 'radiologi', 200000);
  insertLayanan.run(20, 'EKG', 'radiologi', 85000);

  const insertObat = db.prepare('INSERT OR IGNORE INTO obat (id, nama_obat, jenis, satuan, harga_satuan, stok) VALUES (?, ?, ?, ?, ?, ?)');
  insertObat.run(1, 'Paracetamol 500mg', 'tablet', 'tablet', 1500, 500);
  insertObat.run(2, 'Amoxicillin 500mg', 'kapsul', 'kapsul', 3000, 300);
  insertObat.run(3, 'Omeprazole 20mg', 'kapsul', 'kapsul', 4500, 200);
  insertObat.run(4, 'Metformin 500mg', 'tablet', 'tablet', 2500, 400);
  insertObat.run(5, 'Amlodipine 5mg', 'tablet', 'tablet', 3500, 250);
  insertObat.run(6, 'Cetirizine 10mg', 'tablet', 'tablet', 2000, 300);
  insertObat.run(7, 'Betahistine 8mg', 'tablet', 'tablet', 5000, 150);
  insertObat.run(8, 'Salbutamol inhaler', 'lainnya', 'inhaler', 45000, 50);
  insertObat.run(9, 'Antasida sirup', 'sirup', 'botol', 15000, 100);
  insertObat.run(10, 'Ibuprofen 400mg', 'tablet', 'tablet', 2000, 400);
  insertObat.run(11, 'Vitamin C 500mg', 'tablet', 'tablet', 1000, 600);
  insertObat.run(12, 'Dexamethasone 0.5mg', 'tablet', 'tablet', 1500, 300);
  insertObat.run(13, 'CTM 4mg', 'tablet', 'tablet', 800, 400);
  insertObat.run(14, 'Antinyeri topikal', 'salep', 'tube', 18000, 80);
  insertObat.run(15, 'Povidone Iodine 10%', 'lainnya', 'botol', 12000, 120);

  const insertPasien = db.prepare('INSERT OR IGNORE INTO pasien (id, user_id, no_rm, nik, nama, jenis_kelamin) VALUES (?, ?, ?, ?, ?, ?)');
  insertPasien.run(1, 3, 'RM-2026-001', '3271010101900001', 'Budi Santoso', 'L');
  insertPasien.run(2, 4, 'RM-2026-002', '3271014545920002', 'Sari Dewi', 'P');
  insertPasien.run(3, null, 'RM-2026-003', '3271019876850003', 'Ahmad Pratama', 'L');
  insertPasien.run(4, null, 'RM-2026-004', '3271012323880004', 'Dewi Hidayat', 'P');

  db.exec('COMMIT');
  console.log('Seed berhasil');
} catch (e) {
  console.error(e);
}
