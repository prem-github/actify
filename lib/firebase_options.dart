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
    apiKey: 'AIzaSyBllkkTTOsEFzfoMG7AOi1nAyj_yjp2Goo',
    appId: '1:204692743667:android:f984178965e0fb36349e86',
    messagingSenderId: '204692743667',
    projectId: 'actify-f0e1f',
    storageBucket: 'actify-f0e1f.firebasestorage.app',
  );

}
