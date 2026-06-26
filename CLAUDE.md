# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

야놀자(NOL) 숙소 예약 앱의 Flutter 클론입니다. **Android / iOS 모바일 전용**이며 (web·linux·windows·macos 디렉토리는 제거됨), 백엔드 없이 **mock 데이터**로 동작합니다. 주석과 UI는 한국어이고, 앱 타이틀은 `NOL(야놀자)` (`lib/main.dart`)입니다. 숙소 카테고리는 호텔/펜션/리조트/한옥이며 각각 전용 화면이 있습니다.

> 이전에는 "여기가어때" 핑크(`0xFFFF6B6B`) 브랜딩이었으나 **NOL 블루(`0xFF315BFF`)로 리브랜딩**되었습니다. 옛 문서·주석에 남은 핑크/여기가어때 표현은 현행이 아닙니다.

## Development Commands

```bash
# 의존성 (pubspec 변경 후 반드시 둘 다)
flutter pub get
cd ios && pod install        # Firebase/Maps/SignIn 네이티브 의존성

# 실행 (모바일만)
flutter run                  # 기기 자동 선택
flutter run -d ios
flutter run -d android

# 정적 분석 — 커밋 전 필수, 경고 0 유지
flutter analyze
flutter analyze lib/path/to/file.dart   # 단일 파일

# 테스트 (flutter_test 사용)
flutter test
flutter test test/widget_test.dart

# 빌드
flutter build apk
flutter build appbundle
flutter build ios

# 문제 발생 시
flutter clean && flutter pub get && cd ios && pod install
```

코드 포맷은 `dart format <files>`. 린트 규칙은 `analysis_options.yaml`(`package:flutter_lints`) 기준.

## Architecture

### 단일 데이터 스택 (Clean 병렬 스택은 제거됨)
이 코드베이스는 **하나의 데이터 흐름**만 쓴다: **UI → `presentation/provider/*_provider.dart`(Riverpod) → `data/repository/*` → `data/datasource/*` / `data/model/*`**.

| 계층 | 위치 |
|------|------|
| 데이터소스 | `data/datasource/` (mock API, sqflite 리뷰 DB) |
| 모델 | `data/model/` |
| 리포지토리 | `data/repository/` (인터페이스 분리 없이 직접 구현) |

> 과거에는 어디서도 import되지 않던(죽은) **Clean 병렬 스택**(`domain/`, `data/{models,mappers,repositories,datasources}/`, `core/di/injection_container.dart`, `*_provider_clean.dart`, hanok 미니스택)이 공존해 디렉토리 단/복수로 갈렸으나, **전부 제거**되었다. 신규 기능도 위 단일 흐름을 따르며, Provider는 화면/도메인별 `presentation/provider/*_provider.dart`에 정의한다.

### 상태 관리 (Riverpod)
- `flutter_riverpod` 사용. `FutureProvider`(비동기 로딩), `Provider.family`(파라미터), `StateNotifierProvider`(가변 상태, 예: `auth_provider`, `settings_provider`).
- UseCase는 `call()` 규약 — `await useCase()` / `await useCase(param)` 형태로 호출한다. `.execute()` 메서드는 **존재하지 않는다**.

### 라우팅 (`lib/core/router.dart`)
- `GoRouter` + `StatefulShellRoute.indexedStack`로 하단 탭 상태 유지. `initialLocation: '/splash'` (스플래시 후 홈으로 진입).
- 탭 5개: `/home`, `/search`, `/nearby`, `/saved`, `/my-info` (셸: `presentation/screen/main_shell.dart`).
- 셸 밖 라우트: `/detail/:id`, `/hotel`·`/pension`·`/resort`·`/hanok`, `/bookings`, `/payment`·`/payment-complete`, `/login`·`/signup`, `/map`, `/settings` 등.
- 화면 간 복잡한 객체 전달은 `state.extra` 사용 (예: 결제 흐름의 `PaymentArgs`, 완료 화면의 `Booking`).

### 예약 → 결제 흐름
상세화면(`presentation/provider/screen/detail_screen.dart`)에서 날짜 선택 후 `객실 선택` → 로그인 확인 → `context.push('/payment', extra: PaymentArgs(...))` → `payment_screen.dart`(약관 동의·결제수단 선택·모의 결제) → `BookingRepository.addBooking()` + `ref.invalidate(bookingListProvider)` → `payment_complete_screen.dart`. 새 예약은 `bookingListProvider`를 구독하는 예약 내역 화면에 즉시 반영된다. 실제 PG 연동은 없고 1.5초 지연의 모의 결제다.

### 디자인 시스템 (`lib/core/theme/yanolja_theme.dart`)
- 토큰 클래스: `YanoljaColors`(브랜드/텍스트/표면), `YanoljaRadius`(sm8·md12·lg16·xl20·pill999), `YanoljaSpacing`, `YanoljaFormat`(`price()` 천단위 콤마, `discountRate(id)`·`originalPrice()` 모의 할인). 새 색/반경/포맷은 임의 값 대신 이 토큰을 쓴다.
- 전역 `ThemeData`는 `main.dart`의 `_buildYanoljaTheme()`에 정의 (Material3, 화이트 플랫, NOL 블루 강조). 다이얼로그 컨펌은 `presentation/widget/yanolja_confirm_dialog.dart`의 `showYanoljaConfirmDialog`.
- 한국어 로케일: `main.dart`에 `locale: Locale('ko','KR')` + `flutter_localizations` 델리게이트 등록. 기본 위젯(날짜 선택기 등)이 한글로 표시된다. 날짜 범위 선택은 기본 `showDateRangePicker` 대신 커스텀 `presentation/widget/yanolja_date_range_sheet.dart`의 `showYanoljaDateRangeSheet`를 사용한다.

### 인증 / Firebase
- `firebase_core`·`firebase_auth`·`google_sign_in`이 pubspec에 있으나 **현재 비활성화**되어 있다. `main.dart`의 `Firebase.initializeApp`은 주석 처리(GoogleService-Info.plist 누락).
- 실제 인증은 **mock**: `presentation/provider/auth_provider.dart`의 `AuthNotifier`(`StateNotifier<AppUser?>`)와 `AppUser{email, displayName}`. 로그인/회원가입/구글로그인 모두 mock 처리. (README/옛 문서의 "Firebase Auth"는 현행 아님.)

### 규모가 큰 화면
`detail_screen.dart`(~79KB), `home_screen.dart`(~55KB)는 `presentation/provider/screen/`에 위치한다(다른 화면들은 `presentation/screen/`). 수정 시 해당 위치 유의.

## Conventions & Pitfalls

- **Entity ↔ Model 매핑**: 필드명·타입이 다를 수 있으므로 추정하지 말고 양쪽 클래스를 읽고 매핑한다. 가장 흔한 컴파일 에러 원인.
- **Deprecated API 금지**: `Colors.x.withOpacity()` → `withValues(alpha: ...)`.
- **로깅**: `print()` 대신 `debugPrint()`(또는 `if (kDebugMode)`).
- **모바일 전용**: web/desktop 빌드·코드 제안 금지. iOS는 pubspec 변경 시 `pod install` 필수.
- 미사용 import/죽은 코드 제거 — `flutter analyze` 경고 0 유지.

## Working Principles (Karpathy Guidelines)

LLM 코딩 실수를 줄이기 위한 작업 원칙 (출처: `github.com/multica-ai/andrej-karpathy-skills` / karpathy-guidelines). 단순 작업에는 정도를 조절해 적용한다.

1. **코딩 전에 생각한다 (Think Before Coding)** — 가정을 명시한다. 불확실하면 추측해서 진행하지 말고 질문한다. 모호함이 있으면 여러 해석을 제시하고, 더 단순한 접근이 가능한지 먼저 따진다. 혼란을 감추지 않는다. (이 프로젝트에서 자주 어기는 예: Entity↔Model 필드명을 추정하는 것 — 추정 대신 양쪽을 읽는다.)
2. **단순함 우선 (Simplicity First)** — 문제를 푸는 최소한의 코드만 쓴다. 요청하지 않은 기능, 투기적 추상화, 조기 설정화(premature configurability)를 넣지 않는다. 코드를 크게 줄일 수 있으면 리팩터한다. (이중 아키텍처가 이미 복잡하므로 새 계층·새 provider 계열을 함부로 늘리지 않는다.)
3. **외과적 변경 (Surgical Changes)** — 꼭 필요한 곳만 건드린다. 기존 코드의 스타일을 유지하고, 무관한 부분을 "개선"하지 않는다. 내 변경이 만든 잔여물(불필요해진 import/의존성)만 정리한다.
4. **목표 기반 실행 (Goal-Driven Execution)** — 요구사항을 검증 가능한 성공 기준으로 바꾸고, 충족될 때까지 반복한다. 이 저장소의 기본 검증선은 **`flutter analyze` 경고 0 + 관련 화면 실제 동작 확인**이다.

## Reference Docs (참고용 상세 규칙)
- `.claude/rules/00`–`07_*.md`: 프로젝트 개요·아키텍처·명령어·UI/UX·코드품질·플랫폼·상태관리·에러예방.
- `.cursor/rules/*.mdc`: design-system, flutter-conventions, routing-navigation, state-management, performance-optimization 등.
- `ERROR_RULES.md`: 구체적 에러 해결 패턴. `AGENTS.md`: 에이전트 작업 가이드.
