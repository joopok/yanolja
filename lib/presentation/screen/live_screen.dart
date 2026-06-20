import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';

/// NOL 라이브 화면
///
/// 실제 NOL 메인의 "NOL 라이브 놀라운 혜택" 라이브커머스 섹션을 전용 화면으로
/// 재현했습니다. 지금 라이브 중인 방송과 방송 예정 편성을 보여줍니다.
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
          _buildSectionTitle('지금 라이브 중', live: true),
          for (final live in _liveNow)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: _LiveCard(live: live),
            ),
          const SizedBox(height: 8),
          _buildSectionTitle('방송 예정'),
          for (final live in _upcoming)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: _UpcomingRow(live: live),
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

  Widget _buildSectionTitle(String title, {bool live = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        children: [
          if (live) ...[
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: YanoljaColors.sale,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 7),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: YanoljaColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }

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
      gradient: [Color(0xFF0F3D2E), Color(0xFF12B886)],
    ),
  ];

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
      gradient: [Color(0xFF2C1A05), Color(0xFFFFB92E)],
    ),
    _Live(
      title: '[한화리조트] 설악 워터피아 패키지 방송',
      host: '한화리조트',
      time: '내일 15:00',
      viewers: '',
      discount: '추가 적립',
      gradient: [Color(0xFF1A1330), Color(0xFF5B43FF)],
    ),
    _Live(
      title: '[파라다이스시티] 인천 럭셔리 스테이 라이브',
      host: '파라다이스',
      time: '06.23 20:00',
      viewers: '',
      discount: '최대 25%',
      gradient: [Color(0xFF0B2A4A), Color(0xFF1B64DA)],
    ),
  ];
}

class _Live {
  final String title;
  final String host;
  final String time;
  final String viewers;
  final String discount;
  final List<Color> gradient;

  const _Live({
    required this.title,
    required this.host,
    required this.time,
    required this.viewers,
    required this.discount,
    required this.gradient,
  });
}

void _showLivePrep(BuildContext context, String title) {
  HapticFeedback.lightImpact();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$title 라이브는 준비 중이에요'),
      behavior: SnackBarBehavior.floating,
      backgroundColor: YanoljaColors.textPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(YanoljaRadius.md),
      ),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ),
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

/// 라이브 중 큰 카드 (16:9 썸네일 + LIVE 배지 + 정보)
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          border: Border.all(color: YanoljaColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
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
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Icon(
                        Icons.play_circle_fill_rounded,
                        size: 44,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: YanoljaColors.sale,
                              borderRadius:
                                  BorderRadius.circular(YanoljaRadius.sm),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.circle,
                                    size: 7, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (live.viewers.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
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
                            horizontal: 8, vertical: 3),
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
                      const SizedBox(width: 8),
                      Text(
                        live.host,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: YanoljaColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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

/// 방송 예정 가로 카드
class _UpcomingRow extends StatelessWidget {
  final _Live live;

  const _UpcomingRow({required this.live});

  @override
  Widget build(BuildContext context) {
    return YanoljaPressable(
      onTap: () => _showLivePrep(context, live.host),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          border: Border.all(color: YanoljaColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 84,
              height: 64,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: live.gradient,
                ),
                borderRadius: BorderRadius.circular(YanoljaRadius.md),
              ),
              child: Center(
                child: Icon(
                  Icons.play_circle_outline_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    live.time,
                    style: const TextStyle(
                      color: YanoljaColors.primary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
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
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                Icon(Icons.notifications_active_rounded,
                    size: 22, color: YanoljaColors.primary),
                const SizedBox(height: 3),
                const Text(
                  '알림',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: YanoljaColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
