# 🏀 SlamStat - Court Commander 📊

**SlamStat** is the ultimate real-time basketball match tracking powerhouse built with Flutter and Firebase! Whether you're coaching the next championship team or managing your local league, SlamStat brings professional-grade match management to your fingertips.

## 🔥 Game-Changing Features

### 🏆 **Team Management Central**
- 🔐 **Admin Dashboard** - Secure authentication for coaches and administrators
- 👥 **Squad Builder** - Create and manage Boys & Girls teams with complete roster control
- 🌟 **Player Profiles** - Individual stat tracking for every player on your roster
- 📈 **Performance Analytics** - Deep dive into player and team statistics

### ⚡ **Live Match Engine**
- 🕐 **Real-Time Scoring** - Live score updates with quarter-by-quarter breakdowns
- ⏱️ **Game Timer** - Professional match timing with pause/resume functionality
- 🏀 **Match Types** - Support for Friendly games, Tournament matches, and more
- 📊 **Live Stats** - Track rebounds, assists, steals, and shooting percentages in real-time
- 🎯 **Flexible Formats** - Support for 1v1, 2v2, 3v3, 4v4, and full 5v5 matches

### 📱 **Fan Experience**
- 🎯 **SlamView Companion** - Separate app for fans to follow live matches
- 🔔 **Instant Notifications** - Push alerts for game updates, scores, and highlights
- 📋 **Match History** - Complete archive of completed games and results
- 🏅 **Leaderboards** - Team and player rankings with comprehensive stats

## 🛠️ Championship Tech Stack

- **🎯 Flutter** - Cross-platform mobile development framework
- **🔥 Firebase Realtime Database** - Lightning-fast data synchronization
- **🛡️ Firebase Authentication** - Rock-solid security for admin access
- **📢 Firebase Cloud Messaging** - Instant push notifications
- **⚡ Provider/Riverpod** - Advanced state management for smooth performance
- **🔧 Android Studio** - Primary development environment

## 🚀 Quick Start Guide

### 1. **Get the Code**
```bash
git clone https://github.com/yourusername/slamstat.git
cd slamstat
```

### 2. **Install Dependencies**
```bash
flutter pub get
```

### 3. **Firebase Setup**
- Add your `google-services.json` (Android) to `android/app/`
- Add your `GoogleService-Info.plist` (iOS) to `ios/Runner/`
- Configure Firebase in `android/app/build.gradle` and `ios/Runner/Info.plist`

### 4. **Launch the App**
```bash
flutter run
```

## 📂 Court Architecture

```
lib/
├── 🔐 auth/              # Authentication screens & logic
├── 📊 models/            # Data models (Team, Player, Match, Stats)
├── 🏀 screens/           # Main app screens
│   ├── home/             # Dashboard and navigation
│   ├── teams/            # Team management
│   ├── matches/          # Live scoring and match creation
│   └── stats/            # Analytics and reporting
├── 🔧 services/          # Firebase integrations
├── 🎨 widgets/           # Reusable UI components
├── 🎯 utils/             # Helper functions and constants
└── 📱 main.dart          # App entry point
```

## 🏆 Key Highlights

- **⚡ Real-time Updates** - See scores change instantly across all devices
- **📊 Advanced Statistics** - Track shooting percentages, rebounds, assists, and more
- **🎮 Intuitive Interface** - Designed for coaches, players, and fans
- **🔒 Secure & Scalable** - Enterprise-grade Firebase backend
- **📱 Cross-Platform** - Works seamlessly on Android and iOS

## 📸 Screenshots

### 🎨 **App Interface Gallery**
- 🌟 **Splash Screen** - Dynamic loading screen with SlamStat branding
- 🏠 **Home Dashboard** - Central hub for all basketball management activities
- ⚡ **Live Match Page** - Real-time scoring interface with timer and stats
- 👥 **Teams Management** - Complete roster control and team organization
- 🎯 **Team Selection** - Quick team picker for match creation
- 🏀 **Match Format Selection** - Choose between different game formats
![WhatsApp Image 2025-07-16 at 02 08 03_cb33e36c](https://github.com/user-attachments/assets/4241aecb-4636-494e-be87-0415b475e00e)
![WhatsApp Image 2025-07-16 at 02 08 02_62e56dbd](https://github.com/user-attachments/assets/26e964b3-2cb8-4238-83e1-f7247e4dd396)
![WhatsApp Image 2025-07-16 at 02 08 02_81a72cae](https://github.com/user-attachments/assets/cf258550-3663-4252-bc36-56a493a67688)
![WhatsApp Image 2025-07-16 at 02 08 03_ae954b71](https://github.com/user-attachments/assets/90047164-94e4-4880-af6a-da41ece16fac)

## 🎯 Important Match Setup Instructions

### 📋 **Match Format Selection Rules**

**🤝 Friendly Matches:**
- ⚠️ **Format Selection REQUIRED** - Always choose match format (1v1, 2v2, 3v3, 4v4, 5v5)
- 🎯 Format determines court size, game duration, and scoring rules
- 📊 Essential for proper statistics tracking and gameplay

**🏆 College Tournament Matches:**
- ✅ **Format Selection OPTIONAL** - Default to standard 5v5 format
- 🔄 **Exception:** If teams are already registered in the app, format auto-detected
- ⚡ **Special Tournaments:** For 1v1, 2v2, 3v3, or 4v4 college tournaments, format selection IS required
- 🎪 Mixed format tournaments need manual format specification

### 🎮 **Quick Setup Guide**
1. **Select Match Type** (Friendly vs Tournament)
2. **Choose Teams** (from existing roster or create new)
3. **Set Format** (required for Friendly, optional for standard Tournament)
4. **Configure Timer** and start your match!

- 🎥 Video highlights integration
- 📈 Advanced analytics dashboard
- 🏆 Tournament bracket management
- 🌐 Web dashboard for coaches
- 📊 Export game reports

## 🎯 Coming Soon

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [FlutterFire Plugins](https://pub.dev/publishers/firebase.google.com/packages)
- [Basketball Rules & Regulations](https://www.fiba.basketball/documents)

## 🔗 Essential Resources

**Crafted with 🏆 and ❤️ by [Aryant Kumar](https://www.linkedin.com/in/aryant-kumar-dev)**

Connect with the developer:
- 💼 LinkedIn: [Aryant Kumar](https://www.linkedin.com/in/aryant-kumar-dev/)
- 🐱 GitHub: [AryantKumar](https://github.com/AryantKumar)

---

*Ready to dominate the court? Clone, build, and start tracking your team's journey to victory! 🏆*

### 🌟 Don't forget to star the repo if SlamStat helps your team! 🌟
