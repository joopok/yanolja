# Architecture Rules - Clean Architecture Implementation

## MANDATORY Architecture Patterns

### Clean Architecture Layers (STRICTLY ENFORCE)
```
lib/
├── domain/          # Business Logic Layer - NO external dependencies
├── data/           # Data Layer - Implements domain interfaces  
├── presentation/   # UI Layer - Depends on domain only
└── core/          # Shared utilities and DI container
```

🚫 **NEVER violate dependency rules:**
- Domain layer MUST NOT import from data or presentation
- Data layer MUST NOT import from presentation
- Always depend inward (toward domain)

✅ **ALWAYS follow these patterns:**

### 1. UseCase Pattern
```dart
// ✅ CORRECT: Use call() method, NOT execute()
class GetAccommodationsUseCase {
  Future<List<AccommodationEntity>> call() async {
    return await repository.getAllAccommodations();
  }
}

// Usage in providers:
final accommodations = await useCase(); // ✅ CORRECT
final accommodations = await useCase.execute(); // 🚫 WRONG
```

### 2. Repository Pattern
```dart
// ✅ Domain layer - Interface only
abstract class AccommodationRepository {
  Future<List<AccommodationEntity>> getAllAccommodations();
}

// ✅ Data layer - Implementation
class AccommodationRepositoryImpl implements AccommodationRepository {
  final AccommodationDataSource dataSource;
  // Implementation details...
}
```

### 3. Entity-Model Mapping (CRITICAL)
🚫 **NEVER assume field names match** between Entity and Model
✅ **ALWAYS verify actual field structures** before mapping

```dart
// ✅ CORRECT: Verify field names first
BookingEntity(
  guests: model.numberOfGuests,  // Map to correct field name
  accommodationImages: [model.accommodationImageUrl], // Handle type differences
)
```

### 4. Dependency Injection
✅ **ALWAYS use the established DI container** in `core/di/injection_container.dart`
🚫 **NEVER create direct instances** of repositories or use cases in UI

## Provider Architecture Rules

### Two Provider Systems (TRANSITIONAL)
1. **Legacy Providers**: Direct data access (being phased out)
2. **Clean Providers**: UseCase-based (preferred for new features)

✅ **For new features, ALWAYS use Clean Provider pattern:**
```dart
final accommodationListProvider = FutureProvider<List<AccommodationEntity>>((ref) async {
  final useCase = ref.watch(getAccommodationsUseCaseProvider);
  return await useCase();
});
```

### Riverpod Best Practices
- Use `FutureProvider` for async data loading
- Use `Provider.family` for parameterized providers
- Maintain consistent error handling across all providers
- Keep provider logic minimal - delegate to use cases