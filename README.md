<p align="center">
  <img src="Rise/assets/Risebg.png" alt="Rise Logo" width="120" />
</p>

<h1 align="center">Rise Finance</h1>

<p align="center">
  <strong>Grow Your Wealth</strong>
</p>

<p align="center">
  Aplikasi manajemen keuangan pribadi yang elegan dan powerful — dibangun dengan Flutter untuk pengalaman cross-platform yang mulus.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Supabase-Cloud-3ECF8E?logo=supabase&logoColor=white" alt="Supabase" />
  <img src="https://img.shields.io/badge/Hive-Local_DB-FFD700?logo=hive&logoColor=black" alt="Hive" />
  <img src="https://img.shields.io/badge/Version-1.0.0-brightgreen" alt="Version" />
  <img src="https://img.shields.io/badge/License-Proprietary-red" alt="License" />
</p>

---

## Daftar Isi

- [Tentang Rise](#tentang-rise)
- [Fitur Utama](#fitur-utama)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Arsitektur](#arsitektur)
- [Struktur Project](#struktur-project)
- [Instalasi & Setup](#instalasi--setup)
- [Alur Penggunaan](#alur-penggunaan)
- [Data Models](#data-models)
- [Pengembangan Selanjutnya](#pengembangan-selanjutnya)
- [Kontributor](#kontributor)

---

## Tentang Rise

**Rise Finance** adalah aplikasi mobile personal finance manager yang dirancang untuk membantu pengguna mengelola keuangan sehari-hari dengan mudah dan intuitif. Dengan antarmuka yang modern dan fitur-fitur canggih seperti scan struk otomatis (OCR), transfer antar akun, dan analitik visual — Rise hadir sebagai solusi lengkap untuk mengontrol pemasukan, pengeluaran, dan pertumbuhan kekayaan.

### Mengapa Rise?

| Masalah | Solusi Rise |
|---------|------------|
| Sulit mencatat pengeluaran harian | Quick action buttons + scan struk otomatis |
| Tidak tahu kemana uang pergi | Analitik visual dengan donut chart per kategori |
| Ribet pindah-pindah saldo akun | Transfer antar akun (Cash, Bank, Digital Wallet) dalam satu tap |
| Data tidak aman | Google Sign-In + PIN & Biometrik |
| Butuh multi-currency | Dukungan IDR & USD dengan konversi otomatis |

---

## Fitur Utama

### Autentikasi & Keamanan
- **Google Sign-In** — Login cepat dan aman menggunakan akun Google melalui Supabase Auth
- **PIN Protection** — Kunci aplikasi dengan PIN 4+ digit
- **Biometric Auth** — Dukungan fingerprint & face ID via `local_auth`
- **Splash Screen** — Video intro yang memukau saat membuka aplikasi

### Dashboard
- Tampilan **net balance** real-time (Income − Expense)
- Ringkasan **income & expense** dalam card visual
- **Quick Actions** — Tambah income, expense, atau transfer dalam satu sentuhan
- Daftar **transaksi hari ini** dengan detail kategori dan waktu

### Manajemen Transaksi
- Tambah transaksi **income** atau **expense** dengan kategori yang sudah tersedia
- **Kalkulator built-in** untuk input jumlah yang mudah
- Pilih akun sumber (Cash, Bank, Digital Wallet)
- Catatan/notes untuk setiap transaksi
- **Hapus transaksi** dengan long-press (otomatis rollback saldo)

### Scan Struk (OCR)
- **Scan struk belanja** menggunakan kamera HP
- Deteksi otomatis jumlah total menggunakan **Google ML Kit Text Recognition**
- Mendukung format angka Indonesia (titik sebagai pemisah ribuan, koma sebagai desimal)
- Keyword detection: "total", "jumlah", "bayar", "tagihan", "grand total"
- Auto-fill ke form transaksi setelah scan berhasil

### Transfer Antar Akun
- Transfer dana antara akun (misal: Cash → Bank)
- **Atomic transaction** — debit & credit tercatat sebagai pasangan
- Validasi saldo, akun aktif, dan limit transfer
- **Idempotency check** untuk mencegah duplikasi transfer
- **Audit logging** untuk setiap transfer yang berhasil maupun gagal

### Analitik & Statistik
- **Donut chart** breakdown per kategori (custom painted)
- Toggle antara tampilan **Expenses** dan **Income**
- Navigasi per bulan (maju/mundur)
- Persentase dan progress bar per kategori
- Top spending categories ranking

### Manajemen Akun
- Akun default otomatis: **Cash**, **Digital Wallet**, **Bank**
- Lihat saldo per akun secara real-time
- Riwayat transaksi per akun

### Pengaturan
- **Pilihan mata uang** — USD ($) atau IDR (Rp) dengan konversi otomatis
- **Feedback** — Kirim masukan langsung via email
- **Help Center** — Hubungi support via email
- **About** — Informasi versi aplikasi
- **Log Out** — Sign out dari akun Google/Supabase

---

## Screenshots

> *Aplikasi menggunakan desain dengan palet warna hijau gelap (#043927) dan aksen lime (#C5F244) yang memberikan kesan premium dan fresh.*

| Login Screen | Dashboard | Analytics |
|:---:|:---:|:---:|
| Background custom + Logo Rise | Balance, Income/Expense cards | Donut chart & categories |

| Scan Receipt | Transfer | Settings |
|:---:|:---:|:---:|
| Kamera OCR auto-detect | Antar akun dengan validasi | Currency, feedback, logout |

---

## Tech Stack

### Framework & Language
| Teknologi | Versi | Kegunaan |
|-----------|-------|----------|
| **Flutter** | 3.x | Cross-platform UI framework |
| **Dart** | ≥3.0.0 | Bahasa pemrograman utama |

### State Management
| Package | Kegunaan |
|---------|----------|
| `provider` ^6.0.0 | Reactive state management |

### Database & Storage
| Package | Kegunaan |
|---------|----------|
| `hive` ^2.2.3 | Database NoSQL lokal (utama) |
| `hive_flutter` ^1.1.0 | Hive integration untuk Flutter |
| `sqflite` ^2.3.0 | SQLite (legacy/backup) |
| `shared_preferences` ^2.2.0 | Key-value storage (PIN, settings) |
| `path_provider` ^2.1.0 | Akses file system path |

### Cloud & Authentication
| Package | Kegunaan |
|---------|----------|
| `supabase_flutter` ^2.12.0 | Backend-as-a-Service (Auth, Database) |
| `google_sign_in` ^6.2.1 | Native Google Sign-In |
| `local_auth` ^2.3.0 | Biometric authentication |

### Camera & AI
| Package | Kegunaan |
|---------|----------|
| `camera` ^0.10.0 | Akses kamera device |
| `image_picker` ^1.0.4 | Ambil foto dari kamera/galeri |
| `google_mlkit_text_recognition` ^0.11.0 | OCR (text extraction dari gambar) |
| `image` ^4.0.17 | Image processing |

### Utilities
| Package | Kegunaan |
|---------|----------|
| `intl` ^0.18.1 | Formatting tanggal & angka |
| `uuid` ^4.0.0 | Generate unique ID untuk transfer |
| `url_launcher` ^6.3.2 | Buka email/URL eksternal |
| `video_player` ^2.8.2 | Video splash screen |

### Dev Dependencies
| Package | Kegunaan |
|---------|----------|
| `hive_generator` ^2.0.1 | Code generation untuk Hive adapters |
| `build_runner` ^2.4.6 | Dart code generator runner |
| `flutter_launcher_icons` ^0.13.1 | Generate app icon otomatis |

---

## Arsitektur

Rise menggunakan arsitektur **Provider Pattern** yang sederhana namun scalable:

```
┌─────────────────────────────────────────────────┐
│                    UI Layer                      │
│  (Screens: Dashboard, Analytics, Settings, dll)  │
├─────────────────────────────────────────────────┤
│                Provider Layer                    │
│  Repository │ SecurityProvider │ CurrencyProvider │
├─────────────────────────────────────────────────┤
│               Service Layer                      │
│     TransferService │ OcrService │ AuditLogger    │
├─────────────────────────────────────────────────┤
│                Data Layer                        │
│        Hive Boxes │ Supabase │ SharedPrefs        │
└─────────────────────────────────────────────────┘
```

### Alur Data

1. **UI** memanggil method pada **Provider/Repository**
2. **Repository** melakukan operasi CRUD pada **Hive Box** (local database)
3. **Repository** memanggil `notifyListeners()` untuk update UI secara reaktif
4. **Service layer** (TransferService, OcrService) menangani logika bisnis kompleks
5. **Supabase** digunakan untuk autentikasi cloud (Google Sign-In)

---

## Struktur Project

```
Rise/
├── android/                    # Android platform files
├── ios/                        # iOS platform files
├── web/                        # Web platform files
├── windows/                    # Windows platform files
├── linux/                      # Linux platform files
├── macos/                      # macOS platform files
│
├── assets/
│   ├── icon/                   # App icon files
│   ├── intro.mp4               # Video splash screen
│   ├── Background.png          # Login screen background
│   └── Risebg.png              # Rise logo
│
├── Montserrat/                 # Font keluarga Montserrat
│   └── static/
│       ├── Montserrat-ExtraBold.ttf
│       ├── Montserrat-Bold.ttf
│       └── Montserrat-Medium.ttf
│
├── lib/
│   ├── main.dart               # Entry point — setup Supabase, Hive, Providers
│   ├── models.dart             # Data models (Account, Category, MoneyTransaction, dll)
│   ├── models.g.dart           # Generated Hive adapters (auto-generated)
│   ├── repository.dart         # Repository pattern — CRUD operations via Hive
│   ├── db.dart                 # Legacy SQLite database helper
│   ├── theme.dart              # App theme configuration (Material 3)
│   ├── security_provider.dart  # PIN & biometric auth management
│   ├── currency_provider.dart  # Currency switching (IDR/USD) & formatting
│   ├── transfer_service.dart   # Atomic transfer logic & idempotency
│   ├── audit_logger.dart       # Audit trail logging for transfers
│   ├── ocr_service.dart        # OCR receipt scanning & text analysis
│   │
│   └── screens/
│       ├── splash_screen.dart          # Video intro splash screen
│       ├── login_screen.dart           # Google Sign-In login page
│       ├── onboarding.dart             # First-time setup wizard
│       ├── pin_setup.dart              # PIN creation screen
│       ├── lock_screen.dart            # App lock screen (PIN/biometric)
│       ├── home.dart                   # Main navigation (bottom nav bar)
│       ├── dashboard.dart              # Dashboard utama (balance, transactions)
│       ├── add_transaction.dart        # Form tambah transaksi
│       ├── add_transaction_calculator.dart  # Kalkulator input jumlah
│       ├── analytics.dart              # Analitik & donut chart
│       ├── statistics_analysis.dart    # Statistik tambahan
│       ├── calendar_dashboard.dart     # Kalender transaksi
│       ├── accounts.dart               # Daftar & detail akun
│       ├── transfer_screen.dart        # Transfer antar akun
│       ├── scan_receipt_screen.dart     # Kamera OCR scan struk
│       ├── settings.dart               # Halaman pengaturan
│       └── security_settings.dart      # Pengaturan keamanan
│
├── test/                       # Unit & widget tests
├── pubspec.yaml                # Dependencies & configuration
├── pubspec.lock                # Locked dependency versions
├── analysis_options.yaml       # Dart analyzer rules
└── Rise.png                    # App promotional image
```

---

## Instalasi & Setup

### Prasyarat

- **Flutter SDK** ≥ 3.0.0 ([Instalasi Flutter](https://flutter.dev/docs/get-started/install))
- **Android Studio** / **VS Code** dengan Flutter extension
- **Device fisik** atau **emulator** yang sudah terkoneksi
- **JDK** 11+ (untuk build Android)

### Langkah Instalasi

```powershell
# 1. Clone repository
git clone https://github.com/Alistaire-Q/Rise.git

# 2. Masuk ke direktori project
cd Rise

# 3. Install dependencies
flutter pub get

# 4. Generate Hive adapters (jika models.g.dart belum ada/outdated)
dart run build_runner build --delete-conflicting-outputs

# 5. Generate app icon (opsional, jika ingin update icon)
dart run flutter_launcher_icons

# 6. Jalankan aplikasi
flutter run
```

### Konfigurasi Tambahan

#### Supabase (Sudah dikonfigurasi)
Project ini sudah terhubung ke instance Supabase. Jika ingin menggunakan instance sendiri, update kredensial di [`lib/main.dart`](Rise/lib/main.dart):

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_ANON_KEY',
);
```

#### Google Sign-In
OAuth Client ID sudah dikonfigurasi di [`lib/screens/login_screen.dart`](Rise/lib/screens/login_screen.dart). Untuk menggunakan akun Google Cloud sendiri:
1. Buat project di [Google Cloud Console](https://console.cloud.google.com/)
2. Enable Google Sign-In API
3. Buat OAuth 2.0 Client ID (Web Application)
4. Update `webClientId` di `login_screen.dart`

---

## Alur Penggunaan

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Splash      │ ──► │  Login       │ ──► │  Home        │
│  (Video)     │     │  (Google)    │     │  (Dashboard) │
└──────────────┘     └──────────────┘     └──────┬───────┘
                                                  │
                          ┌───────────────────────┼───────────────────────┐
                          │                       │                       │
                   ┌──────▼──────┐        ┌──────▼──────┐        ┌──────▼──────┐
                   │  Analytics  │        │  Scan       │        │  Accounts   │
                   │  (Charts)   │        │  (Camera)   │        │  (Wallet)   │
                   └─────────────┘        └──────┬──────┘        └─────────────┘
                                                  │
                                          ┌──────▼──────┐
                                          │  Add        │
                                          │  Transaction│
                                          └─────────────┘
```

1. **Splash Screen** — Video intro Rise saat pertama buka
2. **Login** — Autentikasi dengan Google account
3. **Dashboard** — Lihat ringkasan keuangan & transaksi terbaru
4. **Quick Actions** — Tambah income/expense/transfer dengan cepat
5. **Scan Receipt** — Foto struk, OCR otomatis detect jumlah
6. **Analytics** — Lihat breakdown pengeluaran/pemasukan per kategori
7. **Accounts** — Kelola akun dan lihat saldo
8. **Settings** — Atur mata uang, kirim feedback, log out

---

## Data Models

### Account
| Field | Type | Keterangan |
|-------|------|------------|
| `id` | `int?` | Primary key (auto-assigned by Hive) |
| `name` | `String` | Nama akun (Cash, Bank, Digital Wallet) |
| `balance` | `double` | Saldo saat ini |
| `isActive` | `bool` | Status aktif akun |
| `createdAt` | `DateTime?` | Waktu pembuatan |

### MoneyTransaction
| Field | Type | Keterangan |
|-------|------|------------|
| `id` | `int?` | Primary key |
| `amount` | `double` | Jumlah transaksi |
| `type` | `TransactionType` | income / expense / transfer |
| `accountId` | `int` | Akun sumber |
| `categoryId` | `int?` | Kategori transaksi |
| `targetAccountId` | `int?` | Akun tujuan (untuk transfer) |
| `date` | `DateTime?` | Tanggal transaksi |
| `notes` | `String?` | Catatan |
| `transferId` | `String?` | UUID untuk pasangan transfer |
| `status` | `TransactionStatus` | pending / completed / failed / cancelled |

### Category
| Field | Type | Keterangan |
|-------|------|------------|
| `id` | `int?` | Primary key |
| `name` | `String` | Nama kategori |
| `icon` | `String?` | Icon identifier |

### Kategori Default

**Expense:** Food, Transportation, Healthcare, Shopping, Other Expense

**Income:** Salary, Freelance, Gift, Investment, Other Income

---

## Pengembangan Selanjutnya

- [ ] **Recurring Transactions** — Transaksi berulang (langganan, gaji bulanan)
- [ ] **Cloud Sync** — Sinkronisasi data ke Supabase / Firebase
- [ ] **Export Data** — Ekspor ke CSV / Excel / PDF
- [ ] **Charts Lanjutan** — Bar chart, line chart untuk tren bulanan
- [ ] **Web Dashboard** — Dashboard berbasis web untuk monitoring
- [ ] **Encrypted Storage** — Upgrade dari SharedPreferences ke flutter_secure_storage
- [ ] **Custom Categories** — Kategori buatan user dengan icon pilihan
- [ ] **Live Exchange Rate** — Kurs mata uang real-time dari API
- [ ] **Widget Home Screen** — Widget ringkasan saldo di home screen Android/iOS
- [ ] **Dark Mode** — Tema gelap untuk penggunaan malam hari

---

## Kontributor

<table>
  <tr>
    <td align="center">
      <strong>Rise Team</strong><br/>
      <sub>qolbysumarrasatriawan@gmail.com</sub>
    </td>
  </tr>
</table>

---

<p align="center">
  <strong>Rise Finance</strong> — <em>Grow Your Wealth</em>
</p>

<p align="center">
  © 2025 Rise App. All rights reserved.
</p>
