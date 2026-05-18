# 📋 Klinik Merah Putih — Spesifikasi Fungsional

> Dokumentasi lengkap semua fitur dan fungsionalitas aplikasi Klinik Merah Putih.

---

## 🌊 User Flow

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   INSTALL    │ ─► │  ONBOARDING  │ ─► │    LOGIN     │
│   APP        │    │  Terms &     │    │  Email +     │
│              │    │  Conditions  │    │  Password    │
└──────────────┘    └──────────────┘    └──────┬───────┘
                                               │
                                               ▼
                    ┌──────────────────────────────────────┐
                    │            HOME SCREEN               │
                    │  ┌──────────────────────────────┐    │
                    │  │     Bottom Navigation Bar     │   │
                    │  ├──────┬──────┬──────┬──────┬──┤   │
                    │  │Dash- │Pasien│Rekam │Bayar │Pro│   │
                    │  │board │      │Medis │      │fil│   │
                    │  └──┬───┘──┬───┘──┬───┘──┬───┘──┘   │
                    └─────┼──────┼──────┼──────┼──────────┘
                          │      │      │      │
                          ▼      ▼      ▼      ▼
                    ┌─────┐ ┌────┐ ┌────┐ ┌────┐
                    │Stats│ │CRUD│ │CRUD│ │CRUD│
                    │Quick│ │List│ │List│ │List│
                    │Acts │ │Form│ │Form│ │Form│
                    └─────┘ └────┘ └────┘ └────┘
```

---

## 🔐 F01 — Autentikasi & Otorisasi

### F01.1 — Onboarding (Terms & Conditions)

| Item | Detail |
|---|---|
| **Screen** | `TermsScreen` |
| **Trigger** | Pertama kali membuka app setelah install |
| **Aksi** | User harus menerima Terms & Conditions sebelum menggunakan aplikasi |
| **Persistence** | `SharedPreferences: terms_accepted = true` |
| **Reset** | Bisa di-reset dari halaman Profil → "Reset Onboarding" |

### F01.2 — Login

| Item | Detail |
|---|---|
| **Screen** | `LoginScreen` |
| **Input** | Email, Password, Role (dropdown) |
| **API** | `POST /api/auth/login` |
| **Response** | JWT Token + User data |
| **Session** | Token disimpan di `SharedPreferences` |
| **Auto-Login** | Jika token ada di storage → skip login screen |
| **Error** | SnackBar "Email atau password salah" |

### F01.3 — Register

| Item | Detail |
|---|---|
| **Screen** | `RegisterScreen` |
| **Input** | Nama, Email, Password, Konfirmasi Password, Role |
| **Validasi** | Email format, password min 6 chars, password match |
| **API** | `POST /api/auth/register` |
| **Response** | JWT Token + User data → Auto login |

### F01.4 — Logout

| Item | Detail |
|---|---|
| **Trigger** | Klik "Keluar Akun" di ProfileScreen |
| **Konfirmasi** | AlertDialog konfirmasi |
| **Aksi** | Hapus session dari SharedPreferences, reset state |
| **Redirect** | Kembali ke LoginScreen |

### F01.5 — Role-Based Access Control (RBAC)

| Role | Hak Akses |
|---|---|
| `admin` | Full access, termasuk pembayaran & ML export |
| `dokter` | Pasien, Rekam Medis, Dashboard |
| `perawat` | Pasien (read/write), Rekam Medis (limited) |
| `apoteker` | Resep, Stok obat |
| `pasien` | Read-only data sendiri |

---

## 📊 F02 — Dashboard

| Item | Detail |
|---|---|
| **Screen** | `DashboardScreen` |
| **Data Source** | `PatientService` + `PaymentService` |

### Statistik Cards

| Card | Ikon | Data | Warna |
|---|---|---|---|
| Total Pasien | 👥 | Count dari API | Blue (#2563EB) |
| Total Transaksi | 📋 | Jumlah pembayaran | Green (#10B981) |
| Debit | 💳 | Sum pembayaran debit | Blue Info (#3B82F6) |
| QRIS/Tunai | 💰 | Sum QRIS + Cash | Amber (#F59E0B) |

### Aksi Cepat (Quick Actions)

| Aksi | Ikon | Navigasi |
|---|---|---|
| Pasien Baru | 👤+ | → `PatientFormScreen` |
| Pembayaran | 💳 | → `PaymentFormScreen` |
| Rekam Medis | 🏥 | → `MedicalRecordFormScreen` |
| Riwayat | 📜 | → Tab Pembayaran (index 3) |

### Aktivitas Terkini

Timeline 5 aktivitas terbaru dengan:
- Ikon + warna sesuai tipe aktivitas
- Judul dan subtitle
- Waktu relatif (format HH:mm)

---

## 👥 F03 — Manajemen Pasien

### F03.1 — Daftar Pasien

| Item | Detail |
|---|---|
| **Screen** | `PatientListScreen` |
| **BLoC Events** | `LoadPatients`, `LoadMorePatients`, `SearchPatients` |
| **Fitur** | Infinite scroll, pull-to-refresh, search bar |
| **Pagination** | 20 item per page |
| **Display** | Nama, NIK, umur, jenis kelamin, badge BPJS |
| **Loading** | Shimmer skeleton cards |
| **Empty State** | Ilustrasi + pesan "Belum ada pasien terdaftar" |
| **Error State** | Pesan error + tombol retry |

### F03.2 — Detail Pasien

| Item | Detail |
|---|---|
| **Screen** | `PatientDetailScreen` |
| **Data** | Profil lengkap pasien |
| **Sections** | Info dasar, kontak, BPJS, riwayat medis terkait |

### F03.3 — Tambah/Edit Pasien

| Item | Detail |
|---|---|
| **Screen** | `PatientFormScreen` |
| **BLoC Event** | `CreatePatient` |
| **Fields** | Nama*, NIK*, Tanggal Lahir*, Jenis Kelamin*, Alamat*, BPJS (opsional), Telepon |
| **Validasi** | NIK 16 digit, field required tidak boleh kosong |
| **API** | `POST /api/patients` (create), `PUT /api/patients/:id` (update) |
| **Success** | SnackBar sukses + kembali ke list |
| **FAB** | "Pasien Baru" pada tab Pasien |

---

## 📝 F04 — Rekam Medis (EMR)

### F04.1 — Daftar Rekam Medis

| Item | Detail |
|---|---|
| **Screen** | `MedicalRecordListScreen` |
| **BLoC Events** | `LoadRecords`, `LoadMoreRecords` |
| **Display** | Diagnosis, treatment, nama dokter, timestamp |
| **Filter** | By pasien_id (opsional) |
| **Pagination** | 20 item per page, infinite scroll |
| **Empty** | "Belum ada rekam medis" |

### F04.2 — Input Rekam Medis

| Item | Detail |
|---|---|
| **Screen** | `MedicalRecordFormScreen` |
| **BLoC Event** | `CreateRecord` |
| **Fields** | Pasien ID*, Diagnosis*, Treatment*, Keterangan |
| **Format** | SOAP style (Subjective, Objective, Assessment, Plan) |
| **Success** | SnackBar + kembali ke list |
| **FAB** | "Rekam Medis" pada tab Rekam Medis |

### F04.3 — Validasi Integritas (Planned)

| Item | Detail |
|---|---|
| **Data Hash** | keccak256 dari konten rekam medis |
| **On-Chain** | Stored sebagai tx_hash di Ethereum |
| **Verification** | `chain_verified` flag |
| **AI Summary** | Generated summary (harus di-approve dokter) |

---

## 💳 F05 — Pembayaran

### F05.1 — Daftar Pembayaran

| Item | Detail |
|---|---|
| **Screen** | `PaymentListScreen` |
| **BLoC Events** | `LoadPayments`, `LoadMorePayments`, `FilterPayments` |
| **Display** | Nama pasien, amount (Rp format), tipe, timestamp |
| **Filter Chips** | Semua, Debit, QRIS, Tunai |
| **Amount Format** | `Rp 150.000` (with dot separator) |
| **Pagination** | 20 items, infinite scroll |

### F05.2 — Form Pembayaran

| Item | Detail |
|---|---|
| **Screen** | `PaymentFormScreen` |
| **BLoC Event** | `SubmitPayment` |
| **Metode Bayar** | |

| Metode | Label | Field Tambahan | Visual |
|---|---|---|---|
| `PaymentType.cash` | TUNAI | - | Formulir standar |
| `PaymentType.debit` | DEBIT | Rekening Debit (text input) | Formulir + ID rekening |
| `PaymentType.qris` | QRIS | QR Code auto-generated | QR barcode viewer (qr_flutter) |

| Field | Tipe | Required | Keterangan |
|---|---|---|---|
| Pasien ID | Text | ✅ | ID pasien terdaftar |
| Nama Pasien | Text | ✅ | Nama lengkap |
| Jumlah (Rp) | Number | ✅ | Nominal pembayaran |
| Metode Bayar | Dropdown | ✅ | Cash / Debit / QRIS |
| Rekening Debit | Text | Conditional | Hanya jika debit |
| Kode QRIS | Auto | Generated | Generated dari data |
| Keterangan | Text | ❌ | Catatan opsional |

### F05.3 — QRIS Integration

```
┌────────────────────────────────┐
│  ╔══════════════════════════╗  │
│  ║                          ║  │
│  ║     ┌────────────────┐   ║  │
│  ║     │  ██ ████ ████  │   ║  │
│  ║     │ █ ███ █  ██ █  │   ║  │
│  ║     │ ██  █  █ ██ █  │   ║  │
│  ║     │ █ ███ █  ██ █  │   ║  │
│  ║     │  ██ ████ ████  │   ║  │
│  ║     └────────────────┘   ║  │
│  ║                          ║  │
│  ╚══════════════════════════╝  │
│                                │
│  Kode QRIS: PAY-xxxx-KLINIK   │
│  Scan untuk membayar           │
└────────────────────────────────┘
```

- Library: `qr_flutter` ^4.1.0
- Data: `QRIS-[paymentId]-KLINIK-MERAH-PUTIH`
- Size: 200 × 200 px

### F05.4 — Summary Pembayaran

| Metric | Kalkulasi |
|---|---|
| Total Transaksi | Count semua pembayaran |
| Total Debit | Sum amount where type=debit |
| Total QRIS | Sum amount where type=qris |
| Total Cash | Sum amount where type=cash |
| Total Keseluruhan | Debit + QRIS + Cash |

---

## ⚙️ F06 — Profil & Pengaturan

### F06.1 — Profil User

| Item | Detail |
|---|---|
| **Screen** | `ProfileScreen` |
| **Header** | Avatar, nama, role, klinik |
| **Layout** | Gradient card + section cards |

### F06.2 — Kepatuhan & Regulasi

| Regulasi | File | Deskripsi |
|---|---|---|
| PMK No. 269/2008 | `pmk_269_2008.md` | Standar Rekam Medis Indonesia |
| UU Kesehatan 17/2023 | `uu_kesehatan_17_2023.md` | Transformasi Digital Kesehatan |
| UU PDP 27/2022 | `uu_pdp_27_2022.md` | Pelindungan Data Pribadi |

- Viewer: `RegulationDetailScreen` (flutter_markdown renderer)

### F06.3 — Pengaturan

| Setting | Tipe | Persistence |
|---|---|---|
| Mode Gelap / Terang | Toggle Switch | `SharedPreferences: is_dark_mode` |
| Reset Onboarding | Button | Hapus `terms_accepted` + `privacy_accepted` |

### F06.4 — Manajemen Data & ML

| Fitur | Detail |
|---|---|
| Export Dataset (CSV) | Download data klinis untuk Machine Learning |
| API | `GET /api/ml/export` |
| Format | CSV (patient + medical records JOIN) |
| Fields | patient_id, no_rm, nama, jenis_kelamin, age, golongan_darah, diagnosis, vitals |

### F06.5 — Logout

| Item | Detail |
|---|---|
| **UI** | Card merah "Keluar Akun" |
| **Konfirmasi** | AlertDialog "Apakah Anda yakin...?" |
| **Aksi** | Clear session → redirect LoginScreen |

---

## 🎨 F07 — Tema & Design System

### Light Theme

| Token | Warna | Hex |
|---|---|---|
| Primary | Blue Medical | `#2563EB` |
| Primary Light | Light Blue | `#60A5FA` |
| Primary Dark | Dark Blue | `#1E40AF` |
| Success | Green Health | `#10B981` |
| Warning | Amber | `#F59E0B` |
| Error | Red Danger | `#EF4444` |
| Info | Blue | `#3B82F6` |
| Accent | Purple AI | `#7C3AED` |
| Background | Cool Gray | `#F8FAFC` |
| Card | White | `#FFFFFF` |
| Text Primary | Dark | `#0F172A` |

### Dark Theme

| Token | Warna | Hex |
|---|---|---|
| Primary | Light Blue | `#60A5FA` |
| Background | Navy | `#0F172A` |
| Card | Dark Navy | `#1E293B` |
| Text Primary | White | `#FFFFFF` |
| Text Body | Light Gray | `#F1F5F9` |

### Typography

| Style | Weight | Size |
|---|---|---|
| Headline Large | Bold | 28px |
| Headline Medium | Bold | 22px |
| Title Large | SemiBold | 18px |
| Body Large | Regular | 16px |
| Body Medium | Regular | 14px |
| Label Medium | Regular | 12px |

---

## 🧩 F08 — Reusable Widgets

| Widget | File | Keterangan |
|---|---|---|
| `PaginatedList` | `paginated_list.dart` | Generic infinite scroll dengan loading more |
| `ShimmerCard` | `shimmer_card.dart` | Skeleton loading animation |
| `StatCard` | `stat_card.dart` | Dashboard statistic card |
| `StatusBadge` | `status_badge.dart` | Colored badge untuk status |

---

## 🔔 F09 — Notifikasi (Backend)

| Item | Detail |
|---|---|
| **Service** | `notification.service.js` |
| **Trigger** | Setelah pembayaran berhasil dibuat |
| **Data** | Nama pasien, amount, tipe pembayaran, status |
| **Mode** | Async (non-blocking) |

---

## 📊 F10 — ML Data Export

| Item | Detail |
|---|---|
| **Endpoint** | `GET /api/ml/export` |
| **Auth** | JWT Token (query param atau header) |
| **Output** | CSV file download |
| **Query** | JOIN pasien + rekam_medis |
| **Filter** | is_active = 1 |
| **Columns** | patient_id, no_rm, patient_name, jenis_kelamin, age, golongan_darah, alergi, tanggal_kunjungan, keluhan_utama, diagnosis, icd10_code, tekanan_darah, nadi, suhu, berat_badan, tinggi_badan, saturasi_oksigen |
| **Use Case** | Training model prediksi penyakit, analisis pola diagnosa |
