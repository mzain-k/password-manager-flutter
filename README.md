# VaultGuard — Secure Password Manager

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%2B%20Firestore-orange)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

A secure, feature-complete password manager built with Flutter and Firebase as a BSCS semester project.

---

## Student Information

| Field | Details |
|---|---|
| **Name** | [YOUR_NAME] |
| **Registration No.** | [YOUR_REGISTRATION_NUMBER] |
| **Course** | Mobile App Development |
| **Project** | Secure Password Manager with Breach Detection & Strength Analysis |

---

## Features

| Feature | Description |
|---|---|
| **Firebase Authentication** | Email/password signup and login with session persistence across restarts |
| **AES-256 Encryption** | All passwords encrypted before storage — never stored in plain text |
| **Password Vault** | Add, view, edit, delete entries with real-time Firestore sync |
| **Strength Analyzer** | Real-time password strength scoring with animated progress bar and improvement suggestions |
| **Breach Detection** | Have I Been Pwned API integration using k-anonymity — password never sent to any server |
| **Password Generator** | Cryptographically secure generator using Random.secure() with configurable length and character sets |
| **Security Dashboard** | Overall security score with weak, breached, and reused password detection |

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter (Dart) |
| **Authentication** | Firebase Authentication |
| **Database** | Cloud Firestore (real-time) |
| **Encryption** | AES-256 via `encrypt` package |
| **Breach Detection** | Have I Been Pwned API |
| **Hashing** | SHA-1 via `crypto` package |
| **HTTP** | `http` package |

---

## Security Architecture

### 1. AES-256 Encryption
Passwords are encrypted with a 256-bit key before being stored in Firestore. A unique IV (Initialization Vector) is generated for every single encryption operation. This means encrypting the same password twice produces completely different cipher text — preventing pattern detection.

**Stored format:** `ivBase64:cipherBase64`

Even if the Firestore database is compromised, the attacker only sees scrambled cipher text — the original passwords are mathematically unrecoverable without the key.

### 2. k-Anonymity Breach Detection
The actual password **never leaves the device**. The process:
1. Hash the password with SHA-1
2. Send only the **first 5 characters** of the hash to the HIBP API
3. The API returns all hashes starting with those 5 characters
4. Compare locally on device — no full hash or password is ever transmitted

This is called k-anonymity — the server cannot determine which specific password is being checked.

### 3. Firestore Security Rules
Server-side rules ensure users can only read and write their own password documents. Cross-user data access is completely blocked at the database level.

match /users/{userId}/passwords/{doc} {
allow read, write: if request.auth != null
&& request.auth.uid == userId;
}

---

## Project Structure
lib/
├── screens/          # UI screens (login, vault, generator, dashboard, etc.)
├── widgets/          # Reusable UI components (PasswordCard, StrengthMeter)
├── models/           # Data classes (PasswordEntry, SecurityStats)
├── services/         # Business logic (auth, Firestore, encryption, breach)
└── utils/            # Helper functions (password strength analyzer)

---

## Setup Instructions

### Prerequisites
- Flutter SDK 3.x
- Android Studio or VS Code with Flutter extension
- A Firebase project

### Installation

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/password-manager-flutter.git

# Navigate into the project
cd password-manager-flutter

# Install dependencies
flutter pub get
```

### Firebase Configuration
1. Create a project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Email/Password** Authentication
3. Enable **Cloud Firestore** (start in test mode, then apply security rules)
4. Add your own `google-services.json` to `android/app/`
5. Run `flutterfire configure`

### Run the App

```bash
flutter run
```

---

## Dependencies

```yaml
firebase_core: ^3.6.0
firebase_auth: ^5.3.1
cloud_firestore: ^5.4.4
encrypt: ^5.0.3
crypto: ^3.0.3
http: ^1.2.2
provider: ^6.1.2
flutter_secure_storage: ^9.2.2
```

---

## Acknowledgements
- [Have I Been Pwned](https://haveibeenpwned.com) by Troy Hunt — Breach detection API
- [encrypt package](https://pub.dev/packages/encrypt) — AES-256 encryption for Flutter
- [Firebase](https://firebase.google.com) — Authentication and real-time database
