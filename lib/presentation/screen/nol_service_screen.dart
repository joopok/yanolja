import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/presentation/widget/nol_my_icon.dart';
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
          SliverToBoxAdapter(
            child: YanoljaEntrance(
              delay: const Duration(milliseconds: 30),
              child: _buildHero(),
            ),
          ),
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
          if (deals.isEmpty)
            SliverToBoxAdapter(child: _buildEmptyState())
          else
            SliverList.separated(
              itemCount: deals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return YanoljaEntrance(
                  delay: YanoljaMotion.stagger(index, start: 180, step: 40),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      0,
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
      subtitle: '전체 메뉴에서 선택한 서비스',
      fallbackRoute: '/all-categories',
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
    final accent = _config.accentColor;
    return Container(
      color: YanoljaColors.surfaceAlt,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: YanoljaColors.background,
          borderRadius: BorderRadius.circular(YanoljaRadius.xl),
          border: Border.all(color: YanoljaColors.border),
          boxShadow: const [
            BoxShadow(
              color: YanoljaColors.shadow,
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (_config.iconAsset == null)
                  Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(_config.icon, color: accent, size: 27),
                  )
                else
                  NolMyIcon(
                    asset: _config.iconAsset!,
                    size: 58,
                    semanticLabel: _config.title,
                  ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _config.badge,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: accent,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _config.heroTitle.replaceAll('\n', ' '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          height: 1.22,
                          fontWeight: FontWeight.w900,
                          color: YanoljaColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              _config.heroSubtitle,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: YanoljaColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ServiceMetricChip(
                  label: _config.primaryMetricLabel,
                  value: _config.primaryMetricValue,
                ),
                _ServiceMetricChip(
                  label: _config.benefitLabel,
                  value: _config.benefitText,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRail() {
    return Container(
      color: YanoljaColors.surfaceAlt,
      padding: const EdgeInsets.fromLTRB(20, 0, 0, 16),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: YanoljaSpacing.m),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      selected ? YanoljaColors.primary : YanoljaColors.surface,
                  borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                  border: Border.all(
                    color:
                        selected ? YanoljaColors.primary : YanoljaColors.border,
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
    final accent = _config.accentColor;
    return Container(
      color: YanoljaColors.surfaceAlt,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: YanoljaColors.background,
          borderRadius: BorderRadius.circular(YanoljaRadius.xl),
          border: Border.all(color: YanoljaColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(YanoljaRadius.md),
              ),
              child: Icon(_config.actionIcon, color: accent),
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
                backgroundColor: YanoljaColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(76, 40),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                ),
              ),
              child: Text(
                _config.actionButtonLabel,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(int count) {
    final sectionTitle = _config.sectionTitle ?? '추천 ${_config.itemName}';
    return Container(
      color: YanoljaColors.surfaceAlt,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: YanoljaColors.textPrimary,
                  letterSpacing: -0.3,
                ),
                children: [
                  TextSpan(text: '$sectionTitle '),
                  TextSpan(
                    text: '$count',
                    style: TextStyle(color: _config.accentColor),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _config.sectionTrailing,
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

  /// 선택한 필터에 해당하는 항목이 없을 때의 빈 상태.
  Widget _buildEmptyState() {
    return Container(
      color: YanoljaColors.surfaceAlt,
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 56),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: YanoljaColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: YanoljaColors.border),
            ),
            child: Icon(
              _config.icon,
              size: 34,
              color: YanoljaColors.textTertiary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            "'$_selectedFilter' 조건의 ${_config.itemName} 항목이 없어요",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: YanoljaColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            '다른 조건을 선택하면 더 많은 항목을 볼 수 있어요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: YanoljaColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: () =>
                setState(() => _selectedFilter = _config.filters.first),
            style: OutlinedButton.styleFrom(
              foregroundColor: _config.accentColor,
              side: BorderSide(color: _config.accentColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(YanoljaRadius.md),
              ),
            ),
            child: const Text(
              '전체 보기',
              style: TextStyle(fontWeight: FontWeight.w900),
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

class _ServiceMetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _ServiceMetricChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: YanoljaColors.surfaceAlt,
        borderRadius: BorderRadius.circular(YanoljaRadius.pill),
        border: Border.all(color: YanoljaColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: YanoljaColors.textTertiary,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: YanoljaColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 액션 시트에 노출되는 요약 정보 한 칸(아이콘 + 라벨 + 값).
///
/// 타입별로 의미가 다른 정보(날짜/인원, 전화/운영시간, 보유/소멸 등)를
/// 같은 시트 레이아웃으로 재사용하기 위한 데이터 홀더다.
class _SheetFacet {
  final IconData icon;
  final String title;
  final String value;

  const _SheetFacet(this.icon, this.title, this.value);
}

/// 여행 예약형(항공/숙소/레저 등)의 기본 시트 요약 정보.
const List<_SheetFacet> _kTravelFacets = [
  _SheetFacet(Icons.calendar_today_rounded, '날짜', '6.19 - 6.20'),
  _SheetFacet(Icons.people_alt_rounded, '인원', '성인 2'),
];

class _ServiceConfig {
  final String type;
  final String title;
  final String badge;
  final String heroTitle;
  final String heroSubtitle;
  final String itemName;
  final IconData icon;
  final String? iconAsset;
  final IconData actionIcon;
  final Color accentColor;
  final String benefitLabel;
  final String benefitText;
  final String primaryMetricLabel;
  final String primaryMetricValue;
  final String actionTitle;
  final String actionSubtitle;
  final String actionButtonLabel;
  final String sheetConfirmLabel;
  final List<_SheetFacet> sheetFacets;
  final String? sectionTitle;
  final String sectionTrailing;
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
    this.iconAsset,
    required this.actionIcon,
    required this.accentColor,
    this.benefitLabel = '혜택',
    required this.benefitText,
    required this.primaryMetricLabel,
    required this.primaryMetricValue,
    required this.actionTitle,
    required this.actionSubtitle,
    this.actionButtonLabel = '조건 보기',
    this.sheetConfirmLabel = '조건 적용하기',
    this.sheetFacets = _kTravelFacets,
    this.sectionTitle,
    this.sectionTrailing = '실시간 업데이트',
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
      accentColor: YanoljaColors.primary,
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
      benefitText: '한정혜택',
      primaryMetricLabel: '진행중',
      primaryMetricValue: '12개',
      actionTitle: '관심 기획전 알림 받기',
      actionSubtitle: '여름 휴가, 호캉스, 해외특가 등 테마별로 모았습니다',
      actionButtonLabel: '알림 받기',
      sheetConfirmLabel: '알림 켜기',
      sheetFacets: const [
        _SheetFacet(Icons.interests_rounded, '관심 테마', '호캉스'),
        _SheetFacet(Icons.notifications_active_rounded, '오픈 알림', '받기'),
      ],
      sectionTitle: '진행 중인 기획전',
      sectionTrailing: '오늘 오픈',
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
    'motel': _ServiceConfig(
      type: 'motel',
      title: '모텔',
      badge: 'NOL MOTEL',
      heroTitle: '가까운 모텔도\nNOL 특가로',
      heroSubtitle: '대실부터 숙박까지, 지금 바로 예약 가능한 모텔을 모았습니다.',
      itemName: '모텔',
      icon: Icons.bed_rounded,
      actionIcon: Icons.schedule_rounded,
      accentColor: const Color(0xFFFF9F1C),
      benefitText: '즉시예약',
      primaryMetricLabel: '대실가',
      primaryMetricValue: '19,000원',
      actionTitle: '대실·숙박 시간과 위치를 빠르게 비교',
      actionSubtitle: '이용 시간대와 지역을 선택하면 예약 가능한 모텔을 보여드려요',
      filters: ['전체', '대실', '숙박', '브랜드', '주차'],
      deals: [
        _ServiceDeal('강남 프리미엄 스테이', '대실 4시간 · 무인 체크인', '24,000원', '대실',
            Icons.meeting_room_rounded, ['대실', '브랜드']),
        _ServiceDeal('홍대 디자인 모텔', '숙박 · 더블베드 · 주차 가능', '46,000원', '숙박',
            Icons.king_bed_rounded, ['숙박', '주차']),
        _ServiceDeal('수원역 브랜드 모텔', '대실/숙박 선택 · 역세권', '19,000원', '브랜드',
            Icons.local_hotel_rounded, ['대실', '숙박', '브랜드']),
      ],
    ),
    'overseas-tour': _ServiceConfig(
      type: 'overseas-tour',
      title: '해외투어/티켓',
      badge: 'GLOBAL TOUR',
      heroTitle: '해외 투어와 입장권을\n출발 전 미리',
      heroSubtitle: '인기 도시의 투어, 입장권, 액티비티를 모바일 바우처로 받아보세요.',
      itemName: '투어',
      icon: Icons.tour_rounded,
      actionIcon: Icons.confirmation_number_rounded,
      accentColor: const Color(0xFF00B8A0),
      benefitText: '모바일권',
      primaryMetricLabel: '도시',
      primaryMetricValue: '32곳',
      actionTitle: '도시별 투어와 입장권을 한눈에',
      actionSubtitle: '여행 도시와 날짜를 고르면 예약 가능한 투어를 보여드려요',
      filters: ['전체', '일본', '동남아', '유럽', '입장권'],
      deals: [
        _ServiceDeal('오사카 USJ 입장권', '익스프레스 패스 옵션 · 즉시발권', '78,000원', '일본',
            Icons.attractions_rounded, ['일본', '입장권']),
        _ServiceDeal('방콕 수상시장 투어', '한국어 가이드 · 호텔 픽업', '52,000원', '동남아',
            Icons.directions_boat_rounded, ['동남아']),
        _ServiceDeal('파리 루브르 우선입장', '오디오 가이드 포함', '36,000원', '유럽',
            Icons.museum_rounded, ['유럽', '입장권']),
      ],
    ),
    'package': _ServiceConfig(
      type: 'package',
      title: '해외패키지',
      badge: 'NOL PACKAGE',
      heroTitle: '항공+숙소를 한 번에\n해외패키지',
      heroSubtitle: '자유여행부터 가족여행까지, 인기 도시 패키지를 큐레이션했습니다.',
      itemName: '패키지',
      icon: Icons.card_travel_rounded,
      actionIcon: Icons.flight_takeoff_rounded,
      accentColor: const Color(0xFF7C5BFF),
      benefitText: '항공포함',
      primaryMetricLabel: '최저가',
      primaryMetricValue: '399,000원',
      actionTitle: '항공·숙소·일정을 한 번에 비교',
      actionSubtitle: '여행지와 출발일, 인원을 고르면 추천 패키지를 보여드려요',
      filters: ['전체', '일본', '동남아', '유럽', '가족'],
      deals: [
        _ServiceDeal('도쿄 3박 4일 자유패키지', '왕복 항공 + 시내 호텔', '619,000원', '일본',
            Icons.apartment_rounded, ['일본']),
        _ServiceDeal('다낭 가족 풀빌라 패키지', '항공 + 풀빌라 + 조식', '799,000원', '가족추천',
            Icons.villa_rounded, ['동남아', '가족']),
        _ServiceDeal('로마·바티칸 7일 패키지', '항공 + 4성 호텔 + 투어', '1,890,000원', '유럽',
            Icons.church_rounded, ['유럽']),
      ],
    ),

    // ── 혜택형(딜카드가 의미상 적합): 쿠폰·특가 ──────────────────────
    'coupons': _couponConfig('coupons', '쿠폰·혜택', 'COUPON BOX'),
    'deals': _couponConfig('deals', '특가', 'HOT DEAL'),

    // ── 고객지원: FAQ / 1:1 문의 ────────────────────────────────────
    'support': _ServiceConfig(
      type: 'support',
      title: '고객센터',
      badge: 'HELP CENTER',
      heroTitle: '무엇을 도와드릴까요?\n바로 찾아드려요',
      heroSubtitle: '자주 묻는 질문부터 전화 상담까지, NOL 고객센터가 함께합니다.',
      itemName: '도움말',
      icon: Icons.support_agent_rounded,
      iconAsset: NolMyIconAsset.support,
      actionIcon: Icons.call_rounded,
      accentColor: YanoljaColors.primary,
      benefitLabel: '상담전화',
      benefitText: '1644-1346',
      primaryMetricLabel: '운영',
      primaryMetricValue: '평일 09-18시',
      actionTitle: '고객센터 1644-1346',
      actionSubtitle: '평일 09:00-18:00 · 주말/공휴일 휴무',
      actionButtonLabel: '전화 안내',
      sheetConfirmLabel: '확인',
      sheetFacets: const [
        _SheetFacet(Icons.call_rounded, '대표번호', '1644-1346'),
        _SheetFacet(Icons.schedule_rounded, '운영시간', '09-18시'),
      ],
      sectionTitle: '자주 묻는 질문',
      sectionTrailing: 'TOP 4',
      filters: ['전체', '예약', '결제', '취소/환불', '회원'],
      deals: [
        _ServiceDeal('예약을 변경하거나 취소하고 싶어요', '예약 내역 > 상세에서 바로 신청할 수 있어요', '자세히',
            '예약', Icons.event_repeat_rounded, ['예약']),
        _ServiceDeal('결제가 중복으로 된 것 같아요', '중복 결제 건은 3~5영업일 내 자동 취소돼요', '자세히',
            '결제', Icons.payments_rounded, ['결제']),
        _ServiceDeal('취소 수수료 기준이 궁금해요', '숙소별 취소 정책은 상세 화면에서 확인돼요', '자세히',
            '취소/환불', Icons.receipt_long_rounded, ['취소/환불']),
        _ServiceDeal('회원 정보를 변경하고 싶어요', '내정보 > 프로필 편집에서 수정할 수 있어요', '자세히', '회원',
            Icons.manage_accounts_rounded, ['회원']),
      ],
    ),
    'inquiry': _ServiceConfig(
      type: 'inquiry',
      title: '1:1 문의',
      badge: 'ASK NOL',
      heroTitle: '궁금한 점을\n1:1로 문의하세요',
      heroSubtitle: '접수된 문의는 보통 1영업일 이내에 알림으로 답변드려요.',
      itemName: '문의',
      icon: Icons.forum_rounded,
      iconAsset: NolMyIconAsset.support,
      actionIcon: Icons.edit_note_rounded,
      accentColor: YanoljaColors.primary,
      benefitLabel: '평균 답변',
      benefitText: '1일 이내',
      primaryMetricLabel: '내 문의',
      primaryMetricValue: '3건',
      actionTitle: '새 문의 작성하기',
      actionSubtitle: '문의 유형과 내용을 입력하면 바로 접수돼요',
      actionButtonLabel: '문의 작성',
      sheetConfirmLabel: '문의 접수',
      sheetFacets: const [
        _SheetFacet(Icons.category_rounded, '유형', '예약/결제'),
        _SheetFacet(Icons.attach_file_rounded, '첨부', '사진 2장'),
      ],
      sectionTitle: '내 문의 내역',
      sectionTrailing: '최근 30일',
      filters: ['전체', '답변완료', '답변대기'],
      deals: [
        _ServiceDeal('환불은 언제 처리되나요?', '8.24 접수 · 카드 환불 일정 안내드렸어요', '보기', '답변완료',
            Icons.task_alt_rounded, ['답변완료']),
        _ServiceDeal('영수증을 다시 받을 수 있나요?', '8.26 접수 · 답변을 준비하고 있어요', '보기',
            '답변대기', Icons.hourglass_bottom_rounded, ['답변대기']),
        _ServiceDeal('쿠폰이 적용되지 않아요', '8.27 접수 · 답변을 준비하고 있어요', '보기', '답변대기',
            Icons.hourglass_bottom_rounded, ['답변대기']),
      ],
    ),

    // ── 마이쇼핑: 최근 본 상품 / 장바구니 (상품 리스트형) ──────────────
    'recent': _ServiceConfig(
      type: 'recent',
      title: '최근 본 상품',
      badge: 'RECENTLY VIEWED',
      heroTitle: '다시 보면\n예약하고 싶은 곳',
      heroSubtitle: '최근 둘러본 숙소와 상품을 한곳에 모았어요.',
      itemName: '상품',
      icon: Icons.history_rounded,
      iconAsset: NolMyIconAsset.recent,
      actionIcon: Icons.compare_arrows_rounded,
      accentColor: YanoljaColors.primary,
      benefitLabel: '가격 변동',
      benefitText: '알림 받기',
      primaryMetricLabel: '최근',
      primaryMetricValue: '7일',
      actionTitle: '관심 상품 가격 비교',
      actionSubtitle: '둘러본 상품의 최신 가격을 한 번에 확인하세요',
      actionButtonLabel: '비교하기',
      sheetConfirmLabel: '비교 보기',
      sheetFacets: const [
        _SheetFacet(Icons.sort_rounded, '정렬', '최근 본 순'),
        _SheetFacet(Icons.local_offer_rounded, '필터', '특가만'),
      ],
      sectionTitle: '최근 본 상품',
      sectionTrailing: '최근 7일',
      filters: ['전체', '호텔', '펜션', '리조트'],
      deals: [
        _ServiceDeal('시그니엘 서울', '잠실 · 시티뷰 디럭스 · 조식 포함', '420,000원', '호텔',
            Icons.apartment_rounded, ['호텔']),
        _ServiceDeal('가평 푸른숲 펜션', '독채 · 개별 바베큐 · 계곡 5분', '180,000원', '펜션',
            Icons.cabin_rounded, ['펜션']),
        _ServiceDeal('제주 오션 리조트', '오션뷰 스위트 · 인피니티풀', '320,000원', '리조트',
            Icons.pool_rounded, ['리조트']),
      ],
    ),
    'cart': _ServiceConfig(
      type: 'cart',
      title: '장바구니',
      badge: 'MY CART',
      heroTitle: '담아둔 상품을\n한 번에 예약',
      heroSubtitle: '장바구니에 담은 숙소와 상품을 모아 결제까지 이어가세요.',
      itemName: '담은 상품',
      icon: Icons.shopping_bag_rounded,
      iconAsset: NolMyIconAsset.saved,
      actionIcon: Icons.payment_rounded,
      accentColor: YanoljaColors.primary,
      benefitLabel: '결제',
      benefitText: '묶음 가능',
      primaryMetricLabel: '담은 상품',
      primaryMetricValue: '2개',
      actionTitle: '장바구니 묶음 결제',
      actionSubtitle: '선택한 상품을 한 번에 결제할 수 있어요',
      actionButtonLabel: '결제하기',
      sheetConfirmLabel: '결제 진행',
      sheetFacets: const [
        _SheetFacet(Icons.event_rounded, '일정', '6.19 - 6.20'),
        _SheetFacet(Icons.credit_card_rounded, '결제수단', 'NOL페이'),
      ],
      sectionTitle: '장바구니 상품',
      sectionTrailing: '담은 순',
      filters: ['전체', '숙소', '레저', '항공'],
      deals: [
        _ServiceDeal('부산 해운대 마린호텔', '6.19-6.20 · 디럭스 더블', '156,000원', '숙소',
            Icons.hotel_rounded, ['숙소']),
        _ServiceDeal('에버랜드 자유이용권', '대인 2매 · 모바일 입장권', '62,000원', '레저',
            Icons.attractions_rounded, ['레저']),
      ],
    ),

    // ── 멤버십/포인트 ──────────────────────────────────────────────
    'points': _ServiceConfig(
      type: 'points',
      title: 'NOL 포인트',
      badge: 'NOL POINT',
      heroTitle: '쌓이고 쓰는\nNOL 포인트',
      heroSubtitle: '예약하고 적립한 포인트로 다음 여행을 더 가볍게 떠나요.',
      itemName: '내역',
      icon: Icons.toll_rounded,
      iconAsset: NolMyIconAsset.points,
      actionIcon: Icons.savings_rounded,
      accentColor: YanoljaColors.primary,
      benefitLabel: '소멸예정',
      benefitText: '800P',
      primaryMetricLabel: '보유',
      primaryMetricValue: '12,400P',
      actionTitle: '소멸 예정 포인트 확인',
      actionSubtitle: '이번 달 소멸 예정 포인트를 미리 확인하세요',
      actionButtonLabel: '내역 보기',
      sheetConfirmLabel: '확인',
      sheetFacets: const [
        _SheetFacet(Icons.account_balance_wallet_rounded, '보유', '12,400P'),
        _SheetFacet(Icons.timelapse_rounded, '소멸예정', '800P'),
      ],
      sectionTitle: '최근 적립·사용 내역',
      sectionTrailing: '이번 달',
      filters: ['전체', '적립', '사용', '소멸'],
      deals: [
        _ServiceDeal('제주 신라스테이 예약 적립', '6.18 · 결제 금액의 1% 적립', '+1,560P', '적립',
            Icons.add_circle_rounded, ['적립']),
        _ServiceDeal('티켓 결제에 포인트 사용', '6.12 · 레저 티켓 결제에 차감', '-3,000P', '사용',
            Icons.remove_circle_rounded, ['사용']),
        _ServiceDeal('첫 리뷰 작성 보너스', '6.01 · 이벤트 보너스 적립', '+500P', '적립',
            Icons.card_giftcard_rounded, ['적립']),
        _ServiceDeal('기간 만료 예정 포인트', '6.30 소멸 예정 · 미리 사용하세요', '800P', '소멸',
            Icons.timelapse_rounded, ['소멸']),
      ],
    ),
    'membership': _ServiceConfig(
      type: 'membership',
      title: '회원등급',
      badge: 'NOL CLUB',
      heroTitle: '지금 내 등급은\nGOLD',
      heroSubtitle: '예약할수록 등급이 올라가고, 등급별 혜택이 더 커져요.',
      itemName: '등급 혜택',
      icon: Icons.workspace_premium_rounded,
      iconAsset: NolMyIconAsset.points,
      actionIcon: Icons.trending_up_rounded,
      accentColor: YanoljaColors.primary,
      benefitLabel: '다음 등급',
      benefitText: 'PLATINUM',
      primaryMetricLabel: '내 등급',
      primaryMetricValue: 'GOLD',
      actionTitle: '다음 등급까지 2회 남았어요',
      actionSubtitle: '90일 내 2회 더 예약하면 PLATINUM으로 올라가요',
      actionButtonLabel: '혜택 보기',
      sheetConfirmLabel: '확인',
      sheetFacets: const [
        _SheetFacet(Icons.military_tech_rounded, '현재 등급', 'GOLD'),
        _SheetFacet(Icons.upgrade_rounded, '다음 등급', 'PLATINUM'),
      ],
      sectionTitle: '등급별 혜택',
      sectionTrailing: 'GOLD 기준',
      filters: ['전체', '적립', '할인', '전용'],
      deals: [
        _ServiceDeal('숙소 예약 5% 추가 적립', 'GOLD 등급 전용 · 결제 시 자동 적용', '5%', '적립',
            Icons.savings_rounded, ['적립']),
        _ServiceDeal('전용 쿠폰 매월 제공', '매월 1일 등급 쿠폰이 자동 지급돼요', '월 1회', '할인',
            Icons.confirmation_number_rounded, ['할인']),
        _ServiceDeal('우선 예약 & 전용 상담', 'GOLD 이상 전용 혜택', '전용', '전용',
            Icons.support_agent_rounded, ['전용']),
      ],
    ),

    // ── 안내형: 드로우 / 첫 구매 / NOL 카드 ──────────────────────────
    'draw': _ServiceConfig(
      type: 'draw',
      title: 'NOL드로우',
      badge: 'LUCKY DRAW',
      heroTitle: '매일 도전하는\n행운의 드로우',
      heroSubtitle: '응모하고 추첨을 기다리세요. 매일 새로운 혜택이 열려요.',
      itemName: '드로우',
      icon: Icons.casino_rounded,
      actionIcon: Icons.confirmation_number_rounded,
      accentColor: YanoljaColors.primaryPurple,
      benefitLabel: '보유 응모권',
      benefitText: '3장',
      primaryMetricLabel: '진행중',
      primaryMetricValue: '3개',
      actionTitle: '오늘의 드로우 응모하기',
      actionSubtitle: '응모권으로 참여하고 추첨 결과를 기다리세요',
      actionButtonLabel: '응모하기',
      sheetConfirmLabel: '응모 완료',
      sheetFacets: const [
        _SheetFacet(Icons.confirmation_number_rounded, '응모권', '3장'),
        _SheetFacet(Icons.schedule_rounded, '발표', '내일 12시'),
      ],
      sectionTitle: '진행 중인 드로우',
      sectionTrailing: '오늘 마감',
      filters: ['전체', '여행', '포인트', '기프트'],
      deals: [
        _ServiceDeal('제주 2박 3일 숙박권', '응모권 1장 · 오늘 23:59 마감', '응모하기', '여행',
            Icons.card_travel_rounded, ['여행']),
        _ServiceDeal('NOL 포인트 10,000P', '응모권 1장 · 매일 추첨', '응모하기', '포인트',
            Icons.toll_rounded, ['포인트']),
        _ServiceDeal('스타벅스 기프트카드', '응모권 1장 · 100명 추첨', '응모하기', '기프트',
            Icons.card_giftcard_rounded, ['기프트']),
      ],
    ),
    'first-benefit': _ServiceConfig(
      type: 'first-benefit',
      title: '첫 구매 혜택',
      badge: 'FIRST BENEFIT',
      heroTitle: 'NOL이 처음이라면\n첫 예약 혜택부터',
      heroSubtitle: '첫 결제에 바로 쓰는 할인과 적립 혜택을 모았어요.',
      itemName: '혜택',
      icon: Icons.redeem_rounded,
      iconAsset: NolMyIconAsset.coupon,
      actionIcon: Icons.card_giftcard_rounded,
      accentColor: YanoljaColors.primary,
      benefitLabel: '대상',
      benefitText: '첫 결제',
      primaryMetricLabel: '최대 혜택',
      primaryMetricValue: '15,000원',
      actionTitle: '첫 구매 쿠폰 받기',
      actionSubtitle: '첫 결제 전용 쿠폰을 한 번에 발급받으세요',
      actionButtonLabel: '쿠폰 받기',
      sheetConfirmLabel: '쿠폰 발급',
      sheetFacets: const [
        _SheetFacet(Icons.local_activity_rounded, '쿠폰', '3장'),
        _SheetFacet(Icons.event_available_rounded, '유효기간', '30일'),
      ],
      sectionTitle: '첫 구매 전용 혜택',
      sectionTrailing: '신규 회원',
      filters: ['전체', '숙소', '레저', '항공'],
      deals: [
        _ServiceDeal('첫 숙소 예약 15% 할인', '첫 결제 시 1회 자동 적용', '최대 15,000원', '숙소',
            Icons.hotel_rounded, ['숙소']),
        _ServiceDeal('첫 레저 티켓 5천원 할인', '레저/공연 첫 결제 전용', '5,000원', '레저',
            Icons.attractions_rounded, ['레저']),
        _ServiceDeal('첫 항공 결제 페이백', '왕복 항공권 결제 후 코인 적립', '10,000코인', '항공',
            Icons.flight_takeoff_rounded, ['항공']),
      ],
    ),
    'nol-card': _ServiceConfig(
      type: 'nol-card',
      title: 'NOL 카드',
      badge: 'NOL CARD',
      heroTitle: '여행에 진심인\nNOL 카드 혜택',
      heroSubtitle: 'NOL 카드로 결제하면 적립과 할인이 더 커져요.',
      itemName: '카드 혜택',
      icon: Icons.credit_card_rounded,
      iconAsset: NolMyIconAsset.card,
      actionIcon: Icons.add_card_rounded,
      accentColor: YanoljaColors.primary,
      benefitLabel: '연회비',
      benefitText: '15,000원',
      primaryMetricLabel: '적립률',
      primaryMetricValue: '최대 5%',
      actionTitle: 'NOL 카드 발급 안내',
      actionSubtitle: '연회비와 주요 혜택을 확인하고 신청하세요',
      actionButtonLabel: '발급 안내',
      sheetConfirmLabel: '확인',
      sheetFacets: const [
        _SheetFacet(Icons.percent_rounded, '기본 적립', '2%'),
        _SheetFacet(Icons.local_fire_department_rounded, '여행 적립', '5%'),
      ],
      sectionTitle: 'NOL 카드 혜택',
      sectionTrailing: '결제 시 자동',
      filters: ['전체', '적립', '할인', '제휴'],
      deals: [
        _ServiceDeal('NOL 예약 5% 적립', '숙소·항공 결제 시 자동 적립', '5% 적립', '적립',
            Icons.savings_rounded, ['적립']),
        _ServiceDeal('전국 주유소 리터당 할인', '제휴 주유소 결제 시 즉시 할인', '리터 60원', '할인',
            Icons.local_gas_station_rounded, ['할인']),
        _ServiceDeal('제휴 레저시설 우대', '워터파크·테마파크 입장 할인', '제휴', '제휴',
            Icons.attractions_rounded, ['제휴']),
      ],
    ),

    // ── 알림/공지/소식 (글 리스트형) ────────────────────────────────
    'notifications': _ServiceConfig(
      type: 'notifications',
      title: '알림',
      badge: 'NOTIFICATIONS',
      heroTitle: '놓치면 아쉬운\n나의 알림',
      heroSubtitle: '예약 상태, 혜택, 소식 알림을 한곳에서 확인하세요.',
      itemName: '알림',
      icon: Icons.notifications_rounded,
      iconAsset: NolMyIconAsset.notification,
      actionIcon: Icons.tune_rounded,
      accentColor: YanoljaColors.primary,
      benefitLabel: '읽지 않음',
      benefitText: '2건',
      primaryMetricLabel: '새 알림',
      primaryMetricValue: '3건',
      actionTitle: '알림 설정 관리',
      actionSubtitle: '받고 싶은 알림 종류를 직접 선택하세요',
      actionButtonLabel: '알림 설정',
      sheetConfirmLabel: '설정 저장',
      sheetFacets: const [
        _SheetFacet(Icons.event_available_rounded, '예약 알림', '받기'),
        _SheetFacet(Icons.local_offer_rounded, '혜택 알림', '받기'),
      ],
      sectionTitle: '최근 알림',
      sectionTrailing: '최근 7일',
      filters: ['전체', '예약', '혜택', '소식'],
      deals: [
        _ServiceDeal('예약이 확정되었어요', '부산 해운대 마린호텔 · 6.19 체크인', '06.18', '예약',
            Icons.event_available_rounded, ['예약']),
        _ServiceDeal('쿠폰이 곧 만료돼요', '국내숙소 12% 쿠폰 · 6.30까지', '06.17', '혜택',
            Icons.local_offer_rounded, ['혜택']),
        _ServiceDeal('찜한 숙소 가격이 내렸어요', '제주 오션 리조트 · 5% 인하', '06.15', '소식',
            Icons.trending_down_rounded, ['소식']),
      ],
    ),
    'notice': _ServiceConfig(
      type: 'notice',
      title: '공지사항',
      badge: 'NOTICE',
      heroTitle: 'NOL의 새 소식과\n안내를 확인하세요',
      heroSubtitle: '서비스 점검, 정책 변경 등 꼭 알아야 할 공지를 모았어요.',
      itemName: '공지',
      icon: Icons.campaign_rounded,
      iconAsset: NolMyIconAsset.notice,
      actionIcon: Icons.notifications_active_rounded,
      accentColor: YanoljaColors.primary,
      benefitLabel: '알림',
      benefitText: '받기',
      primaryMetricLabel: '새 공지',
      primaryMetricValue: '3건',
      actionTitle: '중요 공지 알림 받기',
      actionSubtitle: '점검·정책 변경 공지를 푸시로 받아보세요',
      actionButtonLabel: '알림 설정',
      sheetConfirmLabel: '알림 켜기',
      sheetFacets: const [
        _SheetFacet(Icons.notifications_active_rounded, '푸시 알림', '받기'),
        _SheetFacet(Icons.mark_email_read_rounded, '중요 공지', '우선'),
      ],
      sectionTitle: '전체 공지',
      sectionTrailing: '최근 등록순',
      filters: ['전체', '서비스', '점검', '정책'],
      deals: [
        _ServiceDeal('개인정보 처리방침 개정 안내', '7.1부터 변경된 약관이 적용돼요', '06.24', '정책',
            Icons.policy_rounded, ['정책']),
        _ServiceDeal('정기 서버 점검 안내', '6.30 02:00-04:00 일시 접속 제한', '06.22', '점검',
            Icons.build_circle_rounded, ['점검']),
        _ServiceDeal('NOL페이 서비스 업데이트', '간편결제 속도가 더 빨라졌어요', '06.20', '서비스',
            Icons.system_update_rounded, ['서비스']),
      ],
    ),
    'news': _ServiceConfig(
      type: 'news',
      title: 'NOL 소식',
      badge: 'NOL TODAY',
      heroTitle: '여행이 즐거워지는\nNOL의 이야기',
      heroSubtitle: '새 기능, 제휴 소식, 여행 팁까지 NOL의 최신 소식을 전해요.',
      itemName: '소식',
      icon: Icons.auto_stories_rounded,
      iconAsset: NolMyIconAsset.notice,
      actionIcon: Icons.bookmark_added_rounded,
      accentColor: YanoljaColors.primary,
      benefitLabel: '구독',
      benefitText: '주 1회',
      primaryMetricLabel: '이번 주',
      primaryMetricValue: '4건',
      actionTitle: '관심 소식 구독하기',
      actionSubtitle: '좋아하는 주제의 소식만 골라 받아보세요',
      actionButtonLabel: '구독하기',
      sheetConfirmLabel: '구독 완료',
      sheetFacets: const [
        _SheetFacet(Icons.interests_rounded, '주제', '국내여행'),
        _SheetFacet(Icons.notifications_rounded, '알림', '주 1회'),
      ],
      sectionTitle: '최신 소식',
      sectionTrailing: '에디터 추천',
      filters: ['전체', '기능', '제휴', '여행팁'],
      deals: [
        _ServiceDeal('이번 여름 가장 인기 있는 여행지', '데이터로 보는 7월 국내 여행 트렌드', '읽기', '여행팁',
            Icons.travel_explore_rounded, ['여행팁']),
        _ServiceDeal('새로워진 지도 검색 기능', '주변 숙소를 지도에서 더 쉽게 찾아요', '읽기', '기능',
            Icons.map_rounded, ['기능']),
        _ServiceDeal('NOL x 인기 카페 제휴 시작', '예약하고 제휴 카페 쿠폰 받기', '읽기', '제휴',
            Icons.local_cafe_rounded, ['제휴']),
      ],
    ),

    // ── 안내형: 앱 정보 ────────────────────────────────────────────
    'app-info': _ServiceConfig(
      type: 'app-info',
      title: '앱 정보',
      badge: 'ABOUT NOL',
      heroTitle: 'NOL 앱\n버전과 약관 안내',
      heroSubtitle: '현재 버전과 약관, 오픈소스 라이선스를 확인할 수 있어요.',
      itemName: '항목',
      icon: Icons.info_rounded,
      iconAsset: NolMyIconAsset.settings,
      actionIcon: Icons.system_update_rounded,
      accentColor: YanoljaColors.primary,
      benefitLabel: '상태',
      benefitText: '최신 버전',
      primaryMetricLabel: '버전',
      primaryMetricValue: 'v2.4.1',
      actionTitle: '업데이트 확인',
      actionSubtitle: '새로운 버전이 있는지 확인해보세요',
      actionButtonLabel: '버전 확인',
      sheetConfirmLabel: '확인',
      sheetFacets: const [
        _SheetFacet(Icons.verified_rounded, '현재 버전', 'v2.4.1'),
        _SheetFacet(Icons.cloud_done_rounded, '상태', '최신'),
      ],
      sectionTitle: '약관 및 정보',
      sectionTrailing: 'v2.4.1',
      filters: ['전체', '약관', '정책', '오픈소스'],
      deals: [
        _ServiceDeal('서비스 이용약관', 'NOL 서비스 이용에 대한 약관', '보기', '약관',
            Icons.description_rounded, ['약관']),
        _ServiceDeal('개인정보 처리방침', '개인정보 수집·이용 안내', '보기', '정책',
            Icons.privacy_tip_rounded, ['정책']),
        _ServiceDeal('오픈소스 라이선스', '사용된 오픈소스 라이선스 고지', '보기', '오픈소스',
            Icons.code_rounded, ['오픈소스']),
      ],
    ),

    // 라우터에서 /service/settings 는 SettingsScreen 으로 분기되어 이 키는
    // 직접 노출되지 않지만, resolve() 폴백 안전을 위해 키를 보존한다.
    'settings': _couponConfig('settings', '앱 설정', 'APP SETTINGS'),
  };

  /// 쿠폰·특가처럼 "딜카드"가 의미상 적합한 타입을 위한 템플릿.
  static _ServiceConfig _couponConfig(String type, String title, String badge) {
    return _ServiceConfig(
      type: type,
      title: title,
      badge: badge,
      heroTitle: '$title\n한눈에 확인해요',
      heroSubtitle: '내 여행에 바로 적용할 수 있는 혜택과 추천 액션을 모았습니다.',
      itemName: '혜택',
      icon: Icons.local_offer_rounded,
      iconAsset:
          type == 'settings' ? NolMyIconAsset.settings : NolMyIconAsset.coupon,
      actionIcon: Icons.check_circle_rounded,
      accentColor: YanoljaColors.primary,
      benefitLabel: '적용',
      benefitText: '즉시적용',
      primaryMetricLabel: '보유',
      primaryMetricValue: '8개',
      actionTitle: '사용 가능한 혜택을 우선 정렬',
      actionSubtitle: '숙소, 티켓, 항공에 바로 쓸 수 있는 조건을 확인하세요',
      actionButtonLabel: '혜택 보기',
      sheetConfirmLabel: '혜택 적용',
      sheetFacets: const [
        _SheetFacet(Icons.category_rounded, '적용 대상', '숙소·티켓'),
        _SheetFacet(Icons.event_available_rounded, '유효기간', '~6.30'),
      ],
      sectionTitle: '추천 혜택',
      sectionTrailing: '사용 가능',
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
          color: YanoljaColors.surface,
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          border: Border.all(color: YanoljaColors.border),
          boxShadow: [
            BoxShadow(
              color: YanoljaColors.shadow,
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: YanoljaSpacing.s,
                      vertical: YanoljaSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(YanoljaRadius.pill),
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
                  const SizedBox(height: 8),
                  Text(
                    deal.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: YanoljaColors.textPrimary,
                      letterSpacing: -0.2,
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
                    letterSpacing: -0.2,
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
    final facets = config.sheetFacets;
    return Container(
      decoration: const BoxDecoration(
        color: YanoljaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                  letterSpacing: -0.3,
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
                  for (var i = 0; i < facets.length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(
                      child: _SheetOption(
                        icon: facets[i].icon,
                        title: facets[i].title,
                        value: facets[i].value,
                        color: config.accentColor,
                      ),
                    ),
                  ],
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
                  child: Text(
                    config.sheetConfirmLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
    return Container(
      decoration: const BoxDecoration(
        color: YanoljaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                            letterSpacing: -0.3,
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
                        letterSpacing: -0.2,
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
