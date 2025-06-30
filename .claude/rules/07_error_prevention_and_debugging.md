# Error Prevention and Debugging Rules

## CRITICAL Error Prevention Strategies

### Entity-Model Mapping Verification (MOST COMMON ERROR SOURCE)

🚫 **NEVER assume field compatibility** between Entity and Model classes

✅ **MANDATORY verification process:**
1. **READ the actual Entity class** - verify field names and types
2. **READ the actual Model class** - verify field names and types  
3. **Compare structures** - identify mismatches
4. **Write safe mapping** - handle differences explicitly

```dart
// 🚫 DANGEROUS - Assuming field names match
BookingEntity(
  accommodationImageUrl: model.accommodationImageUrl,  // Field may not exist
  numberOfGuests: model.numberOfGuests,               // Wrong field name
)

// ✅ SAFE - Verified actual field structure first
BookingEntity(
  guests: model.numberOfGuests,                        // Correct Entity field name
  accommodationImages: [model.accommodationImageUrl], // Handle type conversion
  accommodationAddress: model.address ?? '',          // Provide defaults
)
```

### UseCase Call Syntax (SECOND MOST COMMON ERROR)

🚫 **NEVER use .execute() method** - it doesn't exist in this codebase

✅ **ALWAYS use call() method** (implicit in Dart):
```dart
// ✅ CORRECT - UseCase implements call() method
final accommodations = await useCase();
final user = await useCase(email, password);
final booking = await useCase(bookingData);

// 🚫 WRONG - These methods don't exist
final accommodations = await useCase.execute();
final user = await useCase.call();  // Explicit call not needed
```

### Provider Pattern Errors

```dart
// ✅ CORRECT - Proper provider dependency
final accommodationListProvider = FutureProvider<List<AccommodationEntity>>((ref) async {
  final useCase = ref.watch(getAccommodationsUseCaseProvider);  // Dependency injection
  return await useCase();
});

// 🚫 WRONG - Direct instantiation breaks DI
final accommodationListProvider = FutureProvider<List<AccommodationEntity>>((ref) async {
  final useCase = GetAccommodationsUseCase();  // Don't create directly
  return await useCase();
});
```

## Compilation Error Quick Fixes

### Missing Field Errors
```bash
# When you see: "The named parameter 'fieldName' isn't defined"
# 1. Check actual Entity/Model class structure
# 2. Verify field names exactly match
# 3. Check if field is required vs optional
```

### Type Mismatch Errors
```dart
// ✅ CORRECT - Handle type conversions
accommodationImages: model.imageUrl != null ? [model.imageUrl] : [],  // String to List<String>
guests: int.parse(model.guestCount),                                   // String to int
rating: double.tryParse(model.rating) ?? 0.0,                        // String to double with fallback
```

## Static Analysis Error Patterns

### Unused Import Warnings
```dart
// 🚫 CAUSES WARNING - Remove unused imports
import 'package:flutter/cupertino.dart';  // If not using Cupertino widgets

// ✅ CLEAN - Only import what you use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
```

### Dead Null-Aware Expression
```dart
// 🚫 ANALYZER ERROR - Variable cannot be null
final price = accommodation?.price ?? 0;  // When accommodation is non-nullable

// ✅ CORRECT - Remove unnecessary null check
final price = accommodation.price;
```

### Deprecated API Usage
```dart
// 🚫 DEPRECATED - Will cause build warnings
Colors.red.withOpacity(0.5)

// ✅ MODERN - Required for latest Flutter
Colors.red.withValues(alpha: 0.5)
```

## Firebase Integration Debugging

### Common Firebase Errors
```bash
# Error: "Default FirebaseApp is not initialized"
# Solution: Ensure Firebase.initializeApp() called in main()

# Error: "No such file google-services.json"  
# Solution: Add file to android/app/ directory

# Error: "GoogleService-Info.plist not found"
# Solution: Add file to ios/Runner/ and configure in Xcode
```

### Firebase Auth Debugging
```dart
// ✅ PROPER error handling for auth operations
try {
  final userCredential = await useCase(email, password);
  return userCredential.user;
} on FirebaseAuthException catch (e) {
  switch (e.code) {
    case 'user-not-found':
      throw Exception('등록되지 않은 이메일입니다');
    case 'wrong-password':
      throw Exception('비밀번호가 일치하지 않습니다');
    default:
      throw Exception('로그인에 실패했습니다: ${e.message}');
  }
}
```

## Google Maps Integration Debugging

### API Key Issues
```bash
# Error: "API key not valid"
# Check: API key correctly set in both platforms
# Check: Maps API enabled in Google Cloud Console
# Check: Bundle ID/Package name matches console configuration
```

### Maps Loading Issues
```dart
// ✅ PROPER map initialization
GoogleMap(
  onMapCreated: (GoogleMapController controller) {
    _mapController = controller;
    debugPrint('Map loaded successfully');  // Debug logging
  },
  onCameraMove: (CameraPosition position) {
    // Handle camera movements
  },
)
```

## Performance Debugging

### Memory Leak Detection
```dart
// ✅ REQUIRED - Always dispose controllers
@override
void dispose() {
  _scrollController.dispose();
  _animationController?.dispose();
  _subscription?.cancel();
  super.dispose();
}
```

### Image Loading Issues
```dart
// ✅ ROBUST image loading with error handling
CachedNetworkImage(
  imageUrl: accommodation.imageUrls.first,
  placeholder: (context, url) => const ShimmerLoader(),
  errorWidget: (context, url, error) {
    debugPrint('Image load failed: $url - $error');
    return const Icon(Icons.broken_image);
  },
)
```

## Development Workflow Error Prevention

### Pre-Commit Checklist (MANDATORY)
```bash
# ALWAYS run these before committing:
flutter analyze                    # Must pass without warnings
flutter pub deps                   # Check dependency health  
flutter doctor                     # Verify environment
```

### Common Build Failures
```bash
# iOS pod install issues
cd ios && pod deintegrate && pod install

# Android gradle sync issues  
cd android && ./gradlew clean

# Flutter cache corruption
flutter clean && flutter pub get
```

## Error Message Interpretation Guide

### Entity Field Errors
```
"The named parameter 'accommodationImages' isn't defined"
→ Check AccommodationEntity class for correct field name
→ Verify it's accommodationImages vs imageUrls vs images

"The argument type 'String' can't be assigned to parameter type 'List<String>'"
→ Handle type conversion: [stringValue] or stringValue.split(',')
```

### UseCase Errors  
```
"The method 'execute' isn't defined for the type 'GetAccommodationsUseCase'"
→ Use useCase() instead of useCase.execute()
→ Check UseCase class implements call() method

"Too many positional arguments: 0 expected, but 1 found"
→ Check UseCase parameter requirements
→ Verify method signature matches usage
```

### Provider Errors
```
"Cannot read a provider that was disposed"
→ Provider was disposed due to widget rebuild
→ Check provider lifecycle management

"Could not find a provider for type Repository"  
→ Verify DI container registration
→ Check import statements for provider
```

## Debugging Best Practices

### Logging Strategy
```dart
// ✅ STRUCTURED debug logging
debugPrint('🏨 Loading accommodations for category: $category');
debugPrint('✅ Successfully loaded ${accommodations.length} accommodations');
debugPrint('❌ Failed to load accommodations: $error');

// ✅ CONDITIONAL logging for development
if (kDebugMode) {
  print('Detailed debug info: $detailedData');
}
```

### Error Boundary Strategy
```dart
// ✅ GRACEFUL error handling in UI
Consumer(
  builder: (context, ref, child) {
    final asyncValue = ref.watch(accommodationListProvider);
    
    return asyncValue.when(
      data: (accommodations) => AccommodationList(accommodations),
      loading: () => const ShimmerLoader(),
      error: (error, stackTrace) {
        debugPrint('Error loading accommodations: $error');
        return ErrorWidget(
          message: '숙소 목록을 불러올 수 없습니다',
          onRetry: () => ref.refresh(accommodationListProvider),
        );
      },
    );
  },
)
```

🚫 **NEVER ignore errors** - always provide user-friendly error messages
✅ **ALWAYS log errors** for debugging while providing graceful UX degradation