// File generated manually via IDE Firebase integration
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCPqGaIxZYuVlKVsJHmZ6aNs9t2zhMFDOs',
    appId: '1:30809295941:web:8ee74c7980db181c1f272c',
    messagingSenderId: '30809295941',
    projectId: 'klinik-poli',
    authDomain: 'klinik-poli.firebaseapp.com',
    storageBucket: 'klinik-poli.firebasestorage.app',
    measurementId: 'G-HBE0Y7P98F',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDOLaB5SjEXbV4ejhI3IfD178f2G4TBWPQ',
    appId: '1:30809295941:android:fce3eb5ad23a82a11f272c',
    messagingSenderId: '30809295941',
    projectId: 'klinik-poli',
    storageBucket: 'klinik-poli.firebasestorage.app',
  );
}
