import 'package:flutter/material.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';

class NolMyIconAsset {
  NolMyIconAsset._();

  static const String reservation = 'assets/my_icons/v2_reservation.png';
  static const String coupon = 'assets/my_icons/v2_coupon.png';
  static const String points = 'assets/my_icons/v2_points.png';
  static const String review = 'assets/my_icons/v2_review.png';
  static const String notification = 'assets/my_icons/v2_notification.png';
  static const String settings = 'assets/my_icons/v2_settings.png';
  static const String support = 'assets/my_icons/v2_support.png';
  static const String profileEdit = 'assets/my_icons/v2_profile_edit.png';
  static const String saved = 'assets/my_icons/v2_saved.png';
  static const String recent = 'assets/my_icons/v2_recent.png';
  static const String card = 'assets/my_icons/v2_card.png';
  static const String notice = 'assets/my_icons/v2_notice.png';
  static const String location = 'assets/my_icons/v2_location.png';
  static const String language = 'assets/my_icons/v2_language.png';
  static const String security = 'assets/my_icons/v2_security.png';
  static const String theme = 'assets/my_icons/v2_theme.png';

  static const Map<String, IconData> _fallbackIcons = {
    reservation: Icons.luggage_rounded,
    coupon: Icons.confirmation_number_rounded,
    points: Icons.stars_rounded,
    review: Icons.rate_review_rounded,
    notification: Icons.notifications_rounded,
    settings: Icons.tune_rounded,
    support: Icons.support_agent_rounded,
    profileEdit: Icons.manage_accounts_rounded,
    saved: Icons.favorite_rounded,
    recent: Icons.history_rounded,
    card: Icons.credit_card_rounded,
    notice: Icons.campaign_rounded,
    location: Icons.place_rounded,
    language: Icons.language_rounded,
    security: Icons.lock_rounded,
    theme: Icons.contrast_rounded,
  };

  static IconData fallbackIconFor(String asset) {
    return _fallbackIcons[asset] ?? Icons.image_not_supported_rounded;
  }
}

class NolMyIcon extends StatelessWidget {
  final String asset;
  final double size;
  final String? semanticLabel;
  final IconData? fallbackIcon;

  const NolMyIcon({
    super.key,
    required this.asset,
    this.size = 52,
    this.semanticLabel,
    this.fallbackIcon,
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
        errorBuilder: (context, error, stackTrace) {
          return _NolMyIconFallback(
            icon: fallbackIcon ?? NolMyIconAsset.fallbackIconFor(asset),
            size: size,
            semanticLabel: semanticLabel,
          );
        },
      ),
    );
  }
}

class _NolMyIconFallback extends StatelessWidget {
  final IconData icon;
  final double size;
  final String? semanticLabel;

  const _NolMyIconFallback({
    required this.icon,
    required this.size,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = (size * 0.48).clamp(18.0, 32.0);
    return Semantics(
      label: semanticLabel,
      image: semanticLabel != null,
      excludeSemantics: semanticLabel == null,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: YanoljaColors.primaryLight,
          borderRadius: BorderRadius.circular(YanoljaRadius.md),
          border: Border.all(
            color: YanoljaColors.primary.withValues(alpha: 0.10),
          ),
        ),
        child: Icon(
          icon,
          color: YanoljaColors.primary,
          size: iconSize,
        ),
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
