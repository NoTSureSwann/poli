const Database = require('better-sqlite3');
const path = require('path');

const dbPath = path.join(__dirname, 'klinik.db');
const db = new Database(dbPath);

// Enable WAL mode and foreign keys
db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');

// Create all tables
db.exec(`
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

  CREATE INDEX IF NOT EXISTS idx_pasien_user ON pasien(user_id);
  CREATE INDEX IF NOT EXISTS idx_dokter_poli ON dokter(poli_id);
  CREATE INDEX IF NOT EXISTS idx_rekam_pasien ON rekam_medis(pasien_id);
  CREATE INDEX IF NOT EXISTS idx_rekam_dokter ON rekam_medis(dokter_id);
  CREATE INDEX IF NOT EXISTS idx_antrian_tanggal ON antrian(tanggal);
  CREATE INDEX IF NOT EXISTS idx_pembayaran_pasien ON pembayaran(pasien_id);
  CREATE INDEX IF NOT EXISTS idx_pembayaran_struk ON pembayaran(no_struk);
`);

module.exports = db;
