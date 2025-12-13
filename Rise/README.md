# MyFinanceApp (Starter Scaffold)

This repository is a starter scaffold for "MyFinanceApp" — a cross-platform personal finance manager (MVP).

## What's included
- Minimal Flutter app skeleton
- Local SQLite DB helper using `sqflite`
- Data models for Account, Category, Transaction and Budget
- Basic screens: Onboarding, Home, Add Transaction
- **Security: PIN & Biometric Authentication** (local_auth + SharedPreferences)
- Settings screen to manage PIN and biometric options

## Requirements
- Flutter SDK installed (https://flutter.dev)
- Device or emulator connected

## Quick start (PowerShell)

```powershell
cd "d:/WPy64-31241/projects/finance app/my_finance_app"
flutter pub get
flutter run
```

## Features

### Onboarding
- Users set up initial account on first launch
- PIN setup prompted after onboarding (optional, but recommended)

### Security
- **PIN Protection**: Set a 4+ digit PIN on first launch; app locks when exited
- **Biometric Auth**: If device supports (fingerprint/face ID), enable via Settings after PIN is set
- Both methods stored securely in SharedPreferences and local_auth

### Home Screen
- Shows net worth (sum of all accounts)
- Lists all accounts and balances
- Quick "Add Transaction" button
- Settings icon for security configuration

### Security Settings
- Enable/disable biometric authentication
- Reset or remove PIN protection

## Notes & next steps
- This scaffold focuses on core models and UI. Implement features incrementally:
  - Recurring transactions
  - Data backups (cloud sync with Firebase)
  - CSV/Excel export
  - Charts (pie, bar) for reports
  - Web dashboard
- PIN is stored in SharedPreferences (consider upgrading to encrypted storage for production)
- See `lib/` for models, DB, security, and screen implementations

