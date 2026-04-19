-- ============================================================
-- FILE: backend/database/schema.sql
-- Klinik Merah Putih — Complete Database Schema
-- ============================================================

-- ENUM types
CREATE TYPE user_role AS ENUM ('admin', 'dokter', 'perawat', 'apoteker', 'pasien');
CREATE TYPE gender_type AS ENUM ('L', 'P');
CREATE TYPE antrian_status AS ENUM ('menunggu', 'dipanggil', 'selesai', 'batal');
CREATE TYPE pembayaran_type AS ENUM ('BPJS', 'UMUM', 'SUBSIDI', 'ASURANSI');
CREATE TYPE pembayaran_status AS ENUM ('pending', 'lunas', 'gagal', 'refund');

-- ============================================================
-- TABEL USERS (dokter, perawat, admin, apoteker)
-- ============================================================
CREATE TABLE users (
    id                  SERIAL PRIMARY KEY,
    nama                VARCHAR(200) NOT NULL,
    email               VARCHAR(150) UNIQUE NOT NULL,
    password_hash       VARCHAR(255) NOT NULL,
    role                user_role NOT NULL DEFAULT 'perawat',
    nip                 VARCHAR(50) UNIQUE,
    spesialisasi        VARCHAR(100),
    sip_number          VARCHAR(100),               -- Surat Izin Praktik
    wallet_address      VARCHAR(42),                -- Ethereum wallet address
    chain_registered    BOOLEAN DEFAULT FALSE,       -- Sudah di StaffRegistry.sol?
    is_active           BOOLEAN DEFAULT TRUE,
    last_login          TIMESTAMP,
    refresh_token_hash  VARCHAR(255),
    created_at          TIMESTAMP DEFAULT NOW(),
    updated_at          TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- TABEL PASIEN
-- ============================================================
CREATE TABLE pasien (
    id                  SERIAL PRIMARY KEY,
    no_rm               VARCHAR(20) UNIQUE NOT NULL,  -- Nomor Rekam Medis
    nama                VARCHAR(200) NOT NULL,
    nik                 VARCHAR(16) UNIQUE NOT NULL,
    bpjs_id             VARCHAR(20) UNIQUE,
    tanggal_lahir       DATE NOT NULL,
    jenis_kelamin       gender_type NOT NULL,
    golongan_darah      VARCHAR(5),
    alamat              TEXT,
    no_telepon          VARCHAR(20),
    email               VARCHAR(150),
    nama_wali           VARCHAR(200),               -- Untuk pasien anak/lansia
    no_telepon_wali     VARCHAR(20),
    alergi              TEXT[],                     -- Array string alergi
    riwayat_penyakit    TEXT,
    foto_url            VARCHAR(500),
    wallet_address      VARCHAR(42),                -- Untuk verifikasi rekam medis on-chain
    is_active           BOOLEAN DEFAULT TRUE,
    created_by          INTEGER REFERENCES users(id),
    created_at          TIMESTAMP DEFAULT NOW(),
    updated_at          TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- TABEL REKAM MEDIS (EMR)
-- ============================================================
CREATE TABLE rekam_medis (
    id                  SERIAL PRIMARY KEY,
    pasien_id           INTEGER NOT NULL REFERENCES pasien(id) ON DELETE RESTRICT,
    dokter_id           INTEGER NOT NULL REFERENCES users(id),
    tanggal_kunjungan   TIMESTAMP NOT NULL DEFAULT NOW(),
    keluhan_utama       TEXT NOT NULL,              -- S: Subjective
    pemeriksaan_fisik   TEXT,                       -- O: Objective
    diagnosis           TEXT,                       -- A: Assessment
    tindakan_rencana    TEXT,                       -- P: Plan
    icd10_code          VARCHAR(20),                -- Kode ICD-10 diagnosis
    tekanan_darah       VARCHAR(20),
    nadi                INTEGER,
    suhu                DECIMAL(4,1),
    berat_badan         DECIMAL(5,2),
    tinggi_badan        DECIMAL(5,2),
    saturasi_oksigen    INTEGER,
    catatan_tambahan    TEXT,
    lampiran_url        TEXT[],                     -- URL hasil lab, foto, dll
    ai_summary          TEXT,                       -- Output AI (sudah difilter IGC)
    ai_disclaimer       BOOLEAN DEFAULT TRUE,
    dokter_approved     BOOLEAN DEFAULT FALSE,       -- Dokter wajib approve AI output
    data_hash           VARCHAR(66),                -- keccak256 hash → on-chain
    tx_hash             VARCHAR(66),                -- Ethereum transaction hash
    chain_verified      BOOLEAN DEFAULT FALSE,
    is_active           BOOLEAN DEFAULT TRUE,
    created_at          TIMESTAMP DEFAULT NOW(),
    updated_at          TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- TABEL ANTRIAN
-- ============================================================
CREATE TABLE antrian (
    id                  SERIAL PRIMARY KEY,
    pasien_id           INTEGER NOT NULL REFERENCES pasien(id),
    dokter_id           INTEGER REFERENCES users(id),
    nomor_antrian       INTEGER NOT NULL,
    poli                VARCHAR(100) NOT NULL,       -- Poli/unit layanan
    tanggal             DATE NOT NULL DEFAULT CURRENT_DATE,
    status              antrian_status DEFAULT 'menunggu',
    jam_daftar          TIMESTAMP DEFAULT NOW(),
    jam_panggil         TIMESTAMP,
    jam_selesai         TIMESTAMP,
    estimasi_tunggu     INTEGER,                    -- Estimasi menit
    catatan             TEXT,
    created_at          TIMESTAMP DEFAULT NOW(),
    updated_at          TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- TABEL RESEP
-- ============================================================
CREATE TABLE resep (
    id                  SERIAL PRIMARY KEY,
    rekam_medis_id      INTEGER NOT NULL REFERENCES rekam_medis(id),
    pasien_id           INTEGER NOT NULL REFERENCES pasien(id),
    dokter_id           INTEGER NOT NULL REFERENCES users(id),
    apoteker_id         INTEGER REFERENCES users(id),
    tanggal_resep       TIMESTAMP DEFAULT NOW(),
    tanggal_ambil       TIMESTAMP,
    status              VARCHAR(50) DEFAULT 'menunggu',  -- menunggu/disiapkan/diambil
    catatan_dokter      TEXT,
    catatan_apoteker    TEXT,
    total_harga         DECIMAL(12,2),
    is_aktif            BOOLEAN DEFAULT TRUE,
    created_at          TIMESTAMP DEFAULT NOW(),
    updated_at          TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- TABEL DETAIL RESEP (item per resep)
-- ============================================================
CREATE TABLE resep_detail (
    id                  SERIAL PRIMARY KEY,
    resep_id            INTEGER NOT NULL REFERENCES resep(id) ON DELETE CASCADE,
    obat_id             INTEGER NOT NULL REFERENCES stok_obat(id),
    nama_obat           VARCHAR(200) NOT NULL,
    dosis               VARCHAR(100) NOT NULL,      -- contoh: "500mg"
    frekuensi           VARCHAR(100) NOT NULL,      -- contoh: "3x sehari"
    jumlah              INTEGER NOT NULL,
    satuan              VARCHAR(50) NOT NULL,        -- contoh: "tablet"
    aturan_pakai        TEXT,
    harga_satuan        DECIMAL(10,2),
    subtotal            DECIMAL(12,2)
);

-- ============================================================
-- TABEL STOK OBAT
-- ============================================================
CREATE TABLE stok_obat (
    id                  SERIAL PRIMARY KEY,
    kode_obat           VARCHAR(50) UNIQUE NOT NULL,
    nama_generik        VARCHAR(200) NOT NULL,
    nama_dagang         VARCHAR(200),
    kategori            VARCHAR(100),
    satuan              VARCHAR(50) NOT NULL,
    stok_tersedia       INTEGER NOT NULL DEFAULT 0,
    stok_minimum        INTEGER NOT NULL DEFAULT 10,
    harga_beli          DECIMAL(10,2),
    harga_jual          DECIMAL(10,2),
    tanggal_kadaluarsa  DATE,
    lokasi_penyimpanan  VARCHAR(100),
    is_aktif            BOOLEAN DEFAULT TRUE,
    created_at          TIMESTAMP DEFAULT NOW(),
    updated_at          TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- TABEL PEMBAYARAN
-- ============================================================
CREATE TABLE pembayaran (
    id                  SERIAL PRIMARY KEY,
    pasien_id           INTEGER NOT NULL REFERENCES pasien(id),
    rekam_medis_id      INTEGER REFERENCES rekam_medis(id),
    resep_id            INTEGER REFERENCES resep(id),
    jenis_pembayaran    pembayaran_type NOT NULL DEFAULT 'UMUM',
    status              pembayaran_status DEFAULT 'pending',
    total_biaya         DECIMAL(12,2) NOT NULL,
    total_dibayar       DECIMAL(12,2) DEFAULT 0,
    bpjs_claim_id       VARCHAR(100),               -- ID klaim dari P-Care API
    sep_number          VARCHAR(100),               -- Surat Eligibilitas Peserta
    keterangan          TEXT,
    processed_by        INTEGER REFERENCES users(id),
    tx_hash             VARCHAR(66),                -- Ethereum tx (PaymentLedger.sol)
    chain_recorded      BOOLEAN DEFAULT FALSE,
    created_at          TIMESTAMP DEFAULT NOW(),
    updated_at          TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- TABEL AUDIT LOG (IMMUTABLE — TIDAK ADA UPDATE/DELETE)
-- ============================================================
CREATE TABLE audit_log (
    id                  BIGSERIAL PRIMARY KEY,
    user_id             INTEGER REFERENCES users(id),
    action              VARCHAR(100) NOT NULL,
    module              VARCHAR(50) NOT NULL,
    record_id           VARCHAR(100),
    old_data            JSONB,
    new_data            JSONB,
    ip_address          INET,
    user_agent          TEXT,
    igc_rule_triggered  VARCHAR(10),               -- R001–R005
    igc_action          VARCHAR(20),               -- ALLOWED/BLOCKED/FLAGGED
    tx_hash             VARCHAR(66),               -- Referensi SigmaGuard.sol
    created_at          TIMESTAMP DEFAULT NOW()
    -- TIDAK ADA UPDATED_AT — IMMUTABLE BY DESIGN
);

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX idx_pasien_nik ON pasien(nik);
CREATE INDEX idx_pasien_bpjs ON pasien(bpjs_id);
CREATE INDEX idx_pasien_no_rm ON pasien(no_rm);
CREATE INDEX idx_rekam_pasien ON rekam_medis(pasien_id);
CREATE INDEX idx_rekam_dokter ON rekam_medis(dokter_id);
CREATE INDEX idx_rekam_tanggal ON rekam_medis(tanggal_kunjungan);
CREATE INDEX idx_antrian_tanggal ON antrian(tanggal, status);
CREATE INDEX idx_pembayaran_pasien ON pembayaran(pasien_id);
CREATE INDEX idx_audit_user ON audit_log(user_id);
CREATE INDEX idx_audit_module ON audit_log(module, action);
CREATE INDEX idx_audit_created ON audit_log(created_at);
CREATE INDEX idx_stok_kode ON stok_obat(kode_obat);

-- ============================================================
-- TRIGGER: auto update updated_at
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_pasien_updated BEFORE UPDATE ON pasien
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_rekam_updated BEFORE UPDATE ON rekam_medis
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_antrian_updated BEFORE UPDATE ON antrian
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_resep_updated BEFORE UPDATE ON resep
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_stok_updated BEFORE UPDATE ON stok_obat
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_pembayaran_updated BEFORE UPDATE ON pembayaran
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();