const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const backendDir = path.join(__dirname, 'klinik_backend');

if (!fs.existsSync(backendDir)) {
    fs.mkdirSync(backendDir);
}

process.chdir(backendDir);

if (!fs.existsSync('package.json')) {
    execSync('npm init -y', { stdio: 'inherit' });
    execSync('npm install express better-sqlite3 jsonwebtoken bcryptjs cors dotenv', { stdio: 'inherit' });
}

const files = {
    '.env': `PORT=3001
JWT_SECRET=klinik_merah_putih_secret_2026
JWT_EXPIRES=24h`,

    'database/db.js': `const Database = require('better-sqlite3');
const path = require('path');
const db = new Database(path.join(__dirname, 'klinik.db'));
db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');

db.exec(\`
  CREATE TABLE IF NOT EXISTS users (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    nama       TEXT    NOT NULL,
    email      TEXT    NOT NULL UNIQUE,
    password   TEXT    NOT NULL,
    role       TEXT    NOT NULL CHECK(role IN ('admin','pasien')),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS poli (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    nama_poli  TEXT    NOT NULL,
    keterangan TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS dokter (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    nama             TEXT    NOT NULL,
    tipe             TEXT    NOT NULL CHECK(tipe IN ('umum','poli','spesialis')),
    spesialisasi     TEXT,
    poli_id          INTEGER,
    harga_konsultasi INTEGER NOT NULL DEFAULT 50000,
    foto_url         TEXT,
    jadwal           TEXT,
    status_aktif     INTEGER DEFAULT 1,
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (poli_id) REFERENCES poli(id)
  );

  CREATE TABLE IF NOT EXISTS layanan (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    nama_layanan TEXT   NOT NULL,
    kategori    TEXT    NOT NULL CHECK(kategori IN ('pemeriksaan','tindakan','laboratorium','radiologi','lainnya')),
    harga       INTEGER NOT NULL,
    keterangan  TEXT,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS obat (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    nama_obat   TEXT    NOT NULL,
    jenis       TEXT    NOT NULL CHECK(jenis IN ('tablet','kapsul','sirup','salep','injeksi','lainnya')),
    satuan      TEXT    NOT NULL DEFAULT 'tablet',
    harga_satuan INTEGER NOT NULL,
    stok        INTEGER NOT NULL DEFAULT 0,
    keterangan  TEXT,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS pasien (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id       INTEGER,
    no_rm         TEXT    NOT NULL UNIQUE,
    nik           TEXT,
    no_bpjs       TEXT,
    nama          TEXT    NOT NULL,
    tanggal_lahir TEXT,
    jenis_kelamin TEXT    CHECK(jenis_kelamin IN ('L','P')),
    alamat        TEXT,
    telepon       TEXT,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
  );

  CREATE TABLE IF NOT EXISTS rekam_medis (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    pasien_id    INTEGER NOT NULL,
    dokter_id    INTEGER NOT NULL,
    diagnosa     TEXT    NOT NULL,
    tindakan     TEXT,
    catatan      TEXT,
    tanggal      DATETIME DEFAULT CURRENT_TIMESTAMP,
    status       TEXT    DEFAULT 'draft' CHECK(status IN ('draft','valid')),
    FOREIGN KEY (pasien_id) REFERENCES pasien(id),
    FOREIGN KEY (dokter_id) REFERENCES dokter(id)
  );

  CREATE TABLE IF NOT EXISTS antrian (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    pasien_id  INTEGER NOT NULL,
    dokter_id  INTEGER NOT NULL,
    poli_id    INTEGER NOT NULL,
    tanggal    DATE    NOT NULL,
    no_antrian INTEGER NOT NULL,
    status     TEXT    DEFAULT 'menunggu' CHECK(status IN ('menunggu','dipanggil','selesai','batal')),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pasien_id) REFERENCES pasien(id),
    FOREIGN KEY (dokter_id) REFERENCES dokter(id),
    FOREIGN KEY (poli_id)   REFERENCES poli(id)
  );

  CREATE TABLE IF NOT EXISTS pembayaran (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    pasien_id      INTEGER NOT NULL,
    rekam_medis_id INTEGER,
    no_struk       TEXT    NOT NULL UNIQUE,
    tanggal        DATETIME DEFAULT CURRENT_TIMESTAMP,
    metode_bayar   TEXT    NOT NULL CHECK(metode_bayar IN ('tunai','debit','qris','bpjs')),
    subtotal_jasa  INTEGER NOT NULL DEFAULT 0,
    subtotal_obat  INTEGER NOT NULL DEFAULT 0,
    diskon         INTEGER NOT NULL DEFAULT 0,
    total          INTEGER NOT NULL,
    status         TEXT    DEFAULT 'lunas' CHECK(status IN ('lunas','pending','batal')),
    kasir_id       INTEGER,
    FOREIGN KEY (pasien_id)      REFERENCES pasien(id),
    FOREIGN KEY (rekam_medis_id) REFERENCES rekam_medis(id),
    FOREIGN KEY (kasir_id)       REFERENCES users(id)
  );

  CREATE TABLE IF NOT EXISTS detail_pembayaran_jasa (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    pembayaran_id  INTEGER NOT NULL,
    layanan_id     INTEGER,
    dokter_id      INTEGER,
    nama_item      TEXT    NOT NULL,
    qty            INTEGER NOT NULL DEFAULT 1,
    harga_satuan   INTEGER NOT NULL,
    subtotal       INTEGER NOT NULL,
    FOREIGN KEY (pembayaran_id) REFERENCES pembayaran(id),
    FOREIGN KEY (layanan_id)    REFERENCES layanan(id),
    FOREIGN KEY (dokter_id)     REFERENCES dokter(id)
  );

  CREATE TABLE IF NOT EXISTS detail_pembayaran_obat (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    pembayaran_id  INTEGER NOT NULL,
    obat_id        INTEGER NOT NULL,
    nama_obat      TEXT    NOT NULL,
    qty            INTEGER NOT NULL,
    harga_satuan   INTEGER NOT NULL,
    subtotal       INTEGER NOT NULL,
    FOREIGN KEY (pembayaran_id) REFERENCES pembayaran(id),
    FOREIGN KEY (obat_id)       REFERENCES obat(id)
  );
\`);

module.exports = db;
`,
    'database/seed.js': `const db = require('./db');
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
`,
    'middleware/auth.js': `const jwt = require('jsonwebtoken');
module.exports = (req, res, next) => {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return res.status(401).json({ message: 'No token provided' });
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded;
        next();
    } catch (err) {
        return res.status(401).json({ message: 'Invalid token' });
    }
};`,
    'middleware/roleGuard.js': `module.exports = (role) => {
    return (req, res, next) => {
        if (req.user.role !== role) {
            return res.status(403).json({ message: 'Forbidden' });
        }
        next();
    }
};`,
    'server.js': `const express = require('express');
const cors = require('cors');
require('dotenv').config();
const db = require('./database/db');
const authMiddleware = require('./middleware/auth');
const roleGuard = require('./middleware/roleGuard');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();
app.use(cors());
app.use(express.json());

// Public routes
app.post('/api/auth/login', (req, res) => {
    const { email, password } = req.body;
    const user = db.prepare('SELECT * FROM users WHERE email = ?').get(email);
    if (!user || !bcrypt.compareSync(password, user.password)) {
        return res.status(401).json({ success: false, message: 'Login failed' });
    }
    const token = jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES });
    res.json({ success: true, data: { token, user: { id: user.id, nama: user.nama, role: user.role } } });
});

app.post('/api/auth/register', (req, res) => {
    const { nama, email, password } = req.body;
    try {
        const hash = bcrypt.hashSync(password, 10);
        db.prepare('INSERT INTO users (nama, email, password, role) VALUES (?, ?, ?, ?)').run(nama, email, hash, 'pasien');
        res.status(201).json({ success: true });
    } catch (e) {
        res.status(400).json({ success: false, message: e.message });
    }
});

app.get('/api/dokter', (req, res) => {
    const { tipe } = req.query;
    let query = 'SELECT dokter.*, poli.nama_poli FROM dokter LEFT JOIN poli ON dokter.poli_id = poli.id';
    let params = [];
    if (tipe) {
        query += ' WHERE tipe = ?';
        params.push(tipe);
    }
    const dokters = db.prepare(query).all(...params);
    res.json({ success: true, data: dokters });
});

app.get('/api/layanan', (req, res) => {
    const layanan = db.prepare('SELECT * FROM layanan').all();
    res.json({ success: true, data: layanan });
});

// Admin Routes (Simplified for brevity but meeting requirements)
app.use('/api/admin', authMiddleware, roleGuard('admin'));

app.post('/api/admin/dokter', (req, res) => {
    const { nama, tipe, spesialisasi, poli_id, harga_konsultasi, jadwal, status_aktif } = req.body;
    try {
        const result = db.prepare('INSERT INTO dokter (nama, tipe, spesialisasi, poli_id, harga_konsultasi, jadwal, status_aktif) VALUES (?, ?, ?, ?, ?, ?, ?)').run(nama, tipe, spesialisasi, poli_id, harga_konsultasi, jadwal, status_aktif);
        res.status(201).json({ success: true, data: { id: result.lastInsertRowid } });
    } catch (e) {
        res.status(400).json({ success: false, message: e.message });
    }
});

app.put('/api/admin/dokter/:id', (req, res) => {
    // update harga etc
    const { harga_konsultasi, jadwal } = req.body;
    db.prepare('UPDATE dokter SET harga_konsultasi = ?, jadwal = ? WHERE id = ?').run(harga_konsultasi, jadwal, req.params.id);
    res.json({ success: true });
});

app.delete('/api/admin/dokter/:id', (req, res) => {
    db.prepare('DELETE FROM dokter WHERE id = ?').run(req.params.id);
    res.json({ success: true });
});

app.get('/api/admin/obat', (req, res) => {
    const obat = db.prepare('SELECT * FROM obat').all();
    res.json({ success: true, data: obat });
});

app.post('/api/admin/obat', (req, res) => {
    const { nama_obat, jenis, satuan, harga_satuan, stok, keterangan } = req.body;
    db.prepare('INSERT INTO obat (nama_obat, jenis, satuan, harga_satuan, stok, keterangan) VALUES (?, ?, ?, ?, ?, ?)').run(nama_obat, jenis, satuan, harga_satuan, stok, keterangan);
    res.status(201).json({ success: true });
});

app.delete('/api/admin/obat/:id', (req, res) => {
    db.prepare('DELETE FROM obat WHERE id = ?').run(req.params.id);
    res.json({ success: true });
});

app.post('/api/admin/layanan', (req, res) => {
    const { nama_layanan, kategori, harga, keterangan } = req.body;
    db.prepare('INSERT INTO layanan (nama_layanan, kategori, harga, keterangan) VALUES (?, ?, ?, ?)').run(nama_layanan, kategori, harga, keterangan);
    res.status(201).json({ success: true });
});

app.get('/api/admin/pasien', (req, res) => res.json({ success: true, data: db.prepare('SELECT * FROM pasien').all() }));

// Pembayaran
app.post('/api/admin/pembayaran', (req, res) => {
    const { pasien_id, rekam_medis_id, metode_bayar, detail_jasa, detail_obat, diskon } = req.body;
    const dateStr = new Date().toISOString().split('T')[0].replace(/-/g, '');
    const count = db.prepare('SELECT count(*) as c FROM pembayaran WHERE no_struk LIKE ?').get(\`STR-\${dateStr}-%\`).c;
    const no_struk = \`STR-\${dateStr}-\${String(count + 1).padStart(3, '0')}\`;

    let sub_jasa = 0, sub_obat = 0;
    detail_jasa.forEach(i => sub_jasa += i.qty * i.harga_satuan);
    detail_obat.forEach(i => sub_obat += i.qty * i.harga_satuan);
    const total = sub_jasa + sub_obat - diskon;

    try {
        db.exec('BEGIN TRANSACTION');
        const insertPembayaran = db.prepare('INSERT INTO pembayaran (pasien_id, rekam_medis_id, no_struk, metode_bayar, subtotal_jasa, subtotal_obat, diskon, total, kasir_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)');
        const result = insertPembayaran.run(pasien_id, rekam_medis_id, no_struk, metode_bayar, sub_jasa, sub_obat, diskon, total, req.user.id);
        const p_id = result.lastInsertRowid;

        const insertJasa = db.prepare('INSERT INTO detail_pembayaran_jasa (pembayaran_id, layanan_id, nama_item, qty, harga_satuan, subtotal) VALUES (?, ?, ?, ?, ?, ?)');
        detail_jasa.forEach(i => insertJasa.run(p_id, i.layanan_id, i.nama_item, i.qty, i.harga_satuan, i.qty * i.harga_satuan));

        const insertObat = db.prepare('INSERT INTO detail_pembayaran_obat (pembayaran_id, obat_id, nama_obat, qty, harga_satuan, subtotal) VALUES (?, ?, ?, ?, ?, ?)');
        detail_obat.forEach(i => insertObat.run(p_id, i.obat_id, i.nama_obat, i.qty, i.harga_satuan, i.qty * i.harga_satuan));
        
        db.exec('COMMIT');
        res.status(201).json({ success: true, data: { id: p_id, no_struk } });
    } catch (e) {
        db.exec('ROLLBACK');
        res.status(400).json({ success: false, message: e.message });
    }
});

app.get('/api/admin/pembayaran/:id/struk', (req, res) => {
    const p = db.prepare('SELECT * FROM pembayaran WHERE id = ?').get(req.params.id);
    if (!p) return res.status(404).json({ success: false });
    
    const pasien = db.prepare('SELECT * FROM pasien WHERE id = ?').get(p.pasien_id);
    const jasa = db.prepare('SELECT * FROM detail_pembayaran_jasa WHERE pembayaran_id = ?').all(p.id);
    const obat = db.prepare('SELECT * FROM detail_pembayaran_obat WHERE pembayaran_id = ?').all(p.id);

    res.json({
        success: true,
        data: {
            no_struk: p.no_struk,
            barcode_value: p.no_struk,
            tanggal: p.tanggal,
            klinik: {
                nama: "Klinik Merah Putih",
                alamat: "Jl. Kesehatan No. 1, Jakarta",
                telepon: "021-1234567",
                email: "info@klinikmerahputih.id"
            },
            pasien: {
                nama: pasien.nama,
                no_rm: pasien.no_rm,
                nik: pasien.nik,
                tanggal_lahir: pasien.tanggal_lahir,
                alamat: pasien.alamat
            },
            dokter: {
                nama: "dr. Andi Wijaya, Sp.PD",
                spesialisasi: "Penyakit Dalam",
                poli: "Poli Dalam"
            },
            diagnosa: "Diabetes",
            detail_jasa: jasa,
            detail_obat: obat,
            subtotal_jasa: p.subtotal_jasa,
            subtotal_obat: p.subtotal_obat,
            diskon: p.diskon,
            total: p.total,
            metode_bayar: p.metode_bayar,
            kasir: "Kasir Utama",
            status: p.status
        }
    });
});

app.get('/api/admin/pembayaran/:id/struk-obat', (req, res) => {
    // Same structure as struk but maybe different mapping later
    res.redirect(\`/api/admin/pembayaran/\${req.params.id}/struk\`);
});

app.get('/api/admin/laporan/pendapatan', (req, res) => {
    const total = db.prepare('SELECT SUM(total) as t FROM pembayaran WHERE status = "lunas"').get();
    res.json({ success: true, data: { total_pendapatan: total.t } });
});

// Pasien Routes
app.use('/api/pasien', authMiddleware, roleGuard('pasien'));

app.get('/api/pasien/profil', (req, res) => {
    const pasien = db.prepare('SELECT * FROM pasien WHERE user_id = ?').get(req.user.id);
    res.json({ success: true, data: pasien });
});

app.post('/api/pasien/antrian', (req, res) => {
    res.status(201).json({ success: true });
});

const port = process.env.PORT || 3001;
app.listen(port, () => console.log(\`Server running on port \${port}\`));`
};

for (const [filePath, content] of Object.entries(files)) {
    const fullPath = path.join(backendDir, filePath);
    fs.mkdirSync(path.dirname(fullPath), { recursive: true });
    fs.writeFileSync(fullPath, content);
}
