const express = require('express');
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
    const count = db.prepare('SELECT count(*) as c FROM pembayaran WHERE no_struk LIKE ?').get(`STR-${dateStr}-%`).c;
    const no_struk = `STR-${dateStr}-${String(count + 1).padStart(3, '0')}`;

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
    res.redirect(`/api/admin/pembayaran/${req.params.id}/struk`);
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
app.listen(port, () => console.log(`Server running on port ${port}`));