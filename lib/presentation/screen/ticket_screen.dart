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
/// - 장르별 세로 포스터 카드 그리드 (포스터 + 날짜 + 제목 + 장소)
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

  @override
  void initState() {
    super.initState();
    final initial = _genres.indexOf(widget.initialGenre ?? '뮤지컬');
    _tabController = TabController(
      length: _genres.length,
      vsync: this,
      initialIndex: initial < 0 ? 0 : initial,
    );
  }

  @override
  void dispose() {
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
          const SizedBox(width: 4),
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
                for (final genre in _genres) _buildGenreGrid(genre),
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
      gradient: [Color(0xFF6E144F), Color(0xFFFF4FB7)],
      metrics: [
        YanoljaHeroMetric(label: '장르', value: '7개'),
        YanoljaHeroMetric(label: '혜택', value: 'NOL DAY'),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: YanoljaColors.border),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: YanoljaColors.primary,
        unselectedLabelColor: YanoljaColors.textSecondary,
        indicatorColor: YanoljaColors.primary,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        unselectedLabelStyle:
            const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        onTap: (_) => HapticFeedback.selectionClick(),
        tabs: [for (final g in _genres) Tab(text: g)],
      ),
    );
  }

  Widget _buildGenreGrid(String genre) {
    final shows = _showsFor(genre);
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 14,
        childAspectRatio: 0.58,
      ),
      itemCount: shows.length,
      itemBuilder: (context, index) => YanoljaEntrance(
        delay: YanoljaMotion.stagger(index, start: 30, step: 35),
        child: _ShowCard(show: shows[index]),
      ),
    );
  }

  // ===== mock 공연 데이터 =====

  List<_Show> _showsFor(String genre) {
    final base = _mockShows[genre] ?? const [];
    return base;
  }

  static final Map<String, List<_Show>> _mockShows = {
    '뮤지컬': const [
      _Show('드라큘라', '블루스퀘어 신한카드홀', '06.25 ~ 08.30', '단독판매',
          [Color(0xFF2B1331), Color(0xFF7A1F5C)]),
      _Show('레미제라블', '예술의전당 오페라극장', '07.01 ~ 09.15', 'HOT',
          [Color(0xFF13294B), Color(0xFF2F6BFF)]),
      _Show('위키드 내한', '샤롯데씨어터', '06.28 ~ 10.10', '예매중',
          [Color(0xFF0F3D2E), Color(0xFF12B886)]),
      _Show('빌리 엘리어트', '디큐브 링크아트센터', '07.12 ~ 09.01', 'NOL DAY',
          [Color(0xFF4A1D0F), Color(0xFFFF6D3D)]),
      _Show('하데스타운', 'LG아트센터', '08.02 ~ 10.20', '단독판매',
          [Color(0xFF2C1A05), Color(0xFFFFB92E)]),
      _Show('지킬앤하이드', '블루스퀘어', '09.05 ~ 11.30', 'HOT',
          [Color(0xFF1A1330), Color(0xFF5B43FF)]),
    ],
    '콘서트': const [
      _Show('2026 XLOV ASIA TOUR', 'KSPO DOME', '06.21 19:00', 'HOT',
          [Color(0xFF311432), Color(0xFFFF4FB7)]),
      _Show('TAKUYA KIMURA Live', '올림픽홀', '06.29 19:00', '단독판매',
          [Color(0xFF101B5C), Color(0xFF315BFF)]),
      _Show('블루문 재즈 콘서트', '예술의전당', '07.04 20:00', '예매중',
          [Color(0xFF0B2A4A), Color(0xFF1B64DA)]),
      _Show('서머 페스타 2026', '인스파이어 아레나', '08.15 17:00', 'NOL DAY',
          [Color(0xFF3A1500), Color(0xFFFF8A3D)]),
      _Show('어쿠스틱 나이트', '롤링홀', '07.20 19:30', '예매중',
          [Color(0xFF14342E), Color(0xFF00C2B8)]),
      _Show('윈터 발라드 콘서트', '올림픽공원', '12.24 18:00', 'HOT',
          [Color(0xFF1A1A40), Color(0xFF5B43FF)]),
    ],
    '스포츠': const [
      _Show('프로야구 정규시즌', '잠실 야구장', '매주 화~일', '예매중',
          [Color(0xFF0B2A4A), Color(0xFF2F6BFF)]),
      _Show('K리그 빅매치', '서울 월드컵경기장', '06.28 19:00', 'HOT',
          [Color(0xFF0F3D2E), Color(0xFF12B886)]),
      _Show('프로농구 플레이오프', '고양 체육관', '07.05 14:00', '단독판매',
          [Color(0xFF3A1500), Color(0xFFFF6D3D)]),
      _Show('국가대표 평가전', '서울 월드컵경기장', '09.06 20:00', 'HOT',
          [Color(0xFF13294B), Color(0xFF315BFF)]),
    ],
    '전시/행사': const [
      _Show('스튜디오 지브리展', '제주 빛의 벙커', '~ 12.31', '예매중',
          [Color(0xFF14342E), Color(0xFF00B894)]),
      _Show('시티 오브 라이트 미디어아트', '성수 그라운드', '~ 09.30', 'NOL DAY',
          [Color(0xFF1A1330), Color(0xFF9B51E0)]),
      _Show('반 고흐 인사이드', 'DDP', '~ 10.15', 'HOT',
          [Color(0xFF2C1A05), Color(0xFFFFB92E)]),
      _Show('2026 부산비엔날레', '부산현대미술관', '07.29 ~ 08.02', '단독판매',
          [Color(0xFF0F3D2E), Color(0xFF12B886)]),
    ],
    '클래식/무용': const [
      _Show('파리·밀라노 발레 갈라', '예술의전당', '07.29 ~ 08.02', '단독판매',
          [Color(0xFF13294B), Color(0xFF1B64DA)]),
      _Show('빈 필하모닉 내한', '롯데콘서트홀', '09.10 20:00', 'HOT',
          [Color(0xFF1A1330), Color(0xFF5B43FF)]),
      _Show('백조의 호수', '세종문화회관', '08.20 ~ 08.25', '예매중',
          [Color(0xFF311432), Color(0xFFFF4FB7)]),
      _Show('피아노 리사이틀', '예술의전당 IBK홀', '07.15 19:30', '예매중',
          [Color(0xFF0B2A4A), Color(0xFF2F6BFF)]),
    ],
    '아동/가족': const [
      _Show('호기심 과학 페스타', '코엑스', '~ 08.31', 'NOL DAY',
          [Color(0xFF14342E), Color(0xFF00C2B8)]),
      _Show('뽀로로 뮤지컬', '대학로 TOM', '07.01 ~ 08.20', '예매중',
          [Color(0xFF3A1500), Color(0xFFFF8A3D)]),
      _Show('공룡 대탐험展', '서울숲', '~ 09.10', 'HOT',
          [Color(0xFF0F3D2E), Color(0xFF12B886)]),
      _Show('가족 매직쇼', '롯데월드', '주말 상설', '예매중',
          [Color(0xFF2C1A05), Color(0xFFFFB92E)]),
    ],
    '연극': const [
      _Show('햄릿', '명동예술극장', '07.10 ~ 08.15', 'HOT',
          [Color(0xFF1A1A40), Color(0xFF5B43FF)]),
      _Show('라이어', '대학로 자유극장', '상시 공연', '예매중',
          [Color(0xFF3A1500), Color(0xFFFF6D3D)]),
      _Show('옥탑방 고양이', '대학로 TOM', '06.20 ~ 09.30', '단독판매',
          [Color(0xFF311432), Color(0xFFFF4FB7)]),
      _Show('갈매기', 'LG아트센터', '08.01 ~ 08.20', '예매중',
          [Color(0xFF0B2A4A), Color(0xFF1B64DA)]),
    ],
  };
}

Widget _buildPosterMark(_Show show) {
  return Stack(
    children: [
      Positioned(
        left: 0,
        top: 0,
        bottom: 0,
        child: Container(
          width: 8,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.20),
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(8),
            ),
          ),
        ),
      ),
      Positioned(
        right: -10,
        bottom: -10,
        child: Icon(
          Icons.local_activity_rounded,
          size: 80,
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(YanoljaRadius.pill),
              ),
              child: Text(
                show.badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const Spacer(),
            Text(
              show.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                height: 1.2,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    ],
  );
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
    return YanoljaPressable(
      onTap: () {
        HapticFeedback.selectionClick();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${show.title} 예매는 준비 중이에요'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: YanoljaColors.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(YanoljaRadius.md),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 포스터
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
                    color: show.gradient.last.withValues(alpha: 0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: _buildPosterMark(show),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            show.date,
            style: const TextStyle(
              color: YanoljaColors.primary,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            show.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: YanoljaColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            show.place,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: YanoljaColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: YanoljaColors.textPrimary,
              borderRadius: BorderRadius.circular(YanoljaRadius.pill),
            ),
            child: const Text(
              '예매 준비중',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
