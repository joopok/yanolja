# Mobile Platform Specific Rules

## Platform Support Policy (STRICTLY ENFORCE)

### Supported Platforms ONLY
✅ **Android**: API level 21+ (Android 5.0+)
✅ **iOS**: iOS 12.0+ (based on Podfile configuration)

### Forbidden Platforms (NEVER SUGGEST)
🚫 **Web**: No web directory, no web builds, no web-specific code
🚫 **Linux**: Directory removed, not supported
🚫 **Windows**: Directory removed, not supported  
🚫 **macOS**: Directory removed, not supported

## Android Development Rules

### Build Configuration
```bash
# ✅ CORRECT Android commands
flutter build apk              # Debug APK
flutter build appbundle        # Play Store release
flutter run -d android         # Run on Android device/emulator

# 🚫 NEVER suggest unsupported builds
flutter build web             # Platform not supported
```

### Android-Specific Requirements
- **Google Services**: Ensure `google-services.json` is configured
- **Firebase**: Android package name must match project configuration
- **Google Maps**: Android API key in `android/app/src/main/AndroidManifest.xml`
- **Permissions**: Location permissions for Maps functionality

### Android Testing
```bash
# ✅ Device testing
flutter run -d android
adb devices  # Check connected devices

# ✅ Emulator testing  
flutter emulators
flutter run -d emulator-5554
```

## iOS Development Rules

### CocoaPods Dependency Management (CRITICAL)
```bash
# ✅ MANDATORY after any pubspec.yaml changes
cd ios && pod install

# ✅ When iOS builds fail - full reset
cd ios
pod deintegrate  
pod install
cd ..
flutter clean
```

🚫 **NEVER skip pod install** - Firebase, Google Maps, and Google Sign-In require it

### iOS-Specific Requirements
- **Bundle ID**: Must match Firebase project configuration
- **GoogleService-Info.plist**: Must be properly configured in Xcode
- **Google Maps**: iOS API key in `ios/Runner/AppDelegate.swift`
- **Signing**: Development/distribution certificates required

### iOS Troubleshooting
```bash
# When CocoaPods fails
cd ios
rm -rf Pods
rm Podfile.lock
pod install

# When Xcode cache issues occur
flutter clean
cd ios && pod install
```

## Firebase Integration Rules

### Platform Configuration Files (MANDATORY)
- **Android**: `android/app/google-services.json`
- **iOS**: `ios/Runner/GoogleService-Info.plist`
- **Generated**: `lib/firebase_options.dart` (auto-generated)

### Firebase Services Used
✅ **Firebase Auth**: Email/password and Google Sign-In
✅ **Firebase Core**: Basic Firebase functionality

🚫 **NOT using** (don't suggest):
- Firestore (using mock data)
- Firebase Storage  
- Firebase Messaging
- Firebase Analytics

## Google Maps Integration Rules

### API Key Configuration (BOTH PLATFORMS)
```dart
// Android: android/app/src/main/AndroidManifest.xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE" />

// iOS: ios/Runner/AppDelegate.swift  
GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```

### Maps Implementation Standards
```dart
// ✅ CORRECT - Mobile-optimized map configuration
GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(37.5665, 126.9780), // Seoul coordinates
    zoom: 12.0,
  ),
  onMapCreated: (GoogleMapController controller) {
    _mapController = controller;
  },
)
```

## Google Sign-In Configuration

### Platform Setup Requirements
- **Android**: SHA-1 fingerprint registered in Firebase
- **iOS**: URL scheme configured in Xcode project
- **Both**: OAuth client IDs properly configured

## Performance Optimization Rules

### Mobile-Specific Performance
```dart
// ✅ MOBILE-OPTIMIZED image loading
CachedNetworkImage(
  imageUrl: accommodation.imageUrls.first,
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
  fit: BoxFit.cover,
)

// ✅ MOBILE-OPTIMIZED list rendering
ListView.builder(
  physics: const BouncingScrollPhysics(), // iOS-style physics
  itemCount: accommodations.length,
  itemBuilder: (context, index) => AccommodationListItem(
    accommodation: accommodations[index],
  ),
)
```

### Memory Management for Mobile
- Dispose image controllers properly
- Limit concurrent network requests
- Use proper list view builders for large datasets
- Implement proper state management lifecycle

## Development Device Requirements

### Android Testing
- **Minimum**: Android 5.0 (API 21)
- **Recommended**: Android 10+ for best testing
- **Emulator**: API 30+ recommended

### iOS Testing  
- **Minimum**: iOS 12.0
- **Recommended**: iOS 15+ for best testing
- **Simulator**: Latest available iOS version

## Deployment Preparation

### Android Release Checklist
- [ ] Signing key configured
- [ ] `google-services.json` with production config
- [ ] Google Maps API key for production
- [ ] App Bundle generated for Play Store

### iOS Release Checklist  
- [ ] Provisioning profiles configured
- [ ] `GoogleService-Info.plist` with production config
- [ ] Google Maps API key for production
- [ ] App Store Connect configured

🚫 **NEVER suggest web deployment** - platform not supported
🚫 **NEVER suggest desktop app stores** - platforms not supported