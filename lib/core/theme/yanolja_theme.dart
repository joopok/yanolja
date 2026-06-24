/// 🎨 NOL(야놀자) 디자인 시스템
///
/// 현재 NOL 앱의 시각 정체성을 재현하기 위한 중앙 디자인 토큰 모음입니다.
/// - NOL 블루/퍼플 브랜드 컬러
/// - 깔끔한 화이트 배경 + 라이트 그레이 섹션 구분
/// - 플랫(flat) 스타일, 둥근 모서리, 절제된 그림자
///
/// 모든 화면은 이 파일의 토큰을 참조하여 일관된 야놀자 룩앤필을 유지합니다.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// NOL 브랜드 색상 팔레트
class YanoljaColors {
  YanoljaColors._();

  /// NOL 메인 블루
  static const Color primary = Color(0xFF315BFF);

  /// 눌림/진한 블루
  static const Color primaryDark = Color(0xFF2538D8);

  /// 연한 블루 틴트 (배지 배경, 선택 배경 등)
  static const Color primaryLight = Color(0xFFEAF0FF);

  /// NOL 앱 아이콘에 가까운 퍼플 포인트
  static const Color primaryPurple = Color(0xFF5B43FF);

  /// 보조 강조색 — 특가/혜택 표기에 쓰는 레드 톤
  static const Color sale = Color(0xFFFF3D6E);

  /// 포인트 블루 (일부 정보 배지)
  static const Color accentBlue = Color(0xFF1B64DA);

  /// NOL 메뉴 일러스트 보조색
  static const Color mint = Color(0xFF00C2B8);

  /// 혜택/쿠폰 보조색
  static const Color yellow = Color(0xFFFFB92E);

  /// 기본 배경 (화이트)
  static const Color background = Color(0xFFFFFFFF);

  /// 섹션 구분/연한 배경 (라이트 그레이)
  static const Color surfaceAlt = Color(0xFFF5F6F8);

  /// 카드 표면
  static const Color surface = Color(0xFFFFFFFF);

  /// 본문 주요 텍스트 (거의 블랙)
  static const Color textPrimary = Color(0xFF1A1A1A);

  /// 보조 텍스트 (그레이)
  static const Color textSecondary = Color(0xFF6F6F6F);

  /// 흐린 텍스트 / placeholder
  static const Color textTertiary = Color(0xFFA9ADB4);

  /// 경계선/구분선 (얇은 헤어라인)
  static const Color border = Color(0xFFEDEEF0);

  /// 조금 진한 구분선
  static const Color divider = Color(0xFFF1F2F4);

  /// 평점 별 색상
  static const Color star = Color(0xFFFFB21A);

  /// 성공/긍정 (예약 완료 등)
  static const Color success = Color(0xFF12B886);

  /// 그림자
  static const Color shadow = Color(0x14000000);

  /// 깊이감 있는 오버레이 그림자
  static const Color shadowStrong = Color(0x240B1020);
}

/// 📐 공통 모서리 반경
class YanoljaRadius {
  YanoljaRadius._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;
}

/// 📏 공통 간격
class YanoljaSpacing {
  YanoljaSpacing._();
  static const double xs = 4;
  static const double s = 8;
  static const double m = 16;
  static const double l = 20;
  static const double xl = 24;
}

/// 💰 가격/할인 포맷 유틸
class YanoljaFormat {
  YanoljaFormat._();

  static final NumberFormat _won = NumberFormat('#,###');

  /// 천 단위 콤마 포맷 (예: 128000 -> "128,000")
  static String price(int value) => _won.format(value);

  /// id 기반 결정적 할인율(%) — 모킹 데이터에서 특가 느낌을 주기 위함 (10~38%)
  static int discountRate(String id) {
    final hash = id.codeUnits.fold<int>(0, (sum, c) => sum + c);
    return 10 + (hash % 29); // 10 ~ 38
  }

  /// 할인 전 정가 추정 (현재가가 할인가라고 가정)
  static int originalPrice(int discounted, int rate) {
    if (rate <= 0 || rate >= 100) return discounted;
    return (discounted / (1 - rate / 100)).round();
  }
}

/// 앱 전역 토스트/스낵바 헬퍼.
///
/// 화면별로 제각각이던 피드백 문구와 모양을 NOL 톤으로 맞춥니다.
class YanoljaToast {
  YanoljaToast._();

  static void show(
    BuildContext context,
    String message, {
    IconData icon = Icons.check_circle_rounded,
    Duration duration = const Duration(seconds: 2),
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          duration: duration,
        ),
      );
  }
}

/// 🔖 야놀자 스타일 섹션 헤더 (제목 + 선택적 "더보기")
class YanoljaSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? trailingText;
  final VoidCallback? onTrailingTap;
  final EdgeInsetsGeometry padding;

  const YanoljaSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.onTrailingTap,
    this.padding = const EdgeInsets.fromLTRB(20, 24, 20, 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
                      fontSize: 13,
                      color: YanoljaColors.textSecondary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailingText != null)
            GestureDetector(
              onTap: onTrailingTap,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Text(
                    trailingText!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: YanoljaColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: YanoljaColors.textTertiary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// ⭐ 평점 + 리뷰수 작은 표기 (예: ★ 4.8 (1,234))
class YanoljaRating extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double fontSize;

  const YanoljaRating({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.fontSize = 12.5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 15, color: YanoljaColors.star),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: YanoljaColors.textPrimary,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          '(${YanoljaFormat.price(reviewCount)})',
          style: TextStyle(
            fontSize: fontSize,
            color: YanoljaColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
