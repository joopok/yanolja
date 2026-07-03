import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';

class YanoljaMotion {
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration base = Duration(milliseconds: 220);
  static const Duration entrance = Duration(milliseconds: 360);
  static const Curve curve = Curves.easeOutCubic;

  const YanoljaMotion._();

  static Duration stagger(int index, {int start = 40, int step = 55}) {
    // 긴 세로 목록에서 지연이 무한정 커져 카드가 오래 비표시되는 것을 막기 위해
    // 인덱스에 상한(6)을 둔다. (예: step 55 기준 최대 +330ms)
    final capped = index < 6 ? index : 6;
    return Duration(milliseconds: start + (capped * step));
  }

  static bool reduce(BuildContext context) {
    return MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  }
}

/// 진입 시 살짝 떠오르며(slide) 페이드인 + 미세 스케일업으로
/// 등장하는 래퍼. 화면들이 [delay]로 staggered 등장을 연출한다.
///
/// 접근성: 시스템 "동작 줄이기"가 켜져 있으면 애니메이션 없이 즉시 표시한다.
class YanoljaEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset beginOffset;
  final double beginScale;

  const YanoljaEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = YanoljaMotion.entrance,
    this.beginOffset = const Offset(0, 0.045),
    this.beginScale = 0.985,
  });

  @override
  State<YanoljaEntrance> createState() => _YanoljaEntranceState();
}

class _YanoljaEntranceState extends State<YanoljaEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curved;
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _curved = CurvedAnimation(parent: _controller, curve: YanoljaMotion.curve);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeStart();
  }

  void _maybeStart() {
    if (_controller.status != AnimationStatus.dismissed) return;
    // 동작 줄이기 설정 시 애니메이션 없이 최종 상태로 고정.
    if (YanoljaMotion.reduce(context)) {
      _controller.value = 1;
      return;
    }
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _startTimer?.cancel();
      _startTimer = Timer(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (YanoljaMotion.reduce(context)) return widget.child;
    return AnimatedBuilder(
      animation: _curved,
      builder: (context, child) {
        final t = _curved.value;
        final scale =
            widget.beginScale + (1 - widget.beginScale) * t;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: FractionalTranslation(
            translation: Offset(
              widget.beginOffset.dx * (1 - t),
              widget.beginOffset.dy * (1 - t),
            ),
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
      child: widget.child,
    );
  }
}

class YanoljaPremiumHero extends StatelessWidget {
  final String badge;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final List<Widget> metrics;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final double? minHeight;
  final Duration delay;

  const YanoljaPremiumHero({
    super.key,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    this.metrics = const [],
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.all(20),
    this.minHeight,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return YanoljaEntrance(
      delay: delay,
      child: Container(
        margin: margin,
        constraints: BoxConstraints(minHeight: minHeight ?? 0),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(YanoljaRadius.xl),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withValues(alpha: 0.24),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            const Positioned.fill(
                child: CustomPaint(painter: _HeroLinePainter())),
            Positioned(
              right: -18,
              top: -18,
              child: Icon(
                icon,
                size: 126,
                color: Colors.white.withValues(alpha: 0.13),
              ),
            ),
            Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  YanoljaGlassBadge(label: badge),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        height: 1.16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 310),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 13.5,
                        height: 1.42,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  if (metrics.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: metrics,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class YanoljaGlassBadge extends StatelessWidget {
  final String label;
  final IconData? icon;

  const YanoljaGlassBadge({
    super.key,
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(YanoljaRadius.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class YanoljaHeroMetric extends StatelessWidget {
  final String label;
  final String value;

  const YanoljaHeroMetric({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(YanoljaRadius.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class YanoljaPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final double pressedScale;

  const YanoljaPressable({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.pressedScale = 0.97,
  });

  @override
  State<YanoljaPressable> createState() => _YanoljaPressableState();
}

class _YanoljaPressableState extends State<YanoljaPressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = YanoljaMotion.reduce(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null ? null : (_) => _setPressed(true),
      onTapCancel: widget.onTap == null ? null : () => _setPressed(false),
      onTapUp: widget.onTap == null ? null : (_) => _setPressed(false),
      onTap: widget.onTap,
      child: reduceMotion
          ? widget.child
          : AnimatedScale(
              duration: YanoljaMotion.fast,
              curve: YanoljaMotion.curve,
              scale: _pressed ? widget.pressedScale : 1,
              child: widget.child,
            ),
    );
  }
}

class _HeroLinePainter extends CustomPainter {
  const _HeroLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * 0.04, size.height * 0.78)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.60,
        size.width * 0.52,
        size.height * 0.94,
        size.width * 0.92,
        size.height * 0.58,
      );
    canvas.drawPath(path, stroke);

    final accent = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final left = size.width * (0.08 + i * 0.18);
      final top = size.height * (i.isEven ? 0.10 : 0.18);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top + i * 9, size.width * 0.18, 24),
          const Radius.circular(12),
        ),
        accent,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
