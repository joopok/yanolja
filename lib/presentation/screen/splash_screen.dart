import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';

/// Native launch 이후 짧게 보여주는 NOL 브랜드 런치 스크린.
///
/// 디자인 방향 — "Aurora Departure": 밝은 카드 스택 대신 NOL 블루→퍼플로
/// 가득 채운 딥 그라데이션 위에서, NOL 워드마크가 한 번 "켜지듯" 스케일·페이드로
/// 등장하고 뒤로 빛무리(halo)가 피어오른다. 절제된 단일 신(scene) 연출.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _haloBloom;
  late final Animation<double> _progress;
  Timer? _timer;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    // 딥 브랜드 배경에 맞춰 상태바/내비게이션바 아이콘을 라이트로.
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF111A4D),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1280),
    );

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.5, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.82, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        // easeOutBack → 살짝 오버슈트하며 "톡" 들어오는 점등 느낌.
        curve: const Interval(0, 0.62, curve: Curves.easeOutBack),
      ),
    );
    _haloBloom = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.05, 0.78, curve: Curves.easeOutCubic),
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.30, 1, curve: Curves.easeInOut),
    );

    // 네비게이션/타이머 로직 보존: 1720ms 후 홈으로 이동.
    _timer = Timer(const Duration(milliseconds: 1720), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // 동작 줄이기: 애니메이션 없이 최종 상태로 고정(타이머 이동은 그대로 유지).
    if (YanoljaMotion.reduce(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111A4D),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _AuroraBackdrop(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 5),
                  YanoljaEntrance(
                    delay: const Duration(milliseconds: 180),
                    child: const YanoljaGlassBadge(
                      label: '여행을 켜다',
                      icon: Icons.bolt_rounded,
                    ),
                  ),
                  const SizedBox(height: 26),
                  _buildWordmark(),
                  const SizedBox(height: 16),
                  YanoljaEntrance(
                    delay: const Duration(milliseconds: 360),
                    child: Text(
                      '야놀자',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.66),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 7,
                      ),
                    ),
                  ),
                  const Spacer(flex: 6),
                  YanoljaEntrance(
                    delay: const Duration(milliseconds: 480),
                    child: _SplashLoader(progress: _progress),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// NOL 워드마크 로크업: 빛무리(halo)가 피어오르고 그 위로 그라데이션 글자가
  /// 스케일·페이드로 점등된다.
  Widget _buildWordmark() {
    return SizedBox(
      height: 132,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 점등되는 빛무리
          AnimatedBuilder(
            animation: _haloBloom,
            builder: (context, child) {
              final t = _haloBloom.value;
              return Opacity(
                opacity: (0.55 * t).clamp(0.0, 0.55),
                child: Transform.scale(
                  scale: 0.7 + 0.45 * t,
                  child: child,
                ),
              );
            },
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.34),
                    YanoljaColors.primaryPurple.withValues(alpha: 0.18),
                    YanoljaColors.primaryPurple.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          // 워드마크
          FadeTransition(
            opacity: _logoFade,
            child: ScaleTransition(
              scale: _logoScale,
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Color(0xFFE7EDFF),
                    Color(0xFFC4D2FF),
                  ],
                  stops: [0.0, 0.55, 1.0],
                ).createShader(rect),
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'NOL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 98,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -3,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 딥 NOL 블루→퍼플 그라데이션 + 오로라 빛무리 + 가느다란 여정 곡선 배경.
class _AuroraBackdrop extends StatelessWidget {
  const _AuroraBackdrop();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      painter: _AuroraPainter(),
      child: SizedBox.expand(),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  const _AuroraPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 토큰에서 파생한 딥 인디고(임의 색 대신 primaryDark를 어둡게 합성).
    final deepTop = Color.alphaBlend(
      Colors.black.withValues(alpha: 0.46),
      YanoljaColors.primaryDark,
    );
    final base = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Color(0xFF111A4D),
          YanoljaColors.primary,
          YanoljaColors.primaryPurple,
        ],
        stops: const [0.0, 0.62, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, base);
    // 상단을 한층 더 깊게 눌러 깊이감 부여.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.42),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [deepTop, deepTop.withValues(alpha: 0.0)],
        ).createShader(
          Rect.fromLTWH(0, 0, size.width, size.height * 0.42),
        ),
    );

    void glow(Offset center, double radius, Color color) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [color, color.withValues(alpha: 0.0)],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }

    glow(
      Offset(size.width * 0.86, size.height * 0.14),
      size.width * 0.74,
      YanoljaColors.primaryPurple.withValues(alpha: 0.55),
    );
    glow(
      Offset(size.width * 0.06, size.height * 0.84),
      size.width * 0.66,
      YanoljaColors.accentBlue.withValues(alpha: 0.42),
    );
    // 단 하나의 액센트: 미세한 민트 글로우로 화면 중앙을 살짝 띄운다.
    glow(
      Offset(size.width * 0.5, size.height * 0.45),
      size.width * 0.52,
      YanoljaColors.mint.withValues(alpha: 0.13),
    );

    // 조용한 여정 모티프: 떠오르는 한 줄의 곡선(이륙/항로).
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.08);
    final path = Path()
      ..moveTo(-size.width * 0.05, size.height * 0.66)
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.5,
        size.width * 0.7,
        size.height * 0.74,
        size.width * 1.05,
        size.height * 0.5,
      );
    canvas.drawPath(path, arc);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 하단의 절제된 점등 로더 — 카드가 아닌 가느다란 발광 라인 + 짧은 안내.
class _SplashLoader extends StatelessWidget {
  final Animation<double> progress;

  const _SplashLoader({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: progress,
          builder: (context, _) {
            return SizedBox(
              width: 168,
              height: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                child: Stack(
                  children: [
                    Container(color: Colors.white.withValues(alpha: 0.16)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progress.value.clamp(0.06, 1.0),
                        heightFactor: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(YanoljaRadius.pill),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        Text(
          '놀 준비를 마치는 중',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.62),
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
