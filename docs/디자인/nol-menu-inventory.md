# NOL(nol.yanolja.com) 전체 메뉴·링크 인벤토리

> 수집 방법: insane-search 프로토콜(R6/R7). 엔진(`python3 -m engine`)은 전 Yanolja 도메인에서 Akamai Bot Manager(needs_real_tls_stack + needs_js_exec, `must_invoke_playwright_mcp=TRUE`)에 막힘 → 스킬 규칙이 지시하는 **에이전트 주도 브라우저 렌더링(claude-in-chrome: navigate → read_page/get_page_text)** terminal 경로로 완수. (2026-06 기준)

## 1. 글로벌 헤더 (모든 페이지 공통)
| 메뉴 | 링크 | 클론 매핑 |
|---|---|---|
| 로고 NOL | `/` | `/home` |
| 통합검색 (placeholder "국내여행 준비 NOLDAY") | `/search` | `/search` |
| 마이 | `/mypage` | `/my-info` (ProfileScreen) |
| 찜 | `/wishlist` | `/saved` (SavedScreen) |
| 장바구니 | `platform-site.yanolja.com/cart` | `/service/cart` |
| 최근 본 상품 | `/recent-product/list?target=HOME` | `/service/recent` |

## 2. 글로벌 네비게이션 탭
| 탭 | 링크 | 클론 매핑 |
|---|---|---|
| 전체 카테고리 | (메가메뉴/오버레이) | `/all-categories` |
| 홈 | `/` | `/home` |
| 티켓 | `/ticket` | `/ticket` |
| 쿠폰·혜택 | `/benefit?category=BENEFIT_HOME` | `/service/coupons` |
| 특가 | `/promotion` | `/service/deals` |

## 3. 카테고리 아이콘 그리드 (홈, 11종)
| # | 라벨 | 라이브 링크 | 클론 라우트 |
|---|---|---|---|
| 1 | 호텔/리조트 | `/sub-home/hotel?verticalCategory=LOCAL_ACCOMMODATION&verticalSubCategory=HOTEL` | `/hotel` |
| 2 | 펜션/풀빌라 | `/sub-home/pension?...PENSION` | `/pension` |
| 3 | 모텔 | `/sub-home/motel?...MOTEL` | `/service/motel` |
| 4 | 국내레저 | `/sub-home/leisure?verticalCategory=LOCAL_LEISURE` | `/service/leisure` |
| 5 | 교통/쏘카 | `/sub-home/transportation` | `/service/transport` |
| 6 | NOL 티켓 | `/ticket` | `/ticket` |
| 7 | 항공 | `tour.yanolja.com/air` | `/service/flight` |
| 8 | 해외숙소 | `/sub-home/global?verticalCategory=GLOBAL_ACCOMMODATION` | `/service/overseas` |
| 9 | 해외투어&티켓 | `tour.yanolja.com/tna` | `/service/overseas-tour` |
| 10 | 해외패키지 | `tour.yanolja.com/package-main` | `/service/package` |
| 11 | 내 주변 | `/around/keyword-motel?advert=AROUND` | `/nearby` |

## 4. 홈 섹션 순서 (라이브)
1. 메인 배너 캐러셀 (NOL DAY / 여름 펜션 특가전 70% / NOL 페스티벌 등 18+)
2. 가입하고 쿠폰 받으세요 (회원가입 유도)
3. 카테고리 아이콘 그리드(11)
4. **NOL 라이브 놀라운 혜택!** (라이브 커머스: 방송예정/다시보기, 할인율, 가격) → `/live-commerce/{id}`
5. 100% 당첨 드로우 & 식음 크레딧 (아난티 등 프리미엄)
6. 인천 호텔·펜션 최대 3만원 할인
7. 추천! 미주/남태평양 인기숙소
8. 10만원 이하 가성비 펜션
9. 인기 국내레저 모음 (롯데월드타워·아쿠아리움·웨이브파크)
10. 추천! 인기 있는 동남아 여행지
11. 많이 찾는 즐길거리 (평점 표기)
12. **놀라운 특가 "호캉스 어디로 갈까?"** — 지역 탭: 강원/제주/경상/전라충청
13. 지금 떠나는 도심 호캉스 — 지역 탭: 부산/서울강북/서울강남/경기·인천
14. 국내 레저, 오늘 가장 인기 있는 곳 — 탭: 내륙/제주/해양레저
15. **기획전 모음** — 할인혜택/이벤트/MD추천 카드
16. 푸터 (놀유니버스 사업자 정보, 약관, 패밀리 사이트)

## 5. 서브홈/콘텐츠 링크 패턴 (호텔 서브홈 정찰)
- 내 주변: `/around/keyword-hotel?sourcePage=Hotel`
- 기획전(exhibition): `/exhibition/{id}` (예: 4884, 9825, 9842, 4297)
- 이벤트: `content.yanolja.com/event/{id}` (예: 305, 351)
- 프로모션: `content.yanolja.com/promotions/{slug}` (nolday, main-domestic, tamra-monday-jeju ...)
- 라이브: `/live-commerce/{id}`

## 6. 푸터 메뉴
회사소개 · 광고제휴문의 · 인재채용 · 개인정보처리방침 · 청소년보호정책 · 서비스 이용약관 · 위치정보 이용약관 · NOL 티켓 이용정책 · 사업자 정보확인 · 전자금융거래 이용약관/유의사항 · 분쟁해결기준 / 고객센터 1644-1346

## 7. 전체 카테고리(메가메뉴) 그룹 — 클론 `nol_menu.dart` 정합
- **NOL 티켓**: 뮤지컬·콘서트·스포츠·전시/행사·클래식/무용·아동/가족·연극
- **국내여행**: 호텔/리조트·펜션/풀빌라·모텔·게스트하우스·글램핑/캠핑·한옥·국내교통·국내레저·국내항공
- **해외여행**: 해외항공·해외숙소·해외투어/티켓·해외패키지
- **서비스**: NOL 라이브·NOL 특가·쿠폰/혜택·기획전
