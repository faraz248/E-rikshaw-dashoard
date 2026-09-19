# 🛺 E-Rickshaw Dealership & Workshop Management System

A production-grade mobile application built with **Flutter** and **Firebase** to streamline E-Rickshaw sales, financing, customer khata/ledger, battery warranty claims, and workshop service tracking.

---

## ⚡ Key Features

### 👨‍💼 Admin Features
- **Customer Onboarding & Directory:** Manage customer profiles, vehicle assignments, and chassis numbers.
- **Khata / Ledger & EMI Tracking:** Real-time ledger entries, payment receipt logging, and balance tracking.
- **Spare Parts & Inventory:** Track stock levels for batteries, controllers, motors, and accessories with low-stock alerts.
- **Battery Warranty Management:** Process claims, verify battery serials, and update replacement statuses.
- **Document Management:** Secure storage and verification of vehicle RC, insurance, and identity proofs.

### 👤 Customer Features
- **Vehicle Digital Hub:** View vehicle number, model details, and live account standing.
- **Digital Document Vault:** Instant access to uploaded vehicle documents.
- **Warranty Claim Tracker:** Submit and track battery warranty replacements.
- **Service Job Booking:** Schedule maintenance visits, report mechanical/electrical issues, and track workshop job-card status.

---

## 🛠️ Tech Stack & Architecture

- **Framework:** Flutter (Material 3)
- **Backend & Database:** Firebase Authentication, Cloud Firestore
- **Asset / Document Storage:** Cloudinary REST API (Unsigned Upload Presets)
- **State Management:** Reactive Streams (`StreamBuilder`, `StatefulWidget`)
- **Theme:** Custom Design System (`AppColors`, `AppTheme`)

---

## 📁 Project Structure

```text
mobile_app/
├── lib/
│   ├── firebase_options.dart
│   ├── main.dart
│   ├── screens/
│   │   ├── admin/             # Dealership management dashboards & pages
│   │   ├── auth/              # Role-based login and registration
│   │   └── customer/          # Customer self-service portals
│   ├── services/
│   │   └── cloudinary_service.dart
│   └── theme/
│       └── app_theme.dart
└── pubspec.yaml