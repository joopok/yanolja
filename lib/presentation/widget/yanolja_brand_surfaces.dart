import 'package:flutter/material.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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

  const YanoljaPressable({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null ? null : (_) => _setPressed(true),
      onTapCancel: widget.onTap == null ? null : () => _setPressed(false),
      onTapUp: widget.onTap == null ? null : (_) => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        scale: _pressed ? 0.97 : 1,
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
