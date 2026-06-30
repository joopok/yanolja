import 'package:flutter/material.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';

class NolMyIconAsset {
  NolMyIconAsset._();

  static const String reservation = 'assets/my_icons/reservation.png';
  static const String coupon = 'assets/my_icons/coupon.png';
  static const String points = 'assets/my_icons/points.png';
  static const String review = 'assets/my_icons/review.png';
  static const String notification = 'assets/my_icons/notification.png';
  static const String settings = 'assets/my_icons/settings.png';
  static const String support = 'assets/my_icons/support.png';
  static const String profileEdit = 'assets/my_icons/profile_edit.png';
  static const String saved = 'assets/my_icons/saved.png';
  static const String recent = 'assets/my_icons/recent.png';
  static const String card = 'assets/my_icons/card.png';
  static const String notice = 'assets/my_icons/notice.png';
  static const String location = 'assets/my_icons/location.png';
  static const String language = 'assets/my_icons/language.png';
  static const String security = 'assets/my_icons/security.png';
  static const String theme = 'assets/my_icons/theme.png';
}

class NolMyIcon extends StatelessWidget {
  final String asset;
  final double size;
  final String? semanticLabel;

  const NolMyIcon({
    super.key,
    required this.asset,
    this.size = 52,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        semanticLabel: semanticLabel,
        excludeFromSemantics: semanticLabel == null,
      ),
    );
  }
}

class NolMyIconPlate extends StatelessWidget {
  final String asset;
  final double size;
  final double iconSize;
  final String? semanticLabel;

  const NolMyIconPlate({
    super.key,
    required this.asset,
    this.size = 48,
    this.iconSize = 44,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: YanoljaColors.surface,
        borderRadius: BorderRadius.circular(YanoljaRadius.md),
        border: Border.all(color: YanoljaColors.border),
        boxShadow: const [
          BoxShadow(
            color: YanoljaColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: NolMyIcon(
        asset: asset,
        size: iconSize,
        semanticLabel: semanticLabel,
      ),
    );
  }
}
