# Code Quality and Best Practices

## MANDATORY Code Quality Standards

### Import Management (STRICTLY ENFORCE)
```dart
// ✅ CORRECT import organization
import 'package:flutter/material.dart';           // Flutter framework
import 'package:flutter_riverpod/flutter_riverpod.dart';  // Third-party packages
import 'package:yanolja_clone/domain/entities/accommodation_entity.dart';  // Project imports

// 🚫 NEVER leave unused imports - causes analyzer warnings
import 'package:flutter/cupertino.dart';  // Remove if not used
```

### Null Safety Rules (CRITICAL)
```dart
// ✅ CORRECT - Proper null checking
if (accommodation != null) {
  return accommodation.price;
}

// 🚫 WRONG - Dead null-aware expression (analyzer error)
final price = accommodation?.price ?? 0;  // When accommodation cannot be null
```

### String Formatting Standards
```dart
// ✅ MODERN - Use string interpolation
'Price: $price'
'User: ${user.name}'

// 🚫 DEPRECATED - String concatenation
'Price: ' + price.toString()
'User: ' + user.name
```

### Logging Standards
```dart
// ✅ PRODUCTION-SAFE logging
import 'package:flutter/foundation.dart';

debugPrint('Debug information');  // Removed in production builds

if (kDebugMode) {
  print('Development only message');
}

// 🚫 NEVER use raw print in production code
print('This will show in production');  // Analyzer warning
```

## Clean Code Principles

### Function and Method Design
```dart
// ✅ GOOD - Single responsibility, clear purpose
Widget _buildSearchField(ThemeData theme) {
  return SizedBox(height: 42, child: TextField(...));
}

// ✅ GOOD - Descriptive parameter names
Future<List<AccommodationEntity>> getAccommodationsByCategory(String category)

// 🚫 AVOID - Dead code (unused methods/fields)
void _handleFavorites() { /* Never called */ }  // Remove unused methods
```

### Const Optimization
```dart
// ✅ CORRECT - Use const when possible
const SizedBox(height: 8)
const Text('Static text')

// ✅ CORRECT - Don't force const when not beneficial  
SizedBox(height: dynamicHeight)  // No const needed
```

## Error Prevention Strategies

### Entity-Model Mapping (CRITICAL)
🚫 **NEVER assume field compatibility** between layers

✅ **ALWAYS verify before mapping:**
1. Check actual Entity field names in domain layer
2. Check actual Model field names in data layer  
3. Verify data types match or can be converted
4. Handle missing or optional fields properly

```dart
// ✅ SAFE mapping pattern
static AccommodationEntity toEntity(AccommodationModel model) {
  return AccommodationEntity(
    id: model.id,                    // Verify field exists
    name: model.name,                // Verify type matches
    guests: model.numberOfGuests,    // Handle field name differences
    amenities: model.amenities ?? [], // Handle nullable fields
  );
}
```

### UseCase Integration Patterns
```dart
// ✅ CORRECT - Direct call syntax
final result = await useCase();
final result = await useCase(parameter);

// 🚫 WRONG - Method doesn't exist
final result = await useCase.execute();
final result = await useCase.call();  // Explicit call not needed
```

## Static Analysis Compliance

### Flutter Analyze Rules
✅ **MUST pass without warnings:**
- No unused imports
- No dead code
- No deprecated API usage
- Proper null safety
- Consistent formatting

### Code Organization
```dart
// ✅ File naming convention
accommodation_entity.dart        // snake_case
accommodation_repository.dart    // descriptive names
get_accommodations_usecase.dart  // clear purpose

// ✅ Class naming convention  
class AccommodationEntity        // PascalCase
class GetAccommodationsUseCase   // Clear, descriptive
```

## Performance Best Practices

### Widget Performance
```dart
// ✅ EFFICIENT - Proper ListView usage
ListView.builder(
  itemCount: accommodations.length,
  itemBuilder: (context, index) => AccommodationListItem(
    accommodation: accommodations[index],
  ),
)

// 🚫 INEFFICIENT - Building entire list
Column(
  children: accommodations.map((acc) => AccommodationListItem(acc)).toList(),
)
```

### Memory Management
```dart
// ✅ REQUIRED - Dispose resources
@override
void dispose() {
  _controller.dispose();
  _subscription?.cancel();
  super.dispose();
}
```

## Critical Code Review Checklist

Before any commit, verify:
- [ ] `flutter analyze` passes without warnings
- [ ] No unused imports or dead code
- [ ] All string concatenation uses interpolation
- [ ] No raw `print()` statements in production code
- [ ] Proper null safety patterns
- [ ] Entity-Model mapping verified
- [ ] UseCase calls use correct syntax
- [ ] Mobile-only patterns (no web/desktop code)

🚫 **NEVER commit code that:**
- Has analyzer warnings
- Uses deprecated APIs
- Contains dead code
- Includes debug print statements
- Breaks Clean Architecture rules