# 🔄 puskesmas — Kotlin Android application

**native Kotlin Android** dengan output yang identik secara fungsional dan visual.

---

## 📌 Instruksi Utama

Gunakan prompt di bawah ini untuk memberikan instruksi ke AI coding assistant (Gemini, ChatGPT, Cursor, dll.) agar menghasilkan project Kotlin yang **se-identik mungkin** dengan versi Flutter asli.


```text
Buatkan project Android native menggunakan Kotlin dengan arsitektur Modern Android (Jetpack Compose + MVVM + Clean Architecture) yang mereplikasi PERSIS output dari aplikasi Flutter "Klinik Merah Putih" — Sistem Manajemen Klinik untuk fasilitas kesehatan primer di Indonesia.

========================
IDENTITAS APLIKASI
========================
- Nama: Klinik Merah Putih
- Package: com.igchealthcare.klinik
- Min SDK: 26 (Android 8.0)
- Target SDK: 35 (Android 15)
- Bahasa: Kotlin 2.x
- UI: Jetpack Compose (Material 3)
- Arsitektur: MVVM + Clean Architecture
- DI: Hilt (Dagger)
- Networking: Retrofit2 + OkHttp3
- State: StateFlow + MutableStateFlow
- Navigation: Compose Navigation (NavHostController)
- Local Storage: DataStore Preferences
- Image: Coil (Compose)
- QR Code: ZXing (com.google.zxing:core)

========================
BACKEND API (EXISTING) implement CREATE, READ, UPDATE, DELETE
========================
Base URL: http://10.0.2.2:3000/api (Android Emulator → localhost mapping)



Endpoint yang HARUS di-consume:
1. POST /api/auth/register    — Body: { nama, email, password, role }
2. POST /api/auth/login       — Body: { email, password } → Response: { data: { user, token } }
3. GET  /api/patients          — Query: ?page=1&limit=20&search=xxx — Header: Authorization: Bearer <token>
4. GET  /api/patients/:id      — Detail pasien
5. POST /api/patients          — Body: { no_rm, nama, nik, bpjs_id, tanggal_lahir, jenis_kelamin, alamat, no_telepon }
6. PUT  /api/patients/:id      — Update pasien
7. GET  /api/medical-records/patient/:patientId — Rekam medis per pasien
8. GET  /api/medical-records/:id — Detail rekam medis
9. POST /api/medical-records   — Body: { pasien_id, keluhan_utama, pemeriksaan_fisik, diagnosis, tindakan_rencana, icd10_code, tekanan_darah, nadi, suhu, berat_badan, tinggi_badan, saturasi_oksigen, catatan_tambahan }
10. POST /api/payments          — Body: { pasien_id, rekam_medis_id, resep_id, jenis_pembayaran, total_biaya, keterangan } — Role: admin only
11. GET  /api/payments/:id      — Detail pembayaran
12. GET  /api/ml/export         — Download CSV (Token via query atau header)
13. GET  /health                — Health check

Standard API Response Format:
{
  "status": "success",
  "message": "...",
  "data": { ... }
}

Paginated Response:
{
  "status": "success",
  "data": [...],
  "total": 100,
  "page": 1,
  "limit": 20
}

========================
DATA MODELS (Kotlin data class)
========================

// ── User ──
enum class UserRole { admin, dokter, perawat, apoteker, pasien }

data class User(
    val id: String,
    val nama: String,
    val email: String,
    val role: UserRole,
    val token: String? = null
)

// ── Patient ──
data class Patient(
    val id: String,
    val nama: String,
    val nik: String,
    val tanggalLahir: LocalDate,
    val alamat: String,
    val jenisKelamin: String,        // "L" atau "P"
    val noBpjs: String? = null,
    val phoneNumber: String? = null,
    val createdAt: LocalDateTime = LocalDateTime.now()
) {
    val age: String
        get() {
            val years = Period.between(tanggalLahir, LocalDate.now()).years
            return "$years tahun"
        }
    val hasBPJS: Boolean get() = !noBpjs.isNullOrEmpty()
}

// ── Medical Record ──
data class MedicalRecord(
    val id: String,
    val pasienId: String,
    val pasienNama: String,
    val doctorName: String,
    val diagnosis: String,
    val treatment: String,
    val timestamp: LocalDateTime,
    val isValid: Boolean = true
)

// ── Payment ──
enum class PaymentType(val label: String) {
    DEBIT("DEBIT"),
    QRIS("QRIS"),
    CASH("TUNAI")
}

data class Payment(
    val id: String,
    val pasienId: String,
    val pasienNama: String,
    val amount: Double,
    val paymentType: PaymentType,
    val processedBy: String,
    val timestamp: LocalDateTime,
    val description: String? = null,
    val rekeningDebit: String? = null,
    val qrisCode: String? = null
) {
    val formattedAmount: String
        get() = "Rp ${String.format("%,.0f", amount).replace(',', '.')}"
}

// ── Guard Event ──
data class GuardEvent(
    val ruleId: String,
    val action: String,          // "ALLOWED", "BLOCKED", "FLAGGED"
    val context: String,
    val triggeredBy: String,
    val timestamp: LocalDateTime
)

// ── Paginated Result ──
data class PaginatedResult<T>(
    val items: List<T>,
    val totalCount: Int,
    val currentPage: Int,
    val pageSize: Int,
    val hasMore: Boolean
)

========================
NAVIGASI & SCREENS (wajib ada semua)
========================

Screen Navigation Graph:
- SplashScreen → cek onboarding + auth
- TermsScreen → Accept terms & conditions
- LoginScreen → Email + Password + Role dropdown
- RegisterScreen → Nama + Email + Password + Role
- HomeScreen (BottomNavigation — 5 tabs):
  ├── Tab 0: DashboardScreen
  │   ├── 4 StatCards (Total Pasien, Total Transaksi, Debit, QRIS/Tunai)
  │   ├── Quick Actions Row (Pasien Baru, Pembayaran, Rekam Medis, Riwayat)
  │   └── Recent Activities Timeline (5 items)
  ├── Tab 1: PatientListScreen
  │   ├── Search bar
  │   ├── LazyColumn infinite scroll (20 per page)
  │   ├── Shimmer loading skeleton
  │   ├── Pull-to-refresh
  │   └── FAB → PatientFormScreen
  ├── Tab 2: MedicalRecordListScreen
  │   ├── LazyColumn infinite scroll
  │   ├── Card: diagnosis, treatment, dokter, timestamp
  │   └── FAB → MedicalRecordFormScreen
  ├── Tab 3: PaymentListScreen
  │   ├── Filter chips (Semua, Debit, QRIS, Tunai)
  │   ├── LazyColumn infinite scroll
  │   ├── Card: nama pasien, Rp format, tipe, waktu
  │   └── FAB → PaymentFormScreen
  └── Tab 4: ProfileScreen
      ├── Profile header (gradient card + avatar)
      ├── Kepatuhan & Regulasi section (3 regulasi PMK/UU)
      ├── Pengaturan (Dark Mode toggle, Reset Onboarding)
      ├── Manajemen Data & ML (Export CSV button)
      └── Logout button (konfirmasi dialog)

Form Screens (push navigation):
- PatientFormScreen: nama*, nik*, tanggal_lahir*, jenis_kelamin*, alamat*, no_bpjs, telepon
- MedicalRecordFormScreen: pasien_id*, diagnosis*, treatment*
- PaymentFormScreen:
  ├── pasien_id*, nama*, jumlah*
  ├── Metode bayar dropdown (Cash/Debit/QRIS)
  ├── Jika DEBIT → tampilkan field "Rekening Debit"
  ├── Jika QRIS → generate + tampilkan QR barcode (ZXing Bitmap)
  └── Keterangan (opsional)
- RegulationDetailScreen: Markdown renderer (lokasi aset dari bundled assets)

========================
DESIGN SYSTEM & THEME
========================

Color Palette (WAJIB identik dengan Flutter):
- Primary: #2563EB (Blue Medical)
- PrimaryLight: #60A5FA
- PrimaryDark: #1E40AF
- Success: #10B981 (Green Health)
- Warning: #F59E0B (Amber)
- Error: #EF4444 (Red)
- Info: #3B82F6
- Accent: #7C3AED (Purple AI)
- Neutral: #64748B

Light Theme:
- Background: #F8FAFC
- Card: #FFFFFF
- TextPrimary: #0F172A
- TextBody: #334155 / #475569
- TextLabel: #64748B
- Divider: #E2E8F0

Dark Theme:
- Background: #0F172A
- Card: #1E293B
- TextPrimary: #FFFFFF
- TextBody: #F1F5F9 / #CBD5E1
- TextLabel: #94A3B8
- Divider: #334155

Typography (semua dalam sp):
- headlineLarge: 28sp, Bold
- headlineMedium: 22sp, Bold
- titleLarge: 18sp, SemiBold (600)
- bodyLarge: 16sp, Normal
- bodyMedium: 14sp, Normal
- labelMedium: 12sp, Normal

Komponen UI yang wajib:
1. StatCard — card statistik dengan ikon, value, subtitle, warna latar transparan
2. ShimmerCard — Shimmer loading animation (library: com.valentinilk.shimmer)
3. StatusBadge — pill badge berwarna (hijau=aktif, merah=nonaktif, dll)
4. PaginatedList — reusable LazyColumn dengan auto load more trigger
5. QuickActionButton — tombol aksi cepat horizontal dengan ikon + label
6. ActivityTile — timeline item (ikon berwarna + judul + subtitle + waktu)

AppBar:
- Centered title: "Klinik Merah Putih"
- Action: toggle dark mode icon (sun/moon)

BottomNavigation (NavigationBar Material3):
- Dashboard (dashboard icon)
- Pasien (people icon)
- Rekam Medis (medical_information icon)
- Pembayaran (payment icon)
- Profil (person icon)

FloatingActionButton (conditional per tab):
- Tab 1: ExtendedFAB "Pasien Baru" (person_add icon)
- Tab 2: ExtendedFAB "Rekam Medis" (add_moderator icon)
- Tab 3: ExtendedFAB "Pembayaran Baru" (add icon)
- Tab 0, 4: Tidak ada FAB

========================
FITUR SPESIFIK
========================

1. ONBOARDING:
   - Tampilkan terms & conditions pada first launch
   - Simpan state accepted di DataStore
   - Bisa di-reset dari ProfileScreen

2. AUTH:
   - Login: email + password → JWT token
   - Register: nama + email + password + role
   - Auto-login dari cached token di DataStore
   - Logout: clear DataStore + redirect ke LoginScreen

3. PASIEN CRUD:
   - List: paginated 20/page, infinite scroll
   - Search: real-time filter by nama/NIK
   - Create: form validasi (NIK 16 digit, required fields)
   - Detail: profil lengkap dengan badge BPJS
   - Update: pre-fill form

4. REKAM MEDIS:
   - List: paginated, sortir by timestamp DESC
   - Create: diagnosis + treatment + pasien_id
   - Display: contentSummary = "$diagnosis | $treatment"

5. PEMBAYARAN:
   - List: filterable by PaymentType (chips)
   - Create: dengan conditional field berdasarkan metode
   - QRIS: auto-generate QR barcode menggunakan ZXing → Bitmap → Image composable
   - Format currency: "Rp 150.000" (dot separator)
   - Summary: total per tipe + grand total

6. PROFIL:
   - Profile header dengan gradient background (primary 40% alpha → accent 20% alpha)
   - Regulasi viewer: render .md files dari assets (gunakan library Markwon atau Compose Markdown)
   - Dark mode toggle: persist ke DataStore
   - ML Export: buka browser dengan URL /api/ml/export?token=XXX
   - Logout: AlertDialog konfirmasi

========================
STRUKTUR PROJECT KOTLIN
========================

com.igchealthcare.klinik/
├── di/
│   └── AppModule.kt                    // Hilt module (Retrofit, DataStore, Repository)
├── data/
│   ├── api/
│   │   ├── ApiService.kt               // Retrofit interface (semua endpoint)
│   │   ├── AuthInterceptor.kt          // OkHttp interceptor untuk JWT header
│   │   └── dto/                        // Response DTO classes
│   ├── repository/
│   │   ├── AuthRepository.kt
│   │   ├── PatientRepository.kt
│   │   ├── MedicalRecordRepository.kt
│   │   └── PaymentRepository.kt
│   └── local/
│       └── PreferencesManager.kt       // DataStore wrapper (token, theme, onboarding)
├── domain/
│   └── model/
│       ├── User.kt
│       ├── Patient.kt
│       ├── MedicalRecord.kt
│       ├── Payment.kt
│       └── GuardEvent.kt
├── presentation/
│   ├── theme/
│   │   ├── Color.kt                    // Semua warna di atas
│   │   ├── Type.kt                     // Typography
│   │   └── Theme.kt                    // KlinikMerahPutihTheme (light + dark)
│   ├── components/
│   │   ├── StatCard.kt
│   │   ├── ShimmerCard.kt
│   │   ├── StatusBadge.kt
│   │   ├── PaginatedList.kt
│   │   └── QuickActionButton.kt
│   ├── navigation/
│   │   └── AppNavGraph.kt              // NavHost + sealed class Route
│   ├── auth/
│   │   ├── LoginScreen.kt
│   │   ├── RegisterScreen.kt
│   │   └── AuthViewModel.kt
│   ├── onboarding/
│   │   └── TermsScreen.kt
│   ├── home/
│   │   └── HomeScreen.kt              // Scaffold + BottomNav + IndexedStack equivalent
│   ├── dashboard/
│   │   ├── DashboardScreen.kt
│   │   └── DashboardViewModel.kt
│   ├── patient/
│   │   ├── PatientListScreen.kt
│   │   ├── PatientDetailScreen.kt
│   │   ├── PatientFormScreen.kt
│   │   └── PatientViewModel.kt
│   ├── record/
│   │   ├── MedicalRecordListScreen.kt
│   │   ├── MedicalRecordFormScreen.kt
│   │   └── MedicalRecordViewModel.kt
│   ├── payment/
│   │   ├── PaymentListScreen.kt
│   │   ├── PaymentFormScreen.kt
│   │   └── PaymentViewModel.kt
│   └── profile/
│       ├── ProfileScreen.kt
│       ├── RegulationDetailScreen.kt
│       └── ProfileViewModel.kt
├── util/
│   ├── CurrencyFormatter.kt
│   ├── DateFormatter.kt
│   └── QrCodeGenerator.kt             // ZXing → Bitmap helper
└── KlinikApp.kt                        // @HiltAndroidApp Application class

========================
GRADLE DEPENDENCIES (build.gradle.kts app level)
========================

dependencies {
    // Compose BOM
    implementation(platform("androidx.compose:compose-bom:2024.12.01"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material:material-icons-extended")
    
    // Navigation
    implementation("androidx.navigation:navigation-compose:2.8.5")
    
    // Lifecycle + ViewModel
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.8.7")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.8.7")
    
    // Hilt
    implementation("com.google.dagger:hilt-android:2.52")
    kapt("com.google.dagger:hilt-compiler:2.52")
    implementation("androidx.hilt:hilt-navigation-compose:1.2.0")
    
    // Retrofit + OkHttp
    implementation("com.squareup.retrofit2:retrofit:2.11.0")
    implementation("com.squareup.retrofit2:converter-gson:2.11.0")
    implementation("com.squareup.okhttp3:logging-interceptor:4.12.0")
    
    // DataStore
    implementation("androidx.datastore:datastore-preferences:1.1.1")
    
    // Coil (Image loading)
    implementation("io.coil-kt:coil-compose:2.7.0")
    
    // QR Code
    implementation("com.google.zxing:core:3.5.3")
    
    // Shimmer
    implementation("com.valentinilk.shimmer:compose-shimmer:1.3.1")
    
    // Markdown renderer
    implementation("com.halilibo.compose-richtext:richtext-commonmark:1.0.0-alpha01")
    
    // Accompanist (pull refresh, etc)
    implementation("com.google.accompanist:accompanist-swiperefresh:0.36.0")
}

========================
BEHAVIOR REQUIREMENTS
========================

1. App harus support Light + Dark theme, switchable dari ProfileScreen dan AppBar
2. Semua list menggunakan infinite scroll (bukan pagination button)
3. Loading state menggunakan Shimmer skeleton, bukan CircularProgressIndicator
4. Error state menampilkan pesan + tombol Retry
5. Empty state menampilkan ilustrasi + pesan deskriptif
6. Semua form memiliki validasi client-side sebelum submit
7. Format tanggal: "dd MMM yyyy" (contoh: "21 Apr 2026")
8. Format currency: "Rp 150.000" (dot separator Indonesia)
9. Platform-specific: Base URL harus 10.0.2.2:3000 untuk emulator Android
10. Pull-to-refresh pada semua list screen
11. Authentication state harus reactive (auto-navigate saat login/logout)
12. Tab state harus preserved saat switch antar tab (state hoisting)

========================
CATATAN PENTING
========================

- Backend SUDAH ADA dan berjalan di Node.js Express + SQLite
- JANGAN buat ulang backend, cukup consume API yang sudah ada
- Schema database di backend menggunakan tabel: users, pasien, rekam_medis, antrian, stok_obat, resep, resep_detail, pembayaran, audit_log
- Pastikan JSON key mapping PERSIS sesuai backend (snake_case): nama, nik, tanggal_lahir, jenis_kelamin, no_bpjs, dll
- QR code untuk QRIS harus ter-generate secara real-time berdasarkan data pembayaran
- Regulasi (PMK, UU Kesehatan, UU PDP) disimpan sebagai .md files di folder assets/regulations/

Hasilkan SEMUA file Kotlin yang diperlukan dengan kode yang lengkap, compilable, dan siap dijalankan.
```

---

## 📐 Prompt-Prompt Tambahan (Per-Modul)

### Prompt: Authentication Module

```text
Untuk project Kotlin "Klinik Merah Putih" (com.igchealthcare.klinik), buatkan modul Authentication lengkap:

1. AuthRepository.kt — consume POST /api/auth/login dan /api/auth/register
2. AuthViewModel.kt — StateFlow untuk login/register state (Loading, Success, Error)
3. LoginScreen.kt — Compose screen dengan:
   - TextField email
   - TextField password (visual transform)
   - Dropdown role (admin, dokter, perawat, apoteker, pasien)
   - Button login (enabled when valid)
   - Link ke register
   - SnackBar error handling
4. RegisterScreen.kt — Compose screen dengan:
   - TextField nama, email, password, confirm password
   - Dropdown role
   - Validasi: email format, password min 6, password match
5. PreferencesManager.kt — DataStore untuk menyimpan JWT token + User JSON

Backend response format:
{
  "status": "success",
  "data": {
    "user": { "id": 1, "nama": "Admin", "email": "admin@klinik.id", "role": "admin" },
    "token": "eyJhbG..."
  }
}

Gunakan Material3, Hilt injection, dan Retrofit.
```

---

### Prompt: Patient CRUD Module

```text
Untuk project Kotlin "Klinik Merah Putih", buatkan modul Patient Management:

1. PatientRepository.kt — CRUD operations:
   - getPatients(page, limit, search) → PaginatedResult<Patient>
   - getPatientById(id) → Patient?
   - createPatient(patient) → Patient
   - updatePatient(id, patient) → Patient

2. PatientViewModel.kt — StateFlow states:
   - PatientListState (Loading, Loaded, LoadingMore, Error)
   - PatientFormState (Idle, Submitting, Success, Error)
   - searchQuery: MutableStateFlow<String>
   - Infinite scroll support (loadMore trigger)

3. PatientListScreen.kt — Compose:
   - SearchBar di atas
   - LazyColumn dengan pull-to-refresh
   - PatientCard: nama, NIK, umur, badge BPJS jika ada
   - Shimmer loading (ShimmerCard composable)
   - Empty state + error state + retry
   - Auto load more saat scroll ke bawah

4. PatientFormScreen.kt — Compose form:
   - Fields: nama*, nik* (16 digit), tanggal_lahir* (DatePicker), jenis_kelamin* (Radio L/P), alamat*, no_bpjs, telepon
   - Validasi real-time
   - Submit button → loading indicator

5. PatientDetailScreen.kt — Profil pasien lengkap

API JSON keys (snake_case): nama, nik, tanggal_lahir, jenis_kelamin, alamat, no_bpjs / bpjs_id, no_telepon / phone_number
```

---

### Prompt: Payment Module dengan QRIS

```text
Untuk project Kotlin "Klinik Merah Putih", buatkan modul Payment lengkap:

1. PaymentRepository.kt — submit payment dan get payment detail

2. PaymentViewModel.kt — StateFlow:
   - PaymentListState + filter by PaymentType
   - PaymentFormState (Idle, Submitting, Success, Error)

3. PaymentListScreen.kt — Compose:
   - FilterChips row: Semua, Debit, QRIS, Tunai
   - LazyColumn infinite scroll
   - PaymentCard: pasienNama, formattedAmount (Rp xxx.xxx), tipe badge, waktu

4. PaymentFormScreen.kt — Compose form:
   - TextField pasienId, pasienNama, jumlah (number keyboard)
   - Dropdown metode: Cash / Debit / QRIS
   - Conditional: jika DEBIT → tampilkan TextField "Rekening Debit"
   - Conditional: jika QRIS → generate QR code menggunakan ZXing:
     ```kotlin
     fun generateQrBitmap(content: String, size: Int = 512): Bitmap {
         val writer = QRCodeWriter()
         val bitMatrix = writer.encode(content, BarcodeFormat.QR_CODE, size, size)
         val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.RGB_565)
         for (x in 0 until size) {
             for (y in 0 until size) {
                 bitmap.setPixel(x, y, if (bitMatrix[x, y]) Color.BLACK else Color.WHITE)
             }
         }
         return bitmap
     }
     ```
     Data QR: "QRIS-[paymentId]-KLINIK-MERAH-PUTIH"
     Tampilkan sebagai Image(bitmap.asImageBitmap())

5. PaymentType enum: DEBIT("DEBIT"), QRIS("QRIS"), CASH("TUNAI")

6. Currency format: "Rp 150.000" → gunakan DecimalFormat("#,###").format(amount).replace(',', '.')
```

---

### Prompt: Dashboard Module

```text
Untuk project Kotlin "Klinik Merah Putih", buatkan DashboardScreen.kt:

Requirements:
1. 4 StatCards dalam grid (2 kolom di phone, 4 kolom di tablet):
   - Total Pasien (people icon, #2563EB)
   - Total Transaksi (receipt_long icon, #10B981)
   - Total Debit (credit_card icon, #3B82F6)
   - QRIS/Tunai (payments icon, #F59E0B)

2. Quick Actions row (horizontal scroll):
   - Pasien Baru → navigate ke form
   - Pembayaran → navigate ke payment form
   - Rekam Medis → navigate ke record form
   - Riwayat → switch tab ke payments

3. Aktivitas Terkini (5 hardcoded items):
   - Tiap item memiliki icon, warna, title, subtitle, time (HH:mm format)
   - Container dengan rounded corner, icon badge, text

4. Pull-to-refresh pada seluruh layar

Composable StatCard:
@Composable
fun StatCard(
    title: String,
    value: String,
    icon: ImageVector,
    color: Color,
    subtitle: String
)
- Background: color.copy(alpha = 0.08f)
- Icon badge: color.copy(alpha = 0.12f) rounded
- Value text: bold, 18sp
- Subtitle: 11sp, gray
```

---

### Prompt: Theme & Design System

```text
Untuk project Kotlin "Klinik Merah Putih", buatkan design system Compose lengkap:

1. Color.kt:
val Primary = Color(0xFF2563EB)
val PrimaryLight = Color(0xFF60A5FA)
val PrimaryDark = Color(0xFF1E40AF)
val Success = Color(0xFF10B981)
val Warning = Color(0xFFF59E0B)
val ErrorColor = Color(0xFFEF4444)
val Info = Color(0xFF3B82F6)
val Accent = Color(0xFF7C3AED)
val Neutral = Color(0xFF64748B)

Light: background=#F8FAFC, surface=#FFFFFF, onSurface=#0F172A
Dark: background=#0F172A, surface=#1E293B, onSurface=#FFFFFF

2. Type.kt:
headlineLarge = 28sp, FontWeight.Bold
headlineMedium = 22sp, FontWeight.Bold
titleLarge = 18sp, FontWeight.SemiBold (W600)
bodyLarge = 16sp, FontWeight.Normal
bodyMedium = 14sp, FontWeight.Normal
labelMedium = 12sp, FontWeight.Normal

3. Theme.kt:
@Composable
fun KlinikMerahPutihTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
)
Gunakan MaterialTheme dengan colorScheme light/dark + typography dari atas.

4. Components:
- StatCard.kt (dashboard stat)
- ShimmerCard.kt (loading skeleton)
- StatusBadge.kt (pill badge berwarna)
- PaginatedLazyColumn.kt (infinite scroll wrapper)
```

---

## ✅ Checklist Validasi Output Kotlin

Pastikan output Kotlin memenuhi semua kriteria berikut:

| # | Kriteria | Status |
|---|---|---|
| 1 | Semua warna identik dengan Flutter theme | ☐ |
| 2 | 5 tab bottom navigation berfungsi | ☐ |
| 3 | Login + Register → JWT token tersimpan | ☐ |
| 4 | Pasien CRUD + infinite scroll + search | ☐ |
| 5 | Rekam medis list + form create | ☐ |
| 6 | Pembayaran dengan filter chips | ☐ |
| 7 | QRIS QR code ter-generate | ☐ |
| 8 | Dark/Light theme toggle + persist | ☐ |
| 9 | Regulasi .md viewer | ☐ |
| 10 | ML Export CSV (open browser URL) | ☐ |
| 11 | Logout + konfirmasi dialog | ☐ |
| 12 | Shimmer loading skeleton | ☐ |
| 13 | Pull-to-refresh | ☐ |
| 14 | Currency format Rp Indonesian | ☐ |
| 15 | Error + Empty state handling | ☐ |
| 16 | Build berhasil tanpa error | ☐ |
