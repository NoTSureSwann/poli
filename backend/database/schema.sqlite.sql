-- ============================================================
-- FILE: backend/database/schema.sqlite.sql
-- Klinik Merah Putih — Complete SQLite Database Schema
-- ============================================================

-- ============================================================
-- TABEL USERS (dokter, perawat, admin, apoteker)
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    nama                TEXT NOT NULL,
    email               TEXT UNIQUE NOT NULL,
    password_hash       TEXT NOT NULL,
    role                TEXT NOT NULL CHECK(role IN ('admin', 'dokter', 'perawat', 'apoteker', 'pasien')),
    nip                 TEXT UNIQUE,
    spesialisasi        TEXT,
    sip_number          TEXT,
    wallet_address      TEXT,
    chain_registered    INTEGER DEFAULT 0,
    is_active           INTEGER DEFAULT 1,
    last_login          DATETIME,
    refresh_token_hash  TEXT,
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABEL PASIEN
-- ============================================================
CREATE TABLE IF NOT EXISTS pasien (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    no_rm               TEXT UNIQUE NOT NULL,
    nama                TEXT NOT NULL,
    nik                 TEXT UNIQUE NOT NULL,
    bpjs_id             TEXT UNIQUE,
    tanggal_lahir       DATE NOT NULL,
    jenis_kelamin       TEXT NOT NULL CHECK(jenis_kelamin IN ('L', 'P')),
    golongan_darah      TEXT,
    alamat              TEXT,
    no_telepon          TEXT,
    email               TEXT,
    nama_wali           TEXT,
    no_telepon_wali     TEXT,
    alergi              TEXT,
    riwayat_penyakit    TEXT,
    foto_url            TEXT,
    wallet_address      TEXT,
    is_active           INTEGER DEFAULT 1,
    created_by          INTEGER REFERENCES users(id),
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABEL REKAM MEDIS (EMR)
-- ============================================================
CREATE TABLE IF NOT EXISTS rekam_medis (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    pasien_id           INTEGER NOT NULL REFERENCES pasien(id),
    dokter_id           INTEGER NOT NULL REFERENCES users(id),
    tanggal_kunjungan   DATETIME DEFAULT CURRENT_TIMESTAMP,
    keluhan_utama       TEXT NOT NULL,
    pemeriksaan_fisik   TEXT,
    diagnosis           TEXT,
    tindakan_rencana    TEXT,
    icd10_code          TEXT,
    tekanan_darah       TEXT,
    nadi                INTEGER,
    suhu                REAL,
    berat_badan         REAL,
    tinggi_badan        REAL,
    saturasi_oksigen    INTEGER,
    catatan_tambahan    TEXT,
    lampiran_url        TEXT,
    ai_summary          TEXT,
    ai_disclaimer       INTEGER DEFAULT 1,
    dokter_approved     INTEGER DEFAULT 0,
    data_hash           TEXT,
    tx_hash             TEXT,
    chain_verified      INTEGER DEFAULT 0,
    is_active           INTEGER DEFAULT 1,
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABEL ANTRIAN
-- ============================================================
CREATE TABLE IF NOT EXISTS antrian (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    pasien_id           INTEGER NOT NULL REFERENCES pasien(id),
    dokter_id           INTEGER REFERENCES users(id),
    nomor_antrian       INTEGER NOT NULL,
    poli                TEXT NOT NULL,
    tanggal             DATE DEFAULT CURRENT_DATE,
    status              TEXT DEFAULT 'menunggu' CHECK(status IN ('menunggu', 'dipanggil', 'selesai', 'batal')),
    jam_daftar          DATETIME DEFAULT CURRENT_TIMESTAMP,
    jam_panggil         DATETIME,
    jam_selesai         DATETIME,
    estimasi_tunggu     INTEGER,
    catatan             TEXT,
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABEL RESEP
-- ============================================================
CREATE TABLE IF NOT EXISTS resep (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    rekam_medis_id      INTEGER NOT NULL REFERENCES rekam_medis(id),
    pasien_id           INTEGER NOT NULL REFERENCES pasien(id),
    dokter_id           INTEGER NOT NULL REFERENCES users(id),
    apoteker_id         INTEGER REFERENCES users(id),
    tanggal_resep       DATETIME DEFAULT CURRENT_TIMESTAMP,
    tanggal_ambil       DATETIME,
    status              TEXT DEFAULT 'menunggu',
    catatan_dokter      TEXT,
    catatan_apoteker    TEXT,
    total_harga         REAL,
    is_aktif            INTEGER DEFAULT 1,
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABEL DETAIL RESEP (item per resep)
-- ============================================================
CREATE TABLE IF NOT EXISTS resep_detail (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    resep_id            INTEGER NOT NULL REFERENCES resep(id) ON DELETE CASCADE,
    obat_id             INTEGER NOT NULL REFERENCES stok_obat(id),
    nama_obat           TEXT NOT NULL,
    dosis               TEXT NOT NULL,
    frekuensi           TEXT NOT NULL,
    jumlah              INTEGER NOT NULL,
    satuan              TEXT NOT NULL,
    aturan_pakai        TEXT,
    harga_satuan        REAL,
    subtotal            REAL
);

-- ============================================================
-- TABEL STOK OBAT
-- ============================================================
CREATE TABLE IF NOT EXISTS stok_obat (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    kode_obat           TEXT UNIQUE NOT NULL,
    nama_generik        TEXT NOT NULL,
    nama_dagang         TEXT,
    kategori            TEXT,
    satuan              TEXT NOT NULL,
    stok_tersedia       INTEGER NOT NULL DEFAULT 0,
    stok_minimum        INTEGER NOT NULL DEFAULT 10,
    harga_beli          REAL,
    harga_jual          REAL,
    tanggal_kadaluarsa  DATE,
    lokasi_penyimpanan  TEXT,
    is_aktif            INTEGER DEFAULT 1,
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABEL PEMBAYARAN
-- ============================================================
CREATE TABLE IF NOT EXISTS pembayaran (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    pasien_id           INTEGER NOT NULL REFERENCES pasien(id),
    rekam_medis_id      INTEGER REFERENCES rekam_medis(id),
    resep_id            INTEGER REFERENCES resep(id),
    jenis_pembayaran    TEXT NOT NULL DEFAULT 'UMUM' CHECK(jenis_pembayaran IN ('BPJS', 'UMUM', 'SUBSIDI', 'ASURANSI')),
    status              TEXT DEFAULT 'pending' CHECK(status IN ('pending', 'lunas', 'gagal', 'refund')),
    total_biaya         REAL NOT NULL,
    total_dibayar       REAL DEFAULT 0,
    bpjs_claim_id       TEXT,
    sep_number          TEXT,
    keterangan          TEXT,
    processed_by        INTEGER REFERENCES users(id),
    tx_hash             TEXT,
    chain_recorded      INTEGER DEFAULT 0,
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABEL AUDIT LOG
-- ============================================================
CREATE TABLE IF NOT EXISTS audit_log (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id             INTEGER REFERENCES users(id),
    action              TEXT NOT NULL,
    module              TEXT NOT NULL,
    entity_id           INTEGER,
    old_values          TEXT,
    new_values          TEXT,
    ip_address          TEXT,
    user_agent          TEXT,
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_pasien_no_rm ON pasien(no_rm);
CREATE INDEX IF NOT EXISTS idx_pasien_nik ON pasien(nik);
CREATE INDEX IF NOT EXISTS idx_rekam_medis_pasien_id ON rekam_medis(pasien_id);
CREATE INDEX IF NOT EXISTS idx_rekam_medis_dokter_id ON rekam_medis(dokter_id);
CREATE INDEX IF NOT EXISTS idx_antrian_pasien_id ON antrian(pasien_id);
CREATE INDEX IF NOT EXISTS idx_antrian_tanggal ON antrian(tanggal);
CREATE INDEX IF NOT EXISTS idx_resep_pasien_id ON resep(pasien_id);
CREATE INDEX IF NOT EXISTS idx_pembayaran_pasien_id ON pembayaran(pasien_id);