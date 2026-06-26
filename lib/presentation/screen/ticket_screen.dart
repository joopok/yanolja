import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';

/// NOL 티켓 화면
///
/// 실제 NOL 티켓 화면을 분석해 재현했습니다.
/// - 공연 테마 히어로 배너
/// - 장르 탭(뮤지컬·콘서트·스포츠·전시/행사·클래식/무용·아동/가족·연극)
/// - 장르별 세로 포스터 카드 그리드 (포스터 + 날짜 + 제목 + 장소 + CTA)
class TicketScreen extends StatefulWidget {
  /// 진입 시 선택할 장르 (전체 카테고리에서 query로 전달)
  final String? initialGenre;

  const TicketScreen({super.key, this.initialGenre});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen>
    with SingleTickerProviderStateMixin {
  static const List<String> _genres = [
    '뮤지컬',
    '콘서트',
    '스포츠',
    '전시/행사',
    '클래식/무용',
    '아동/가족',
    '연극',
  ];

  late final TabController _tabController;

  /// 첫 진입 시 잠깐 스켈레톤을 보여준 뒤 콘텐츠로 전환한다(1회).
  bool _loading = true;
  Timer? _loadTimer;

  @override
  void initState() {
    super.initState();
    final initial = _genres.indexOf(widget.initialGenre ?? '뮤지컬');
    _tabController = TabController(
      length: _genres.length,
      vsync: this,
      initialIndex: initial < 0 ? 0 : initial,
    );
    _loadTimer = Timer(const Duration(milliseconds: 420), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanoljaColors.background,
      appBar: YanoljaAppBar.sub(
        title: 'NOL 티켓',
        fallbackRoute: '/home',
        actions: [
          IconButton(
            tooltip: '검색',
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.go('/search'),
          ),
          const SizedBox(width: YanoljaSpacing.xs),
        ],
      ),
      body: Column(
        children: [
          _buildHero(),
          YanoljaEntrance(
            delay: const Duration(milliseconds: 90),
            beginOffset: const Offset(0, 0.025),
            child: _buildTabBar(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                for (final genre in _genres) _buildGenreView(genre),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return const YanoljaPremiumHero(
      margin: EdgeInsets.fromLTRB(20, 12, 20, 12),
      badge: 'CULTURE PICK',
      title: '보고 싶던 공연,\n단독 혜택가로',
      subtitle: '뮤지컬, 콘서트, 전시까지 예매 오픈 알림으로 먼저 만나보세요',
      icon: Icons.confirmation_number_rounded,
      gradient: [Color(0xFF6E144F), _Stage.pink],
      metrics: [
        YanoljaHeroMetric(label: '장르', value: '7개'),
        YanoljaHeroMetric(label: '혜택', value: 'NOL DAY'),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: YanoljaColors.background,
        border: Border(bottom: BorderSide(color: YanoljaColors.border)),
      ),
      // 첫 탭이 그리드(좌측 20)와 광학적으로 맞도록 6 + labelPadding 14 = 20.
      padding: const EdgeInsets.only(left: 6),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        labelColor: YanoljaColors.primary,
        unselectedLabelColor: YanoljaColors.textSecondary,
        indicatorColor: YanoljaColors.primary,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        labelPadding: const EdgeInsets.symmetric(horizontal: 14),
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.3,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        onTap: (_) => HapticFeedback.selectionClick(),
        tabs: [for (final g in _genres) Tab(text: g)],
      ),
    );
  }

  /// 장르 탭 본문: 로딩 → 스켈레톤, 비어있음 → 안내, 그 외 → 포스터 그리드.
  Widget _buildGenreView(String genre) {
    if (_loading) return const _TicketSkeleton();
    final shows = _showsFor(genre);
    if (shows.isEmpty) {
      return _EmptyState(onAction: () => _tabController.animateTo(0));
    }
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      gridDelegate: _ticketGridDelegate,
      itemCount: shows.length,
      itemBuilder: (context, index) => YanoljaEntrance(
        // 행 단위로 묶어 한 줄씩 위로 떠오르는 웨이브 등장.
        delay: YanoljaMotion.stagger(index ~/ 2, start: 80, step: 60),
        child: _ShowCard(show: shows[index]),
      ),
    );
  }

  // ===== mock 공연 데이터 =====

  List<_Show> _showsFor(String genre) => _mockShows[genre] ?? const [];

  static const Map<String, List<_Show>> _mockShows = {
    '뮤지컬': [
      _Show('드라큘라', '블루스퀘어 신한카드홀', '06.25 ~ 08.30', '단독판매', _Stage.plum),
      _Show('레미제라블', '예술의전당 오페라극장', '07.01 ~ 09.15', 'HOT', _Stage.royalBlue),
      _Show('위키드 내한', '샤롯데씨어터', '06.28 ~ 10.10', '예매중', _Stage.emerald),
      _Show('빌리 엘리어트', '디큐브 링크아트센터', '07.12 ~ 09.01', 'NOL DAY', _Stage.sunset),
      _Show('하데스타운', 'LG아트센터', '08.02 ~ 10.20', '단독판매', _Stage.amber),
      _Show('지킬앤하이드', '블루스퀘어', '09.05 ~ 11.30', '오픈예정', _Stage.violet),
    ],
    '콘서트': [
      _Show('2026 XLOV ASIA TOUR', 'KSPO DOME', '06.21 19:00', 'HOT', _Stage.magenta),
      _Show('TAKUYA KIMURA Live', '올림픽홀', '06.29 19:00', '단독판매', _Stage.royalBlue),
      _Show('블루문 재즈 콘서트', '예술의전당', '07.04 20:00', '예매중', _Stage.azure),
      _Show('서머 페스타 2026', '인스파이어 아레나', '08.15 17:00', 'NOL DAY', _Stage.sunset),
      _Show('어쿠스틱 나이트', '롤링홀', '07.20 19:30', '예매중', _Stage.teal),
      _Show('윈터 발라드 콘서트', '올림픽공원', '12.24 18:00', '오픈예정', _Stage.violet),
    ],
    '스포츠': [
      _Show('프로야구 정규시즌', '잠실 야구장', '매주 화~일', '예매중', _Stage.azure),
      _Show('K리그 빅매치', '서울 월드컵경기장', '06.28 19:00', 'HOT', _Stage.emerald),
      _Show('프로농구 플레이오프', '고양 체육관', '07.05 14:00', '단독판매', _Stage.sunset),
      _Show('국가대표 평가전', '서울 월드컵경기장', '09.06 20:00', '오픈예정', _Stage.royalBlue),
    ],
    '전시/행사': [
      _Show('스튜디오 지브리展', '제주 빛의 벙커', '~ 12.31', '예매중', _Stage.teal),
      _Show('시티 오브 라이트 미디어아트', '성수 그라운드', '~ 09.30', 'NOL DAY', _Stage.violet),
      _Show('반 고흐 인사이드', 'DDP', '~ 10.15', 'HOT', _Stage.amber),
      _Show('2026 부산비엔날레', '부산현대미술관', '07.29 ~ 08.02', '단독판매', _Stage.emerald),
    ],
    '클래식/무용': [
      _Show('파리·밀라노 발레 갈라', '예술의전당', '07.29 ~ 08.02', '단독판매', _Stage.azure),
      _Show('빈 필하모닉 내한', '롯데콘서트홀', '09.10 20:00', '오픈예정', _Stage.violet),
      _Show('백조의 호수', '세종문화회관', '08.20 ~ 08.25', '예매중', _Stage.magenta),
      _Show('피아노 리사이틀', '예술의전당 IBK홀', '07.15 19:30', '예매중', _Stage.royalBlue),
    ],
    '아동/가족': [
      _Show('호기심 과학 페스타', '코엑스', '~ 08.31', 'NOL DAY', _Stage.teal),
      _Show('뽀로로 뮤지컬', '대학로 TOM', '07.01 ~ 08.20', '예매중', _Stage.sunset),
      _Show('공룡 대탐험展', '서울숲', '~ 09.10', 'HOT', _Stage.emerald),
      _Show('가족 매직쇼', '롯데월드', '주말 상설', '예매중', _Stage.amber),
    ],
    '연극': [
      _Show('햄릿', '명동예술극장', '07.10 ~ 08.15', 'HOT', _Stage.violet),
      _Show('라이어', '대학로 자유극장', '상시 공연', '예매중', _Stage.sunset),
      _Show('옥탑방 고양이', '대학로 TOM', '06.20 ~ 09.30', '단독판매', _Stage.magenta),
      _Show('갈매기', 'LG아트센터', '08.01 ~ 08.20', '예매중', _Stage.azure),
    ],
  };
}

/// 포스터 그리드 공통 레이아웃 — 세로 포스터(2열) 비율을 한 곳에서 관리.
const SliverGridDelegateWithFixedCrossAxisCount _ticketGridDelegate =
    SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  mainAxisSpacing: 22,
  crossAxisSpacing: 14,
  childAspectRatio: 0.56,
);

/// 🎭 무대 그라데이션 팔레트
///
/// 장르 포스터·히어로 공용. "무대 암전" 톤의 어두운 베이스에서
/// NOL 토큰 계열 포인트(블루/퍼플/민트/옐로 등)로 떨어지도록 정돈했다.
/// 토큰에 없는 컬처 핑크·오렌지·자주는 의도적 포스터 색으로만 한정해 둔다.
class _Stage {
  _Stage._();

  // 토큰 외 의도 색 (포스터 전용)
  static const Color pink = Color(0xFFFF4FB7);
  static const Color orange = Color(0xFFFF8A3D);
  static const Color plumEnd = Color(0xFF7A1F5C);

  static const List<Color> royalBlue = [Color(0xFF101B5C), YanoljaColors.primary];
  static const List<Color> azure = [Color(0xFF0B2A4A), YanoljaColors.accentBlue];
  static const List<Color> violet = [Color(0xFF1A1330), YanoljaColors.primaryPurple];
  static const List<Color> emerald = [Color(0xFF0F3D2E), YanoljaColors.success];
  static const List<Color> teal = [Color(0xFF14342E), YanoljaColors.mint];
  static const List<Color> amber = [Color(0xFF2C1A05), YanoljaColors.yellow];
  static const List<Color> magenta = [Color(0xFF311432), pink];
  static const List<Color> sunset = [Color(0xFF3A1500), orange];
  static const List<Color> plum = [Color(0xFF2B1331), plumEnd];
}

/// 배지 상태로 예매 가능 여부를 파생해 CTA 라벨·색을 결정한다.
/// '오픈예정'만 아직 닫힌 상태로 본다.
bool _isBookingOpen(String badge) => badge != '오픈예정';

/// 포스터 배지 색상 한 쌍 (배경 + 글자).
class _BadgeStyle {
  final Color background;
  final Color foreground;
  const _BadgeStyle(this.background, this.foreground);
}

/// 배지 라벨별 알약 스타일. 어두운 포스터 위 대비를 우선한다.
/// (NOL DAY 옐로 위에는 흰 글자 대비가 약해 다크 텍스트를 쓴다.)
_BadgeStyle _badgeStyle(String badge) {
  switch (badge) {
    case 'HOT':
      return const _BadgeStyle(YanoljaColors.sale, Colors.white);
    case 'NOL DAY':
      return const _BadgeStyle(YanoljaColors.yellow, YanoljaColors.textPrimary);
    case '단독판매':
      return const _BadgeStyle(YanoljaColors.accentBlue, Colors.white);
    case '오픈예정':
    case '예매중':
    default:
      return _BadgeStyle(Colors.white.withValues(alpha: 0.22), Colors.white);
  }
}

class _Show {
  final String title;
  final String place;
  final String date;
  final String badge;
  final List<Color> gradient;

  const _Show(this.title, this.place, this.date, this.badge, this.gradient);
}

class _ShowCard extends StatelessWidget {
  final _Show show;

  const _ShowCard({required this.show});

  @override
  Widget build(BuildContext context) {
    final bookingOpen = _isBookingOpen(show.badge);
    return YanoljaPressable(
      onTap: () {
        HapticFeedback.selectionClick();
        YanoljaToast.show(
          context,
          bookingOpen
              ? '${show.title} 예매를 진행할게요'
              : '${show.title} 오픈 알림을 신청했어요',
          icon: bookingOpen
              ? Icons.confirmation_number_rounded
              : Icons.notifications_active_rounded,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 세로 포스터
          Expanded(
            child: Container(
              width: double.infinity,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: show.gradient,
                ),
                borderRadius: BorderRadius.circular(YanoljaRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: show.gradient.last.withValues(alpha: 0.26),
                    blurRadius: 18,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: _PosterFace(show: show),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            show.date,
            style: const TextStyle(
              color: YanoljaColors.primary,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            show.place,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: YanoljaColors.textSecondary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          _CtaPill(bookingOpen: bookingOpen),
        ],
      ),
    );
  }
}

/// 포스터 내부 — 좌측 티켓 스파인 + 하단 스크림 + 배지/제목 위계.
class _PosterFace extends StatelessWidget {
  final _Show show;

  const _PosterFace({required this.show});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 제목 가독을 위한 하단 스크림
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.42),
              ],
            ),
          ),
        ),
        // 티켓 스파인(좌측 띠)
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Container(
            width: 7,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(7),
              ),
            ),
          ),
        ),
        // 코너 워터마크
        Positioned(
          right: -12,
          bottom: -12,
          child: Icon(
            Icons.local_activity_rounded,
            size: 76,
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PosterBadge(label: show.badge),
              const Spacer(),
              Text(
                show.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.5,
                  height: 1.18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 포스터 위 상태/프로모 배지 알약.
class _PosterBadge extends StatelessWidget {
  final String label;

  const _PosterBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final style = _badgeStyle(label);
    final isStatus = label == '예매중' || label == '오픈예정';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: YanoljaSpacing.xs),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(YanoljaRadius.pill),
        border: isStatus
            ? Border.all(color: Colors.white.withValues(alpha: 0.26))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label == '오픈예정') ...[
            Icon(Icons.schedule_rounded, size: 11, color: style.foreground),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              color: style.foreground,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// 카드 하단 CTA — 예매가능(채움 프라이머리) vs 오픈예정(보조 알림).
class _CtaPill extends StatelessWidget {
  final bool bookingOpen;

  const _CtaPill({required this.bookingOpen});

  @override
  Widget build(BuildContext context) {
    if (bookingOpen) {
      return Container(
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: YanoljaColors.primary,
          borderRadius: BorderRadius.circular(YanoljaRadius.pill),
          boxShadow: [
            BoxShadow(
              color: YanoljaColors.primary.withValues(alpha: 0.22),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          '예매하기',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
        ),
      );
    }
    return Container(
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: YanoljaColors.surfaceAlt,
        borderRadius: BorderRadius.circular(YanoljaRadius.pill),
        border: Border.all(color: YanoljaColors.border),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 14,
            color: YanoljaColors.textSecondary,
          ),
          SizedBox(width: 4),
          Text(
            '오픈 알림',
            style: TextStyle(
              color: YanoljaColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// 첫 진입 로딩 스켈레톤 — 실제 그리드와 동일한 비율/여백.
class _TicketSkeleton extends StatelessWidget {
  const _TicketSkeleton();

  @override
  Widget build(BuildContext context) {
    return YanoljaEntrance(
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        gridDelegate: _ticketGridDelegate,
        itemCount: 6,
        itemBuilder: (_, __) => const _SkeletonTile(),
      ),
    );
  }
}

class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [YanoljaColors.surfaceAlt, YanoljaColors.border],
              ),
              borderRadius: BorderRadius.circular(YanoljaRadius.lg),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _bar(width: 56, radius: YanoljaRadius.sm),
        const SizedBox(height: 6),
        _bar(width: 104, radius: YanoljaRadius.sm),
        const SizedBox(height: 10),
        _bar(height: 32, radius: YanoljaRadius.pill),
      ],
    );
  }

  Widget _bar({double? width, double height = 12, required double radius}) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: YanoljaColors.surfaceAlt,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// 빈 장르 안내 — NOL 톤(연블루 원형 + 알림 유도 + 보조 CTA).
class _EmptyState extends StatelessWidget {
  final VoidCallback onAction;

  const _EmptyState({required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: YanoljaColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_activity_rounded,
                size: 34,
                color: YanoljaColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              '아직 준비 중인 공연이에요',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: YanoljaColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '예매 오픈 소식을 가장 먼저 알려드릴게요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: YanoljaColors.textSecondary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 20),
            YanoljaPressable(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: YanoljaSpacing.l,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: YanoljaColors.primary,
                  borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                ),
                child: const Text(
                  '인기 공연 보러가기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
