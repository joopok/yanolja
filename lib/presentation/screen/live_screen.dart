import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';

/// NOL 라이브 화면
///
/// 실제 NOL 메인의 "NOL 라이브 놀라운 혜택" 라이브커머스 섹션을 전용 화면으로
/// 재현했습니다. 지금 라이브 중인 방송 / 방송 예정 편성 / 지난 방송 다시보기를
/// 위계가 분명한 카드로 보여줍니다.
class LiveScreen extends StatelessWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanoljaColors.surfaceAlt,
      appBar: const YanoljaAppBar.sub(
        title: 'NOL 라이브',
        fallbackRoute: '/home',
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          _buildHero(),

          // ── 지금 라이브 중 ──────────────────────────────
          YanoljaEntrance(
            delay: const Duration(milliseconds: 90),
            child: _SectionHeader(
              title: '지금 라이브 중',
              live: true,
              count: _liveNow.length,
            ),
          ),
          if (_liveNow.isEmpty)
            const YanoljaEntrance(
              delay: Duration(milliseconds: 120),
              child: _EmptyState(
                icon: Icons.videocam_off_rounded,
                message: '지금 진행 중인 라이브가 없어요',
                hint: '방송 예정 편성을 먼저 확인해 보세요',
              ),
            )
          else
            for (var i = 0; i < _liveNow.length; i++)
              YanoljaEntrance(
                delay: YanoljaMotion.stagger(i, start: 120, step: 45),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      YanoljaSpacing.l, 0, YanoljaSpacing.l, 14),
                  child: _LiveCard(live: _liveNow[i]),
                ),
              ),

          const SizedBox(height: YanoljaSpacing.s),

          // ── 방송 예정 ──────────────────────────────────
          YanoljaEntrance(
            delay: const Duration(milliseconds: 170),
            child: _SectionHeader(
              title: '방송 예정',
              subtitle: '알림 신청하고 단독 특가 방송을 놓치지 마세요',
              count: _upcoming.length,
            ),
          ),
          if (_upcoming.isEmpty)
            const YanoljaEntrance(
              delay: Duration(milliseconds: 200),
              child: _EmptyState(
                icon: Icons.event_busy_rounded,
                message: '예정된 방송이 없어요',
              ),
            )
          else
            for (var i = 0; i < _upcoming.length; i++)
              YanoljaEntrance(
                delay: YanoljaMotion.stagger(i, start: 210, step: 40),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      YanoljaSpacing.l, 0, YanoljaSpacing.l, 12),
                  child: _ScheduleRow(live: _upcoming[i], replay: false),
                ),
              ),

          const SizedBox(height: YanoljaSpacing.s),

          // ── 다시보기 ──────────────────────────────────
          YanoljaEntrance(
            delay: const Duration(milliseconds: 250),
            child: _SectionHeader(
              title: '다시보기',
              subtitle: '놓친 라이브의 특가 혜택을 영상으로 다시 만나보세요',
              count: _replays.length,
            ),
          ),
          if (_replays.isEmpty)
            const YanoljaEntrance(
              delay: Duration(milliseconds: 280),
              child: _EmptyState(
                icon: Icons.history_rounded,
                message: '다시 볼 방송이 아직 없어요',
              ),
            )
          else
            for (var i = 0; i < _replays.length; i++)
              YanoljaEntrance(
                delay: YanoljaMotion.stagger(i, start: 290, step: 40),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      YanoljaSpacing.l, 0, YanoljaSpacing.l, 12),
                  child: _ScheduleRow(live: _replays[i], replay: true),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return const YanoljaPremiumHero(
      margin: EdgeInsets.fromLTRB(20, 14, 20, 18),
      badge: 'LIVE COMMERCE',
      title: '지금 가장 핫한\n라이브 특가',
      subtitle: '방송 중에만 받을 수 있는 단독 쿠폰과 라이브 특가를 만나보세요',
      icon: Icons.live_tv_rounded,
      gradient: [Color(0xFF8A0B33), YanoljaColors.sale],
      metrics: [
        YanoljaHeroMetric(label: '방송중', value: '2개'),
        YanoljaHeroMetric(label: '혜택', value: '최대 42%'),
      ],
    );
  }

  // ── 라이브 중 (현재 진행) ──────────────────────────────
  static const List<_Live> _liveNow = [
    _Live(
      title: '[소노위크] 우리나라 대표 레저휴양시설 비발디파크 특집',
      host: '소노호텔&리조트',
      time: '방송 중',
      viewers: '2,847',
      discount: '최대 38%',
      gradient: [Color(0xFF13294B), Color(0xFF2F6BFF)],
    ),
    _Live(
      title: '[오션월드] 짜릿한 여름! 돌아온 오션월드 얼리버드',
      host: '대명소노',
      time: '방송 중',
      viewers: '1,932',
      discount: '최대 42%',
      gradient: [Color(0xFF0F3D2E), YanoljaColors.success],
    ),
  ];

  // ── 방송 예정 (편성표) ─────────────────────────────────
  static const List<_Live> _upcoming = [
    _Live(
      title: '[소노위크] 전 지점 특가로 떠나는 여름 휴가',
      host: '소노호텔&리조트',
      time: '오늘 19:00',
      viewers: '',
      discount: '단독 쿠폰',
      gradient: [Color(0xFF311432), Color(0xFFFF4FB7)],
    ),
    _Live(
      title: '[롯데호텔] 제주 오션뷰 스위트 라이브 특가',
      host: '롯데호텔',
      time: '내일 11:00',
      viewers: '',
      discount: '최대 30%',
      gradient: [Color(0xFF2C1A05), YanoljaColors.yellow],
    ),
    _Live(
      title: '[한화리조트] 설악 워터피아 패키지 방송',
      host: '한화리조트',
      time: '내일 15:00',
      viewers: '',
      discount: '추가 적립',
      gradient: [Color(0xFF1A1330), YanoljaColors.primaryPurple],
    ),
    _Live(
      title: '[파라다이스시티] 인천 럭셔리 스테이 라이브',
      host: '파라다이스',
      time: '06.23 20:00',
      viewers: '',
      discount: '최대 25%',
      gradient: [Color(0xFF0B2A4A), YanoljaColors.accentBlue],
    ),
  ];

  // ── 다시보기 (지난 방송) ───────────────────────────────
  static const List<_Live> _replays = [
    _Live(
      title: '[소노위크] 여름 성수기 객실 단독 특가 다시보기',
      host: '소노호텔&리조트',
      time: '06.20 방송',
      viewers: '4.1만',
      discount: '',
      meta: '48:20',
      gradient: [Color(0xFF13294B), YanoljaColors.primary],
    ),
    _Live(
      title: '[글래드호텔] 도심 호캉스 라이브 하이라이트',
      host: '글래드호텔',
      time: '06.18 방송',
      viewers: '2.7만',
      discount: '',
      meta: '35:06',
      gradient: [Color(0xFF311432), YanoljaColors.primaryPurple],
    ),
    _Live(
      title: '[켄싱턴리조트] 설악 가족 패키지 완판 방송',
      host: '켄싱턴리조트',
      time: '06.15 방송',
      viewers: '3.5만',
      discount: '',
      meta: '41:52',
      gradient: [Color(0xFF0F3D2E), YanoljaColors.mint],
    ),
  ];
}

class _Live {
  final String title;
  final String host;
  final String time;
  final String viewers;
  final String discount;

  /// 다시보기 영상 길이 등 보조 표기 (없으면 빈 문자열)
  final String meta;
  final List<Color> gradient;

  const _Live({
    required this.title,
    required this.host,
    required this.time,
    required this.viewers,
    required this.discount,
    this.meta = '',
    required this.gradient,
  });
}

/// 섹션 헤더 — 선택적 라이브 박동 점 + 부제 + 개수 칩
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool live;
  final int? count;

  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.live = false,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          YanoljaSpacing.l, YanoljaSpacing.l, YanoljaSpacing.l, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (live) ...[
            const _PulsingDot(color: YanoljaColors.sale, size: 9),
            const SizedBox(width: YanoljaSpacing.s),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: YanoljaColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.2,
                      color: YanoljaColors.textSecondary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (count != null && count! > 0) ...[
            const SizedBox(width: YanoljaSpacing.s),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: YanoljaSpacing.xs),
              decoration: BoxDecoration(
                color: live
                    ? YanoljaColors.sale.withValues(alpha: 0.1)
                    : YanoljaColors.surface,
                borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                border: live
                    ? null
                    : Border.all(color: YanoljaColors.border),
              ),
              child: Text(
                live ? '$count개 방송중' : '$count',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color:
                      live ? YanoljaColors.sale : YanoljaColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 섹션 비었을 때의 NOL식 안내 카드
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? hint;

  const _EmptyState({
    required this.icon,
    required this.message,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          YanoljaSpacing.l, 0, YanoljaSpacing.l, YanoljaSpacing.s),
      padding: const EdgeInsets.symmetric(horizontal: YanoljaSpacing.l, vertical: 30),
      decoration: BoxDecoration(
        color: YanoljaColors.surface,
        borderRadius: BorderRadius.circular(YanoljaRadius.lg),
        border: Border.all(color: YanoljaColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: YanoljaColors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: YanoljaColors.textTertiary, size: 24),
          ),
          const SizedBox(height: YanoljaSpacing.m),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: YanoljaColors.textSecondary,
              letterSpacing: -0.2,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: YanoljaSpacing.xs),
            Text(
              hint!,
              style: const TextStyle(
                fontSize: 12,
                color: YanoljaColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 라이브 박동 점 (접근성: reduce-motion 시 정적 점)
class _PulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const _PulsingDot({required this.color, this.size = 8});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOut,
    ).drive(Tween<double>(begin: 1.0, end: 0.35));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _dot() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: 0.45),
            blurRadius: 6,
            spreadRadius: 0.5,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (YanoljaMotion.reduce(context)) return _dot();
    return FadeTransition(opacity: _opacity, child: _dot());
  }
}

void _showLivePrep(BuildContext context, String host, {bool replay = false}) {
  HapticFeedback.lightImpact();
  YanoljaToast.show(
    context,
    replay ? '$host 다시보기는 준비 중이에요' : '$host 라이브는 곧 열릴 예정이에요',
    icon: replay ? Icons.play_circle_fill_rounded : Icons.live_tv_rounded,
  );
}

Widget _buildLiveStrip() {
  return SizedBox(
    height: 26,
    child: Row(
      children: [
        for (var i = 0; i < 12; i++) ...[
          Expanded(
            child: Container(
              height: i.isEven ? 16 : 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: i.isEven ? 0.42 : 0.24),
                borderRadius: BorderRadius.circular(YanoljaRadius.pill),
              ),
            ),
          ),
          if (i != 11) const SizedBox(width: 4),
        ],
      ],
    ),
  );
}

/// 라이브 중 큰 카드 (16:9 썸네일 + LIVE 배지 + 시청자수 + 정보)
class _LiveCard extends StatelessWidget {
  final _Live live;

  const _LiveCard({required this.live});

  @override
  Widget build(BuildContext context) {
    return YanoljaPressable(
      onTap: () => _showLivePrep(context, live.host),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: YanoljaColors.surface,
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          border: Border.all(color: YanoljaColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: live.gradient,
                  ),
                ),
                child: Stack(
                  children: [
                    // 배지·하단 요소 가독성을 위한 스크림
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.22),
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.42),
                            ],
                            stops: const [0.0, 0.28, 0.6, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Icon(
                        Icons.play_circle_fill_rounded,
                        size: 44,
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: YanoljaSpacing.s, vertical: YanoljaSpacing.xs),
                            decoration: BoxDecoration(
                              color: YanoljaColors.sale,
                              borderRadius:
                                  BorderRadius.circular(YanoljaRadius.sm),
                              boxShadow: [
                                BoxShadow(
                                  color: YanoljaColors.sale
                                      .withValues(alpha: 0.45),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _PulsingDot(color: Colors.white, size: 7),
                                SizedBox(width: 4),
                                Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (live.viewers.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: YanoljaSpacing.s, vertical: YanoljaSpacing.xs),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.35),
                                borderRadius:
                                    BorderRadius.circular(YanoljaRadius.sm),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.visibility_rounded,
                                      size: 12, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    live.viewers,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 14,
                      right: 72,
                      bottom: 16,
                      child: _buildLiveStrip(),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: YanoljaSpacing.s, vertical: 3),
                        decoration: BoxDecoration(
                          color: YanoljaColors.sale.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(YanoljaRadius.pill),
                        ),
                        child: Text(
                          live.discount,
                          style: const TextStyle(
                            color: YanoljaColors.sale,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: YanoljaSpacing.s),
                      const Icon(Icons.storefront_rounded,
                          size: 13, color: YanoljaColors.textTertiary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          live.host,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: YanoljaColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: YanoljaSpacing.s),
                  Text(
                    live.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.3,
                      fontWeight: FontWeight.w800,
                      color: YanoljaColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 방송 예정 / 다시보기 가로 카드
///
/// [replay] 값으로 두 모드를 분명히 구분한다.
/// - 예정: 파란 방송 시각 + 특가 배지 + "알림" 액션
/// - 다시보기: 시청수·방송일(뮤트 톤) + "다시보기" 액션
class _ScheduleRow extends StatelessWidget {
  final _Live live;
  final bool replay;

  const _ScheduleRow({required this.live, required this.replay});

  @override
  Widget build(BuildContext context) {
    return YanoljaPressable(
      onTap: () => _showLivePrep(context, live.host, replay: replay),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: YanoljaColors.surface,
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          border: Border.all(color: YanoljaColors.border),
          boxShadow: const [
            BoxShadow(
              color: YanoljaColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildThumb(),
            const SizedBox(width: 13),
            Expanded(child: _buildInfo()),
            const SizedBox(width: YanoljaSpacing.s),
            _buildAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildThumb() {
    return Container(
      width: 92,
      height: 68,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: live.gradient,
        ),
        borderRadius: BorderRadius.circular(YanoljaRadius.md),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.34),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Icon(
              replay
                  ? Icons.play_circle_fill_rounded
                  : Icons.schedule_rounded,
              color: Colors.white.withValues(alpha: 0.92),
              size: 26,
            ),
          ),
          // 예정 = "예정" 라벨 / 다시보기 = 영상 길이
          if (replay ? live.meta.isNotEmpty : true)
            Positioned(
              right: 5,
              bottom: 5,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.42),
                  borderRadius: BorderRadius.circular(YanoljaRadius.sm),
                ),
                child: Text(
                  replay ? live.meta : '예정',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        replay ? _buildReplayMeta() : _buildUpcomingMeta(),
        const SizedBox(height: 3),
        Text(
          live.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13.5,
            height: 1.3,
            fontWeight: FontWeight.w800,
            color: YanoljaColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingMeta() {
    return Row(
      children: [
        Text(
          live.time,
          style: const TextStyle(
            color: YanoljaColors.primary,
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: YanoljaColors.sale.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(YanoljaRadius.pill),
          ),
          child: Text(
            live.discount,
            style: const TextStyle(
              color: YanoljaColors.sale,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReplayMeta() {
    return Row(
      children: [
        const Icon(Icons.visibility_rounded,
            size: 13, color: YanoljaColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          '${live.viewers} 시청',
          style: const TextStyle(
            color: YanoljaColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          '·',
          style: TextStyle(
            color: YanoljaColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          live.time,
          style: const TextStyle(
            color: YanoljaColors.textTertiary,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAction() {
    final label = replay ? '다시보기' : '알림';
    final icon = replay
        ? Icons.play_circle_fill_rounded
        : Icons.notifications_active_rounded;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: YanoljaColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: YanoljaColors.primary),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: YanoljaColors.primary,
          ),
        ),
      ],
    );
  }
}
