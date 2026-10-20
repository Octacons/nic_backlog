# Nic-BackLog — Aplikasi Backlog Gaming Pribadi

**Nic-BackLog** adalah aplikasi mobile berbasis Flutter yang dirancang untuk membantu para gamer mencatat, mengelola, dan melacak daftar permainan (_gaming backlog_) pribadi beserta jurnal aktivitas bermain (_game logs_) secara terorganisir.

---

## Fitur Utama

### 1. Autentikasi Pengguna (Auth)

- **Registrasi Akun**: Pendaftaran akun baru menggunakan _username_, _email_, dan _password_.
- **Login Fleksibel**: Masuk ke aplikasi menggunakan _username_ atau _email_.
- **Logout**: Keluar dari sesi pengguna dengan aman.

### 2. Manajemen Backlog Game

- **Daftar Koleksi Game**: Menampilkan daftar game yang dimiliki pengguna lengkap dengan gambar _cover_ rasio 16:9, genre, deskripsi singkat, dan label status.
- **Tambah & Perbarui Game**: Menambahkan game baru atau mengubah informasi game yang sudah ada, meliputi:
  - Judul game (_Title_)
  - Gambar sampul (_Cover Image_) dengan fitur pemotongan otomatis (_crop_ rasio 16:9)
  - Genre permainan
  - Tanggal rilis (_Release Date_)
  - Deskripsi atau catatan singkat
  - Status progres permainan:
    - `PLAYING` — Sedang dimainkan
    - `COMPLETED` — Sudah tamat
    - `BACKLOGGED` — Masuk antrean untuk dimainkan nanti
    - `DROPPED` — Berhenti dimainkan
- **Detail Game**: Melihat informasi lengkap mengenai suatu game beserta rata-rata penilaian (_overall rating_).

### 3. Jurnal & Log Permainan (Game Logs)

- **Catatan Progres Harian**: Mencatat sesi atau progres bermain pada setiap game (misalnya: _"Selesai Chapter 1"_ atau _"Mengalahkan Boss Terakhir"_).
- **Rating Sesi**: Memberikan penilaian (_rating_ skala `1.0 - 5.0`) pada setiap sesi log permainan.
- **Hapus Log dengan Swipe**: Menghapus catatan jurnal dengan gestur _swipe-to-delete_ disertai dialog konfirmasi.

---

## Teknologi & Library yang Digunakan

- **Framework**: [Flutter](https://flutter.dev/) (Dart SDK `^3.11.5`)
- **State Management**: `flutter_bloc` & `equatable` (menggunakan pola **BLoC** dan **Sealed Classes** untuk penanganan _state_ `Initial`, `Loading`, `Success`, dan `Failure` yang aman serta _exhaustive_)
- **Backend & Cloud Services (Firebase)**:
  - `firebase_core` — Inisialisasi layanan Firebase
  - `firebase_auth` — Autentikasi pengguna
  - `cloud_firestore` — Penyimpanan database NoSQL _real-time_ untuk data pengguna, daftar game, dan jurnal permainan
  - `firebase_storage` — Penyimpanan media/gambar sampul game
- **Utilitas & UI Pendukung**:
  - `image_picker` & `image_cropper` — Memilih dan memotong gambar sampul game dengan rasio 16:9
  - `intl` — Pemformatan tanggal

---

## Struktur Folder Proyek

Proyek ini menerapkan pemisahan arsitektur menjadi tiga lapisan utama (**Data**, **Logic/BLoC**, dan **Presentation**):

```text
lib/
├── data/
│   ├── models/                 # Model data (UserModel, GameModel, GameLogModel)
│   └── repositories/           # Komunikasi dengan Firebase Auth & Cloud Firestore
├── logic/
│   ├── auth/                   # AuthBloc, AuthEvent, AuthState (Sealed)
│   ├── game/                   # GameBloc, GameEvent, GameState (Sealed)
│   └── game_log/               # GameLogBloc, GameLogEvent, GameLogState (Sealed)
├── presentation/
│   ├── auth/                   # Layar Login & Register
│   ├── game/                   # Layar Detail Game, Tambah/Edit Game & Jurnal, beserta Widget
│   └── home/                   # Layar Utama (Daftar Backlog Game)
├── utils/
│   └── app_logger.dart         # Utilitas pencatatan log aplikasi
├── firebase_options.dart       # Konfigurasi Firebase
└── main.dart                   # Titik masuk utama aplikasi (Entry Point)
```

---

## Cara Menjalankan Aplikasi

1. **Prasyarat**:
   - Pastikan [Flutter SDK](https://docs.flutter.dev/get-started/install) sudah terpasang.
   - Siapkan perangkat Android/iOS atau emulator.

2. **Unduh Dependensi**:

   ```bash
   flutter pub get
   ```

3. **Konfigurasi Firebase**:
   - Pastikan file konfigurasi Firebase (`google-services.json` pada `android/app/` dan `firebase_options.dart` pada `lib/`) sudah terpasang sesuai dengan proyek Firebase Anda.

4. **Jalankan Aplikasi**:
   ```bash
   flutter run
   ```
