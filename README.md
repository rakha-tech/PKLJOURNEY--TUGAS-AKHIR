# PKLJOURNEY

Aplikasi mobile berbasis **Flutter** untuk manajemen, presensi, dan monitoring **Praktik Kerja Lapangan (PKL)** siswa SMK. PKLJOURNEY menghubungkan empat peran utama—**Admin Sekolah**, **Murid**, **Guru Pembimbing**, dan **Mentor IDUKA**—dalam satu alur kerja yang terstruktur.

---

## Fitur Utama per Peran

### 1. Admin Sekolah
- **Dashboard Ringkasan** (`AdminDashboardScreen`): Memantau total akun terdaftar (Guru, Mentor, Murid) dan status penetapan bimbingan.
- **Kelola Akun** (`AdminAccountsScreen`): Mendaftarkan dan menghapus akun Guru (NIP), Murid (NISN), serta mentor IDUKA lengkap dengan data perusahaan dan alamat.
- **Penetapan Bimbingan** (`AdminPlacementScreen`): Menugaskan, memindahkan, atau melepaskan guru pembimbing untuk setiap siswa PKL dengan fitur pencarian dan filter status.

### 2. Murid PKL
- **Dashboard Siswa** (`DashboardScreen`): Menampilkan sapaan harian, ringkasan persentase kehadiran, jumlah jurnal, status presensi hari ini, jurnal terbaru, serta informasi tempat PKL dan mentor IDUKA.
- **Presensi & Foto Kegiatan** (`AttendanceScreen`): Pencatatan presensi masuk dan pulang beserta dokumentasi foto dan riwayat kehadiran.
- **Jurnal Harian** (`JournalScreen`): Mencatat aktivitas harian PKL dengan kategori (*Orientasi*, *Proyek*, *Pembelajaran*, *Kegiatan*).

### 3. Guru Pembimbing
- **Dashboard Pembimbing** (`TeacherDashboardScreen`): Ringkasan jumlah murid bimbingan dan jurnal yang menunggu peninjauan.
- **Murid Bimbingan & Lokasi PKL** (`TeacherStudentsScreen`): Melihat daftar murid yang ditugaskan serta informasi perusahaan/lokasi PKL.
- **Riwayat Kehadiran** (`TeacherAttendanceScreen`): Memantau catatan jam masuk, jam pulang, dan foto bukti presensi murid bimbingan.
- **Review Jurnal** (`TeacherReviewsScreen`): Meninjau jurnal kegiatan harian murid dan memberikan catatan pembimbing.

### 4. Mentor IDUKA (Industri)
- **Konfirmasi Presensi** (`TeacherAttendanceScreen` mode IDUKA): Memverifikasi, menyetujui, atau menolak catatan kehadiran siswa PKL di lokasi industri.
- **Review Jurnal** (`TeacherReviewsScreen`): Memantau dan meninjau laporan kegiatan harian siswa di tempat praktik.

---

## Teknologi yang Digunakan

- **Framework**: Flutter (Dart SDK `^3.14.0`)
- **Backend / BaaS**: `supabase_flutter` (`^2.18.3`)
- **UI & Ikon**: `material_ui` (`^1.1.0`), `cupertino_icons` (`^1.0.8`), serta tema kustom (`AppTheme.light` dengan palet warna *Maroon* & *Cream*).

---

## Struktur Proyek

```text
lib/
├── main.dart                         # Entry point, inisialisasi Supabase, & navigasi berbasis role
├── theme/
│   └── app_theme.dart                # Definisi warna (AppColors) & tema aplikasi (AppTheme)
├── widgets/
│   └── app_widgets.dart              # Komponen UI bersama (BrandMark, WhiteCard, InfoPill, dll.)
└── screens/
    ├── splash_screen.dart            # Layar pembuka animasi
    ├── login_screen.dart             # Layar masuk dengan pilihan cepat akun demo
    ├── profile_screen.dart           # Profil pengguna & aksi keluar (logout)
    ├── dashboard_screen.dart         # Beranda murid
    ├── attendance_screen.dart        # Presensi murid
    ├── journal_screen.dart           # Jurnal kegiatan murid
    ├── admin_dashboard_screen.dart   # Beranda admin
    ├── admin_accounts_screen.dart    # Manajemen akun pengguna
    ├── admin_placement_screen.dart   # Penetapan guru pembimbing siswa
    ├── teacher_dashboard_screen.dart # Beranda guru pembimbing
    ├── teacher_students_screen.dart  # Daftar murid bimbingan & lokasi PKL
    ├── teacher_attendance_screen.dart# Monitoring & konfirmasi presensi
    └── teacher_reviews_screen.dart   # Peninjauan jurnal kegiatan murid
```

---

## Memulai (Getting Started)

### Prasyarat
- Flutter SDK terinstal dan terkonfigurasi (`flutter doctor`)
- Dart SDK `^3.14.0`
- Proyek Supabase aktif (untuk konfigurasi `SUPABASE_URL` dan `SUPABASE_PUBLISHABLE_KEY`)

### Langkah Instalasi

1. **Clone repositori**
   ```bash
   git clone https://github.com/rakha-tech/PKLJOURNEY--TUGAS-AKHIR.git
   cd PKLJOURNEY--TUGAS-AKHIR
   ```

2. **Unduh dependensi**
   ```bash
   flutter pub get
   ```

3. **Konfigurasi Environment**
   Salin file `env.json.example` menjadi `env.json`, lalu sesuaikan nilainya:
   ```bash
   cp env.json.example env.json
   ```
   Isi `env.json`:
   ```json
   {
     "SUPABASE_URL": "https://your-project-id.supabase.co",
     "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_your_key_here"
   }
   ```

4. **Jalankan Aplikasi**
   ```bash
   flutter run --dart-define-from-file=env.json
   ```

---

## Akun Demo (Data Dummy)

Pada layar **Login**, tersedia tombol pilihan cepat untuk mengisi kredensial akun demo masing-masing peran secara otomatis:

| Peran | Username | Password |
| :--- | :--- | :--- |
| **Admin** | `admin` | `123456` |
| **Murid** | `ahmadfauzi` | `123456` |
| **Guru** | `budisantoso` | `123456` |
| **Mentor (IDUKA)** | `hendro_aksara` | `123456` |
