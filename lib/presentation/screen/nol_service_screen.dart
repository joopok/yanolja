import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_bottom_nav.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';

class NolServiceScreen extends StatefulWidget {
  final String type;

  const NolServiceScreen({super.key, required this.type});

  @override
  State<NolServiceScreen> createState() => _NolServiceScreenState();
}

class _NolServiceScreenState extends State<NolServiceScreen> {
  late _ServiceConfig _config;
  late String _selectedFilter;

  @override
  void initState() {
    super.initState();
    _config = _ServiceConfig.resolve(widget.type);
    _selectedFilter = _config.filters.first;
  }

  @override
  void didUpdateWidget(covariant NolServiceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type) {
      _config = _ServiceConfig.resolve(widget.type);
      _selectedFilter = _config.filters.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final deals = _config.filteredDeals(_selectedFilter);

    return Scaffold(
      backgroundColor: YanoljaColors.surfaceAlt,
      bottomNavigationBar: const YanoljaBottomNav(selectedBranchIndex: 0),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(child: _buildHero()),
          SliverToBoxAdapter(
            child: YanoljaEntrance(
              delay: const Duration(milliseconds: 70),
              child: _buildFilterRail(),
            ),
          ),
          SliverToBoxAdapter(
            child: YanoljaEntrance(
              delay: const Duration(milliseconds: 110),
              child: _buildActionPanel(),
            ),
          ),
          SliverToBoxAdapter(
            child: YanoljaEntrance(
              delay: const Duration(milliseconds: 150),
              child: _buildSectionHeader(deals.length),
            ),
          ),
          SliverList.separated(
            itemCount: deals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return YanoljaEntrance(
                delay: YanoljaMotion.stagger(index, start: 180, step: 40),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    index == 0 ? 0 : 0,
                    20,
                    index == deals.length - 1 ? 24 : 0,
                  ),
                  child: _ServiceDealCard(
                    deal: deals[index],
                    accentColor: _config.accentColor,
                    onTap: () => _showDealSheet(deals[index]),
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return YanoljaSliverAppBar.sub(
      title: _config.title,
      actions: [
        IconButton(
          tooltip: '검색',
          icon: const Icon(Icons.search_rounded),
          onPressed: () => context.go('/search'),
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  Widget _buildHero() {
    return Container(
      color: YanoljaColors.background,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      child: YanoljaPremiumHero(
        badge: _config.badge,
        title: _config.heroTitle,
        subtitle: _config.heroSubtitle,
        icon: _config.icon,
        gradient: [_config.darkColor, _config.accentColor],
        padding: const EdgeInsets.all(22),
        metrics: [
          YanoljaHeroMetric(
            label: _config.primaryMetricLabel,
            value: _config.primaryMetricValue,
          ),
          YanoljaHeroMetric(label: '혜택', value: _config.benefitText),
        ],
      ),
    );
  }

  Widget _buildFilterRail() {
    return Container(
      color: YanoljaColors.background,
      padding: const EdgeInsets.fromLTRB(20, 0, 0, 18),
      child: SizedBox(
        height: 42,
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: _config.filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final filter = _config.filters[index];
            final selected = filter == _selectedFilter;

            return YanoljaPressable(
              pressedScale: 0.985,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedFilter = filter);
              },
              child: AnimatedContainer(
                duration: YanoljaMotion.base,
                curve: YanoljaMotion.curve,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      selected ? YanoljaColors.textPrimary : Colors.transparent,
                  borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                  border: Border.all(
                    color: selected
                        ? YanoljaColors.textPrimary
                        : YanoljaColors.border,
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: selected ? Colors.white : YanoljaColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionPanel() {
    return Container(
      color: YanoljaColors.background,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: YanoljaColors.surfaceAlt,
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          border: Border.all(color: YanoljaColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(YanoljaRadius.md),
              ),
              child: Icon(_config.actionIcon, color: _config.accentColor),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _config.actionTitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: YanoljaColors.textPrimary,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _config.actionSubtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: YanoljaColors.textSecondary,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: _showQuickActionSheet,
              style: FilledButton.styleFrom(
                backgroundColor: _config.accentColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(76, 40),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                ),
              ),
              child: const Text(
                '바로보기',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(int count) {
    return Container(
      color: YanoljaColors.surfaceAlt,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: YanoljaColors.textPrimary,
                  letterSpacing: 0,
                ),
                children: [
                  TextSpan(text: '추천 ${_config.itemName} '),
                  TextSpan(
                    text: '$count',
                    style: TextStyle(color: _config.accentColor),
                  ),
                ],
              ),
            ),
          ),
          Text(
            '실시간 업데이트',
            style: TextStyle(
              color: _config.accentColor,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickActionSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _ServiceActionSheet(config: _config);
      },
    );
  }

  void _showDealSheet(_ServiceDeal deal) {
    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _DealBottomSheet(
          deal: deal,
          accentColor: _config.accentColor,
          itemName: _config.itemName,
        );
      },
    );
  }
}

class _ServiceConfig {
  final String type;
  final String title;
  final String badge;
  final String heroTitle;
  final String heroSubtitle;
  final String itemName;
  final IconData icon;
  final IconData actionIcon;
  final Color accentColor;
  final Color darkColor;
  final String benefitText;
  final String primaryMetricLabel;
  final String primaryMetricValue;
  final String actionTitle;
  final String actionSubtitle;
  final List<String> filters;
  final List<_ServiceDeal> deals;

  const _ServiceConfig({
    required this.type,
    required this.title,
    required this.badge,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.itemName,
    required this.icon,
    required this.actionIcon,
    required this.accentColor,
    required this.darkColor,
    required this.benefitText,
    required this.primaryMetricLabel,
    required this.primaryMetricValue,
    required this.actionTitle,
    required this.actionSubtitle,
    required this.filters,
    required this.deals,
  });

  List<_ServiceDeal> filteredDeals(String filter) {
    if (filter == filters.first) return deals;
    return deals.where((deal) => deal.tags.contains(filter)).toList();
  }

  static _ServiceConfig resolve(String type) {
    return _configs[type] ?? _configs['deals']!;
  }

  static final Map<String, _ServiceConfig> _configs = {
    'flight': _ServiceConfig(
      type: 'flight',
      title: '항공',
      badge: 'NOL AIR',
      heroTitle: '항공권과 숙소를\n한 번에 설계해요',
      heroSubtitle: '국내선부터 해외 도시까지, 지금 가능한 특가 노선을 모았습니다.',
      itemName: '항공권',
      icon: Icons.flight_takeoff_rounded,
      actionIcon: Icons.calendar_month_rounded,
      accentColor: const Color(0xFF315BFF),
      darkColor: const Color(0xFF071A5C),
      benefitText: '10% 쿠폰',
      primaryMetricLabel: '최저가',
      primaryMetricValue: '39,900원',
      actionTitle: '왕복·편도 조건을 빠르게 비교',
      actionSubtitle: '출발지, 날짜, 인원을 선택하고 추천 노선을 확인하세요',
      filters: ['전체', '국내선', '해외선', '주말출발', '쿠폰'],
      deals: [
        _ServiceDeal('김포 → 제주', '아침 출발 · 위탁수하물 포함', '39,900원', '10% 쿠폰',
            Icons.flight_takeoff_rounded, ['국내선', '쿠폰']),
        _ServiceDeal('인천 → 도쿄', '2박 3일 추천 · 호텔 동시 예약 혜택', '119,000원', '해외 인기',
            Icons.public_rounded, ['해외선', '쿠폰']),
        _ServiceDeal('김해 → 다낭', '가족 여행 추천 노선', '149,000원', '주말출발',
            Icons.beach_access_rounded, ['해외선', '주말출발']),
      ],
    ),
    'overseas': _ServiceConfig(
      type: 'overseas',
      title: '해외숙소',
      badge: 'GLOBAL STAY',
      heroTitle: '해외 인기 숙소를\nNOL 혜택가로',
      heroSubtitle: '도쿄, 오사카, 방콕, 다낭 인기 지역 숙소를 큐레이션했습니다.',
      itemName: '해외숙소',
      icon: Icons.luggage_rounded,
      actionIcon: Icons.public_rounded,
      accentColor: const Color(0xFF4C6FFF),
      darkColor: const Color(0xFF16226E),
      benefitText: '코인 적립',
      primaryMetricLabel: '도시',
      primaryMetricValue: '18곳',
      actionTitle: '도시별 숙소와 항공을 함께 비교',
      actionSubtitle: '여행지, 체크인, 투숙 인원을 한 번에 맞춰보세요',
      filters: ['전체', '일본', '동남아', '럭셔리', '가족'],
      deals: [
        _ServiceDeal('도쿄 신주쿠 시티호텔', '역 도보 4분 · 조식 옵션', '128,000원', '일본',
            Icons.apartment_rounded, ['일본']),
        _ServiceDeal('방콕 리버뷰 리조트', '수영장 · 스파 · 공항 픽업', '96,000원', '동남아',
            Icons.pool_rounded, ['동남아', '럭셔리']),
        _ServiceDeal('다낭 패밀리 풀빌라', '방 2개 · 키즈풀 · 해변 3분', '184,000원', '가족추천',
            Icons.villa_rounded, ['동남아', '가족']),
      ],
    ),
    'leisure': _ServiceConfig(
      type: 'leisure',
      title: '레저/티켓',
      badge: 'PLAY PASS',
      heroTitle: '오늘 놀 거리도\nNOL에서 바로 예약',
      heroSubtitle: '워터파크, 테마파크, 액티비티 티켓을 모바일 입장권으로 받아보세요.',
      itemName: '티켓',
      icon: Icons.attractions_rounded,
      actionIcon: Icons.qr_code_2_rounded,
      accentColor: const Color(0xFFFF4FB7),
      darkColor: const Color(0xFF6E144F),
      benefitText: '즉시발권',
      primaryMetricLabel: '할인',
      primaryMetricValue: '최대 42%',
      actionTitle: '날짜별 입장권과 남은 수량 확인',
      actionSubtitle: '방문일만 고르면 사용 가능한 티켓을 바로 보여드려요',
      filters: ['전체', '테마파크', '워터파크', '액티비티', '가족'],
      deals: [
        _ServiceDeal('캐리비안 워터데이 패스', '종일권 · 모바일 즉시입장', '32,900원', '42% 할인',
            Icons.water_drop_rounded, ['워터파크', '가족']),
        _ServiceDeal('도심 루프탑 클라이밍', '2시간 이용권 · 장비 포함', '18,000원', '액티비티',
            Icons.terrain_rounded, ['액티비티']),
        _ServiceDeal('패밀리 테마파크 자유이용권', '대인/소인 공통 특가', '29,900원', '테마파크',
            Icons.celebration_rounded, ['테마파크', '가족']),
      ],
    ),
    'performance': _ServiceConfig(
      type: 'performance',
      title: '공연/전시',
      badge: 'CULTURE PICK',
      heroTitle: '주말의 공연과 전시를\n감각적으로 고르세요',
      heroSubtitle: '뮤지컬, 콘서트, 미디어아트 전시를 좌석/시간대별로 비교합니다.',
      itemName: '공연',
      icon: Icons.theater_comedy_rounded,
      actionIcon: Icons.event_seat_rounded,
      accentColor: const Color(0xFFFF6D3D),
      darkColor: const Color(0xFF61210F),
      benefitText: '좌석 추천',
      primaryMetricLabel: '예매',
      primaryMetricValue: '오픈중',
      actionTitle: '좌석 등급과 회차별 가격 비교',
      actionSubtitle: '원하는 날짜와 시간대를 골라 남은 좌석을 확인하세요',
      filters: ['전체', '뮤지컬', '콘서트', '전시', '오늘'],
      deals: [
        _ServiceDeal('시티 오브 라이트 미디어전', '성수 · 10:00-20:00', '14,900원', '전시',
            Icons.auto_awesome_rounded, ['전시', '오늘']),
        _ServiceDeal('블루문 재즈 콘서트', '금요일 20:00 · R석 추천', '48,000원', '콘서트',
            Icons.music_note_rounded, ['콘서트']),
        _ServiceDeal('뮤지컬 스테이지 나이트', '주말 회차 · 커플석 잔여', '62,000원', '뮤지컬',
            Icons.theater_comedy_rounded, ['뮤지컬']),
      ],
    ),
    'transport': _ServiceConfig(
      type: 'transport',
      title: '교통',
      badge: 'MOVE SMART',
      heroTitle: '이동까지 이어지는\n여행 동선',
      heroSubtitle: '렌터카, 쏘카, 공항 이동, 셔틀까지 여행에 맞춰 연결합니다.',
      itemName: '교통',
      icon: Icons.directions_bus_rounded,
      actionIcon: Icons.route_rounded,
      accentColor: const Color(0xFFFF4D5C),
      darkColor: const Color(0xFF651620),
      benefitText: '무료취소',
      primaryMetricLabel: '예약',
      primaryMetricValue: '당일가능',
      actionTitle: '숙소 위치 기준 이동 수단 추천',
      actionSubtitle: '픽업 지역과 시간을 선택하면 최적 동선을 보여드려요',
      filters: ['전체', '렌터카', '쏘카', '공항', '셔틀'],
      deals: [
        _ServiceDeal('제주 공항 렌터카', '48시간 · 완전자차 옵션', '58,000원', '렌터카',
            Icons.directions_car_filled_rounded, ['렌터카', '공항']),
        _ServiceDeal('서울 도심 쏘카 6시간', '주차존 240곳 · 바로 출발', '24,900원', '쏘카',
            Icons.car_rental_rounded, ['쏘카']),
        _ServiceDeal('공항 프리미엄 셔틀', '새벽 도착 항공편 대응', '18,000원', '공항',
            Icons.airport_shuttle_rounded, ['공항', '셔틀']),
      ],
    ),
    'camping': _ServiceConfig(
      type: 'camping',
      title: '글램핑/캠핑',
      badge: 'OUTDOOR STAY',
      heroTitle: '자연 속 하룻밤도\n편하게 고르세요',
      heroSubtitle: '글램핑, 카라반, 캠핑장과 주변 레저를 한 화면에서 확인합니다.',
      itemName: '캠핑',
      icon: Icons.park_rounded,
      actionIcon: Icons.local_fire_department_rounded,
      accentColor: const Color(0xFF00B894),
      darkColor: const Color(0xFF064D45),
      benefitText: '장비대여',
      primaryMetricLabel: '지역',
      primaryMetricValue: '12곳',
      actionTitle: '날씨와 편의시설 기준으로 추천',
      actionSubtitle: '바베큐, 불멍, 개별 화장실 조건을 빠르게 골라보세요',
      filters: ['전체', '글램핑', '카라반', '바베큐', '가족'],
      deals: [
        _ServiceDeal('가평 리버사이드 글램핑', '개별 바베큐 · 불멍 세트', '89,000원', '글램핑',
            Icons.cabin_rounded, ['글램핑', '바베큐']),
        _ServiceDeal('태안 오션 카라반', '해변 1분 · 반려동물 가능', '112,000원', '카라반',
            Icons.rv_hookup_rounded, ['카라반', '가족']),
        _ServiceDeal('평창 숲속 패밀리 캠프', '아이 체험 프로그램 포함', '76,000원', '가족',
            Icons.forest_rounded, ['가족', '바베큐']),
      ],
    ),
    'guesthouse': _ServiceConfig(
      type: 'guesthouse',
      title: '게스트하우스',
      badge: 'GUEST HOUSE',
      heroTitle: '여행자들이 모이는\n감성 게스트하우스',
      heroSubtitle: '제주·강릉·부산 인기 게스트하우스를 NOL 혜택가로 만나보세요.',
      itemName: '게스트하우스',
      icon: Icons.holiday_village_rounded,
      actionIcon: Icons.groups_rounded,
      accentColor: const Color(0xFFFF8A3D),
      darkColor: const Color(0xFF5C2E0B),
      benefitText: '조식제공',
      primaryMetricLabel: '최저가',
      primaryMetricValue: '29,000원',
      actionTitle: '도미토리·개인실 조건을 빠르게 비교',
      actionSubtitle: '지역, 인원, 조식 여부를 골라 추천 숙소를 확인하세요',
      filters: ['전체', '제주', '강릉', '부산', '도미토리', '개인실'],
      deals: [
        _ServiceDeal('제주 올레 게스트하우스', '도미토리 · 조식 · 올레길 5분', '29,000원', '제주',
            Icons.holiday_village_rounded, ['제주', '도미토리']),
        _ServiceDeal('강릉 바다뷰 게스트하우스', '개인실 · 루프탑 · 해변 3분', '54,000원', '강릉',
            Icons.house_rounded, ['강릉', '개인실']),
        _ServiceDeal('부산 남포동 감성 하우스', '파티룸 · 자전거 대여', '38,000원', '부산',
            Icons.cabin_rounded, ['부산', '도미토리']),
      ],
    ),
    'event': _ServiceConfig(
      type: 'event',
      title: '기획전',
      badge: 'NOL EVENT',
      heroTitle: 'NOL이 준비한\n특별 기획전',
      heroSubtitle: '시즌 테마 기획전과 한정 프로모션을 한 곳에서 확인하세요.',
      itemName: '기획전',
      icon: Icons.campaign_rounded,
      actionIcon: Icons.local_fire_department_rounded,
      accentColor: const Color(0xFFFF6D3D),
      darkColor: const Color(0xFF61210F),
      benefitText: '한정혜택',
      primaryMetricLabel: '진행중',
      primaryMetricValue: '12개',
      actionTitle: '관심 기획전 알림 받기',
      actionSubtitle: '여름 휴가, 호캉스, 해외특가 등 테마별로 모았습니다',
      filters: ['전체', '국내', '해외', '레저', '시즌'],
      deals: [
        _ServiceDeal('여름 호캉스 페스타', '전국 5성 호텔 최대 35% 할인', '특가전', '국내',
            Icons.pool_rounded, ['국내', '시즌']),
        _ServiceDeal('해외여행 다시 시작', '인기 도시 항공+숙소 패키지', '기획전', '해외',
            Icons.flight_takeoff_rounded, ['해외']),
        _ServiceDeal('워터파크 얼리버드', '여름 레저 입장권 사전 특가', '레저전', '레저',
            Icons.water_drop_rounded, ['레저', '시즌']),
      ],
    ),
    'coupons': _couponConfig('coupons', '쿠폰·혜택', 'COUPON BOX'),
    'cart': _couponConfig('cart', '장바구니', 'SAVED DEALS'),
    'notifications': _couponConfig('notifications', '알림', 'NOL NOTICE'),
    'news': _couponConfig('news', 'NOL 소식', 'NOL TODAY'),
    'draw': _couponConfig('draw', 'NOL드로우', 'LUCKY DRAW'),
    'first-benefit': _couponConfig('first-benefit', '첫 구매 혜택', 'FIRST PAYBACK'),
    'nol-card': _couponConfig('nol-card', 'NOL 카드', 'NOL CARD'),
    'deals': _couponConfig('deals', '특가', 'HOT DEAL'),
    'support': _couponConfig('support', '고객센터', 'HELP DESK'),
    'notice': _couponConfig('notice', '공지사항', 'NOTICE'),
    'settings': _couponConfig('settings', '앱 설정', 'APP SETTINGS'),
    'app-info': _couponConfig('app-info', '앱 정보', 'ABOUT NOL'),
    'package': _couponConfig('package', '패키지', 'PACKAGE'),
    'overseas-tour': _couponConfig('overseas-tour', '해외투어', 'GLOBAL TOUR'),
    'motel': _couponConfig('motel', '모텔', 'MOTEL'),
    'points': _couponConfig('points', 'NOL 포인트', 'NOL POINT'),
    'membership': _couponConfig('membership', '회원등급', 'VIP CLUB'),
    'recent': _couponConfig('recent', '최근 본 상품', 'RECENT VIEW'),
    'inquiry': _couponConfig('inquiry', '1:1 문의', 'INQUIRY'),
  };

  static _ServiceConfig _couponConfig(String type, String title, String badge) {
    return _ServiceConfig(
      type: type,
      title: title,
      badge: badge,
      heroTitle: '$title\n한눈에 확인해요',
      heroSubtitle: '내 여행에 바로 적용할 수 있는 혜택과 추천 액션을 모았습니다.',
      itemName: '혜택',
      icon: Icons.local_offer_rounded,
      actionIcon: Icons.check_circle_rounded,
      accentColor: YanoljaColors.primary,
      darkColor: const Color(0xFF101B5C),
      benefitText: '즉시적용',
      primaryMetricLabel: '보유',
      primaryMetricValue: '8개',
      actionTitle: '사용 가능한 혜택을 우선 정렬',
      actionSubtitle: '숙소, 티켓, 항공에 바로 쓸 수 있는 조건을 확인하세요',
      filters: const ['전체', '숙소', '티켓', '항공', '오늘'],
      deals: const [
        _ServiceDeal('국내숙소 12% 쿠폰', '3만원 이상 결제 시 자동 적용', '최대 20,000원', '숙소',
            Icons.hotel_rounded, ['숙소', '오늘']),
        _ServiceDeal('티켓 즉시할인', '레저/공연 모바일 티켓 전용', '최대 8,000원', '티켓',
            Icons.confirmation_number_rounded, ['티켓']),
        _ServiceDeal('항공 첫 결제 페이백', '왕복 항공권 결제 후 코인 적립', '12,000코인', '항공',
            Icons.flight_takeoff_rounded, ['항공', '오늘']),
      ],
    );
  }
}

class _ServiceDeal {
  final String title;
  final String subtitle;
  final String price;
  final String badge;
  final IconData icon;
  final List<String> tags;

  const _ServiceDeal(
    this.title,
    this.subtitle,
    this.price,
    this.badge,
    this.icon,
    this.tags,
  );
}

class _ServiceDealCard extends StatelessWidget {
  final _ServiceDeal deal;
  final Color accentColor;
  final VoidCallback onTap;

  const _ServiceDealCard({
    required this.deal,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return YanoljaPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          border: Border.all(color: YanoljaColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(deal.icon, color: accentColor, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(YanoljaRadius.pill),
                        ),
                        child: Text(
                          deal.badge,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    deal.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: YanoljaColors.textPrimary,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    deal.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: YanoljaColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  deal.price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: YanoljaColors.textPrimary,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: YanoljaColors.textTertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceActionSheet extends StatelessWidget {
  final _ServiceConfig config;

  const _ServiceActionSheet({required this.config});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: YanoljaColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              config.actionTitle,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: YanoljaColors.textPrimary,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              config.actionSubtitle,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: YanoljaColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _SheetOption(
                    icon: Icons.calendar_today_rounded,
                    title: '날짜',
                    value: '6.19 - 6.20',
                    color: config.accentColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SheetOption(
                    icon: Icons.people_alt_rounded,
                    title: '인원',
                    value: '성인 2',
                    color: config.accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: config.accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(YanoljaRadius.md),
                  ),
                ),
                child: const Text(
                  '조건 적용하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DealBottomSheet extends StatelessWidget {
  final _ServiceDeal deal;
  final Color accentColor;
  final String itemName;

  const _DealBottomSheet({
    required this.deal,
    required this.accentColor,
    required this.itemName,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: YanoljaColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(deal.icon, color: accentColor, size: 29),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deal.badge,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        deal.title,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: YanoljaColors.textPrimary,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              deal.subtitle,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: YanoljaColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: YanoljaColors.surfaceAlt,
                borderRadius: BorderRadius.circular(YanoljaRadius.md),
              ),
              child: Row(
                children: [
                  Text(
                    itemName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: YanoljaColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    deal.price,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: YanoljaColors.textPrimary,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(YanoljaRadius.md),
                  ),
                ),
                child: const Text(
                  '선택하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _SheetOption({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: YanoljaColors.surfaceAlt,
        borderRadius: BorderRadius.circular(YanoljaRadius.md),
        border: Border.all(color: YanoljaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 9),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: YanoljaColors.textTertiary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: YanoljaColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
