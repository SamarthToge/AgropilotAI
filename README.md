# 🌱 AgroPilot AI

![Flutter Version](https://img.shields.io/badge/Flutter-3.x-blue.svg)
![Firebase](https://img.shields.io/badge/Firebase-Integrated-yellow.svg)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-lightgrey.svg)

**AgroPilot AI** is a smart, AI-powered agricultural monitoring application built with Flutter. It provides farmers and agricultural enthusiasts with live sensor data, yield predictions, and critical alerts to optimize crop growth and farm management. 

---

## ✨ Key Features

- **📡 Live Sensor Monitoring:** Track vital statistics in real-time, including:
  - 🌡️ Temperature
  - 💧 Humidity
  - 💨 CO₂ Levels
  - 🌱 Soil Moisture
- **🤖 Yield Prediction:** AI-driven insights to forecast crop yields based on historic and live sensor inputs.
- **⚠️ Actionable Alerts:** Automated alerts and recommendations when environmental factors fall outside of ideal biological ranges.
- **📊 History & Analytics:** Comprehensive history tracking and visual reports to study long-term trends.
- **🔌 ESP32 / IoT Ready:** Supports live hardware data integration (e.g., ESP32 sensors) alongside a fallback demo model for testing.
- **🔐 Secure Authentication:** Seamless user login and profile management via Firebase Auth.
- **☁️ Cloud Sync:** Real-time data synchronization with Firebase / Firestore to monitor fields from anywhere.

---

## 🛠️ Technology Stack

- **Frontend:** Flutter & Dart
- **State Management:** Provider
- **Backend/Database:** Firebase (Authentication, Realtime Database, Firestore)
- **UI & Visualization:** Google Fonts, `fl_chart` for analytics

---

## 🚀 Getting Started

Follow these steps to set up the project locally on your machine.

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.0.0 or higher)
- Android Studio / VS Code (with Flutter & Dart plugins)
- A Firebase project to connect your backend services

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/SamarthToge/AgropilotAI.git
   cd agropilot_ai
   ```

2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   - Add your `google-services.json` to `android/app/` (for Android).
   - Add your `GoogleService-Info.plist` to `ios/Runner/` (for iOS).
   - Alternatively, make sure your specific `firebase_options.dart` is securely configured.

4. **Run the App:**
   ```bash
   flutter run
   ```

---

## 📂 Project Structure

```text
lib/
├── constants/         # App UI constants (Theme colors, text styles)
├── models/            # Data models (Sensors, Alerts, Yield data)
├── providers/         # State management (AppState, SensorProvider, etc.)
├── screens/           # Main UI screens (Dashboard, Login, Sensor Details)
├── services/          # External services (Firebase, DummyData seeding)
├── widgets/           # Reusable UI components (Cards, Drawers, Graphs)
└── main.dart          # App entry point
```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! 

1. Fork the project.
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the Branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.
