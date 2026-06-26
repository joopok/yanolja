# 디자인 반복(Iteration) 합의 — 5인 가설 토론 결과

5명 토론자가 "다음 반복의 단일 최우선 개선"을 두고 각 가설을 옹호·반증한 결과(과학 토론). 팀리더 종합 합의.

## 가설 요약
- **H1 서비스 placeholder 분기** — `nol_service_screen`의 17종이 동일 쿠폰 템플릿으로 수렴 → "앱이 깨진 인상". 라이브 정합 직결.
- **H2 홈 콘텐츠 깊이** — 라이브 16섹션 대비 클론 ~45%. (반론: 홈은 이미 가장 완성된 표면)
- **H3 NolFooter + 기획전 상세** — 전 페이지 푸터 부재(최고 ROI 퀵윈), 기획전 카드가 상세로 진입 안 함.
- **H4 티켓/라이브 상세** — 카드 탭이 토스트로만 끝나는 "공허한 인터랙션". (데이터는 카드에 이미 존재)
- **H5 품질 마감** — YanoljaSpacing 사용 0%, hex 리터럴 191개, 등장 애니메이션 13화면 누락 = 하네스 직접 차감 지표.

## 합의 (채택)
세 축을 **frontend-design 스킬 재디자인 패스(Iteration 2)**로 통합한다. 단, 아키텍처 추가 금지·NOL 브랜드 시스템(블루 플랫·토큰) 안에서 크래프트만 끌어올린다.

1. **[H1+frontend-design] 서비스 화면 콘텐츠 분기 + 시각 재디자인**
   - `_couponConfig` 단일 수렴 해소: support/inquiry→`/settings`·전화 안내, recent/cart→상품 리스트형, points/membership→잔액·등급형, notice/news→글 리스트형. coupons/deals는 현 딜카드 유지(의미 적합).
   - 히어로/카드 깊이·모션 강화(YanoljaPremiumHero 패턴 일관).
2. **[H5] 품질 마감(하네스 10/10 직선)**
   - hex 리터럴 → `YanoljaColors`(ticket 33·nol_service·live 우선), 등장 애니메이션 누락 화면(all_categories 등) 보강, 빈/로딩/에러 100%.
3. **[H3] NolFooter 전 화면 부착(완료: home) + 기획전 동선** — `NolFooter` 위젯 신설(완료), 홈 하단 배선(완료). 기획전 상세는 시간 허용 시 후속.

## 검증선
`flutter analyze` 경고 0 + 하네스 evaluation_criteria 10/10 + reduce-motion 동작.
