# SlamStat – Court Commander

> Real-time basketball match tracking and team management platform

[![Build](https://img.shields.io/badge/build-passing-brightgreen)](https://github.com/AryantKumar/slamstat)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Realtime-FFCA28?logo=firebase)](https://firebase.google.com)
[![Last Commit](https://img.shields.io/github/last-commit/AryantKumar/slamstat)](https://github.com/AryantKumar/slamstat/commits)
[![Stars](https://img.shields.io/github/stars/AryantKumar/slamstat?style=social)](https://github.com/AryantKumar/slamstat/stargazers)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

<div align="center">

**[📱 Download APK](https://drive.google.com/file/d/1MZxbs6xXpHKb66GhhZopsTAhAYFOdqH1/view?usp=sharing)** • **[🌐 Live Demo](https://slamstat.web.app/)**

</div>

---

## Overview

SSlamStat is a production-grade basketball tracking platform. It delivers real-time match tracking, comprehensive player analytics, and centralized team management for coaches, tournament organizers, and league administrators across iOS and Android.

The platform synchronizes live scoring, quarter-by-quarter updates, and detailed performance metrics across all connected devices with sub-second latency.

---

## 💡 Why SlamStat?

Traditional basketball tracking relies on paper scoresheets or expensive proprietary systems. SlamStat bridges this gap with a lightweight, scalable solution that provides professional-grade statistics without the complexity or cost. Whether managing a local league or tracking college tournaments, SlamStat delivers instant insights and eliminates manual data entry.

---

## ⚙️ Core Features

**Team & Player Management**
- Role-based admin authentication with Firebase security rules
- Multi-team support across Boys/Girls divisions
- Individual player profiles with historical performance data
- Automated stat aggregation and trend analysis

**Live Match Engine**
- Real-time score synchronization across all devices
- Quarter-based tracking with configurable timing
- Support for 1v1 through 5v5 formats
- Advanced metrics: FG%, rebounds, assists, steals, turnovers
- Match types: friendly scrimmages and tournament brackets

**Fan & Viewer Experience**
- Live match feed accessible via web or mobile
- Push notifications for game events and final scores
- Complete match history with searchable archives
- Dynamic leaderboards for players and teams

---

## 🧩 Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter 3.0+** | Cross-platform UI framework (iOS/Android/Web) |
| **Firebase Realtime Database** | Live data sync and persistence |
| **Firebase Authentication** | Secure role-based access control |
| **Firebase Cloud Messaging** | Push notifications |
| **Firebase Hosting** | Web deployment infrastructure |
| **Riverpod** | State management and dependency injection |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Firebase CLI
- Active Firebase project

### Installation

```bash
git clone https://github.com/AryantKumar/slamstat.git
cd slamstat
flutter pub get
```

### Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable: Realtime Database, Authentication, Cloud Messaging, Hosting
3. Add configuration files:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
4. Configure security rules (see `/docs/firebase-setup.md`)

### Run

```bash
flutter run                      # Development
flutter build apk --release      # Android production
flutter build ios --release      # iOS production
flutter build web --release      # Web deployment
firebase deploy --only hosting

```

---

## 🏗️ Project Structure

```
lib/
├── auth/              # Authentication flows
├── models/            # Data models (Match, Player, Team, Stats)
├── providers/         # Riverpod state providers
├── screens/           # UI screens
├── services/          # Firebase integration layer
├── widgets/           # Reusable components
├── utils/             # Helpers and constants
└── main.dart          # App entry point
```

---

## 🧠 Architecture

SlamStat follows clean architecture principles with separation of concerns:

```
UI Layer (Screens/Widgets)
      ↓
Business Logic (Riverpod Providers)
      ↓
Data Layer (Firebase Services)
      ↓
Models (Immutable Data Classes)
```

**Key Design Decisions:**
- Riverpod for reactive state management
- Repository pattern for Firebase abstractions
- Immutable models with JSON serialization
- Optimistic UI updates with rollback on error

Full architecture documentation: [`/docs/architecture.md`](docs/architecture.md)

---

## 🖼️ Screenshots

<div align="center">

| Splash | Dashboard | Live Match |
|:------:|:---------:|:----------:|
| <img src="https://github.com/user-attachments/assets/806708a8-bfb5-4736-9164-3b74db0b36a2" width="250"/> | <img src="https://github.com/user-attachments/assets/ba4a3f9e-0407-4c86-88dd-32e15e7539b1" width="250"/> | <img src="https://github.com/user-attachments/assets/b08690de-4c85-4085-acc3-d524228f46c6" width="250"/> |

| Teams | Match Setup |
|:-----:|:-----------:|
| <img src="https://github.com/user-attachments/assets/78edf821-45c3-4cc8-9905-6d5607219f0f" width="250"/> | <img src="https://github.com/user-attachments/assets/eee9a4fc-f9cf-46c5-b8f9-dc479467e055" width="250"/> |

</div>

---

## 🔮 Roadmap

- [ ] Video highlight integration with timestamp sync
- [ ] Advanced analytics dashboards (Chart.js visualizations)
- [ ] Tournament bracket automation
- [ ] Web admin portal for coaches
- [ ] PDF/Excel match report exports
- [ ] Offline-first architecture with sync queue
- [ ] Machine learning insights (shot prediction, player recommendations)

---

## 👨‍💻 Developer

**Aryant Kumar** – Flutter Developer | Firebase Specialist  
[LinkedIn](https://www.linkedin.com/in/aryant-kumar-dev) • [GitHub](https://github.com/AryantKumar) • [Portfolio](https://aryant-portfolio.framer.website/)


---

## 📘 Resources

- [Flutter Docs](https://docs.flutter.dev/) • [Firebase for Flutter](https://firebase.flutter.dev/)
- [Riverpod Guide](https://riverpod.dev/) • [FIBA Rules](https://www.fiba.basketball/documents)

---

## ⭐ Support

**Found this useful?** Star the repo and share it with your network!

### Contributing
Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting PRs.

### License
MIT License – see [LICENSE](LICENSE) for details.

### Issues
Report bugs or request features via [GitHub Issues](https://github.com/AryantKumar/slamstat/issues).

---

<div align="center">

**[📱 Download APK](https://drive.google.com/file/d/1MZxbs6xXpHKb66GhhZopsTAhAYFOdqH1/view?usp=sharing)** • **[🌐 Try Live Demo](https://slamstat.web.app/)**

Built with Flutter & Firebase

</div>
