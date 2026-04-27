# Actify

Starter Flutter Android app using Firebase, Riverpod, `go_router`, and a clean architecture-friendly structure.

## Included

- Android app ID: `com.actify.app`
- Firebase bootstrap in `main.dart`
- Riverpod root setup
- Auth-aware routing
- Service wrappers for Auth, Firestore, and Storage
- Feature-first folders with `data`, `domain`, and `presentation`

## Folder Structure

```text
lib/
  core/
    config/
    router/
    theme/
  features/
    auth/
      data/
      domain/
      presentation/
    home/
      presentation/
  services/
  shared/
```

## Firebase Setup

This repo includes a placeholder `lib/firebase_options.dart` so the project structure is complete.
Replace it with a generated file from FlutterFire CLI before running the app against Firebase.

Expected steps once Flutter tooling is installed:

```bash
flutter pub get
dart pub global activate flutterfire_cli
flutterfire configure --project=<your-firebase-project-id> --platforms=android --android-package-name=com.actify.app
```

Then place the generated `google-services.json` in:

```text
android/app/google-services.json
```

## Recommended Verification

```bash
flutter analyze
flutter test
flutter run
```

