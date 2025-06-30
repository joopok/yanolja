# UI/UX Standards and Design Rules

## MANDATORY UI Component Standards

### Critical Measurements (NEVER DEVIATE)
```dart
// ✅ Search field height - EXACTLY 42px (user-tested optimal)
SizedBox(
  height: 42,  // MANDATORY - Material Design optimized
  child: TextField(...)
)

// 🚫 NEVER use heights that create poor UX:
height: 52,  // Too tall - user complained
height: 36,  // Too short - touch target too small
```

### Animation Standards (STRICTLY ENFORCE)
```dart
// ✅ CORRECT animation timing - natural user experience
duration: const Duration(milliseconds: 300),  // MAX 300ms
child: SlideAnimation(
  verticalOffset: 20.0,  // MAX 20px - subtle movement
)

// 🚫 WRONG - creates jarring user experience:
duration: const Duration(milliseconds: 375),  // Too slow
verticalOffset: 50.0,  // Too obvious, disturbing
```

### Color System Rules

#### Deprecated API Migration (CRITICAL)
```dart
// ✅ MODERN - ALWAYS use this
Colors.red.withValues(alpha: 0.5)
Color(0xFFFF6B6B).withValues(alpha: 0.8)

// 🚫 DEPRECATED - NEVER use this
Colors.red.withOpacity(0.5)  // Will cause build warnings
```

#### Brand Colors
```dart
// Primary brand color - Yanolja pink
Color(0xFFFF6B6B)

// Use consistently across:
// - Primary buttons
// - Active navigation states  
// - Accent elements
```

## Layout and Spacing Rules

### Consistent Spacing System
```dart
// Standard spacing units - stick to these values
const double spacingXS = 4.0;
const double spacingS = 8.0;
const double spacingM = 16.0;
const double spacingL = 24.0;
const double spacingXL = 32.0;
```

### Typography Standards
- **Font Family**: Pretendard (Korean-optimized)
- **Use Material Typography** scale for consistency
- **Korean text**: Ensure proper line height for readability

## Navigation UX Rules

### Bottom Navigation (6 Tabs)
```dart
// Fixed tab order - NEVER change:
// 1. Home (홈)
// 2. Search (검색)  
// 3. Saved (찜)
// 4. Profile (내정보)
// 5. Bookings (예약내역)
// 6. More (더보기)
```

### Screen Transitions
✅ **ALWAYS use Hero animations** for accommodation cards
✅ **Maintain StatefulShellRoute** state across tab switches
🚫 **NEVER break tab state** when navigating

## Accommodation Category UI Rules

### Hotel Screen Standards
- Regional filtering (지역별 필터)
- Professional amenities focus
- Business traveler UX

### Pension Screen Standards  
- Seasonal themes (봄/여름/가을/겨울)
- Family/couple theme options
- Seasonal image carousels

### Resort Screen Standards
- Luxury amenity filters (풀빌라, 스위트룸, 오션뷰, 스파)
- Premium experience focus
- High-end imagery

### Hanok Screen Standards
- Traditional Korean aesthetics
- Cultural authenticity
- Heritage site information

## Accessibility Requirements
- **Touch targets**: Minimum 44x44dp
- **Color contrast**: WCAG AA compliance
- **Text scaling**: Support system font sizes
- **Screen reader**: Proper semanticLabel on images

## Performance Standards
- **Image loading**: Always use `cached_network_image`
- **List performance**: Implement proper `ListView.builder`
- **Animation performance**: 60fps requirement
- **Memory management**: Dispose controllers properly

🚫 **NEVER compromise on:**
- Touch target sizes
- Animation smoothness  
- Korean text rendering quality
- Brand color consistency