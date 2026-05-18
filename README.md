# Clinic SIPAS (Sistem Informasi Pelayanan Antrian & Sehat)

**Klinik Merah Putih** adalah sistem informasi manajemen klinik modern yang dibangun dengan arsitektur **Node.js (Backend)** dan **Flutter (Mobile Frontend)**, serta menggunakan **Supabase PostgreSQL** sebagai database utama. Aplikasi ini juga telah diintegrasikan dengan teknologi AI (Groq Qwen3-32b) untuk fitur Chatbot.

## 🚀 Fitur Utama
- **Autentikasi Aman:** Menggunakan JWT (JSON Web Tokens) dan enkripsi password menggunakan Bcrypt (SHA-256 Hash).
- **Manajemen Pasien & Rekam Medis:** Pencatatan dan histori rekam medis yang terintegrasi.
- **Antrian & Pembayaran:** Sistem antrian realtime dan manajemen tarif/pembayaran.
- **AI Chatbot (Groq):** Konsultasi pintar terintegrasi dengan model Qwen3-32b dari Groq.
- **Supabase Cloud DB:** Backend terhubung ke Supabase dengan koneksi aman (SSL connection).

## 🛠️ Tech Stack
* **Frontend:** Flutter (Dart), Provider, Dio
* **Backend:** Node.js, Express.js, PostgreSQL (pg-pool)
* **Database:** Supabase PostgreSQL
* **AI:** Groq API (Qwen3-32b)

## 🔒 Security & Data Protection (RSA 256 / SHA)
Data sensitif dalam sistem ini dilindungi melalui beberapa lapisan keamanan:
1. **Password Hashing (SHA/Bcrypt):** Semua password pengguna di-hash dengan Salt (Bcrypt) dan tidak pernah disimpan dalam *plain-text*.
2. **JWT dengan Signature Aman (HS256/RS256):** Token sesi ditandatangani menggunakan *secret key* yang kuat untuk mencegah manipulasi data.
3. **SSL/TLS Encryption:** Koneksi ke database Supabase dan API eksternal menggunakan `rejectUnauthorized: false` (hanya HTTPS/SSL) yang memastikan data yang transit terenkripsi.
4. **Environment Variables:** Semua kunci rahasia (`GROQ_API_KEY`, `DATABASE_URL`, `JWT_SECRET`) disimpan di dalam file `.env` yang secara otomatis di-ignore oleh Git untuk menghindari kebocoran data (*data leak*).

## 🗂️ Panduan Staging & Production
Langkah-langkah untuk melakukan *deploy* dan transisi dari Staging ke Production:

### 1. Staging Phase (Pengujian)
Semua fitur baru harus di-*push* ke branch `staging` terlebih dahulu.
```bash
# Pindah ke branch staging
git checkout staging

# Tambahkan perubahan
git add .

# Commit dengan pesan yang deskriptif
git commit -m "feat: update database configuration to supabase"

# Push ke remote repository (branch staging)
git push origin staging
```
Lakukan *testing* secara menyeluruh di *environment* staging.

### 2. Production Phase (Rilis)
Jika di branch `staging` semua fitur sudah aman dan diuji coba, lakukan *merge* ke branch `main`/`master` untuk *production*.
```bash
# Pindah ke branch utama (main)
git checkout main

# Gabungkan dari staging
git merge staging

# Push ke production
git push origin main
```

---
*Created and maintained by [NoTSureSwann]*
