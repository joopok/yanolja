import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';

/// Native launch 이후 짧게 보여주는 브랜드 스플래시 화면.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _progress;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF7FAFF),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1280),
    )..forward();

    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.05, 0.78, curve: Curves.easeOut),
    );
    _scale = Tween<double>(begin: 0.94, end: 1).animate(curve);
    _progress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.18, 1, curve: Curves.easeOutCubic),
    );

    _timer = Timer(const Duration(milliseconds: 1720), () {
      if (mounted) context.go('/home');
    });
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
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _SplashBackdrop(),
          Positioned(
            left: 0,
            right: 0,
            bottom: -size.height * 0.03,
            height: size.height * 0.52,
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/brand/splash_image.png',
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 28),
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SplashTopBar(),
                      const Spacer(flex: 2),
                      const _SplashBrandCard(),
                      const SizedBox(height: 18),
                      const _SplashChips(),
                      const Spacer(flex: 3),
                      _SplashLoadingTrack(progress: _progress),
                    ],
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

class _SplashBackdrop extends StatelessWidget {
  const _SplashBackdrop();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SplashBackdropPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _SplashBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF8FBFF),
          Color(0xFFEAF0FF),
          Color(0xFFE3FAF7),
        ],
        stops: [0, 0.58, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, base);

    final ticket = Paint()
      ..color = Colors.white.withValues(alpha: 0.72)
      ..style = PaintingStyle.fill;
    final ticketRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.5, size.height * 0.12, size.width * 0.56,
          size.height * 0.18),
      const Radius.circular(28),
    );
    canvas.save();
    canvas.rotate(-0.12);
    canvas.drawRRect(ticketRect, ticket);
    canvas.restore();

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = YanoljaColors.primary.withValues(alpha: 0.2);
    final path = Path()
      ..moveTo(size.width * 0.06, size.height * 0.73)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.58,
        size.width * 0.48,
        size.height * 0.88,
        size.width * 0.72,
        size.height * 0.68,
      )
      ..cubicTo(
        size.width * 0.83,
        size.height * 0.59,
        size.width * 0.92,
        size.height * 0.72,
        size.width * 0.98,
        size.height * 0.62,
      );
    canvas.drawPath(path, stroke);

    void drawNode(Offset offset, Color color) {
      canvas.drawCircle(offset, 12, Paint()..color = color);
      canvas.drawCircle(offset, 5, Paint()..color = Colors.white);
    }

    drawNode(
        Offset(size.width * 0.09, size.height * 0.72), YanoljaColors.primary);
    drawNode(Offset(size.width * 0.31, size.height * 0.64), YanoljaColors.mint);
    drawNode(Offset(size.width * 0.52, size.height * 0.78),
        YanoljaColors.primaryPurple);
    drawNode(Offset(size.width * 0.72, size.height * 0.68), YanoljaColors.sale);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SplashTopBar extends StatelessWidget {
  const _SplashTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Color(0x16000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              'assets/brand/app_icon_source.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(YanoljaRadius.pill),
            border: Border.all(color: Colors.white),
          ),
          child: const Text(
            'NOL READY',
            style: TextStyle(
              color: YanoljaColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _SplashBrandCard extends StatelessWidget {
  const _SplashBrandCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: YanoljaColors.textPrimary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  '놀',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '여기가어때',
                      style: TextStyle(
                        color: YanoljaColors.textPrimary,
                        fontSize: 31,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      '오늘의 여행을 켜는 가장 빠른 패스',
                      style: TextStyle(
                        color: YanoljaColors.textSecondary,
                        fontSize: 13,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.bolt_rounded,
                  color: YanoljaColors.primary,
                  size: 22,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    '숙소, 티켓, 예약 정보를 한 번에 준비 중',
                    style: TextStyle(
                      color: YanoljaColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashChips extends StatelessWidget {
  const _SplashChips();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('STAY', YanoljaColors.primary),
      ('TICKET', YanoljaColors.sale),
      ('LOCAL', YanoljaColors.mint),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: item.$2.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(YanoljaRadius.pill),
              border: Border.all(color: item.$2.withValues(alpha: 0.16)),
            ),
            child: Text(
              item.$1,
              style: TextStyle(
                color: item.$2,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
      ],
    );
  }
}

class _SplashLoadingTrack extends StatelessWidget {
  final Animation<double> progress;

  const _SplashLoadingTrack({required this.progress});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.84),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text(
                    '여행 준비 중',
                    style: TextStyle(
                      color: YanoljaColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  Spacer(),
                  Text(
                    'NOL',
                    style: TextStyle(
                      color: YanoljaColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  value: progress.value.clamp(0.08, 1),
                  backgroundColor: YanoljaColors.primaryLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    YanoljaColors.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
