<div align="center">

<img src="https://github.com/iamaymo/adati_mobile_app/blob/main/images/adati_logo.png" alt="Adati Logo" width="120"/>

# 🛠️ Adati

**Tools & Equipment Rental App**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Django Backend](https://img.shields.io/badge/Backend-Django%20REST-092E20?logo=django)](https://github.com/iamaymo/adati_back_end_api)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

> A peer-to-peer tools & equipment rental platform built on the **Sharing Economy** philosophy — connecting tool owners with renters through a secure, smart, and fully tracked digital experience.

</div>

---

## 📋 Table of Contents

- [About the Project](#-about-the-project)
- [Key Features](#-key-features)
- [Tech Stack](#-tech-stack)
- [App Screenshots](#-app-screenshots)
- [Project Architecture](#-project-architecture)
- [Getting Started](#-getting-started)
- [Folder Structure](#-folder-structure)
- [API Integration](#-api-integration)
- [User Roles](#-user-roles)
- [Order Lifecycle](#-order-lifecycle)
- [Security & Trust](#-security--trust)
- [Backend Repository](#-backend-repository)
- [Team](#-team)

---

## 🌟 About the Project

**Adati** is a graduation project developed at **Al-Razi University — Faculty of Computer Science & IT**

The app addresses a real gap in the local Yemeni market: expensive professional tools that sit idle while others need them for temporary use. Adati creates a **trusted digital marketplace** where tool owners can earn extra income and renters can access equipment at a fraction of the purchase cost.

> Built on the **Sharing Economy** model, Adati transforms idle assets into productive resources while promoting sustainability and community trust.

---

## ✨ Key Features

### 👤 For All Users

- 📱 Clean onboarding with Login / Register / Guest Browse
- 🪪 **Mandatory ID Verification** — upload front & back of national ID
- 🔍 Smart search with filtering by **tool category** and **city**
- ❤️ Save tools to **Favorites** for quick access
- ⭐ Mutual **rating system** for tools and users
- 🚨 **Report a Problem** — direct channel to admin
- ⚙️ Full settings: edit profile, change password, delete account
- 📄 Terms & Policies, Support & Help (FAQ + Live Chat + Email)

### 🔧 For Tool Owners (Providers)

- ➕ List tools with photos, description, category, and daily price
- 💰 Automatic **25% security deposit** calculation based on real tool value
- ✅ Accept or reject incoming rental requests
- 📦 Manage rentals via interactive **order tracking timeline**
- 🔍 Inspect tool condition on return and confirm via **checkbox**
- 💵 View earnings per order (net profit after platform commission)

### 🛒 For Renters

- 🛍️ Add tools to **Cart** and rent multiple items
- 💳 Pay via **One Cash Wallet** or **Jaib Wallet**
- 📲 OTP verification for payment security
- 📊 View **Rental Summary** with full price breakdown before confirming
- 🗺️ **Track My Rental** — real-time order status timeline
- 📦 Confirm tool receipt and request return with one tap
- 🔁 Rate the tool after order completion

### 🖥️ Admin Dashboard

- Full user management (activate/deactivate accounts, grant roles)
- Tool management with color-coded availability labels
- Order tracking & financial reports with auto-calculated platform revenue
- Security deposit (insurance) management
- Review moderation
- Favorites analytics
- Reports & issue resolution system

---

## 🛠️ Tech Stack

| Layer                | Technology                          |
| -------------------- | ----------------------------------- |
| **Frontend**         | Flutter (Dart)                      |
| **Backend**          | Django REST Framework (Python)      |
| **Database**         | MySQL                               |
| **State Management** | StatefulWidgets / setState          |
| **HTTP Client**      | http package                        |
| **Authentication**   | Token-based (Simple JWT / DRF Auth) |
| **Admin Panel**      | Django Admin + Jazzmin UI           |
| **Design Tool**      | Figma                               |
| **IDE**              | VS Code + Android Studio            |

---

## 📱 App Screenshots

<details>
<summary>Click to expand screenshots</summary>

### Onboarding & Auth

| Gateway                             | Login                               | Register                                            | ID Verification                      |
| ----------------------------------- | ----------------------------------- | --------------------------------------------------- | ------------------------------------ |
| <img src="/md/2.png"  width="150"/> | <img src="/md/3.png"  width="150"/> | <img src="/md/4.png" alt="Adati Logo" width="150"/> | <img src="/md/35.png"  width="150"/> |

### Home & Search

| Home Screen                         | Search                              | Filter                              | Tool Details                        |
| ----------------------------------- | ----------------------------------- | ----------------------------------- | ----------------------------------- |
| <img src="/md/5.png"  width="150"/> | <img src="/md/7.png"  width="150"/> | <img src="/md/8.png"  width="150"/> | <img src="/md/6.png"  width="150"/> |

### Rental Flow

| Cart                                 | Wallet Selection                     | OTP Verify                           | Rental Summary                       |
| ------------------------------------ | ------------------------------------ | ------------------------------------ | ------------------------------------ |
| <img src="/md/12.png"  width="150"/> | <img src="/md/13.png"  width="150"/> | <img src="/md/14.png"  width="150"/> | <img src="/md/16.png"  width="150"/> |

### Order Tracking

| Incoming Requests                   | Request Details                      | Track My Rental                      | Rented Tools                         |
| ----------------------------------- | ------------------------------------ | ------------------------------------ | ------------------------------------ |
| <img src="/md/9.png"  width="150"/> | <img src="/md/10.png"  width="150"/> | <img src="/md/11.png"  width="150"/> | <img src="/md/21.png"  width="150"/> |

### Profile & Settings

| Profile                              | My Tools                             | Favorites                            | Settings                             |
| ------------------------------------ | ------------------------------------ | ------------------------------------ | ------------------------------------ |
| <img src="/md/18.png"  width="150"/> | <img src="/md/20.png"  width="150"/> | <img src="/md/17.png"  width="150"/> | <img src="/md/26.png"  width="150"/> |

### Reports & Support

| Reports Problem                      | Reports Problem 2                    | Reports Problem 3                    | Support and Help                     |
| ------------------------------------ | ------------------------------------ | ------------------------------------ | ------------------------------------ |
| <img src="/md/32.png"  width="150"/> | <img src="/md/33.png"  width="150"/> | <img src="/md/34.png"  width="150"/> | <img src="/md/30.png"  width="150"/> |

</details>

---

## 🏗️ Project Architecture

```
Adati uses a Client-Server architecture:

┌────────────────────────────────────┐
│        Flutter App (Client)        │
│  ┌───────────┐    ┌─────────────┐  │
│  │    UI     │    │  API Layer  │  │
│  │  Widgets  │ ◄► │    (HTTP)   │  │
│  └───────────┘    └─────┬───────┘  │
└──────────────────────── │ ─────────┘
                          │ REST API (JSON)
┌──────────────────────── │ ────────┐
│        Django Backend   │         │
│  ┌──────────────────────▼─────┐   │
│  │    Django REST Framework   │   │
│  └──────────────┬─────────────┘   │
│  ┌──────────────▼─────────────┐   │
│  │     MySQL Database         │   │
│  └────────────────────────────┘   │
└───────────────────────────────────┘
```

The app follows a **Hybrid methodology (Waterfall + Scrum)**:

- **Waterfall** — initial requirements, DB design, system architecture
- **Scrum (Sprints)** — iterative feature development (design and code)
- **Waterfall** — final integration testing and QA

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or VS Code with Flutter extension
- A running instance of the server [Adati Backend](https://github.com/iamaymo/adati_back_end_api)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/iamaymo/adati_mobile_app.git

# 2. Navigate into the project
cd adati_mobile_app

# 3. Install dependencies
flutter pub get

# 4. Start The Emulator (Android Studio Emulator)

# 5. Run the app
flutter run
```

### Build APK

```bash
flutter build apk --release
```

---

## 🔌 API Integration

The app communicates with the Django REST backend via HTTP.

### Main Endpoints

| Feature             | Method      | Endpoint                      |
| ------------------- | ----------- | ----------------------------- |
| Register            | `POST`      | `/api/auth/register/`         |
| Login               | `POST`      | `/api/auth/login/`            |
| Get Tools           | `GET`       | `/api/tools/`                 |
| Search & Filter     | `GET`       | `/api/tools/?category=&city=` |
| Create Order        | `POST`      | `/api/orders/`                |
| Track Order         | `GET`       | `/api/orders/{id}/`           |
| Update Order Status | `PATCH`     | `/api/orders/{id}/status/`    |
| Submit Review       | `POST`      | `/api/reviews/`               |
| Submit Report       | `POST`      | `/api/reports/`               |
| Manage Insurance    | `GET/PATCH` | `/api/insurances/`            |

> 📌 For full API documentation, refer to the [Backend Repository](https://github.com/iamaymo/adati_back_end_api).

---

## 👥 User Roles

| Role      | Description                                                                                      |
| --------- | ------------------------------------------------------------------------------------------------ |
| **Admin** | Full platform control via Django Admin Dashboard                                                 |
| **User**  | Can list tools for rent, browse & rent tools, manage orders, track rentals, and rate tools/users |
| **Guest** | Can only browse tools|

---

## 🔄 Order Lifecycle

```
[Renter sends request]
        ↓
[Owner: Accept / Reject]
        ↓
[Owner: Handed to Delivery]
        ↓
[Renter: Received by Customer ✓]
        ↓
     [Rental Period]
        ↓
[Renter: Ready for Pickup]
        ↓
[Renter: Handed to Delivery (Back)]
        ↓
[Owner: Received tool back]
        ↓
[Owner: Inspect tool → Check ✓ condition]
        ↓
[Owner: Finish Order]
        ↓
[Insurance Refunded to Renter 💰]
        ↓
[Both parties: Rate each other ⭐]
```

---

## 🔒 Security & Trust

- **ID Verification** — every user must upload a national ID (front + back) before creating an account
- **Security Deposit** — automatically calculated at **25% of tool's real value**, held until safe return
- **Mutual Rating System** — only completed order parties can leave one review
- **Django security protocols** — SQL injection protection, password hashing, access control
- **OTP Payment Verification** — wallet number confirmed via one-time code (For now using static number 0 0 0 0 0 0)

---

## 🖥️ Backend Repository

The Django REST API backend lives here:

👉 **[https://github.com/iamaymo/adati_back_end_api](https://github.com/iamaymo/adati_back_end_api)**

The backend README contains setup instructions, migration commands, and server run commands.

---


<div align="center">

Made with ❤️ by Ayman Al-Qadasi — 2026

</div>
