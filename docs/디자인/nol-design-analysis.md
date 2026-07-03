# NOL 클론 디자인 분석 & 라이브 정합 매핑

## 디자인 시스템 (lib/core/theme/yanolja_theme.dart)
- **컬러**: NOL 블루 `#315BFF`(primary), `#2538D8`(dark), `#EAF0FF`(light), 퍼플 `#5B43FF`, 할인 `#FF3D6E`(sale), 별점 `#FFB21A`, 성공 `#12B886`. 화이트 배경 + `#F5F6F8`(surfaceAlt) 섹션 구분.
- **반경**: sm8/md12/lg16/xl20/pill999. **간격**: 4/8/16/20/24.
- **포맷**: `YanoljaFormat.price/discountRate/originalPrice`. **공통 위젯**: `YanoljaSectionHeader`, `YanoljaRating`, `YanoljaToast`.
- **모션**: `YanoljaMotion`(fast140/base220/entrance360, easeOutCubic), `YanoljaEntrance`(fade+slide+scale 등장, reduce-motion 존중), `YanoljaPressable`.

## 라이브 NOL 룩 → 클론 반영 상태
| 라이브 특징 | 클론 반영 |
|---|---|
| 화이트 배경 + 8px 회색 섹션 띠 | ✅ `_SectionDivider`, surfaceAlt |
| NOL 블루 강조 + 둥근 플랫 카드 | ✅ 전역 토큰 |
| 카테고리 아이콘 11종 | ✅ 홈 그리드 10종(+내주변 탭) — 라이브 순서/라벨 일치 |
| 지역 탭 호캉스 특가 | ✅ `_buildRegionSection` (서울/강원/제주/부산·경상/전라·충청) |
| 기획전 모음 | ✅ `_buildCurationStrip` (할인혜택/이벤트/MD추천) |
| 할인율 빨강 + 정가 취소선 + 별점 | ✅ 홈·카테고리·서비스 카드 |
| 칩 필터(선택=primary 채움) | ✅ 카테고리/서비스/지역 칩 |
| 라이브 커머스 | ✅ `/live` (LiveScreen) |
| 스켈레톤 로딩 | ✅ 홈·카테고리·saved·booking·nearby |

## 메뉴 목적지 처리
- 카테고리 화면: `/hotel`·`/pension`·`/resort`·`/hanok` → 공용 `NolCategoryListScreen`.
- 제너릭 서비스 허브: `/service/:type` (flight/overseas/leisure/transport/camping/guesthouse/event/coupons/cart/deals/motel/overseas-tour/package/... 27종) → `NolServiceScreen`.
- 전체 메뉴: `/all-categories` ← `core/nol_menu.dart`(NOL티켓/국내여행/해외여행/서비스 그룹).
- 모텔·해외투어·해외패키지: 전용 리치 `_ServiceConfig`로 승격.

## 검증 기준 (하네스)
1) `flutter analyze` 경고 0  2) 라이브 NOL 룩 일관성  3) 디자인 토큰 사용  4) 등장 애니메이션/마이크로인터랙션  5) 빈/로딩/에러 상태  6) 코드 안전성. 목표 점수 10/10.
