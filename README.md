# Smart AgroConnect 🚜
A Comprehensive Farm Management System built with Flutter and Firebase.

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

Smart AgroConnect is a professional-grade mobile solution designed to help modern farmers digitize their operations. By centralizing crop cycles, task management, and financial tracking into a real-time dashboard, the app enables data-driven decision-making in the field.

**🌟 Key Features**

- **📊 Intelligent Dashboard:** Real-time KPIs for Active Crops, Pending Tasks, Total Acres, and cumulative Expenses.
- **📶 Offline Persistence:** Full functionality in remote areas with native Firestore local caching; data auto-syncs when back online.
- **📅 Task Management:** Track daily farm activities (Irrigation, Fertilization, Harvest) tied directly to specific crop cycles.
- **💰 Financial Analytics:** Log expenses and harvest yields to monitor profitability per field.
- **☁️ Weather Integration:** Live weather data from OpenWeatherMap API for local agricultural planning.
- **🔐 Secure Auth:** Complete user lifecycle management via Firebase Authentication.


## 🏗️ Technical Architecture

The project follows the **MVVM (Model-View-ViewModel)** architectural pattern to ensure strict separation of concerns and scalability.

- **UI Layer (Views):** Built with highly modularized Flutter widgets.
- **Logic Layer (ViewModels):** Powered by the `Provider` package for clean state management.
- **Data Layer (Models & Services):** Structured NoSQL data models and external API services.

### Folder Structure
```
lib/
├── models/         # Data structures (Crop, Task, Expense)
├── viewmodels/     # Business logic & ChangeNotifier classes
├── views/          # UI Screens (Dashboard, Auth, Crops)
├── services/       # External APIs (WeatherService)
└── utils/          # App constants, themes, and styles
```
**🛠️ Technology Stack**
Frontend: Flutter (Dart)

Backend: Firebase (Auth, Cloud Firestore)

State Management: Provider

Data Visualization: fl_chart

Icons: Lucide Icons / FontAwesome

**🚀 Getting Started**
Prerequisites
Flutter SDK installed on your machine.

A Firebase project set up on the Firebase Console.

Installation
Clone the repository:

git clone https://github.com/UmairAhmad-dev/Smart-AgroConnect-Flutter
```
**Install dependencies:**

cd Smart-AgroConnect
flutter pub get

**Configure Firebase:**

Add your google-services.json (Android) to android/app/.

Add your GoogleService-Info.plist (iOS) to ios/Runner/.

**Run the app:**

flutter run
```
**👨‍💻 Author**
Umair Ahmad

GitHub: https://github.com/UmairAhmad-dev

LinkedIn: https://www.linkedin.com/in/umair-ahmad-aa3903290/

This project was developed as part of the 5th-semester App Development Project.