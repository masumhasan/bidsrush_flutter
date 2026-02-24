# BidsRush - Live Commerce App

A live commerce mobile application where sellers can broadcast live streams, showcase products, and interact with buyers in real time.

## Features

- **Live Streaming** — Broadcast and watch live shopping streams powered by Stream Video
- **Real-time Chat** — In-stream chat overlay via Stream Chat
- **Authentication** — JWT-based auth with secure token storage
- **Seller Hub** — Multi-step seller registration, product creation, and show management
- **Profile Management** — Edit profile details and upload avatar photos
- **Video Playback** — Watch recorded past streams
- **Categories** — Browse streams by category
- **Splash Screen** — Animated BidsRush logo on startup

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.10+ / Dart |
| State Management | Provider |
| Video Streaming | Stream Video Flutter |
| Chat | Stream Chat Flutter |
| Networking | HTTP (REST API) |
| Auth Storage | Flutter Secure Storage |
| UI | Google Fonts, Shimmer, Lottie, Cached Network Image |
| Video Playback | Chewie / Video Player |

## Project Structure

```
lib/
├── main.dart                  # App entry point
├── config/
│   └── theme.dart             # App theme & design tokens
├── core/
│   └── constants/
│       └── app_constants.dart # API URLs, keys, timeouts
├── models/
│   ├── user_model.dart
│   ├── stream_model.dart
│   ├── product_model.dart
│   └── seller_registration.dart
├── providers/
│   ├── auth_provider.dart
│   ├── video_stream_provider.dart
│   └── chat_provider.dart
├── services/
│   ├── api_service.dart       # REST API client
│   ├── auth_service.dart      # Login, signup, token management
│   ├── chat_service.dart      # Stream Chat integration
│   └── stream_service.dart    # Stream Video integration
├── screens/
│   ├── splash_screen.dart
│   ├── auth/                  # Sign in, Sign up
│   ├── home/                  # Home feed, All live/past streams
│   ├── stream/                # Broadcast, Viewer, Start stream
│   ├── video/                 # Recorded stream playback
│   ├── seller/                # Seller hub & registration flow
│   ├── profile/               # Profile, Edit, Settings, Referral
│   └── categories/            # Category browsing
└── widgets/
    ├── buttons.dart
    ├── seller_widgets.dart
    ├── video_player_widget.dart
    ├── recorded_stream_player.dart
    └── chat/
        └── chat_overlay.dart
```

## Prerequisites

- Flutter SDK 3.10+
- Android Studio / Xcode
- Running backend server (see `backend/` directory)
- Android device or emulator

## Getting Started

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Configure environment

Create a `.env` file in the `app/` root (optional — defaults are provided):

```env
API_BASE_URL=http://localhost:5000/api
STREAM_API_KEY=your_stream_api_key
```

### 3. Connect a device

**Physical Android device (recommended):**

```bash
adb reverse tcp:5000 tcp:5000
```

**Emulator:** The app defaults to `localhost` with `adb reverse`. For emulator without `adb reverse`, update `app_constants.dart` to use `10.0.2.2`.

### 4. Run the app

```bash
flutter run
```

Or target a specific device:

```bash
flutter run -d emulator-5554
```

## API Configuration

The app connects to the BidsRush backend REST API. Key endpoints:

| Endpoint | Description |
|---|---|
| `/api/auth` | Authentication (login, register, profile, avatar upload) |
| `/api/stream` | Live stream management |
| `/api/products` | Product CRUD |
| `/api/stream/token` | Stream Video token generation |

## Key Screens

| Screen | Description |
|---|---|
| Splash | Animated logo with fade + scale |
| Home | Live stream feed, categories, recent streams |
| Broadcast | Go live with camera + chat |
| Viewer | Watch a live stream with chat overlay |
| Seller Hub | Dashboard for sellers to manage shows & products |
| Profile Edit | Update name, email, phone, address, and avatar |

## Building for Release

```bash
flutter build apk --release
flutter build appbundle --release
```
