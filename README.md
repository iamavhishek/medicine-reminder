# 💊 Ausadhi Khau — Medicine Reminder

A beautiful, cross-platform medicine reminder app built with **Flutter**. Designed to help users manage medication schedules with smart notifications, flexible dosing phases, and a clean, minimal UI.

## ✨ Features

- **Smart Reminders** — Get timely notifications for every dose, powered by `flutter_local_notifications` and timezone-aware scheduling.
- **Flexible Scheduling** — Supports daily, weekly, and monthly frequencies with multi-phase dosing (e.g., different dosages across treatment stages).
- **Per-Day Controls** — Skip a single day, manually enable for one day, or toggle individual time-slot reminders.
- **Calendar View** — Visual overview of your entire month with day-by-day medicine details.
- **Insights Dashboard** — Track active medicines, daily dose count, compliance rate, and medicine type distribution.
- **Data Backup & Restore** — Export and import your data as `.mrbackup` files for safe migration.
- **Dark & Light Themes** — Elegant monochrome design with system, light, and dark mode support.
- **Desktop Support** — Full sidebar navigation, system tray integration, and launch-at-startup on macOS, Windows, and Linux.
- **Onboarding Flow** — Guided setup with permission requests for notifications, exact alarms (Android), and battery optimization.

## 🛠 Tech Stack

| Layer            | Technology                                       |
| ---------------- | ------------------------------------------------ |
| Framework        | Flutter (Dart)                                   |
| State Management | flutter_bloc (BLoC pattern)                      |
| Local Storage    | Hive CE                                          |
| Models           | Freezed + JSON Serializable                      |
| Routing          | go_router (StatefulShellRoute)                   |
| Notifications    | flutter_local_notifications + timezone           |
| Desktop          | window_manager, tray_manager, launch_at_startup  |
| Background Tasks | workmanager (Android), periodic timers (Desktop) |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `^3.10.8`
- Dart SDK (included with Flutter)
- Xcode (for macOS/iOS), Android Studio (for Android), or Visual Studio (for Windows)

### Run Locally

```bash
# Install dependencies
flutter pub get

# Generate model code (Freezed + Hive adapters)
flutter pub run build_runner build --delete-conflicting-outputs

# Run in debug mode
flutter run
```

### Build for Production

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# macOS
flutter build macos --release

# Windows (MSIX)
flutter pub run msix:create
```

## 📁 Project Structure

```
lib/
├── blocs/              # BLoC state management (medicine, theme)
├── models/             # Freezed data models (Medicine, MedicineSchedule)
├── repositories/       # MedicineRepository (data + notification orchestration)
├── screens/            # Full-page screens (home, calendar, insights, settings, etc.)
├── services/           # Business logic services (Hive, notifications, desktop, background)
├── utils/              # Theme config + medicine utility helpers
├── widgets/            # Reusable UI components organized by feature
└── main.dart           # App entry point, routing, initialization
```

## 📄 License

This project is private and not published to pub.dev.
