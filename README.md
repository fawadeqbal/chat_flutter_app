# PingCrood Chat Application

A high-performance, real-time chat application built with Flutter and NestJS, featuring a professional UI and robust communication features.

## 🚀 Features

### 💬 Real-time Messaging
- **Instant Delivery**: Sub-millisecond delivery via Socket.io.
- **Advanced State**: Real-time statuses (Sent/Delivered/Seen), typing indicators, and reactions.
- **Pinned Content**: Pin messages for quick access in any chat session.

### � High-Fidelity Calls
- **WebRTC Powered**: Low-latency HD audio and video communication.
- **Direct Connect**: Instant matching without ringing or waiting screens.
- **Immersive UI**: Multi-tasking floating UI with camera/mic toggles and view switching.

### 🎲 Random Matchmaking
- **Live Discovery**: Search using your live camera feed as an immersive background.
- **Fluid Skipping**: Instant "Swipe-up" gesture to cycle through potential matches.
- **Live Awareness**: Real-time user queue counts and automated persistent re-matching.

### 🎨 User Experience
- **Modern UI**: Professional glassmorphism design with responsive Light/Dark modes.
- **Cross-Platform**: Tailored experiences for Web (Chrome) and Mobile (Android).
- **Notifications**: Integrated local alerts for incoming messages and events.

## 🏗 Architecture & Data Flow

PingCrood uses a decoupled, event-driven architecture:
- **Messaging**: Custom Socket.io logic for atomic writes (Prisma) and instant broadcasting.
- **Presence**: Redis-backed layer for real-time status (Online/Typing) with zero lag.
- **Integrity**: PostgreSQL and Prisma ensure type-safe consistency for relationships and history.

### Data Flow
1. **Security**: JWT-based WebSocket handshaking for encrypted communication.
2. **Alerts**: Real-time Socket events combined with integrated local notifications.
3. **Reactive UI**: Flutter Provider pattern for instant UI updates without reloads.

## 🛠 Technical Stack

| Component | Technology | Role |
|-----------|------------|------|
| **Frontend** | Flutter | Cross-platform UI & State (Provider) |
| **Real-time** | Socket.io | Bidirectional event networking |
| **Backend** | NestJS | Scalable modular API & Gateways |
| **Database** | PostgreSQL | Relational storage & Data integrity |
| **ORM** | Prisma | Type-safe database mapping |
| **Cache** | Redis | Presence engine & Matchmaking queue |

## 🗺 Roadmap
- [ ] **E2EE**: Signal Protocol for ultimate message privacy.
- [ ] **Group Calls**: Multi-party WebRTC video conferencing.
- [ ] **Rich Media**: Voice notes, HD document sharing, and polls.
- [ ] **AI Tools**: Intelligent moderation and smart chat indexing.

## ⚙️ Quick Start
1. **Backend**: `npm install` -> Configure `.env` -> `npx prisma db push` -> `npm run start:dev`
2. **Frontend**: `flutter pub get` -> Update `baseUrl` -> `flutter run`

## 🤝 Contributions & License
PingCrood is **Open Source (MIT)**. We welcome PRs! Please follow our established Linting patterns and maintain professional code standards.
