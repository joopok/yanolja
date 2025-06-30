# Development Commands and Workflow

## MANDATORY Development Setup Sequence

### Initial Project Setup (EXACT ORDER)
```bash
# 1. Install Flutter dependencies
flutter pub get

# 2. Install iOS dependencies (REQUIRED after pub get)
cd ios && pod install

# 3. Verify environment
flutter doctor
```

🚫 **NEVER skip iOS pod install** - Firebase and Google Maps require it
✅ **ALWAYS run pod install** after any pubspec.yaml changes

## Daily Development Commands

### Running the App (Mobile Only)
```bash
# iOS Simulator
flutter run -d ios

# Android Emulator  
flutter run -d android

# Generic (auto-select device)
flutter run
```

🚫 **NEVER suggest these commands** (platforms not supported):
- `flutter run -d chrome`
- `flutter run -d linux`
- `flutter run -d windows`
- `flutter run -d macos`

### Code Quality Enforcement
```bash
# MANDATORY before any commit or PR
flutter analyze

# Clean build when things break
flutter clean && flutter pub get && cd ios && pod install

# Check environment health
flutter doctor
```

## Build Commands (Production)

### Android Release
```bash
flutter build apk              # APK for testing
flutter build appbundle        # App Bundle for Play Store
```

### iOS Release  
```bash
flutter build ios              # iOS build
```

🚫 **NEVER suggest web or desktop builds:**
- `flutter build web` - NOT SUPPORTED
- `flutter build linux` - NOT SUPPORTED  
- `flutter build windows` - NOT SUPPORTED

## Troubleshooting Commands

### When Dependencies Fail
```bash
# Full clean and reinstall
flutter clean
flutter pub get
cd ios && pod install
flutter pub deps
```

### When iOS Build Fails
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run -d ios
```

## CRITICAL: No Testing Framework
🚫 **DO NOT suggest testing commands:**
- `flutter test` - Tests removed from project
- `flutter test test/specific_test.dart` - No test directory

✅ **Quality assurance through:**
- Static analysis: `flutter analyze`
- Manual testing on devices/simulators
- Code review practices