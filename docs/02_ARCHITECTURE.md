# 🏛️ Klinik Merah Putih — Arsitektur Sistem

> Dokumen arsitektur teknis untuk Sistem Manajemen Klinik "Merah Putih" — aplikasi mobile healthcare berbasis **Flutter + Node.js** dengan fitur blockchain-ready dan AI-assisted.

---

## 🎯 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    KLINIK MERAH PUTIH                            │
│                  Sistem Manajemen Klinik                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              📱 FLUTTER MOBILE APP                      │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐              │    │
│  │  │ Screens  │──│   BLoC   │──│ Services │              │    │
│  │  │  (UI)    │  │ (State)  │  │  (API)   │              │    │
│  │  └──────────┘  └──────────┘  └─────┬────┘              │    │
│  │       │              │              │                    │    │
│  │  ┌────┴────┐    ┌────┴────┐         │                   │    │
│  │  │ Widgets │    │ Models  │         │  HTTP / REST      │    │
│  │  │ Theme   │    │ Enums   │         │                   │    │
│  │  └─────────┘    └─────────┘         │                   │    │
│  └─────────────────────────────────────┼───────────────────┘    │
│                                        │                        │
│  ─────────────────── API Layer ────────┼───────────────────     │
│                                        │                        │
│  ┌─────────────────────────────────────┼───────────────────┐    │
│  │              ⚙️ NODE.JS BACKEND                         │    │
│  │  ┌──────────┐  ┌──────────┐  ┌─────┴────┐              │    │
│  │  │  Routes  │──│ Control- │──│  Middle-  │              │    │
│  │  │  (API)   │  │  lers    │  │   ware    │              │    │
│  │  └──────────┘  └─────┬────┘  └──────────┘              │    │
│  │                      │                                   │    │
│  │           ┌──────────┴──────────┐                       │    │
│  │           │     Services        │                       │    │
│  │           │  (Notification, ML) │                       │    │
│  │           └──────────┬──────────┘                       │    │
│  └──────────────────────┼──────────────────────────────────┘    │
│                         │                                       │
│  ─────────────────── Data Layer ───────────────────────────     │
│                         │                                       │
│  ┌──────────────────────┼──────────────────────────────────┐    │
│  │              🗄️ DATABASE LAYER                          │    │
│  │  ┌──────────┐  ┌────┴─────┐  ┌──────────┐              │    │
│  │  │  SQLite  │  │PostgreSQL│  │  Redis   │              │    │
│  │  │  (Dev)   │  │  (Prod)  │  │  (Cache) │              │    │
│  │  └──────────┘  └──────────┘  └──────────┘              │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              🔗 BLOCKCHAIN LAYER (Future)               │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │    │
│  │  │StaffRegistry │  │ PaymentLedger│  │ SigmaGuard   │  │    │
│  │  │   .sol       │  │     .sol     │  │    .sol      │  │    │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🧠 Arsitektur Frontend (Flutter)

### Pattern: **BLoC (Business Logic Component) + Provider**

```
┌───────────────────────────────────────────────────┐
│                    MyApp                            │
│  ┌─────────────────────────────────────────────┐   │
│  │  ChangeNotifierProvider<AuthService>         │   │
│  │                                              │   │
│  │   TermsScreen ──┐                            │   │
│  │                  ▼                            │   │
│  │   LoginScreen ──► AuthService.login()         │   │
│  │                  ▼                            │   │
│  │   HomeScreen ─── MultiBlocProvider ──────┐   │   │
│  │        │         ├─ PatientBloc          │   │   │
│  │        │         ├─ MedicalRecordBloc    │   │   │
│  │        │         └─ PaymentBloc          │   │   │
│  │        │                                 │   │   │
│  │        ├── DashboardScreen               │   │   │
│  │        ├── PatientListScreen             │   │   │
│  │        ├── MedicalRecordListScreen       │   │   │
│  │        ├── PaymentListScreen             │   │   │
│  │        └── ProfileScreen                 │   │   │
│  │                                          │   │   │
│  └──────────────────────────────────────────┘   │
└───────────────────────────────────────────────────┘
```

### Alur Data (BLoC Pattern)

```
  UI (Screen)          BLoC              Service           Backend
  ──────────          ─────             ─────────          ───────
      │                 │                  │                  │
      │  add(Event)     │                  │                  │
      ├────────────────►│                  │                  │
      │                 │  call method()   │                  │
      │                 ├─────────────────►│                  │
      │                 │                  │   HTTP Request   │
      │                 │                  ├─────────────────►│
      │                 │                  │   JSON Response  │
      │                 │                  │◄─────────────────┤
      │                 │  return data     │                  │
      │                 │◄─────────────────┤                  │
      │  emit(State)    │                  │                  │
      │◄────────────────┤                  │                  │
      │                 │                  │                  │
  BlocBuilder           │                  │                  │
  rebuilds UI           │                  │                  │
```

### State Management Strategy

| Layer | Pattern | Keterangan |
|---|---|---|
| **Global Auth** | `Provider` (ChangeNotifier) | Session user, login/logout lifecycle |
| **Feature State** | `BLoC` (flutter_bloc) | Per-module state (Patient, Record, Payment) |
| **Local UI State** | `StatefulWidget` | Theme toggle, form input, tab index |
| **Persistence** | `SharedPreferences` | Dark mode, onboarding flag, JWT cache |

---

## ⚙️ Arsitektur Backend (Node.js)

### Pattern: **Modular MVC (Model-View-Controller)**

```
                    HTTP Request
                         │
                         ▼
                  ┌──────────────┐
                  │   app.js     │  Express middleware chain:
                  │              │  helmet → cors → morgan → json
                  └──────┬───────┘
                         │
                  ┌──────┴───────┐
                  │   Routes     │  URL mapping → controller
                  │  /api/auth   │
                  │  /api/patients│
                  │  /api/medical-records│
                  │  /api/payments│
                  │  /api/ml     │
                  └──────┬───────┘
                         │
            ┌────────────┼────────────┐
            │            │            │
    ┌───────┴──────┐     │     ┌──────┴──────┐
    │  Middleware   │     │     │  Controller │
    │  auth.js     │     │     │  (.js)      │
    │ ─────────── │     │     │ ─────────── │
    │ JWT verify   │     │     │ Business    │
    │ Role check   │     │     │ Logic       │
    └──────────────┘     │     └──────┬──────┘
                         │            │
                         │     ┌──────┴──────┐
                         │     │  Database   │
                         │     │  Query      │
                         │     │  Helper     │
                         │     └──────┬──────┘
                         │            │
                    ┌────┴────────────┴────┐
                    │    SQLite / PG       │
                    │    Database           │
                    └─────────────────────┘
```

### REST API Endpoints

| Method | Endpoint | Auth | Role | Deskripsi |
|---|---|---|---|---|
| `POST` | `/api/auth/register` | ❌ | - | Registrasi user baru |
| `POST` | `/api/auth/login` | ❌ | - | Login + generate JWT |
| `GET` | `/api/patients` | ✅ | Any | List pasien (paginated) |
| `GET` | `/api/patients/:id` | ✅ | Any | Detail pasien by ID |
| `POST` | `/api/patients` | ✅ | Any | Tambah pasien baru |
| `PUT` | `/api/patients/:id` | ✅ | Any | Update data pasien |
| `GET` | `/api/medical-records/patient/:patientId` | ✅ | Any | Rekam medis per pasien |
| `GET` | `/api/medical-records/:id` | ✅ | Any | Detail rekam medis |
| `POST` | `/api/medical-records` | ✅ | Any | Input rekam medis baru |
| `POST` | `/api/payments` | ✅ | Admin | Buat pembayaran |
| `GET` | `/api/payments/:id` | ✅ | Any | Detail pembayaran |
| `GET` | `/api/ml/export` | ✅ | Any | Export data CSV (ML) |
| `GET` | `/health` | ❌ | - | Health check server |

### Middleware Pipeline

```
Request → helmet() → cors() → morgan() → json() → authenticate() → authorize() → Controller
```

---

## 🔐 Security Architecture

```
┌─────────────────────────────────────────────────┐
│                SECURITY LAYERS                   │
├─────────────────────────────────────────────────┤
│                                                  │
│  Layer 1: Transport                              │
│  ├── HTTPS (production)                          │
│  └── Helmet.js (HTTP security headers)           │
│                                                  │
│  Layer 2: Authentication                         │
│  ├── JWT Token (jsonwebtoken)                    │
│  ├── bcryptjs password hashing                   │
│  └── Session persistence (SharedPreferences)     │
│                                                  │
│  Layer 3: Authorization                          │
│  ├── Role-Based Access Control (RBAC)            │
│  │   ├── admin   → Full access                   │
│  │   ├── dokter  → Medical records + patients    │
│  │   ├── perawat → Limited medical access        │
│  │   ├── apoteker→ Prescription access           │
│  │   └── pasien  → Read-only own data            │
│  └── authorize() middleware per-route             │
│                                                  │
│  Layer 4: Data Integrity (Future)                │
│  ├── keccak256 hash → on-chain verification      │
│  ├── Ethereum tx hash storage                    │
│  └── Audit log (immutable, no UPDATE/DELETE)     │
│                                                  │
│  Layer 5: Compliance                             │
│  ├── PMK No. 269/2008 (Rekam Medis)              │
│  ├── UU Kesehatan 17/2023                        │
│  └── UU PDP 27/2022 (Data Pribadi)               │
│                                                  │
└─────────────────────────────────────────────────┘
```

---

## 🐳 Deployment Architecture

```
Docker Compose Stack:
┌─────────────────────────────────────────────┐
│                                              │
│  ┌──────────────────────┐                   │
│  │  PostgreSQL 15       │  Port: 5432       │
│  │  Volume: pgdata      │  DB: puskesmas_db │
│  └──────────┬───────────┘                   │
│             │                                │
│  ┌──────────┴───────────┐                   │
│  │  Redis 7 Alpine      │  Port: 6379       │
│  │  Cache & Sessions    │                   │
│  └──────────┬───────────┘                   │
│             │                                │
│  ┌──────────┴───────────┐                   │
│  │  Node.js Backend     │  Port: 3000       │
│  │  Express API         │                   │
│  │  depends_on: pg+redis│                   │
│  └──────────────────────┘                   │
│                                              │
└─────────────────────────────────────────────┘
         ▲
         │  HTTP API
         │
┌────────┴────────┐
│ Flutter Mobile   │
│ Android / iOS    │
│ Web              │
└─────────────────┘
```

---

## 📐 Design Patterns Used

| Pattern | Lokasi | Keterangan |
|---|---|---|
| **BLoC** | `lib/bloc/` | Reactive state management |
| **Provider** | `main.dart` | Global dependency injection |
| **MVC** | `backend/src/modules/` | Separation of concerns |
| **Repository** | `lib/services/` | Data access abstraction |
| **Factory** | `lib/models/` | `fromJson()` constructors |
| **Observer** | `BlocBuilder` | Reactive UI rebuild |
| **Middleware** | `backend/src/middleware/` | Cross-cutting concerns |
| **Singleton** | `PaymentService._mockPayments` | Shared mock data |
| **IndexedStack** | `home_screen.dart` | Tab-based navigation with state preservation |

---

## 🌐 Platform Support

| Platform | Status | Keterangan |
|---|---|---|
| **Android** | ✅ Aktif | Emulator via 10.0.2.2:3000 |
| **iOS** | ✅ Aktif | Simulator via localhost:3000 |
| **Web** | ✅ Aktif | Browser via localhost:3000 |
| **Windows** | ⚪ Tersedia | Desktop build configured |
| **macOS** | ⚪ Tersedia | Desktop build configured |
| **Linux** | ⚪ Tersedia | Desktop build configured |
