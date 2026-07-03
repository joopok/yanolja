# NOL (야놀자) — Design Specification

> **DESIGN.md** · 디자인 시스템 핸드오프 문서
> NOL(야놀자) 모바일 앱의 디자인 언어를 코드 기준으로 정리한 명세서입니다.
> 출처: 사용자 제공 Flutter 클론 (`yanolja/` 로컬 + GitHub `joopok/yanolja`).
> 모든 토큰·컴포넌트·카피는 앱의 `lib/core/theme/yanolja_theme.dart`, `lib/main.dart`, `lib/presentation/widget/*` 에서 직접 추출했습니다.

---

## 0. 한눈에 보기 (TL;DR)

| 항목 | 값 |
|------|-----|
| 제품 | NOL — 숙소·티켓·레저 예약 모바일 앱 (한국어, 모바일 전용) |
| 브랜드 컬러 | **NOL Blue `#315BFF`** (1차) · Purple `#5B43FF` (악센트) · Deal-Red `#FF3D6E` (할인) |
| 서체 | Pretendard (앱 플랫폼 한글 폰트의 웹 대체) — w400~w900 |
| 보이스 | 한국어 우선 · **해요체** · 따뜻하고 혜택 중심 · 이모지 미사용 |
| 화면 거터 | 20px · 카드 12~14px 간격 |
| 라운딩 | 버튼 12 · 카드 16~20 · 검색바 18 · 바텀시트 28 · 칩 pill |
| 그림자 | 얇은 보더 + 부드러운 드롭(8% 블랙) "flat but floating" |
| 모션 | easeOutCubic · 누르면 0.97 축소 · 장식 애니메이션 없음 |
| 아이콘 | Material Symbols Rounded (UI) + 3D 클레이 일러스트 PNG (서비스 타일) |

---

## 1. 제품 컨텍스트

NOL은 "야놀자의 새 이름"으로, **숙소·티켓·레저·공연을 한 곳에서 한 번에** 예약하는 모바일 커머스 앱입니다. 한국어 전용, 모바일 세로 화면 전용이며 5탭 셸로 구성됩니다.

| 탭 | 라벨 | 라우트 |
|----|------|--------|
| 검색 | Search | `/search` |
| 내주변 | Nearby | `/nearby` |
| 홈 | Home | `/home` (기본) |
| 찜 | Saved | `/saved` |
| 마이 | My | `/my-info` |

핵심 플로우: **홈 → 검색·필터 → 상세(날짜·객실) → 로그인 확인 → 결제(약관·수단, 모의 1.5초) → 예약 완료**.

> **리브랜딩 주의.** 앱은 과거 "여기가어때" 핑크(`#FF6B6B`) 정체성이었으나 지금은 **NOL 블루(`#315BFF`)** 입니다. 옛 코드 주석의 핑크/여기가어때 흔적은 모두 폐기 — 항상 NOL 블루를 사용하세요.

---

## 2. CONTENT FUNDAMENTALS (보이스 & 카피)

모든 라벨·배너·토스트에 적용하는 카피 규칙.

- **언어:** 한국어 우선. 영어는 제품에 이미 존재하는 고유명사/외래어(NOL, NOLDAY, WiFi, NEW)에만. UI를 영어로 번역하지 않습니다.
- **톤:** 따뜻하고 산뜻하며 혜택 중심 — 딱딱한 예약 엔진이 아니라 친절한 컨시어지. "자정까지만 이 가격" 같은 가벼운 FOMO를 쓰되 정중함 유지.
- **존댓말 레벨:** 일관된 **해요체**. 문장은 -요/-어요/-세요로 종결. 예: "어디로 떠나볼까요?", "찜 목록에 담았어요", "예약이 완료되었어요". 합니다체(딱딱함)·반말 모두 금지.
- **인칭:** 사용자를 직접 "당신"이라 부르기보다 질문하거나("어디로 떠나볼까요?") 사용자의 것을 대신 보고("내 주변", "찜 목록")합니다.
- **케이스:** 한글은 케이스 없음. 영어 토큰은 상태(NEW)·브랜드(NOL, NOLDAY)는 대문자, 그 외는 브랜드 표기대로.
- **숫자·금액:** 항상 콤마 + **원** 접미("128,000원"). 1박 단가는 "/ 1박". 할인은 가격 앞에 굵은 빨강 % ("오늘 예약가 24% 128,000원"). 평점은 소수 1자리 + 괄호 리뷰수 ("★ 4.8 (1,247)"). 거리 km ("0.8km").
- **마이크로카피 패턴:**
  - 검색 플레이스홀더: *어디로 떠나볼까요?*
  - 섹션 헤더: 짧은 명사구 — *오늘의 특가 · 인기 숙소 · 내 주변 숙소* + 옅은 *더보기 ›* 링크.
  - 확인 토스트: 과거형·안심형 — *찜 목록에 담았어요 · 예약이 완료되었어요*.
  - 프로모 아이브로우: *NOLDAY · 단독특가 · 최대 38%*.
  - CTA: 동사 우선·짧게 — *객실 선택 · 결제하기 · 로그인 · 혜택 보기*.
- **이모지:** 제품 UI에서 **미사용**. 상태는 컬러 배지 + Material 글리프로 전달.
- **한 줄 무드:** "밤이 좋아, 놀자" — 경쾌하고 혜택에 밝으며 모바일 네이티브, 신뢰감.

---

## 3. VISUAL FOUNDATIONS

- **컬러 & 무드:** **화이트 중심의 플랫** UI. 캔버스는 순백(`#FFFFFF`), 섹션 구분은 옅은 회색(`#F5F6F8`). **NOL 블루가 척추** — 모든 CTA·활성 탭·링크·선택 상태. **퍼플**은 보조/앱아이콘 악센트. **딜레드**는 할인·미확인 알림 점에만. 색은 단호하지만 절제 — 화면 대부분은 흰 바탕 + 근흑 텍스트, 파랑이 일한다.
- **타이포그래피:** Pretendard. 스케일이 **무겁다** — 헤딩은 w800~w900에 음수 자간(-0.3~-0.6px), 앱바 타이틀 24px/900. 본문 산문에만 w400. 한글 가독성 위해 행간 넉넉(1.4~1.5), `word-break: keep-all`.
- **간격 & 레이아웃:** **20px 화면 거터**가 거의 보편. 세로 리듬 여유 — 섹션 헤더 위 24px, 아래 12px. 스택 카드 간 12~14px. 모바일 세로 전용, 390~430px 폭 기준.
- **라운딩:** 일관되고 넉넉 — 버튼 12, 인풋/카드 16, 히어로/숙소 카드 20, 검색바 18, 바텀시트 28, 칩/선택-pill 완전 둥글게. 아이콘 버튼은 14px 스퀴클.
- **카드:** 흰 표면에 **1px 헤어라인 보더(`#EDEEF0`) + 부드러운 저대비 드롭(`0 10px 20px rgba(0,0,0,.078)`)** 동시 적용 — "납작하지만 살짝 떠 있는". 숙소 카드는 20px 라운드에 사진이 가장자리까지 꽉 차고 클립됨.
- **그림자:** 부드럽고 절제. 카드 8% 블랙 앰비언트, 작은 컨트롤(검색바)은 더 옅게(`.04`), 시트/팝오버는 더 깊게, 블루틴트 아이콘 버튼은 옅은 브랜드 글로우. 진하거나 하드한 그림자 금지.
- **배경 & 이미지:** 숙소 카드·상세 히어로에 실사진(호텔/해변/인테리어), 항상 둥근 클립 안 풀블리드. 사진에는 **상→하 블랙 스크림 그라데이션**(28% → 투명 → 18%)을 깔아 흰 오버레이 컨트롤·배지 가독성 확보. 프로모 배너는 **브랜드 그라데이션**(블루→퍼플, 또는 카테고리 페어)에 코너의 옅은 대형 글리프. 그라데이션은 *프로모*에만, 크롬에는 안 씀.
- **보더 & 디바이더:** 헤어라인만 — 카드/인풋 `#EDEEF0`, 리스트 디바이더 살짝 옅은 `#F1F2F4`. 1px, 절대 두껍지 않게.
- **투명도 & 블러:** 사진 위 컨트롤(공유·하트·이미지 카운터)은 반투명 **다크**(`rgba(0,0,0,.24~.54)`), 그라데이션 히어로의 글래스 배지/지표는 반투명 **화이트**(`rgba(255,255,255,.14~.18)`). 무거운 backdrop-blur 미사용.
- **모션:** 빠르고 부드럽게, `easeOutCubic` `cubic-bezier(.215,.61,.355,1)`. 누름 = 축소(일반 0.97, 아이콘 버튼 0.94); 선택된 내비 아이콘은 틴트 pill 안에서 1.04로 살짝 팝. 화면 진입 시 짧은 페이드+상승(~360ms), 리스트 항목 ~55ms 스태거. 바운스·무한 장식 루프 없음. `prefers-reduced-motion` 존중.
- **호버/프레스:** 1차 버튼은 `#2538D8`로 어두워짐; 틴트 표면은 틴트가 깊어짐; 탭 가능한 모든 것은 누르면 축소. 데스크톱 호버 어휘 없음(모바일 앱) — 호버는 프레스의 가벼운 프리뷰로 취급.
- **선택 상태:** 어디서나 파랑 — 선택 칩/탭은 `#EAF0FF` 블루틴트 + 헤어라인 블루 보더 + w700~800 블루 라벨.

---

## 4. ICONOGRAPHY

NOL은 **두 개의 아이콘 시스템**을 병행합니다.

1. **UI 크롬 — Material Symbols Rounded.** 앱은 `Icons.*_rounded`를 전반에 사용(search, home, near_me, favorite, person, menu, chevron_right, notifications, mic, ios_share, star, card_giftcard…). 웹에서는 Google Fonts의 **Material Symbols Rounded**를 같은 이름으로 사용. 활성/선택 글리프는 *채움*(`FILL 1`), 비활성은 외곽선(`FILL 0`).
   ```html
   <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@24,400,0,0&display=block" />
   <span class="material-symbols-rounded">favorite</span>
   ```
2. **서비스 타일 — 3D 클레이 일러스트.** 홈 카테고리 그리드·검색/내주변 진입점은 부드러운 **3D 렌더 PNG 일러스트**(클레이풍 호텔, 구름 위 비행기, 티켓, 공연 무대, 초밥…). `assets/search_icons/` · `assets/nearby_icons/`에 위치. 시그니처 카테고리 그리드에는 글리프 대신 이걸 사용하고, 일러스트가 없을 때만 카테고리 그라데이션 위 Material 글리프로 폴백.

- **이모지:** 제품 아이콘으로 절대 미사용.
- **유니코드:** 글리프-as-아이콘은 평점의 **★**(앰버 `--nol-star`)뿐. 그 외 전부 Material Symbol 또는 클레이 PNG.
- SVG 손그림·새 아이콘 언어 발명 금지 — Material Symbols Rounded + 번들 클레이 세트 재사용.

---

## 5. DESIGN TOKENS

전부 `:root` CSS 커스텀 프로퍼티. `styles.css` 한 파일만 링크하면 됩니다. **하드코딩 hex 금지 — 항상 `--nol-*` 토큰 사용.**

### 5.1 Color

| 토큰 | 값 | 용도 |
|------|-----|------|
| `--nol-blue` | `#315BFF` | 1차 — CTA·활성·링크 |
| `--nol-blue-dark` | `#2538D8` | 프레스/호버 darken |
| `--nol-blue-light` | `#EAF0FF` | 틴트 — 선택 pill·배지·인포 배너 |
| `--nol-purple` | `#5B43FF` | 앱아이콘 퍼플, 보조 악센트 |
| `--nol-sale` | `#FF3D6E` | 할인%·알림 점 |
| `--nol-mint` | `#00C2B8` | NEW 배지 |
| `--nol-yellow` | `#FFB92E` | 쿠폰·혜택 |
| `--nol-star` | `#FFB21A` | 평점 별 |
| `--nol-bg` / `--nol-surface` | `#FFFFFF` | 앱 배경 / 카드 |
| `--nol-surface-alt` | `#F5F6F8` | 섹션 구분·칩·옅은 채움 |
| `--nol-surface-input` | `#F7F8FB` | 텍스트필드 채움 |
| `--nol-surface-search` | `#F3F5FA` | 홈 검색바 채움 |
| `--nol-text-primary` | `#1A1A1A` | 본문·헤딩 |
| `--nol-text-secondary` | `#6F6F6F` | 보조 카피 |
| `--nol-text-tertiary` | `#A9ADB4` | 플레이스홀더·메타·취소선 |
| `--nol-border` | `#EDEEF0` | 카드/인풋 헤어라인 |
| `--nol-divider` | `#F1F2F4` | 리스트 디바이더 |
| `--nol-success` | `#12B886` | 예약 완료·긍정 |
| `--nol-error` | `#E03131` | 검증·에러 |
| `--nol-snackbar` | `#121826` | 토스트/스낵바 배경 |

**카테고리 그라데이션 페어** (base→accent): `--cat-flight-*`(항공) · `--cat-overseas-*`(해외숙소) · `--cat-leisure-*`(레저) · `--cat-ticket-*`(티켓) · `--cat-traffic-*`(교통) · `--cat-hotel-*`(호텔·리조트) · `--cat-pension-*`(펜션·풀빌라) · `--cat-premium-*`(프리미엄) · `--cat-camping-*`(글램핑·캠핑) · `--cat-motel-*`(모텔). 각 `-1`/`-2`로 사용: `linear-gradient(135deg, var(--cat-hotel-1), var(--cat-hotel-2))`.

### 5.2 Typography

서체 스택: `--nol-font-sans` = `"Pretendard Variable", … "Apple SD Gothic Neo", "Noto Sans KR", sans-serif`.

| 역할 | 토큰 | 크기/굵기 | 자간 |
|------|------|-----------|------|
| Display LG | `--nol-display-lg` | 30 / 800 | -0.6 |
| Display SM | `--nol-display-sm` | 22 / 700 | -0.4 |
| Headline MD | `--nol-headline-md` | 20 / 700 | -0.4 |
| Headline SM | `--nol-headline-sm` | 18 / 700 | -0.3 |
| Title LG | `--nol-title-lg` | 17 / 700 | -0.3 |
| Title MD | `--nol-title-md` | 15 / 600 | -0.2 |
| Body LG | `--nol-body-lg` | 15 / 400 | -0.2 |
| Body MD | `--nol-body-md` | 14 / 400 | -0.2 |
| Body SM | `--nol-body-sm` | 12 / 400 | -0.1 |
| Label LG/MD/SM | `--nol-label-*` | 14·12·11 / 500–600 | — |

편의 클래스: `.nol-display-lg`, `.nol-title-md`, `.nol-body-md` … (typography.css). 굵기 토큰 `--nol-w-regular`(400) ~ `--nol-w-black`(900).

### 5.3 Spacing · Radius · Shadow · Motion

- **Spacing:** `--nol-space-xs`(4) · `-s`(8) · `-m`(16) · `-l`(20, 거터) · `-xl`(24). 보조: `--nol-gutter`(20), `--nol-section-gap`(24), `--nol-card-gap`(12), `--nol-tap-min`(44).
- **Radius:** `--nol-radius-sm`(8) · `-md`(12) · `-squircle`(14) · `-lg`(16) · `-search`(18) · `-xl`(20) · `-sheet`(28) · `-pill`(999).
- **Shadow:** `--nol-shadow-card`(보더+8% 드롭) · `-soft`(검색바·컨트롤) · `-overlay`(시트·팝오버) · `-brand`(블루틴트 글로우) · `-appbar`(스크롤 헤어라인).
- **Motion:** `--nol-dur-fast`(140) · `-base`(220) · `-entrance`(360) · `--nol-ease`(easeOutCubic) · `--nol-press-scale`(0.97) · `-sm`(0.94) · `--nol-active-scale`(1.04).

---

## 6. COMPONENTS

컴파일된 라이브러리는 `window.NOLDesignSystem_bc8818` 에 노출됩니다. 사용법은 각 컴포넌트의 `*.prompt.md`, props는 `*.d.ts` 참고.

| 그룹 | 컴포넌트 | 요약 |
|------|----------|------|
| core | **Button** | 플랫 블루 CTA. variant primary/secondary/tonal/ghost × size lg/md/sm, `block` |
| core | **IconButton** | 스퀴클/원형 아이콘 버튼. surface/tint/overlay/ghost, `active` 토글 |
| core | **Badge** | 상태 배지. new/popular/sale/brand/neutral, `soft` = 틴트 pill |
| core | **Tag** | 어메니티 칩(기본) / 필터 pill(`selectable`+`selected`) |
| core | **Rating** | ★ 4.8 (1,247) — 앰버 별 + 굵은 값 + 옅은 괄호 카운트 |
| core | **PriceTag** | 시그니처 딜 가격 — 취소선 원가 / 빨강 % / 굵은 가격 / 1박 |
| forms | **SearchBar** | 56px 홈 검색바, 음성 버튼. `readOnly`=진입 숏컷 |
| forms | **TextField** | 회색 채움·16 라운드·블루 포커스·`error` 빨강 |
| navigation | **BottomNav** | 5탭 바. 선택 시 블루틴트 pill + 채움 글리프 |
| navigation | **SectionHeader** | 제목(+부제) + 더보기 › 링크 |
| navigation | **CategoryTile** | 홈 그리드 셀 — 클레이 PNG 또는 그라데이션+글리프 |
| cards | **Card** | 보더+소프트 그림자 범용 표면. radius md/lg/xl |
| cards | **AccommodationCard** | 시그니처 숙소 카드 — 스크림 사진·배지·하트·평점·칩·딜 가격 |
| cards | **PromoBanner** | 그라데이션 프로모 히어로 — 글래스 아이브로우·대형 글리프·CTA |
| feedback | **Toast** | 다크 스낵바 — 잉크 pill·흰 라벨·상태 글리프 |

```jsx
// 예시 — 번들에서 컴포넌트 읽기
const { Button, AccommodationCard } = window.NOLDesignSystem_bc8818;
<Button variant="primary" size="lg" block>결제하기</Button>
```

---

## 7. FILE MAP

```
styles.css                  단일 진입점 (@import 매니페스트)
tokens/                     colors · typography · spacing · radius · shadows · motion · base
fonts/fonts.css             Pretendard @font-face
assets/
  brand/                    app_icon · splash · launch
  search_icons/             3D 클레이 서비스 일러스트 (숙소·항공·티켓·레저·공연·쿠폰…)
  nearby_icons/             내주변 클레이 아이콘 (맛집·액티비티·위치…)
components/
  core/ forms/ navigation/ cards/ feedback/
                            각 폴더: <Name>.jsx + .d.ts + .prompt.md + *.card.html
guidelines/                 파운데이션 스펙 카드 (Colors·Type·Spacing·Brand)
ui_kits/nol_app/            인터랙티브 NOL 앱 (홈→검색→상세→결제)
readme.md · DESIGN.md · SKILL.md
_ds_bundle.js · _ds_manifest.json   (자동 생성 — 직접 수정 금지)
```

---

## 8. 대체 & 주의사항

- **폰트 대체.** Flutter 앱은 번들 폰트가 없고 플랫폼 한글 페이스(Apple SD Gothic Neo / Noto Sans KR)에 의존합니다. 웹 충실도를 위해 **Pretendard**(오픈소스, 거의 동일한 메트릭, 400~900 전체)로 대체하여 `fonts/fonts.css`에서 CDN 로드. *라이선스 보유 시 실제 폰트로 교체하세요.*
- **Material Symbols Rounded**는 Flutter 번들 Material Icons의 웹 대체 — 시각적으로 동등.
- 클레이 일러스트 PNG는 저해상도 앱 에셋 — 래스터로 취급, 과도한 업스케일 지양.
- `_ds_bundle.js` 등 `_`로 시작하는 파일은 컴파일러 자동 생성물 — 직접 수정 금지.

---

## 9. 출처

- **로컬 코드베이스(기준):** `yanolja/` — `lib/core/theme/yanolja_theme.dart`, `lib/main.dart`, `lib/core/nol_menu.dart`, `lib/presentation/widget/*`, `lib/data/datasource/mock_accommodation_api.dart`.
- **GitHub:** https://github.com/joopok/yanolja — 동일 Flutter 프로젝트 (Android/iOS, Riverpod + GoRouter, 목 데이터). 여기서 추가 화면·플로우를 더 정확히 참고할 수 있습니다.
- 본 디자인 시스템은 사용자가 제공한 클론/학습 프로젝트에서 재구성한 것이며, 토큰·동작·카피는 앱 자체의 테마·위젯에서 직접 추출했습니다.
