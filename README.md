<p align="center">
  <img src="Rise/assets/Risebg.png" alt="Rise Logo" width="120" />
</p>

<h1 align="center">Rise Finance</h1>

<p align="center">
  <strong>Grow Your Wealth</strong>
</p>

<p align="center">
  An elegant and powerful personal finance management application — built with Flutter for a seamless cross-platform experience.
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter" /></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart" /></a>
  <a href="https://supabase.com"><img src="https://img.shields.io/badge/Supabase-Cloud-3ECF8E?logo=supabase&logoColor=white" alt="Supabase" /></a>
  <a href="https://pub.dev/packages/hive"><img src="https://img.shields.io/badge/Hive-Local_DB-FFD700?logo=hive&logoColor=black" alt="Hive" /></a>
  <img src="https://img.shields.io/badge/Version-1.0.0-brightgreen" alt="Version" />
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT" /></a>
  <a href="https://github.com/Alistaire-Q/Rise/actions"><img src="https://github.com/Alistaire-Q/Rise/actions/workflows/flutter.yml/badge.svg" alt="Flutter CI" /></a>
</p>

---

## Table of Contents

- [About Rise](#about-rise)
- [Key Features](#key-features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Installation & Setup](#installation--setup)
- [User Flow](#user-flow)
- [Data Models](#data-models)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)
- [Contributors](#contributors)

---

## About Rise

**Rise Finance** is a mobile personal finance manager designed to help users manage their daily finances easily and intuitively. 

> **Developer Note:** While it serves as a practical utility app, Rise is also designed to be an **excellent learning resource and boilerplate** for developers. It demonstrates a clean architecture implementation using the **Provider pattern**, offline-first approach with **Hive**, cloud authentication via **Supabase**, and real-world ML integration using **Google ML Kit** for OCR. We welcome developers of all skill levels to explore, learn from, and contribute to this codebase!

### Why Rise?

| Problem | Rise Solution |
|---------|------------|
| Hard to track daily expenses | Quick action buttons + automatic receipt scanning |
| Don't know where the money goes | Visual analytics with donut charts per category |
| Cumbersome to move account balances | Inter-account transfers (Cash, Bank, Digital Wallet) in one tap |
| Data is not secure | Google Sign-In for cloud authentication |
| Need multi-currency support | Supports IDR & USD with automatic conversion |

---

## Key Features

### Authentication & Security
- **Google Sign-In** — Fast and secure login using a Google account via Supabase Auth
- **Splash Screen** — Stunning video intro upon opening the app

### Dashboard
- Real-time **net balance** display (Income − Expense)
- **Income & expense** summary in visual cards
- **Quick Actions** — Add income, expense, or transfer with a single touch
- List of **today's transactions** with detailed categories and time

### Transaction Management
- Add **income** or **expense** transactions with preset categories
- **Built-in calculator** for easy amount input
- Select source account (Cash, Bank, Digital Wallet)
- Notes for each transaction
- **Delete transaction** via long-press (automatic balance rollback)

### Receipt Scanner (OCR)
- **Scan shopping receipts** using the phone's camera
- Automatic detection of total amount using **Google ML Kit Text Recognition**
- Supports Indonesian number format (dot as thousands separator, comma as decimal)
- Keyword detection: "total", "jumlah", "bayar", "tagihan", "grand total"
- Auto-fill transaction form upon successful scan

### Inter-Account Transfers
- Transfer funds between accounts (e.g., Cash → Bank)
- **Atomic transactions** — debit & credit are recorded as a pair
- Validation for balance, active accounts, and transfer limits
- **Idempotency checks** to prevent duplicate transfers
- **Audit logging** for every successful and failed transfer

### Analytics & Statistics
- **Donut chart** breakdown per category (custom painted)
- Toggle between **Expenses** and **Income** views
- Month-by-month navigation (forward/backward)
- Percentage and progress bar per category
- Top spending categories ranking

### Account Management
- Automatic default accounts: **Cash**, **Digital Wallet**, **Bank**
- View real-time balances per account
- Transaction history per account

### Settings
- **Currency options** — USD ($) or IDR (Rp) with automatic conversion
- **Feedback** — Send feedback directly via email
- **Help Center** — Contact support via email
- **About** — App version information
- **Log Out** — Sign out from Google/Supabase account

---

## Screenshots

> *The app uses a dark green (#043927) color palette with lime accents (#C5F244) to provide a premium and fresh look.*

| Login Screen | Dashboard | Analytics |
|:---:|:---:|:---:|
| Custom background + Rise Logo | Balance, Income/Expense cards | Donut chart & categories |

| Scan Receipt | Transfer | Settings |
|:---:|:---:|:---:|
| OCR auto-detect camera | Inter-account with validation | Currency, feedback, logout |

---

## Tech Stack

### Framework & Language
| Technology | Version | Purpose |
|-----------|-------|----------|
| **Flutter** | 3.x | Cross-platform UI framework |
| **Dart** | ≥3.0.0 | Primary programming language |

### State Management
| Package | Purpose |
|---------|----------|
| `provider` ^6.0.0 | Reactive state management |

### Database & Storage
| Package | Purpose |
|---------|----------|
| `hive` ^2.2.3 | Local NoSQL database (primary) |
| `hive_flutter` ^1.1.0 | Hive integration for Flutter |
| `sqflite` ^2.3.0 | SQLite (legacy/backup) |
| `shared_preferences` ^2.2.0 | Key-value storage (PIN, settings) |
| `path_provider` ^2.1.0 | File system path access |

### Cloud & Authentication
| Package | Purpose |
|---------|----------|
| `supabase_flutter` ^2.12.0 | Backend-as-a-Service (Auth, Database) |
| `google_sign_in` ^6.2.1 | Native Google Sign-In |

### Camera & AI
| Package | Purpose |
|---------|----------|
| `camera` ^0.10.0 | Device camera access |
| `image_picker` ^1.0.4 | Pick images from camera/gallery |
| `google_mlkit_text_recognition` ^0.11.0 | OCR (text extraction from images) |
| `image` ^4.0.17 | Image processing |

### Utilities
| Package | Purpose |
|---------|----------|
| `intl` ^0.18.1 | Date & number formatting |
| `uuid` ^4.0.0 | Generate unique IDs for transfers |
| `url_launcher` ^6.3.2 | Open email/external URLs |
| `video_player` ^2.8.2 | Video splash screen |

### Dev Dependencies
| Package | Purpose |
|---------|----------|
| `hive_generator` ^2.0.1 | Code generation for Hive adapters |
| `build_runner` ^2.4.6 | Dart code generator runner |
| `flutter_launcher_icons` ^0.13.1 | Automated app icon generation |

---

## Architecture

Rise uses the **Provider Pattern** architecture, which is simple yet scalable:

```
┌─────────────────────────────────────────────────┐
│                    UI Layer                      │
│  (Screens: Dashboard, Analytics, Settings, etc.) │
├─────────────────────────────────────────────────┤
│                Provider Layer                    │
│         Repository │ CurrencyProvider             │
├─────────────────────────────────────────────────┤
│               Service Layer                      │
│     TransferService │ OcrService │ AuditLogger    │
├─────────────────────────────────────────────────┤
│                Data Layer                        │
│        Hive Boxes │ Supabase │ SharedPrefs        │
└─────────────────────────────────────────────────┘
```

### Data Flow

1. **UI** calls methods on the **Provider/Repository**
2. **Repository** performs CRUD operations on the **Hive Box** (local database)
3. **Repository** calls `notifyListeners()` to update the UI reactively
4. **Service layer** (TransferService, OcrService) handles complex business logic
5. **Supabase** is used for cloud authentication (Google Sign-In)

---

## Project Structure

```text
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
├── Montserrat/                 # Montserrat font family
│   └── static/
│       ├── Montserrat-ExtraBold.ttf
│       ├── Montserrat-Bold.ttf
│       └── Montserrat-Medium.ttf
│
├── lib/
│   ├── main.dart               # Entry point — setup Supabase, Hive, Providers
│   ├── models.dart             # Data models (Account, Category, MoneyTransaction, etc.)
│   ├── models.g.dart           # Generated Hive adapters (auto-generated)
│   ├── repository.dart         # Repository pattern — CRUD operations via Hive
│   ├── db.dart                 # Legacy SQLite database helper
│   ├── theme.dart              # App theme configuration (Material 3)
│   ├── currency_provider.dart  # Currency switching (IDR/USD) & formatting
│   ├── transfer_service.dart   # Atomic transfer logic & idempotency
│   ├── audit_logger.dart       # Audit trail logging for transfers
│   ├── ocr_service.dart        # OCR receipt scanning & text analysis
│   │
│   └── screens/
│       ├── splash_screen.dart          # Video intro splash screen
│       ├── login_screen.dart           # Google Sign-In login page
│       ├── onboarding.dart             # First-time setup wizard
│       ├── home.dart                   # Main navigation (bottom nav bar)
│       ├── dashboard.dart              # Main dashboard (balance, transactions)
│       ├── add_transaction.dart        # Add transaction form
│       ├── add_transaction_calculator.dart  # Input amount calculator
│       ├── analytics.dart              # Analytics & donut chart
│       ├── statistics_analysis.dart    # Additional statistics
│       ├── calendar_dashboard.dart     # Transaction calendar
│       ├── accounts.dart               # Account list & details
│       ├── transfer_screen.dart        # Inter-account transfer
│       ├── scan_receipt_screen.dart     # OCR camera receipt scanner
│       └── settings.dart               # Settings page
│
├── test/                       # Unit & widget tests
├── pubspec.yaml                # Dependencies & configuration
├── pubspec.lock                # Locked dependency versions
├── analysis_options.yaml       # Dart analyzer rules
└── Rise.png                    # App promotional image
```

---

## Installation & Setup

### Prerequisites

- **Flutter SDK** ≥ 3.0.0 ([Flutter Installation](https://flutter.dev/docs/get-started/install))
- **Android Studio** / **VS Code** with Flutter extension
- **Physical device** or **emulator** connected
- **JDK** 11+ (for Android build)

### Installation Steps

```bash
# 1. Clone repository
git clone https://github.com/Alistaire-Q/Rise.git

# 2. Enter project directory
cd Rise

# 3. Install dependencies
flutter pub get

# 4. Generate Hive adapters (if models.g.dart is missing/outdated)
dart run build_runner build --delete-conflicting-outputs

# 5. Generate app icon (optional, to update the icon)
dart run flutter_launcher_icons

# 6. Run the application
flutter run
```

### Additional Configuration

#### Supabase (Pre-configured)
This project is already connected to a Supabase instance. If you want to use your own instance, update the credentials in [`lib/main.dart`](Rise/lib/main.dart):

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_ANON_KEY',
);
```

#### Google Sign-In
OAuth Client ID is pre-configured in [`lib/screens/login_screen.dart`](Rise/lib/screens/login_screen.dart). To use your own Google Cloud account:
1. Create a project in the [Google Cloud Console](https://console.cloud.google.com/)
2. Enable Google Sign-In API
3. Create OAuth 2.0 Client ID (Web Application)
4. Update `webClientId` in `login_screen.dart`

---

## User Flow

```text
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

1. **Splash Screen** — Rise video intro upon first launch
2. **Login** — Authenticate with Google account
3. **Dashboard** — View financial summary & latest transactions
4. **Quick Actions** — Quickly add income/expense/transfer
5. **Scan Receipt** — Photo receipt, automatic OCR detects amount
6. **Analytics** — View expense/income breakdown per category
7. **Accounts** — Manage accounts and view balances
8. **Settings** — Set currency, send feedback, log out

---

## Data Models

### Account
| Field | Type | Description |
|-------|------|------------|
| `id` | `int?` | Primary key (auto-assigned by Hive) |
| `name` | `String` | Account name (Cash, Bank, Digital Wallet) |
| `balance` | `double` | Current balance |
| `isActive` | `bool` | Active status of the account |
| `createdAt` | `DateTime?` | Creation time |

### MoneyTransaction
| Field | Type | Description |
|-------|------|------------|
| `id` | `int?` | Primary key |
| `amount` | `double` | Transaction amount |
| `type` | `TransactionType` | income / expense / transfer |
| `accountId` | `int` | Source account |
| `categoryId` | `int?` | Transaction category |
| `targetAccountId` | `int?` | Target account (for transfer) |
| `date` | `DateTime?` | Transaction date |
| `notes` | `String?` | Notes |
| `transferId` | `String?` | UUID for paired transfers |
| `status` | `TransactionStatus` | pending / completed / failed / cancelled |

### Category
| Field | Type | Description |
|-------|------|------------|
| `id` | `int?` | Primary key |
| `name` | `String` | Category name |
| `icon` | `String?` | Icon identifier |

### Default Categories

**Expense:** Food, Transportation, Healthcare, Shopping, Other Expense

**Income:** Salary, Freelance, Gift, Investment, Other Income

---

## Roadmap

- [ ] **Recurring Transactions** — Repeating transactions (subscriptions, monthly salary)
- [ ] **Cloud Sync** — Data synchronization to Supabase / Firebase
- [ ] **Export Data** — Export to CSV / Excel / PDF
- [ ] **Advanced Charts** — Bar charts, line charts for monthly trends
- [ ] **Web Dashboard** — Web-based dashboard for monitoring
- [ ] **Encrypted Storage** — Upgrade from SharedPreferences to flutter_secure_storage
- [ ] **Custom Categories** — User-created categories with custom icons
- [ ] **Live Exchange Rate** — Real-time currency exchange rates from API
- [ ] **Home Screen Widget** — Balance summary widget on Android/iOS home screen
- [ ] **Dark Mode** — Dark theme for nighttime use

---

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## License

Distributed under the MIT License. See `LICENSE` for more information.

---

## Contributors

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
