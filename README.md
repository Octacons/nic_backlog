# Nic-BackLog — Aplikasi Backlog Gaming Pribadi

**Nic-BackLog** adalah aplikasi Flutter untuk melakukan pencatatan, pengaturan, serta tracking daftar game (_backlog_) pribadi sekaligus jurnal/catatan progres setiap kali selesai bermain game (_game logs_).

---

## Arsitektur

### 1. Clean Architecture

Project ini menggunakan konsep **Clean Architecture**. Kode dibagi menjadi 3 bagian utama:

- **Data (`lib/data/`)**: Isinya `models` dan `repositories`. Kirim data dan menyimpan data semua dilakukan di folder ini.
- **Logic (`lib/logic/`)**: Isinya BLoC (`event`, `state`, `bloc`) business logic nya di sini.
- **Presentation (`lib/presentation/`)**: Isinya tampilan layar (_screens_) dan komponen UI (_widgets_). Bagian ini nampilin data ke layar dan nerima input dari user.

### 2. Alasan Pakai BLoC (`flutter_bloc`)

Project ini menggunakan **BLoC** untuk _state management_ karena:

- **Maintainable (Gampang Dirawat)**: Kalau mau nambah fitur baru atau benerin bug, cukup cek bagian BLoC atau Repository-nya.
- **Readable (Gampang Dibaca)**: Alur datanya jelas karena menggunakan konsep `Event` (aksi dari user) dan `State` (kondisi layar). Apalagi semua `State` di sini sudah menggunakan `sealed class` (`Initial`, `Loading`, `Success`, `Failure`), jadi dipaksa selalu untuk selalu menghandle kondisi loading, sukses, atau error di UI.
- **Repository Terpisah ke Backend**: BLoC nggak langsung tembak ke Firebase, tapi lewat layer **Repository** (`AuthRepository`, `GameRepository`, `GameLogRepository`) dulu. Jadi penghubung antara Flutter dan backend benar-benar terpisah dan rapi.

---

## Hal Unik di Project Ini (Trik Teknis)

### 1. Simpan Gambar Pakai Base64 (Tanpa Firebase Storage)

Cara penyimpanan gambar cover game di aplikasi ini sedikit berbeda dari biasanya. Karena fitur **Firebase Storage** sekarang berbayar (harus upgrade akun ke _Blaze Plan_), aku nggak pakai Firebase Storage dan menggantinya dengan metode **Base64**:

- Waktu user memilih gambar cover, gambarnya bakal di-crop rasio 16:9 dan dikompres dulu lewat `image_cropper` supaya ukurannya kecil.
- Setelah itu, file gambar diubah (di-_encode_) menjadi string **Base64** (`data:image/jpeg;base64,...`) lalu disimpan langsung sebagai teks di dalam dokumen Cloud Firestore.
- Waktu ditampilkan di layar, string Base64 tadi tinggal di-_decode_ balik jadi gambar lewat `Image.memory`.
- Walaupun nyimpan gambar dalam bentuk Base64 di database sebenarnya kurang efisien dibanding pakai _storage_ khusus file, cara ini tetap berjalan dengan sangat baik dan jadi solusi yang pas buat menghindari fitur berbayar di Firebase.

### 2. Bypass Login Pakai Username di Firebase Auth

Secara bawaan, **Firebase Authentication** sebenarnya cuma mengizinkan login pakai **Email dan Password** (`signInWithEmailAndPassword`), jadi normalnya kita nggak bisa login pakai _username_. Tapi di aplikasi ini, user tetap bisa login pakai _username_ maupun _email_ karena ada sedikit trik _bypass_ di dalam `AuthRepository`:

- **Saat Register**: Waktu user daftar akun, aplikasi ngecek dulu ke koleksi `users` di Firestore buat mastiin _username_-nya belum dipakai orang lain. Setelah akun berhasil dibuat di Firebase Auth pakai email & password, aplikasi langsung nyimpan data `uid`, `username`, dan `email` user tersebut ke koleksi `users` di Firestore.
- **Saat Login**: Aplikasi bakal ngecek teks yang diketik user di kolom login, apakah mengandung karakter `@` atau nggak:
  1. Kalau **ada `@`**, sistem menganggap input itu adalah _email_, jadi langsung dikirim ke `signInWithEmailAndPassword`.
  2. Kalau **nggak ada `@`**, sistem menganggap input itu adalah _username_. Sebelum login ke Firebase Auth, aplikasi bakal nyari (_query_) dulu ke koleksi `users` di Firestore yang punya `username` sama dengan input tadi.
  3. Kalau dokumennya ketemu, aplikasi ngambil data `email` asli milik _username_ tersebut dari Firestore, lalu `email` itulah yang dikirim ke fungsi `signInWithEmailAndPassword` di balik layar. Dengan logika ini, user bisa bebas login cukup ketik _username_ aja.

---

## Penggunaan AI & Implementasi Design System (`DESIGN.md`)

Dalam pembuatan project ini, Saya memanfaatkan **AI** untuk membantu proses _coding_, _refactoring_, sampai penerapan tampilan:

- **Bantuan AI untuk Coding & Arsitektur**: AI dipakai buat bantu ngerapihin struktur _Clean Architecture_, pasang `sealed class` di semua _state_ BLoC, nyelesaiin fitur CRUD (Create, Read, Update, Delete), dan ngecek supaya kodenya bersih dari error.
- **Design System dari Internet (`DESIGN.md`)**:
  - Untuk tampilan UI-nya, aku ambil referensi design system bernama **VoiceBox** dari internet lewat **[designmd.ai/chef/voicebox](https://designmd.ai/chef/voicebox)** dalam bentuk file [`DESIGN.md`](DESIGN.md).
  - Dari file [`DESIGN.md`](DESIGN.md) yang di-download tadi, aku minta bantuan AI buat langsung nerjemahin dan pasang _design system_ tersebut ke dalam kodingan Flutter ([`lib/utils/app_theme.dart`](lib/utils/app_theme.dart)) dan ke semua halaman aplikasi.
  - Hasilnya, aplikasi punya gaya ala majalah editorial dengan warna hitam-putih yang kontras (`#0A0A0A` & `#FAFAFA`), aksen merah (`#EF4444`), bentuk komponen yang kotak tegas tanpa lengkungan (`borderRadius: 0`), dan garis pinggir (`border`) yang tebal.

---

## Fitur Aplikasi

### 1. Autentikasi (Auth)

- **Register**: Daftar akun baru pakai username, email, dan password.
- **Login**: Bisa masuk pakai username atau email.
- **Logout**: Keluar dari akun dengan aman.

### 2. Kelola Backlog Game (CRUD)

- **Lihat Daftar Game**: Nampilin semua game di backlog lengkap dengan gambar cover 16:9, genre, deskripsi singkat, dan statusnya.
- **Tambah & Edit Game**: Bisa tambah game baru atau edit data game yang udah ada (judul, upload & crop cover 16:9, genre, tanggal rilis, deskripsi, dan status: `PLAYING`, `COMPLETED`, `BACKLOGGED`, atau `DROPPED`).
- **Hapus Game**: Hapus game beserta seluruh catatan log di dalamnya lewat dialog konfirmasi.

### 3. Jurnal & Log Permainan (Game Logs — CRUD)

- **Tambah Catatan Main**: Bikin jurnal progres setiap habis main (misalnya: _"Selesai Chapter 1"_ atau _"Tamat"_).
- **Edit & Rating Log**: Bisa edit isi catatan jurnal dan kasih rating sesi dari `1.0` sampai `5.0`.
- **Hapus Log**: Bisa hapus log dengan cara _swipe_ ke kiri di daftar jurnal atau lewat tombol hapus waktu lagi buka halaman edit log.

---

## Teknologi & Package yang Dipakai

- **Flutter** (Dart SDK `^3.11.5`)
- **State Management**: `flutter_bloc` & `equatable`
- **Backend (Firebase)**: `firebase_core`, `firebase_auth`, `cloud_firestore`
- **Design System**: [VoiceBox (`DESIGN.md`)](https://designmd.ai/chef/voicebox)
- **Pendukung Lainnya**: `image_picker`, `image_cropper`, `intl`, `flutter_launcher_icons`

---

## Struktur Folder

```text
lib/
├── data/
│   ├── models/                 # Model data (UserModel, GameModel, GameLogModel)
│   └── repositories/           # Koneksi terpisah ke backend Firebase (Auth, Game, GameLog)
├── logic/
│   ├── auth/                   # AuthBloc, AuthEvent, AuthState (Sealed)
│   ├── game/                   # GameBloc, GameEvent, GameState (Sealed)
│   └── game_log/               # GameLogBloc, GameLogEvent, GameLogState (Sealed)
├── presentation/
│   ├── auth/                   # Halaman Login & Register
│   ├── game/                   # Halaman Detail Game, Tambah/Edit Game & Log, dan Widget
│   └── home/                   # Halaman Utama (Daftar Backlog Game)
├── utils/
│   ├── app_logger.dart         # Logger untuk keperluan debugging
│   └── app_theme.dart          # Tema hasil implementasi dari DESIGN.md (VoiceBox)
├── firebase_options.dart       # Konfigurasi Firebase
└── main.dart                   # Entry point aplikasi
```

---

## Cara Menjalankan Project

1. Pastikan Flutter SDK sudah terinstall di komputer.
2. Jalankan perintah berikut untuk mengambil semua package:
   ```bash
   flutter pub get
   ```
3. Pastikan konfigurasi Firebase (`google-services.json` di `android/app/` dan `firebase_options.dart` di `lib/`) sudah sesuai.
4. Jalankan aplikasi ke emulator atau device:
   ```bash
   flutter run
   ```
