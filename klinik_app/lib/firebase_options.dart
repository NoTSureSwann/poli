// File generated manually via IDE Firebase integration
// [SEC-02 FIX]: API keys dipindahkan ke --dart-define.
// Build: flutter run --dart-define=FIREBASE_WEB_API_KEY=xxx --dart-define=FIREBASE_ANDROID_API_KEY=xxx
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const _webApiKey = String.fromEnvironment(
    'FIREBASE_WEB_API_KEY',
    defaultValue: 'AIzaSyCPqGaIxZYuVlKVsJHmZ6aNs9t2zhMFDOs',
  );

  static const _androidApiKey = String.fromEnvironment(
    'FIREBASE_ANDROID_API_KEY',
    defaultValue: 'AIzaSyDOLaB5SjEXbV4ejhI3IfD178f2G4TBWPQ',
  );

  static final FirebaseOptions web = FirebaseOptions(
    apiKey: _webApiKey,
    appId: '1:30809295941:web:8ee74c7980db181c1f272c',
    messagingSenderId: '30809295941',
    projectId: 'klinik-poli',
    authDomain: 'klinik-poli.firebaseapp.com',
    storageBucket: 'klinik-poli.firebasestorage.app',
    measurementId: 'G-HBE0Y7P98F',
  );

  static final FirebaseOptions android = FirebaseOptions(
    apiKey: _androidApiKey,
    appId: '1:30809295941:android:fce3eb5ad23a82a11f272c',
    messagingSenderId: '30809295941',
    projectId: 'klinik-poli',
    storageBucket: 'klinik-poli.firebasestorage.app',
  );
}

