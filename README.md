# 🎬 **Cinec Movie Booking App**

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-v3.13.0+-blue?logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-Backend-orange?logo=firebase&logoColor=white" />
  <img src="https://img.shields.io/badge/Platform-Android%20|%20iOS-success?logo=android&logoColor=white" />
  <img src="https://img.shields.io/badge/License-MIT-green" />
</p>

---

## 🎥 **Overview**

**Cinec Movie Booking App** is a Flutter-based mobile application designed for an intuitive movie ticket booking experience.  
The app integrates **Firebase** for authentication, Firestore for real-time data, and Storage for movie poster management.

---

## ✨ **Features**

🎦 **Browse Movies** – Explore the latest movies with detailed descriptions and posters.  
🎟️ **Book Tickets** – Real-time seat selection and secure booking.  
🕒 **Showtime Management** – Multiple showtimes per movie with seat availability tracking.  
👤 **User Authentication** – Sign up / Sign in via Firebase Authentication.  
📜 **Booking History** – View past bookings instantly.  
🛠️ **Admin Panel** – Add and manage showtimes and movie data.

---

## 🧠 **Tech Stack**

| Layer | Technology |
|:--|:--|
| **Frontend** | Flutter (Dart) |
| **Backend** | Firebase (Authentication, Firestore, Storage) |
| **State Management** | Stream-based reactivity |
| **Design Pattern** | Repository pattern for data layer |

---

## 🏗️ **Architecture & Database**

### 🗂️ **Firestore Collections**
collections/
├── movies/
│ └── {movieId}/
│ ├── title: string
│ ├── synopsis: string
│ ├── genre: string
│ ├── duration: number
│ ├── posterUrl: string
│ └── trailerUrl: string
├── showtimes/
│ └── {showtimeId}/
│ ├── movieId: string
│ ├── theater: string
│ ├── time: timestamp
│ ├── price: number
│ ├── totalSeats: number
│ └── bookedSeats: array
├── bookings/
│ └── {bookingId}/
│ ├── userId: reference
│ ├── showtimeRef: reference
│ ├── seats: array
│ ├── totalAmount: number
│ ├── bookingDate: timestamp
│ └── movieTitle: string
└── users/
└── {userId}/
├── email: string
└── name: string


---

## ⚙️ **Installation & Setup**

### 🧩 **Prerequisites**
- Flutter SDK **(v3.0 or higher)**
- Android Studio / VS Code with Flutter plugin
- Firebase project configured
- Git

---

### 🚀 **Setup Steps**

1️⃣ **Clone the repository**
```bash
https://github.com/Aathi18/cinec_movie_app.git
cd cinec_movie_app

2️⃣ Install dependencies
flutter pub get

3️⃣ Firebase Setup

Create a project on Firebase Console
Enable Authentication (Email/Password)

Enable Cloud Firestore and Storage

Download google-services.json → place in android/app/

Add your SHA-1 and SHA-256 keys to Firebase

4️⃣ Configure Firebase
Update lib/firebase_options.dart with your Firebase configuration.

5️⃣ Run the app
flutter run

📦 Building Release APK

To generate a release APK:
flutter build apk --release
build/app/outputs/flutter-apk/app-release.apk
