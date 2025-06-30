# Data and State Management Rules

## Riverpod State Management (MANDATORY PATTERNS)

### Provider Types and Usage Rules
```dart
// ✅ CORRECT - FutureProvider for async data
final accommodationListProvider = FutureProvider<List<AccommodationEntity>>((ref) async {
  final useCase = ref.watch(getAccommodationsUseCaseProvider);
  return await useCase();
});

// ✅ CORRECT - Provider.family for parameterized data
final accommodationsByCategoryProvider = FutureProvider.family<List<AccommodationEntity>, String>((ref, category) async {
  final useCase = ref.watch(getAccommodationsByCategoryProvider);
  return await useCase(category);
});

// ✅ CORRECT - Simple Provider for non-async data
final themeProvider = Provider<ThemeData>((ref) {
  return AppTheme.lightTheme;
});
```

### Provider Naming Convention (STRICTLY ENFORCE)
```dart
// ✅ CORRECT naming patterns
final accommodationListProvider = ...        // List of items
final accommodationByIdProvider = ...        // Single item by ID
final accommodationsByCategoryProvider = ... // Filtered list
final createBookingUseCaseProvider = ...     // Use case providers
final userRepositoryProvider = ...           // Repository providers

// 🚫 WRONG - Unclear or inconsistent naming
final dataProvider = ...                     // Too vague
final getStuffProvider = ...                 // Unclear purpose
```

## Mock Data Management Rules

### Data Structure Requirements (CRITICAL)
🚫 **NEVER have insufficient mock data** - each category needs substantial data for testing

✅ **MANDATORY minimum data requirements:**
- **Hotels**: 50+ entries across major Korean cities
- **Pensions**: 30+ entries with seasonal variations
- **Resorts**: 25+ entries with luxury amenities
- **Hanoks**: 20+ entries with traditional features

### Mock Data Standards
```dart
// ✅ CORRECT - Realistic, diverse mock data
AccommodationModel(
  id: 'hotel_001',
  name: '신라호텔 서울',                    // Korean names
  category: '호텔',                        // Proper categories
  price: 280000,                           // Realistic pricing (75k-500k)
  rating: 4.8,                            // Believable ratings (3.5-5.0)
  address: '서울특별시 중구 동호로 249',     // Real-style addresses
  imageUrls: [                            // Multiple high-quality images
    'https://example.com/hotel1_1.jpg',
    'https://example.com/hotel1_2.jpg',
  ],
)

// 🚫 WRONG - Insufficient or unrealistic data
AccommodationModel(
  id: 'test1',                             // Poor naming
  name: 'Test Hotel',                      // Not Korean context
  price: 1000,                            // Unrealistic pricing
  rating: 5.0,                            // Every rating perfect
)
```

### Geographic Distribution Rules
✅ **MUST cover major Korean regions:**
- 서울 (Seoul): 30%+ of accommodations
- 부산 (Busan): 15%+ of accommodations  
- 제주 (Jeju): 20%+ of accommodations
- 강원도 (Gangwon): 15%+ of accommodations
- Other regions: Remaining distribution

## Category-Specific Data Rules

### Hotel Category Standards
```dart
// ✅ REQUIRED hotel-specific features
AccommodationModel(
  category: '호텔',
  amenities: [
    '비즈니스센터', '컨시어지', '룸서비스', '피트니스센터',
    '레스토랑', '바/라운지', '회의실', '주차장'
  ],
  hasWifi: true,               // Business travel essentials
  hasParking: true,
  hasBreakfast: true,
)
```

### Pension Category Standards  
```dart
// ✅ REQUIRED pension-specific features
AccommodationModel(
  category: '펜션',
  amenities: [
    '바베큐시설', '개별테라스', '독채펜션', '애완동물동반',
    '수영장', '가족룸', '취사가능', '주방용품'
  ],
  seasonalImages: SeasonalImagesModel(
    spring: ['spring1.jpg', 'spring2.jpg'],
    summer: ['summer1.jpg', 'summer2.jpg'],
    autumn: ['autumn1.jpg', 'autumn2.jpg'],
    winter: ['winter1.jpg', 'winter2.jpg'],
  ),
  theme: '가족여행',  // or '커플', '친구'
)
```

### Resort Category Standards
```dart
// ✅ REQUIRED resort-specific features  
AccommodationModel(
  category: '리조트',
  amenities: [
    '풀빌라', '스위트룸', '오션뷰', '스파', '골프장',
    '마리나', '키즈클럽', '올인클루시브', '컨시어지'
  ],
  price: 300000,  // Higher price range (200k-500k)
)
```

### Hanok Category Standards
```dart
// ✅ REQUIRED hanok-specific features
AccommodationModel(
  category: '한옥',
  amenities: [
    '전통온돌', '마당', '전통차체험', '한복체험',
    '전통건축', '문화해설', '조식제공'
  ],
  description: '조선시대 양반가의 전통을 그대로...',  // Cultural context
)
```

## Search and Filtering Rules

### Search Provider Standards
```dart
// ✅ CORRECT - Comprehensive search functionality
final searchResultsProvider = FutureProvider.family<List<AccommodationEntity>, String>((ref, query) async {
  if (query.isEmpty) return [];
  
  final useCase = ref.watch(searchAccommodationsUseCaseProvider);
  return await useCase(query);
});

// ✅ CORRECT - Search history management
final searchHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
  return SearchHistoryNotifier();
});
```

### Filtering Standards
- **Category filtering**: Exact match on category field
- **Price filtering**: Range-based filtering
- **Location filtering**: Address-based or region-based
- **Amenity filtering**: Array intersection logic
- **Rating filtering**: Minimum rating threshold

## State Management Best Practices

### Provider Lifecycle
```dart
// ✅ CORRECT - Proper provider cleanup
@override
void dispose() {
  // Cancel subscriptions
  // Clear cached data when appropriate
  super.dispose();
}
```

### Error Handling in Providers
```dart
// ✅ CORRECT - Consistent error handling
final accommodationListProvider = FutureProvider<List<AccommodationEntity>>((ref) async {
  try {
    final useCase = ref.watch(getAccommodationsUseCaseProvider);
    return await useCase();
  } catch (e) {
    // Log error for debugging
    debugPrint('Failed to load accommodations: $e');
    throw Exception('숙소 목록을 불러올 수 없습니다');  // Korean user message
  }
});
```

### Caching Strategy
- **Accommodation lists**: Cache for 5 minutes
- **User data**: Cache until logout
- **Search results**: No caching (real-time)
- **Images**: Use `cached_network_image` package

## Data Validation Rules

### Entity Validation (MANDATORY)
```dart
// ✅ REQUIRED field validation
class AccommodationEntity {
  final String id;            // NEVER empty
  final String name;          // NEVER empty  
  final int price;           // ALWAYS > 0
  final double rating;       // ALWAYS 0.0-5.0 range
  final List<String> imageUrls;  // NEVER empty
  
  const AccommodationEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.imageUrls,
  }) : assert(price > 0, 'Price must be positive'),
       assert(rating >= 0.0 && rating <= 5.0, 'Rating must be 0-5'),
       assert(imageUrls.isNotEmpty, 'At least one image required');
}
```

🚫 **NEVER allow invalid data** to propagate through the system
✅ **ALWAYS validate at entity creation** time