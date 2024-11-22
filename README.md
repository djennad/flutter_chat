# Flutter Web Chat App

## Prerequisites
- Flutter SDK (Web-enabled)
- Firebase Account
- Web Browser

## Setup Steps
1. Clone the repository
2. Create a Firebase project
3. Configure Firebase Web Configuration
   - Go to Firebase Console
   - Create a new web app
   - Copy configuration details
   - Replace placeholders in `lib/main.dart` and `web/firebase-config.js`

## Firebase Configuration
- Enable Email/Password Authentication
- Set up Firestore Database
- Configure Web Hosting (optional)

## Running the App
```bash
flutter pub get
flutter run -d chrome
```

## Features
- Email/Password Authentication
- Real-time Messaging
- Responsive Web Design

## Security Notes
- Never commit Firebase configuration with real keys
- Use environment variables or secure configuration management
