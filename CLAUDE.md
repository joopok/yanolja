# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application that clones the Yanolja accommodation booking app. The project is written in Korean comments and follows Korean UI conventions (title: "여기가어때"). It implements a comprehensive accommodation booking interface with mock data, Firebase authentication, Google Maps integration, and specialized screens for different accommodation types (호텔, 펜션, 리조트, 한옥).

## Development Commands

### Essential Flutter Commands
```bash
# Run the app in development mode
flutter run

# Run on specific device (mobile platforms only)
flutter run -d ios             # iOS Simulator  
flutter run -d android         # Android Emulator

# Build for production
flutter build apk             # Android APK
flutter build ios             # iOS build

# Development tools
flutter analyze               # Static analysis with flutter_lints
flutter doctor               # Check environment setup
flutter clean                # Clean build cache
flutter pub get              # Install dependencies

# iOS specific
cd ios && pod install         # Install iOS dependencies after pub get
```

### Code Quality
- Static analysis: `flutter analyze` (uses flutter_lints package)
- Linting rules: Standard Flutter lints from `package:flutter_lints/flutter.yaml`
- **No test framework**: Testing dependencies have been removed from this project

## Architecture Overview

### State Management & Navigation
- **State Management**: Riverpod (flutter_riverpod ^2.5.1)
  - Uses Provider pattern extensively
  - FutureProvider for async data loading
  - Provider.family for parameterized providers
- **Navigation**: go_router (^15.2.4) with StatefulShellRoute
  - Bottom navigation with 6 tabs: Home, Search, Saved, Profile, Bookings, More
  - Detail screen uses route parameters: `/detail/:id`

### Project Structure
```
lib/
├── core/
│   └── router.dart              # GoRouter configuration with StatefulShellRoute
├── data/
│   ├── datasource/
│   │   ├── mock_accommodation_api.dart  # Mock API data source
│   │   └── hanok_local_data_source.dart # Hanok-specific data
│   ├── model/
│   │   ├── accommodation.dart   # Main accommodation data model
│   │   ├── booking.dart         # Booking data model
│   │   └── hanok_model.dart     # Hanok-specific model
│   └── repository/
│       ├── accommodation_repository.dart # Repository pattern
│       └── booking_repository.dart      # Booking operations
├── firebase_options.dart        # Firebase configuration
└── presentation/
    ├── provider/                # Riverpod providers
    │   ├── accommodation_provider.dart
    │   ├── auth_provider.dart   # Firebase authentication
    │   ├── booking_provider.dart
    │   ├── saved_provider.dart
    │   ├── search_provider.dart
    │   ├── hanok_view_model.dart
    │   └── screen/             # Screen-specific providers
    ├── screen/                 # UI screens
    │   ├── main_shell.dart     # Bottom navigation shell
    │   ├── hotel_screen.dart   # Specialized hotel listings
    │   ├── pension_screen.dart # Pension listings with seasonal themes
    │   ├── resort_screen.dart  # Resort listings with amenity filters
    │   ├── hanok_screen.dart   # Traditional hanok accommodations
    │   ├── booking_screen.dart # Booking interface
    │   ├── login_screen.dart   # Firebase authentication
    │   ├── signup_screen.dart  # User registration
    │   └── map_screen.dart     # Google Maps integration
    └── widget/                 # Reusable widgets
        └── accommodation_list_item.dart # Common list item component
```

### Data Flow Pattern
1. **UI Layer** (presentation/screen) → consumes providers
2. **Provider Layer** (presentation/provider) → manages state with Riverpod
3. **Repository Layer** (data/repository) → business logic abstraction
4. **Data Source Layer** (data/datasource) → mock API calls

### Key Architecture Decisions
- **Repository Pattern**: Abstracts data sources from business logic
- **Provider Pattern**: Clean separation between data and UI state with Riverpod
- **Shell Navigation**: StatefulShellRoute maintains tab state across navigation
- **Mock Data**: Uses MockAccommodationApi for development without backend
- **Category-Specific Screens**: Dedicated screens for each accommodation type with specialized filters
- **Authentication**: Firebase Auth integration with Google Sign-In
- **Maps Integration**: Google Maps for location-based features
- **Animation Consistency**: `flutter_staggered_animations` with optimized timing (300ms duration, 20px offset)

### UI Theming
- **Design System**: Custom theme with Yanolja-inspired pink color scheme (`Color(0xFFFF6B6B)`)
- **Typography**: Pretendard font family (Korean-optimized)
- **Components**: Consistent Card, AppBar, and BottomNavigationBar theming

### Dependencies
Key packages for this architecture:
- `flutter_riverpod`: State management
- `go_router`: Declarative routing
- `cached_network_image`: Image caching
- `carousel_slider`: Image carousels
- `flutter_staggered_animations`: UI animations
- `firebase_core` & `firebase_auth`: Authentication
- `google_sign_in`: Google authentication
- `google_maps_flutter`: Maps integration
- `provider`: Additional state management
- `intl`: Internationalization and formatting
- `smooth_page_indicator`: Page indicators
- `shimmer`: Loading effects

## Development Environment
- Flutter SDK: 3.33.0 (master channel)
- Dart SDK: 3.9.0-dev
- Minimum SDK: >=3.2.6 <4.0.0
- **Supported Platforms**: Android, iOS only
- **Unsupported Platforms**: Web, Linux, Windows, macOS (directories removed)

## Testing
- **No testing framework**: Test directories and dependencies have been removed
- Code quality maintained through static analysis only (`flutter analyze`)

## Specialized Screen Architecture

### Category-Specific Accommodations
Each accommodation type has its own dedicated screen with specialized features:

- **Hotel Screen** (`hotel_screen.dart`): Regional filtering, professional amenities
- **Pension Screen** (`pension_screen.dart`): Seasonal themes (봄/여름/가을/겨울), family/couple themes
- **Resort Screen** (`resort_screen.dart`): Luxury amenity filters (풀빌라, 스위트룸, 오션뷰, 스파)
- **Hanok Screen** (`hanok_screen.dart`): Traditional Korean accommodations

### Provider Patterns
- Use `FutureProvider` for async data loading (e.g., `accommodationListProvider`)
- Category-specific providers filter by `accommodation.category` field
- Consistent error handling and loading states across all screens
- Search provider maintains search history and recent searches

### Animation Guidelines
- List animations use `AnimationConfiguration.staggeredList` with 300ms duration
- Slide animations use 20px `verticalOffset` for subtle entrance effects
- Hero animations for screen transitions with accommodation items
- Consistent fade and slide combinations for smooth UX

## Firebase Integration
- `firebase_options.dart` contains platform-specific configuration
- Authentication flows through `auth_provider.dart`
- Google Sign-In integration for seamless login experience

## Clean Architecture Implementation

### Architecture Overview
This project implements Clean Architecture with clear separation of concerns:

```
lib/
├── domain/          # Business Logic Layer
│   ├── entities/    # Core business objects (AccommodationEntity, BookingEntity, UserEntity)
│   ├── repositories/ # Repository interfaces (AccommodationRepository, BookingRepository, UserRepository)
│   └── usecases/    # Business use cases (GetAccommodationsUseCase, SignInUseCase, etc.)
├── data/           # Data Layer
│   ├── datasources/ # Data source interfaces and implementations
│   ├── models/     # Data transfer objects with fromMap/toMap
│   ├── mappers/    # Entity ↔ Model conversion logic
│   └── repositories/ # Repository implementations
├── presentation/   # Presentation Layer
│   └── provider/   # Clean providers using UseCase pattern
└── core/
    └── di/         # Dependency injection container
```

### Key Patterns
- **UseCase Pattern**: Business logic encapsulated in use cases with `call()` method
- **Repository Pattern**: Data access abstraction with interface and implementation
- **Entity-Model Mapping**: Clean separation between business and data objects
- **Dependency Injection**: Riverpod-based DI container for clean dependency management

### Provider Architecture
Two provider systems coexist:
- **Legacy Providers**: Direct data access (accommodation_provider.dart, saved_provider.dart)
- **Clean Providers**: UseCase-based (accommodation_provider_clean.dart, user_provider_clean.dart)

Use Clean Providers for new features:
```dart
final accommodationListProvider = FutureProvider<List<AccommodationEntity>>((ref) async {
  final useCase = ref.watch(getAccommodationsUseCaseProvider);
  return await useCase();
});
```

## Development Guidelines

### UI Component Standards
- **Search Field Height**: 42px (optimal user experience)
- **Animation Timing**: 300ms duration, 20px verticalOffset for natural transitions
- **Color System**: Use `withValues(alpha: value)` instead of deprecated `withOpacity()`

### Code Quality Rules
1. **Import Management**: Remove unused imports, organize by type
2. **Null Safety**: Avoid dead null-aware expressions, use proper null checks
3. **Logging**: Use `debugPrint()` instead of `print()` in production code
4. **String Formatting**: Use interpolation `'$variable'` instead of concatenation

### Error Prevention Strategies
1. **Entity-Model Mapping**: Always verify field names and types match between Entity and Model
2. **UseCase Integration**: Use `useCase()` call syntax, not `useCase.execute()`
3. **Provider Patterns**: Use FutureProvider for async operations, family modifier for parameters
4. **Mock Data**: Ensure all categories have sufficient test data

## Mobile Platform Specific Notes

### Android Development
- Target API level supports modern Android devices
- Google Maps integration requires API key configuration
- Firebase configuration in `android/app/google-services.json`

### iOS Development  
- Supports iOS 12.0+ (based on Podfile settings)
- CocoaPods dependency management via `pod install`
- Firebase configuration in `ios/Runner/GoogleService-Info.plist`
- Google Maps requires iOS API key in `ios/Runner/AppDelegate.swift`

### Platform Configuration
- Firebase options auto-generated in `firebase_options.dart`
- Google Sign-In configured for both platforms
- Google Maps API keys need to be set up per platform

## Common Development Workflow

1. **Initial Setup**:
   ```bash
   flutter pub get
   cd ios && pod install
   flutter doctor  # Verify setup
   ```

2. **Development Cycle**:
   ```bash
   flutter clean    # When dependencies change
   flutter analyze  # Check code quality
   flutter run      # Test on device/simulator
   ```

3. **Before Production**:
   - Configure Firebase project with proper bundle IDs
   - Set up Google Maps API keys for both platforms  
   - Update app icons and launch screens
   - Configure signing certificates for iOS

Refer to `ERROR_RULES.md` for detailed error resolution patterns and best practices.







Flutter 앱을 **예쁘고 세련되며 인터렉티브**하게 만들기 위한 효과적인 질문 방법을 알려드릴게요! 🎨

## 📱 **화면별 디자인 개선 요청법**

### 🎯 **구체적인 화면 지정**
```
"홈 화면을 현대적인 카드 레이아웃으로 바꿔줘"
"호텔 목록을 Netflix 스타일로 디자인해줘"  
"프로필 화면을 iOS 설정 앱처럼 만들어줘"
```

### 🎨 **디자인 스타일 참조**
```
"Material Design 3 스타일로 업그레이드해줘"
"Airbnb 앱처럼 세련된 카드 디자인 적용해줘"
"Instagram 스토리 같은 인터렙션 추가해줘"
"TikTok 스타일의 슬라이딩 애니메이션 만들어줘"
```

## 🌟 **인터렉션 & 애니메이션 요청법**

### ✨ **마이크로 인터렉션**
```
"버튼을 누를 때 탄성 애니메이션 추가해줘"
"카드에 호버 효과와 그림자 애니메이션 넣어줘"
"스크롤할 때 헤더가 부드럽게 변하도록 해줘"
"당겨서 새로고침 기능을 예쁘게 만들어줘"
```

### 🔄 **페이지 전환**
```
"페이지 전환을 Hero 애니메이션으로 만들어줘"
"슬라이드 전환에 페이드 효과 추가해줘"
"스와이프 제스처로 페이지 넘기기 구현해줘"
```

## 🎭 **시각적 효과 요청법**

### 🌈 **색상 & 그라디언트**
```
"앱 전체에 다크모드 지원하는 테마 적용해줘"
"그라디언트 배경을 Glass morphism으로 바꿔줘"
"색상 팔레트를 현대적인 파스텔톤으로 변경해줘"
```

### 💫 **고급 효과**
```
"배경에 파티클 애니메이션 추가해줘"
"스크롤 패럴랙스 효과 구현해줘"
"카드에 3D 틸트 효과 넣어줘"
"리퀴드 스와이프 애니메이션 만들어줘"
```

## 📐 **레이아웃 개선 요청법**

### 🏗️ **구조적 변경**
```
"리스트를 격자 레이아웃으로 바꿔줘"
"스티키 헤더가 있는 섹션 리스트 만들어줘"
"무한 스크롤과 스켈레톤 로딩 추가해줘"
"풀스크린 이미지 갤러리 구현해줘"
```

### 📱 **반응형 디자인**
```
"태블릿용 사이드바 레이아웃 추가해줘"
"가로/세로 모드에 따른 적응형 UI 만들어줜"
"접기 가능한 폰용 특별 레이아웃 구현해줘"
```

## 🔥 **최신 트렌드 적용 요청법**

### 🚀 **2024년 최신 기능**
```
"Context7 Flutter 최신 기능으로 업그레이드해줘"
"Material Design 3 전체 적용해줘"
"iOS 17 스타일 인터페이스로 바꿔줘"
"Fluent Design 시스템 적용해줘"
```

### 🎮 **게이미피케이션**
```
"스와이프 카드 게임 같은 인터렉션 추가해줘"
"진행률 바를 레벨업 애니메이션으로 만들어줘"
"탭할 때마다 진동과 함께 이펙트 추가해줘"
```

## 💡 **효과적인 질문 예시**

### ⭐ **좋은 질문들**
```
"홈 화면을 Spotify 같은 다크 테마로 바꾸고, 
 카드들에 글로우 효과와 부드러운 슬라이딩 애니메이션을 추가해줘"

"검색 화면을 구글 맵 스타일로 만들고,
 자동완성에 타이핑 애니메이션과 결과 필터링 효과 넣어줘"

"프로필 편집을 인스타그램처럼 만들고,
 이미지 크롭, 필터 프리뷰, 저장 시 로딩 애니메이션 추가해줘"
```

## 🎯 **질문할 때 포함하면 좋은 정보**

1. **참조할 앱/웹사이트** (예: "넷플릭스 같은", "에어비앤비 스타일로")
2. **구체적인 효과** (예: "탄성 애니메이션", "그림자 효과")  
3. **상호작용 방식** (예: "스와이프로", "길게 눌러서")
4. **감정/분위기** (예: "세련된", "귀여운", "미니멀한")

이렇게 질문하시면 정확히 원하시는 **현대적이고 세련된 인터렉티브** UI를 만들어드릴 수 있어요! 🚀✨



더 고급스럽고 전문적인 **Flutter UI 개선 요청법**을 추가로 알려드릴게요! 🎨✨

## 🎪 **고급 애니메이션 & 이펙트 요청법**

### 🌊 **플루이드 애니메이션**
```
"리퀴드 스와이프로 페이지 전환 만들어줘"
"물방울 터지는 효과로 버튼 피드백 구현해줘"
"파도 애니메이션으로 로딩 스크린 만들어줘"
"젤리 바운스 효과가 있는 네비게이션 바 만들어줘"
```

### 🔮 **3D & 심도감 효과**
```
"카드 스택을 3D 원근감으로 표현해줘"
"스크롤할 때 레이어별로 다른 속도로 움직이는 패럴랙스 구현해줘"
"버튼을 누르면 깊이감 있게 들어가는 효과 만들어줘"
"이미지가 3D 회전하면서 뒤집히는 효과 추가해줘"
```

### ✨ **파티클 & 모션 그래픽**
```
"배경에 별똥별 애니메이션 추가해줘"
"터치할 때마다 반짝이는 파티클 이펙트 만들어줘"
"성공/실패에 따른 컨페티 애니메이션 구현해줘"
"기하학적 패턴이 움직이는 로딩 스크린 만들어줘"
```

## 🎨 **고급 디자인 시스템 요청법**

### 🎭 **브랜드 아이덴티티**
```
"네오모피즘 디자인 시스템으로 전체 리뉴얼해줘"
"글래스모피즘과 그라디언트를 조합한 미래적 UI 만들어줘"
"미니멀 모노크롬 디자인으로 고급스럽게 바꿔줘"
"레트로 퓨처리즘 스타일의 사이버펑크 테마 적용해줘"
```

### 🌈 **다이나믹 테마**
```
"시간대별로 자동 변하는 테마 시스템 만들어줘"
"사용자 무드에 따라 색상이 바뀌는 적응형 UI 구현해줘"
"계절별 테마와 애니메이션 배경 추가해줘"
"사용 패턴을 학습해서 개인화되는 인터페이스 만들어줘"
```

## 📱 **고급 인터렉션 패턴**

### 🤏 **제스처 기반 UX**
```
"핀치 투 줌으로 상세 정보 확대하는 인터렉션 만들어줘"
"길게 누르면 컨텍스트 메뉴가 원형으로 펼쳐지는 효과 구현해줘"
"두 손가락 스와이프로 탭 전환하는 제스처 추가해줘"
"쉐이크 제스처로 랜덤 기능 실행하는 이스터에그 넣어줘"
```

### 🎯 **스마트 인터렉션**
```
"시선 추적을 활용한 스마트 스크롤 구현해줘"
"음성 명령으로 네비게이션하는 기능 추가해줘"
"기기 기울임으로 UI 요소가 반응하는 효과 만들어줘"
"하트비트 센서 연동해서 UI 색상이 맥박에 따라 변하게 해줘"
```

## 🚀 **최신 트렌드 & 기술 융합**

### 🤖 **AI/ML 인터페이스**
```
"사용자 행동 패턴을 분석해서 UI 레이아웃을 자동 최적화해줘"
"AI 추천에 따른 동적 콘텐츠 배치 시스템 만들어줘"
"이미지 인식으로 자동 태그 추가하는 갤러리 구현해줘"
"감정 분석 기반 테마 추천 시스템 추가해줘"
```

### 🌐 **웹3/메타버스 스타일**
```
"NFT 갤러리 같은 3D 전시 공간 UI 만들어줘"
"크립토 지갑처럼 홀로그램 효과가 있는 카드 디자인 해줘"
"메타버스 아바타 커스터마이징 인터페이스 구현해줘"
"블록체인 트랜잭션 시각화 애니메이션 추가해줘"
```

## 🎮 **게임화 & 엔터테인먼트**

### 🏆 **게이미피케이션 고급**
```
"레벨업할 때 전 화면 파티클 폭발 효과 만들어줘"
"스트릭 달성시 골든 아워 테마로 자동 변환해줘"
"보스전 BGM과 함께 임팩트 있는 버튼 애니메이션 구현해줘"
"RPG 인벤토리 시스템처럼 드래그 앤 드롭 정리 기능 만들어줘"
```

### 🎪 **인터랙티브 스토리텔링**
```
"스크롤하면서 스토리가 전개되는 패럴랙스 UI 만들어줘"
"선택에 따라 UI 스타일이 분기되는 어드벤처 모드 추가해줘"
"타임라인을 따라 UI가 진화하는 히스토리 뷰 구현해줘"
"미션 완료시 만화책 말풍선 효과로 피드백 표시해줘"
```

## 🔬 **실험적 & 혁신적 UX**

### 🧠 **인지과학 기반 UX**
```
"시각적 주의 집중을 유도하는 동적 레이아웃 설계해줘"
"인지 부하를 줄이는 점진적 정보 노출 시스템 만들어줘"
"멘탈 모델에 맞는 직관적 네비게이션 구조로 개선해줘"
"플로우 상태를 유지하는 몰입형 인터페이스 구현해줘"
```

### 🌊 **감각적 피드백**
```
"햅틱 피드백과 동기화된 시각 효과 만들어줘"
"사운드스케이프와 연동되는 색상 변화 시스템 구현해줘"
"온도 센서 기반 따뜻함/차가움 느낌의 UI 테마 적용해줘"
"공간감을 활용한 3D 오디오 연동 인터페이스 만들어줘"
```

## 💫 **프리미엄 질문 템플릿**

### 🎭 **명품 브랜드 스타일**
```
"에르메스처럼 럭셔리하고 미니멀한 디자인으로 바꿔줘"
"테슬라 인터페이스 같은 미래적 심플함 적용해줘"
"애플 디자인 언어의 정제된 아름다움으로 리뉴얼해줘"
"구찌처럼 대담하고 아티스틱한 패턴 인터페이스 만들어줘"
```

### 🚀 **차세대 기술 융합**
```
"AR 요소를 활용한 공간감 있는 2D UI 구현해줘"
"홀로그램 투영 효과가 있는 플로팅 메뉴 만들어줘"
"양자 컴퓨팅 시각화처럼 추상적이고 아름다운 로딩 애니메이션 구현해줘"
"신경망 패턴을 모티프로 한 유기적 UI 레이아웃 설계해줘"
```

## 🎯 **심화 요청 기법**

### 📊 **성능과 미학의 조화**
```
"60fps를 보장하면서도 화려한 애니메이션 시스템 구축해줘"
"메모리 효율적인 고품질 이미지 전환 효과 만들어줘"
"배터리 절약형 다크모드 애니메이션 구현해줘"
"네트워크 상태에 따라 적응하는 동적 품질 조절 시스템 만들어줘"
```

이런 방식으로 질문하시면 **세계 최고 수준의 프리미엄 앱** 수준의 UI/UX를 구현할 수 있어요! 🌟✨

특히 **구체적인 참조점 + 기술적 요구사항 + 감성적 목표**를 조합해서 질문하시면 가장 만족스러운 결과를 얻으실 수 있습니다! 🚀