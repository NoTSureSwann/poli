# 📦 Klinik Merah Putih — Struktur Project

> **Sistem Manajemen Klinik Terintegrasi** berbasis Flutter (Frontend Mobile) + Node.js Express (Backend REST API) dengan database SQLite/PostgreSQL.

---

## 🏗️ Gambaran Umum

```
klinik/
├── lib/                          # 🎯 Flutter Frontend (Dart)
│   ├── main.dart                 # Entry point aplikasi
│   ├── bloc/                     # Business Logic Components (BLoC Pattern)
│   │   ├── patient_bloc.dart         # State management pasien
│   │   ├── medical_record_bloc.dart  # State management rekam medis
│   │   └── payment_bloc.dart         # State management pembayaran
│   ├── models/                   # Data Models (Serializable)
│   │   ├── user.dart                 # Model user + role enum
│   │   ├── patient.dart              # Model pasien
│   │   ├── medical_record.dart       # Model rekam medis
│   │   ├── payment.dart              # Model pembayaran + PaymentType enum
│   │   └── guard_event.dart          # Model IGC Guard event
│   ├── screens/                  # UI Screens (Pages)
│   │   ├── auth/                     # 🔐 Autentikasi
│   │   │   ├── login_screen.dart         # Halaman login
│   │   │   └── register_screen.dart      # Halaman registrasi
│   │   ├── onboarding/               # 📋 Onboarding
│   │   │   └── terms_screen.dart         # Terms & conditions
│   │   ├── dashboard/                # 📊 Dashboard
│   │   │   └── dashboard_screen.dart     # Statistik + aksi cepat
│   │   ├── patients/                 # 👥 Modul Pasien
│   │   │   ├── patient_list_screen.dart      # Daftar pasien (paginated)
│   │   │   ├── patient_detail_screen.dart    # Detail profil pasien
│   │   │   └── patient_form_screen.dart      # Form tambah/edit pasien
│   │   ├── records/                  # 📝 Modul Rekam Medis
│   │   │   ├── medical_record_list_screen.dart   # Daftar rekam medis
│   │   │   └── medical_record_form_screen.dart   # Form input rekam medis
│   │   ├── payments/                 # 💳 Modul Pembayaran
│   │   │   ├── payment_list_screen.dart      # Riwayat pembayaran
│   │   │   └── payment_form_screen.dart      # Form pembayaran (QRIS/Debit/Tunai)
│   │   ├── profile/                  # ⚙️ Profil & Pengaturan
│   │   │   ├── profile_screen.dart           # Profil user + settings
│   │   │   └── regulation_detail_screen.dart # Viewer regulasi (Markdown)
│   │   └── home_screen.dart          # Container utama (Bottom Navigation)
│   ├── services/                 # 🔌 API & Data Services
│   │   ├── auth_service.dart         # Autentikasi (JWT, session)
│   │   ├── patient_service.dart      # CRUD pasien (REST API)
│   │   └── payment_service.dart      # Transaksi pembayaran
│   ├── theme/                    # 🎨 Design System
│   │   └── app_theme.dart            # Light/Dark theme + color palette
│   └── widgets/                  # 🧩 Reusable Widgets
│       ├── paginated_list.dart       # Generic infinite scroll list
│       ├── shimmer_card.dart         # Loading skeleton animation
│       ├── stat_card.dart            # Kartu statistik dashboard
│       └── status_badge.dart         # Badge status berwarna
│
├── backend/                      # ⚙️ Node.js Backend
│   ├── src/
│   │   ├── app.js                    # Express server entry point
│   │   ├── config/
│   │   │   └── database.js               # Koneksi SQLite + query helper
│   │   ├── middleware/
│   │   │   └── auth.js                   # JWT auth + role authorization
│   │   ├── modules/                  # Feature Modules (MVC Pattern)
│   │   │   ├── auth/
│   │   │   │   ├── auth.controller.js        # Login & register logic
│   │   │   │   └── auth.routes.js            # POST /register, /login
│   │   │   ├── pasien/
│   │   │   │   ├── pasien.controller.js      # CRUD pasien
│   │   │   │   └── pasien.routes.js          # GET/POST/PUT /patients
│   │   │   ├── medical-record/
│   │   │   │   ├── medical-record.controller.js  # CRUD rekam medis
│   │   │   │   └── medical-record.routes.js      # GET/POST /medical-records
│   │   │   ├── pembayaran/
│   │   │   │   ├── pembayaran.controller.js  # Create & get pembayaran
│   │   │   │   └── pembayaran.routes.js      # GET/POST /payments
│   │   │   └── ml/
│   │   │       ├── ml.controller.js          # Export data CSV untuk ML
│   │   │       └── ml.routes.js              # GET /ml/export
│   │   ├── services/
│   │   │   └── notification.service.js       # Payment notification service
│   │   └── utils/
│   │       ├── auth.js                   # bcrypt + JWT helpers
│   │       └── response.js               # Standar format response API
│   ├── database/
│   │   ├── schema.sql                # PostgreSQL schema (production)
│   │   ├── schema.sqlite.sql         # SQLite schema (development)
│   │   ├── migrate.js                # Database migration script
│   │   └── seed.js                   # Data seeding script
│   ├── postman/                  # 📬 Postman collection
│   ├── tests/                    # 🧪 Backend tests
│   ├── package.json
│   └── .env                      # Environment variables backend
│
├── assets/                       # 📁 Static Assets
│   └── regulations/              # Dokumen regulasi (Markdown)
│       ├── pmk_269_2008.md           # PMK No. 269/2008
│       ├── uu_kesehatan_17_2023.md   # UU Kesehatan
│       └── uu_pdp_27_2022.md         # UU PDP (Data Pribadi)
│
├── docker-compose.yml            # 🐳 Docker: PostgreSQL + Redis + Backend
├── pubspec.yaml                  # Flutter dependencies
├── .env                          # Flutter environment config
├── database.sqlite               # SQLite database file (dev)
└── analysis_options.yaml         # Dart lint rules
```

---

## 📊 Statistik Project

| Komponen | Jumlah File | Bahasa |
|---|---|---|
| **Flutter Screens** | 12 | Dart |
| **Flutter BLoC** | 3 | Dart |
| **Flutter Models** | 5 | Dart |
| **Flutter Services** | 3 | Dart |
| **Flutter Widgets** | 4 | Dart |
| **Backend Controllers** | 5 | JavaScript |
| **Backend Routes** | 5 | JavaScript |
| **Backend Middleware** | 1 | JavaScript |
| **Database Schema** | 2 | SQL |
| **TOTAL** | ~40+ | Dart + JS + SQL |

---

## 📱 Dependencies Flutter

| Package | Versi | Fungsi |
|---|---|---|
| `flutter_bloc` | ^9.1.1 | State management (BLoC Pattern) |
| `provider` | ^6.1.2 | Dependency injection (AuthService) |
| `dio` | ^5.9.2 | HTTP client (advanced) |
| `http` | ^1.6.0 | HTTP client (standard) |
| `shared_preferences` | ^2.5.5 | Local storage (session, theme) |
| `flutter_dotenv` | ^6.0.0 | Environment variables |
| `google_fonts` | ^8.0.2 | Typography premium |
| `cached_network_image` | ^3.4.1 | Image caching |
| `shimmer` | ^3.0.0 | Loading skeleton animation |
| `intl` | ^0.20.2 | Internationalization & format |
| `flutter_markdown` | ^0.7.5 | Markdown renderer (regulasi) |
| `url_launcher` | ^6.3.2 | URL & file launcher |
| `qr_flutter` | ^4.1.0 | QR code generator (QRIS) |
| `device_sim` | ^0.1.3 | Device simulator (debug) |

---

## ⚙️ Dependencies Backend

| Package | Versi | Fungsi |
|---|---|---|
| `express` | ^4.18.2 | Web framework |
| `helmet` | ^7.1.0 | Security headers |
| `cors` | ^2.8.5 | Cross-Origin Resource Sharing |
| `bcryptjs` | ^2.4.3 | Password hashing |
| `jsonwebtoken` | ^9.0.2 | JWT authentication |
| `pg` | ^8.11.3 | PostgreSQL driver |
| `sqlite3` | ^6.0.1 | SQLite driver (development) |
| `redis` | ^4.6.12 | Redis cache client |
| `morgan` | ^1.10.0 | HTTP request logger |
| `axios` | ^1.6.2 | HTTP client (internal) |
| `dotenv` | ^16.3.1 | Environment variables |
