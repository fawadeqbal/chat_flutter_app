# PingCrood Chat Application

A high-performance, real-time chat application built with Flutter and NestJS, featuring a professional UI and robust communication features.

## 🚀 Key Features

### 💬 Real-time Messaging
- **Instant Communication**: Powered by Socket.io for sub-millisecond message delivery.
- **Message Status**: Real-time Sent, Delivered, and Seen indicators.
- **Typing Indicators**: Visual feedback when your partner is typing.
- **Pinned Messages**: Easily pin and access important information in any chat.
- **Message Reactions**: Express yourself with a wide range of interactive emoji reactions.

### 👥 Social & Networking
- **Presence Tracking**: Real-time Online/Offline status indicators.
- **Friend Management**: Full friend request system (Send, Accept, Decline).
- **QR Code Networking**: Unique QR codes for seamless user identification and networking.
- **Unified Profile**: Personalized profile with custom avatars and biographical info.

### 📞 High-Fidelity Audio & Video Calls
- **Crystal Clear Communication**: High-quality calling powered by WebRTC with low latency.
- **Direct Connect**: Instant connection for random matches, skipping the traditional ringing phase.
- **Background Preview**: Local camera stream remains active during transitions for a seamless experience.
- **Call Management**: Toggle camera/microphone, switch views, and hang up with a sleek floating UI.

### 🎲 Random Matchmaking
- **Live Discovery**: Immersive searching UI with your live camera feed as the background.
- **Swipe to Skip**: Quickly cycle through potential partners with an intuitive vertical swipe-up gesture.
- **Queue Awareness**: Real-time indicator showing exactly how many people are matching at that moment.
- **Persistent Loop**: Automatically return to searching when a partner leaves or skips, keeping you in the action!

### 🎨 User Experience
- **Premium Design**: Modern, responsive UI with advanced animations and glassmorphism.
- **Theme Engine**: Support for both vibrant Light and professional Dark modes.
- **Web & Mobile**: Fully cross-platform experience optimized for Chrome and Android.
- **Push Notifications**: Integrated local notifications to never miss a message.

## 🏗 System Explanation

### Architecture Overview
PingCrood follows a decoupled, event-driven architecture designed for high availability and low latency:
- **Event-Driven Messaging**: Core chat logic relies on a custom implementation of **Socket.io**. When a message is sent, the backend performs a transactional Prisma write and simultaneously broadcasts events to the sender's and receiver's active socket threads.
- **Presence Engine**: User status (Online/Offline/Typing) is managed via a dedicated Redis-backed presence layer within NestJS, ensuring that even under high load, status updates remain near-instantaneous.
- **Relational Integrity**: PostgreSQL ensures absolute data consistency for friend relationships, room memberships, and message history, while Prisma provides a type-safe interface for all database operations.

### Data Flow
1. **Connection**: Client establishes a secure WebSocket connection using JWT handshaking.
2. **Notification**: Incoming messages trigger both a WebSocket event (if the app is interactive) and a Local Notification (if the app is backgrounded).
3. **Synchronization**: The **Provider** pattern in Flutter ensures that any state change (new message, reaction, presence update) is immediately reflected across all relevant UI components without full-page reloads.

## 🛠 Technical Stack

### Frontend (Flutter)
- **State Management**: Provider with a structured notification architecture.
- **Networking**: Dio (HTTP) + Socket.io Client (Real-time).
- **Theme System**: Dynamic ThemeProvider for visual consistency.
- **Asset Handling**: Integrated image picker and file upload support.

### Backend (NestJS)
- **Framework**: NestJS for a scalable, modular architecture.
- **Real-time Gateway**: Custom Socket.io gateway for event-driven networking.
- **ORM & Database**: Prisma with PostgreSQL for efficient data management.
- **Presence Engine**: Redis-backed presence tracking for high-volume status updates.
- **Security**: JWT-based authentication with robust guard verification.
- **File Storage**: Professional static file serving with automated upload management.

## 📁 Project Structure

- `chat_flutter_app/`: Flutter mobile and web frontend.
- `chat-nest-backend/`: NestJS API and real-time backend service.

## ⚙️ Quick Start

1. **Backend Setup**:
   - `cd chat-nest-backend`
   - `npm install`
   - Configure `.env` with your PostgreSQL and SMTP details.
   - `npx prisma db push`
   - `npm run start:dev`

2. **Frontend Setup**:
   - `cd chat_flutter_app`
   - `flutter pub get`
   - Update `baseUrl` in `ApiClient` to point to your backend.
   - `flutter run`

## 🗺 Future Roadmap

We are constantly evolving. Here's what we have planned:
- [ ] **End-to-End Encryption (E2EE)**: Implementing Signal Protocol for ultimate message privacy.
- [ ] **WebRTC Group Calls**: Scaling our current 1-on-1 calling to support multi-party video conferencing.
- [ ] **AI-Powered Moderation**: Intelligent filtering and automated moderation for group environments.
- [ ] **Rich Media Sharing**: Dedicated support for high-fidelity voice notes, document sharing, and interactive polls.
- [ ] **Status Stories**: A professional "Updates" feed to share fleeting moments with your network.

## 🤝 Open Source & Contributions

PingCrood is proudly **Open Source** and open for contributions from the community! We believe in building the future of communication together.

### How to Contribute
1. **Fork the Repo**: Create your own copy of the project.
2. **Explore Issues**: Look for "good first issue" or "enhancement" tags in our issue tracker.
3. **Submit a PR**: We love clean code and detailed descriptions. Please ensure your code follows the established Linting patterns.
4. **Documentation**: Help us improve this README or contribute to our Wiki.

### Contribution Guidelines
- **Maintain Code Style**: We use strict linting rules for both Flutter and NestJS.
- **Write Tests**: Any new feature should ideally come with a verification test.
- **Be Professional**: We follow a standard Code of Conduct to ensure a welcoming environment for everyone.

### License
Distributed under the **MIT License**. See `LICENSE` for more information.
