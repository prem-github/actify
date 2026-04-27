import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Placeholder Firebase options for local scaffolding.
///
/// Replace this file with the generated output from:
/// `flutterfire configure --project=<project-id> --platforms=android`
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions are not configured for web in this project.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions are only scaffolded for Android.',
        );
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for Fuchsia.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FIREBASE_API_KEY',
    appId: 'REPLACE_WITH_FIREBASE_APP_ID',
    messagingSenderId: 'REPLACE_WITH_FIREBASE_SENDER_ID',
    projectId: 'REPLACE_WITH_FIREBASE_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_FIREBASE_STORAGE_BUCKET',
  );
}

