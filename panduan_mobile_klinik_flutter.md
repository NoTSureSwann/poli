# 📱 PANDUAN LENGKAP MOBILE PROGRAMMING (FLUTTER)

## Aplikasi Klinik & Poli fitur — Flutlab.io + Supabase (2026)

### Disesuaikan dengan panduan agentic IDE antigravity + compatible for Flutlab.io on platform web

---

## 📋 DAFTAR ISI

1. [Persiapan Environment Flutlab.io & VSCode](#1-persiapan-environment)
2. [Setup Project Flutter untuk Flutlab.io](#2-setup-project-flutter)
3. [Struktur Folder Project Klinik (Dart)](#3-struktur-folder-project-klinik)
4. [Setup Backend API (Supabase)](#4-setup-backend-api-supabase)
5. [Pengujian API dengan Supabase API URL](#5-pengujian-api-dengan-supabase)
6. [Prompt Text untuk Fitur Klinik & Poli (Flutter)](#6-prompt-text-untuk-fitur-klinik--poli)
7. [Free Token AI API — Integrasi Gemini di Flutter](#7-free-token-ai-api)
8. [Free API — Alternatif MockAPI.io](#8-free-api-mockapiio)

---

## 1. PERSIAPAN ENVIRONMENT

### 1.1 Menggunakan Flutlab.io (Web IDE)
FlutLab.io adalah IDE berbasis web yang sangat cocok untuk Flutter. Tidak perlu instalasi SDK lokal.
1. Buka [FlutLab.io](https://flutlab.io) dan buat akun (gratis).
2. Di Dashboard, Anda bisa langsung membuat project baru, menulis kode, dan melihat preview di web emulator secara real-time.

### 1.2 Instalasi Agentic IDE (VSCode lokal - Opsional)
Jika ingin mendevelop secara lokal:
1. Install Flutter SDK dari situs resmi Flutter.
2. Buka VSCode dan install ekstensi wajib:
   - **Flutter** (Otomatis menginstal ekstensi Dart)
   - **Awesome Flutter Snippets** (Snippet cepat untuk Flutter)
   - **Prettier / Dart Formatter** (Format kode otomatis)
   - **Thunder Client** (Testing API)
   - **GitLens** (Manajemen Git)

---

## 2. SETUP PROJECT FLUTTER UNTUK FLUTLAB.IO

### 2.1 Buat Project Baru
**Di FlutLab.io:**
1. Klik tombol **+ New Project**.
2. Pilih template **Flutter Hello World**.
3. Beri nama `klinik_app` dan klik **Create**.

**Di Lokal (CLI):**
```bash
flutter create klinik_app
cd klinik_app
```

### 2.2 Konfigurasi `pubspec.yaml`
Tambahkan library/dependencies penting untuk aplikasi klinik. Di FlutLab, buka file `pubspec.yaml` dan tambahkan:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Backend / API
  supabase_flutter: ^2.0.0
  http: ^1.2.0
  
  # State Management & Navigasi
  provider: ^6.1.1
  go_router: ^13.2.0
  
  # UI Components & Icons
  google_fonts: ^6.1.0
  font_awesome_flutter: ^10.7.0
  intl: ^0.19.0 # Untuk format tanggal & uang
  
  # AI Integration
  google_generative_ai: ^0.2.2
```
Setelah itu jalankan `flutter pub get` (Di FlutLab biasanya berjalan otomatis saat file disimpan).

---

## 3. STRUKTUR FOLDER PROJECT KLINIK

Di dalam folder `lib/`, buat struktur seperti ini agar rapi dan scalable:

```text
lib/
├── screens/              ← Halaman-halaman utama
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── daftar_poli_screen.dart
│   ├── pendaftaran_screen.dart
│   ├── antrian_screen.dart
│   ├── riwayat_pasien_screen.dart
│   └── profil_screen.dart
├── widgets/              ← Komponen UI reusable
│   ├── card_poli.dart
│   ├── card_antrian.dart
│   ├── header_klinik.dart
│   └── loading_spinner.dart
├── services/             ← Koneksi ke API & Supabase
│   ├── supabase_service.dart
│   └── ai_service.dart
├── models/               ← Class / Entity data
│   ├── poli_model.dart
│   ├── dokter_model.dart
│   └── antrian_model.dart
├── providers/            ← State management
│   └── auth_provider.dart
├── utils/                ← Helper functions (konversi tanggal, dll)
│   ├── constants.dart
│   └── helpers.dart
└── main.dart             ← Entry point aplikasi
```

---

## 4. SETUP BACKEND API (SUPABASE)

Sebagai pengganti Express.js/Node.js, kita menggunakan Supabase (Firebase Alternative open-source dengan PostgreSQL bawaan).

### 4.1 Persiapan Supabase
1. Daftar di [Supabase](https://supabase.com/).
2. Buat Project Baru (misal: `klinik-db`).
3. Masuk ke **Project Settings -> API** untuk mendapatkan `Project URL` dan `anon/public Key`.

### 4.2 Inisialisasi Supabase di Flutter (`main.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Ganti dengan URL dan Anon Key dari dashboard Supabase Anda
  await Supabase.initialize(
    url: 'https://xyzcompany.supabase.co',
    anonKey: 'public-anon-key',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Klinik App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
    );
  }
}
```

### 4.3 Contoh Database Tables di Supabase (SQL Editor)
Jalankan query ini di SQL Editor Supabase untuk membuat tabel:

```sql
-- Tabel Poli
CREATE TABLE poli (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  nama_poli TEXT NOT NULL,
  deskripsi TEXT,
  jam_buka TIME,
  jam_tutup TIME
);

-- Tabel Antrian
CREATE TABLE antrian (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  pasien_id UUID REFERENCES auth.users(id),
  poli_id UUID REFERENCES poli(id),
  tanggal DATE NOT NULL,
  keluhan TEXT,
  nomor_antrian INTEGER,
  status TEXT DEFAULT 'menunggu'
);
```

---

## 5. PENGUJIAN API DENGAN SUPABASE

Supabase secara otomatis membuatkan REST API untuk setiap tabel. Anda bisa mengujinya langsung dari Postman, Thunder Client, maupun membaca dokumentasi API otomatis di Dashboard Supabase (menu **API Docs**).

### 5.1 Endpoint API Supabase (REST API Mode)
**Base URL:** `https://<PROJECT_REF>.supabase.co/rest/v1`
**Headers Wajib:**
- `apikey`: `<ANON_KEY>`
- `Authorization`: `Bearer <ANON_KEY>` (atau Bearer Token User jika RLS aktif)

| Aksi | Method | Endpoint | Deskripsi |
|---|---|---|---|
| Get Semua Poli | GET | `/poli?select=*` | Mengambil daftar poli |
| Daftar Antrian | POST | `/antrian` | Tambah antrian baru |
| Antrian Saya | GET | `/antrian?pasien_id=eq.<USER_ID>` | Filter antrian pasien spesifik |

### 5.2 Contoh Request Fetch di Flutter (`services/supabase_service.dart`)

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<List<dynamic>> getDaftarPoli() async {
    try {
      final data = await supabase.from('poli').select();
      return data;
    } catch (e) {
      print('Error fetch poli: $e');
      return [];
    }
  }
  
  Future<void> daftarAntrian(String poliId, String keluhan) async {
    final userId = supabase.auth.currentUser?.id;
    await supabase.from('antrian').insert({
      'pasien_id': userId,
      'poli_id': poliId,
      'keluhan': keluhan,
      'tanggal': DateTime.now().toIso8601String(),
    });
  }
}
```

---

## 6. PROMPT TEXT UNTUK FITUR KLINIK & POLI (FLUTTER)

> Gunakan prompt berikut pada AI (seperti Gemini, Claude, atau ChatGPT) untuk membantu Anda men-generate kode Flutter di FlutLab.

**Prompt — Buat Screen Daftar Poli:**
```text
Buatkan widget UI Flutter (StatelessWidget) untuk halaman Daftar Poli klinik dengan fitur:
- ListView.builder menampilkan daftar poli (nama, ikon, jam buka).
- Search bar (TextField) di bagian atas untuk filter poli.
- FutureBuilder untuk menangani loading state saat fetch data dari Supabase.
- Tampilkan CircularProgressIndicator saat loading, dan Text error jika gagal.
- Gunakan Card widget dengan UI yang modern.
Sertakan kode lengkap beserta import package-nya.
```

**Prompt — Buat Form Pendaftaran Antrian:**
```text
Buatkan form pendaftaran antrian di Flutter (StatefulWidget) menggunakan Form widget dengan field:
- DropdownButtonFormField untuk pilih poli.
- TextFormField untuk keluhan (minimal 10 karakter, gunakan validator bawaan form).
- Tampilkan date picker (showDatePicker) untuk pilih tanggal kunjungan (minimal besok).
- Tombol Submit yang memanggil Supabase insert dan menampilkan SnackBar sukses.
```

**Prompt — Buat Halaman Riwayat Pasien:**
```text
Buatkan halaman riwayat kunjungan pasien di Flutter:
- Gunakan ListView.builder dengan data dari Supabase (asumsikan fetch dari tabel antrian).
- Setiap item menampilkan: tanggal, nama poli, dan status (Selesai/Menunggu).
- Berikan warna background Container/Card untuk status yang berbeda (Hijau=Selesai, Kuning=Menunggu, Merah=Batal).
- Implementasikan RefreshIndicator untuk pull-to-refresh data terbaru.
```

---

## 7. FREE TOKEN AI API — INTEGRASI GEMINI DI FLUTTER

### 7.1 Setup Gemini di Flutter
Gunakan package `google_generative_ai` untuk mengintegrasikan Chatbot AI Klinik (tanpa biaya cloud / free tier).

**File: `services/ai_service.dart`**
```dart
import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  // Dapatkan API Key gratis di https://aistudio.google.com/
  static const _apiKey = 'API_KEY_GEMINI_ANDA';
  
  static const _systemPrompt = '''
Kamu adalah asisten virtual Klinik Sehat.
Bantu pasien dengan informasi poli, cara daftar, dan saran umum kesehatan.
Jangan berikan diagnosa medis. Jawab dalam Bahasa Indonesia yang ramah.
Batasi jawaban maksimal 150 kata untuk hemat token.
''';

  Future<String> chatKlinik(String pesanPasien) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash', // Model gratis tercepat
      apiKey: _apiKey,
      systemInstruction: Content.system(_systemPrompt),
    );

    try {
      final response = await model.generateContent([Content.text(pesanPasien)]);
      return response.text ?? "Maaf, saya tidak mengerti.";
    } catch (e) {
      return "Error: Layanan AI sementara tidak tersedia.";
    }
  }
}
```

---

## 8. FREE API — ALTERNATIF MOCKAPI.IO

Jika Anda belum ingin menggunakan Supabase dan hanya butuh dummy API (Mock) JSON gratis yang sangat cepat, gunakan **MockAPI.io**.

### 8.1 Cara Menggunakan MockAPI:
1. Buka [https://mockapi.io/](https://mockapi.io/).
2. Login dan buat Project baru.
3. Buat resource baru bernama `poli` dan atur propertinya (misal: `nama_poli`, `deskripsi`).
4. Generate 10 data otomatis dari dashboard MockAPI.
5. Anda akan mendapatkan URL seperti: `https://69f7826cdd0c226688edc6e7.mockapi.io/poli`

### 8.2 Cara Fetch Data di Flutter (Menggunakan package `http`)
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> fetchPoliMock() async {
  final url = Uri.parse('https://69f7826cdd0c226688edc6e7.mockapi.io/poli');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return json.decode(response.body); // Mengembalikan List of Map
  } else {
    throw Exception('Gagal mengambil data poli');
  }
}
```
