# Panduan Lengkap Setup Flutter (Multi-Platform: Android, Windows, Web)

Panduan ini mendokumentasikan langkah demi langkah untuk mengatur lingkungan pengembangan Flutter untuk berbagai platform (Android, Windows Desktop, dan Web), serta panduan penyelesaian masalah umum (troubleshooting), seperti masalah virtualisasi.

> **Tautan Referensi Setup Guide:** [Masukkan Link Di Sini](#)
> 
> **Screenshot Petunjuk Setup:**
> <br>
> <!-- Ganti path di bawah ini dengan path gambar screenshot Anda -->
> ![Screenshot Setup](URL_ATAU_PATH_GAMBAR_SCREENSHOT)

---

## 1. Menjalankan Aplikasi Tanpa Emulator (Windows & Web)
Jika spesifikasi hardware Anda terbatas atau Anda belum dapat mengaktifkan fitur virtualisasi BIOS, menjalankan Flutter sebagai aplikasi Windows atau Web adalah solusi termudah dan jauh lebih ringan.

### A. Kompilasi ke Windows Desktop
1. Pastikan Anda telah menginstal **Visual Studio** dengan komponen (_workload_) "Desktop development with C++".
2. Buka terminal VS Code di dalam direktori project Anda.
3. Jalankan aplikasi menggunakan perintah berikut:
   ```bash
   flutter run -d windows
   ```
4. Atau, pada bagian ujung kanan bawah VS Code (Status Bar), klik *Device Selector* (misal `<No Device>`), pilih **Windows (desktop)**, lalu tekan `F5` atau klik Run/Play.

### B. Kompilasi ke Browser (Google Chrome)
1. Flutter dapat dijalankan sebagai aplikasi web secara instan.
2. Pada terminal jalankan:
   ```bash
   flutter run -d chrome
   ```
3. Atau, pada *Device Selector* di VS Code, ubah target menjadi **Chrome (web)**.

---

## 2. Persiapan Folder Android SDK & Emulator
*(Ikuti langkah di bawah ini jika Anda butuh mencoba aplikasi secara persis pada simulasi sistem operasi Android.)*

Struktur folder adalah aspek paling penting. Jika strukturnya salah, _Flutter_ maupun _VS Code_ tidak akan mendeteksi SDK.

1. Unduh file zip **Android SDK Command-Line Tools**.
2. Buat hierarki folder khusus SDK secara manual:
   `C:\Users\<username>\AppData\Local\Android\Sdk\`
3. Di dalam folder `Sdk`, buat folder bernama `cmdline-tools`, lalu di dalamnya buat lagi folder `latest`.
4. Ekstrak dan **pindahkan semua isi** bawaan awal `cmdline-tools` yang diunduh ke dalam folder `latest` tersebut.

---

## 3. Pengaturan Windows Environment Variables

1. Akses menu pencarian Windows dan ketik **"Edit the system environment variables"**, klik **"Environment Variables..."**.
2. Buat variabel baru di area (_User variables_):
   * **Variable name:** `ANDROID_HOME`
   * **Variable value:** `C:\Users\<username>\AppData\Local\Android\Sdk`
   *(Ganti `<username>` dengan nama user PC Anda).*
3. Cari entri **Path**, lalu klik **Edit**. Tambahkan 3 target baru berikut:
   * `%ANDROID_HOME%\cmdline-tools\latest\bin`
   * `%ANDROID_HOME%\platform-tools`
   * `%ANDROID_HOME%\emulator`
4. Klik **OK** pada semua antarmuka yang ada.

---

## 4. Konfigurasi Flutter CLI & Pembuatan Emulator (AVD)

1. Buka **Terminal Baru** di VS Code, lalu kenalkan folder Android SDK ke dalam Flutter:
   ```bash
   flutter config --android-sdk "C:\Users\<username>\AppData\Local\Android\Sdk"
   ```
2. Setujui secara otomatis seluruh lisensi SDK:
   ```bash
   flutter doctor --android-licenses
   ```
   *(Tekan `y` dan Enter secara proaktif sampai semua disetujui)*
3. Unduh System Image dan komponen pendukungnya (Contoh Android 13 / API 33):
   ```bash
   sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.2" "system-images;android-33;google_apis;x86_64" "emulator"
   ```
4. Rakit mesin virtual Android Virtual Device (AVD):
   ```bash
   avdmanager create avd -n "Pixel_Emulator" -k "system-images;android-33;google_apis;x86_64" --device "pixel"
   ```

---

## 5. Troubleshooting (Penyelesaian Masalah)

### Kasus: `The Android emulator exited with code 1 during startup`
Error ini (yang seringkali diikuti pesan *x86_64 emulation requires hardware acceleration*) terjadi karena komputer/hardware fisik menolak menjalankan mesin simulasi.

**Penyelesaian:**

1. **Virtualisasi Hardware Sengaja Dimatikan dari BIOS (Akar Masalah Terbesar):**
   - **Tindakan:** Mulai ulang (Restart) PC / laptop Anda.
   - Segera sesaat komputer menyala kembali (sebelum OS Windows *loading*), tekan secara terus menerus tombol **F2, F10, F12, Del, atau Esc** untuk membuka menu **BIOS / UEFI System Utility**.
   - Telusuri menu **Advanced**, **System Configuration**, atau **Security**.
   - Cari pilihan konfigurasi bernada: **Intel Virtualization Technology**, **Intel VT-x**, **AMD-V**, atau **Virtualization**.
   - Ubah setelan statusnya menjadi `Enabled`.
   - Tekan F10 untuk menyimpan (*Save and Exit*) dan memulai OS Windows.

2. **Hypervisor Driver Belum Diaktifkan di Windows:**
   - Meskipun BIOS sudah dalam keadaan *Enabled*, kadang-kadang driver *Hyper-V* belum terpasang. Instal driver resmi (AEHD) milik Google untuk emulator ini.
   - Menggunakan terminal PowerShell atau Command Prompt **Sebagai Administrator (Run as Administrator)**, tempel perintah ini:
   ```bash
   "C:\Users\<username>\AppData\Local\Android\Sdk\extras\google\Android_Emulator_Hypervisor_Driver\silent_install.bat"
   ```
   - *Catatan: Untuk driver Windows saat ini, AEHD mensupport otomatis prosesor Intel maupun AMD tanpa menggunakan HAXM.*

### Kasus: `Error: Building with plugins requires symlink support.`
Error ini terjadi saat melakukan _compile_ Flutter ke **Windows Desktop**. Sistem operasi Windows membatasi hak istimewa untuk membuat manipulasi folder *symlink* secara sembarangan guna menghindari virus, sehingga Flutter tidak dapat merakit kode.

**Penyelesaian:**
1. Buka kotak pencarian Windows (Start) lalu ketik dan buka: **Developer settings**.
2. Pada baris tulisan **Developer Mode**, geser _toggle_ / saklar dari Off menjadi **On**.
3. Jika Windows meminta konfirmasi peringatan atau _UAC_, tekan **Yes**.
4. Tutup pengaturan, kembali ke VS Code terminal, dan jalankan lagi `flutter run -d windows` atau klik *Run/Play*.
