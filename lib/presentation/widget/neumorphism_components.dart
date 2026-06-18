import 'package:flutter/material.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';

/// 🌟 그림자 헬퍼 (야놀자 플랫 스타일)
///
/// 과거 네오모피즘(이중 그림자) 구조를 호환성 유지를 위해 동일한 이름으로 노출하되,
/// 실제 시각은 야놀자 디자인 언어에 맞춘 절제된 단일 그림자로 통일합니다.
class NeumorphismHelper {
  /// 기본 그림자 (살짝 떠 있는 카드 느낌)
  static List<BoxShadow> get elevatedShadow => const [
    BoxShadow(
      color: YanoljaColors.shadow,
      offset: Offset(0, 4),
      blurRadius: 14,
      spreadRadius: 0,
    ),
  ];

  /// 눌린 상태 (그림자 거의 없음 — 플랫)
  static List<BoxShadow> get pressedShadow => const [
    BoxShadow(
      color: YanoljaColors.shadow,
      offset: Offset(0, 1),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  /// 부드러운 그림자 (미묘한 떠 있음)
  static List<BoxShadow> get softShadow => const [
    BoxShadow(
      color: YanoljaColors.shadow,
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  /// 강조 그림자 (조금 더 또렷)
  static List<BoxShadow> get boldShadow => const [
    BoxShadow(
      color: YanoljaColors.shadow,
      offset: Offset(0, 6),
      blurRadius: 18,
      spreadRadius: 0,
    ),
  ];
}

/// 🎨 **야놀자 플랫 카드** (구 네오모피즘 카드)
/// 화이트 표면 + 얇은 헤어라인 보더 + 절제된 단일 그림자로 입체감을 표현합니다.
/// 클래스/생성자 시그니처는 호환성을 위해 유지합니다.
class NeumorphismCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool isPressed;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final List<BoxShadow>? customShadow;

  const NeumorphismCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16,
    this.isPressed = false,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.customShadow,
  });

  @override
  State<NeumorphismCard> createState() => _NeumorphismCardState();
}

class _NeumorphismCardState extends State<NeumorphismCard> {
  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? YanoljaColors.surface;

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: YanoljaColors.border, width: 1),
        boxShadow: widget.customShadow ??
            (widget.isPressed
                ? NeumorphismHelper.pressedShadow
                : NeumorphismHelper.softShadow),
      ),
      child: widget.child,
    );

    if (widget.onTap == null && widget.onLongPress == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        splashColor: YanoljaColors.primary.withValues(alpha: 0.06),
        highlightColor: YanoljaColors.primary.withValues(alpha: 0.04),
        child: card,
      ),
    );
  }
}

/// 🎯 **네오모피즘 버튼**
/// 인터렉티브한 버튼 컴포넌트 (텍스트 + 아이콘 지원)
class NeumorphismButton extends StatefulWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double fontSize;
  final FontWeight fontWeight;
  final double iconSize;
  final MainAxisSize mainAxisSize;
  final MainAxisAlignment mainAxisAlignment;

  const NeumorphismButton({
    super.key,
    this.text,
    this.icon,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.borderRadius = 16,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.iconSize = 20,
    this.mainAxisSize = MainAxisSize.min,
    this.mainAxisAlignment = MainAxisAlignment.center,
  });

  @override
  State<NeumorphismButton> createState() => _NeumorphismButtonState();
}

class _NeumorphismButtonState extends State<NeumorphismButton> {
  @override
  Widget build(BuildContext context) {
    return NeumorphismCard(
      borderRadius: widget.borderRadius,
      backgroundColor: widget.backgroundColor,
      padding: widget.padding,
      onTap: widget.onTap,
      child: Row(
        mainAxisSize: widget.mainAxisSize,
        mainAxisAlignment: widget.mainAxisAlignment,
        children: [
          if (widget.icon != null) ...[
            Icon(
              widget.icon,
              size: widget.iconSize,
              color: widget.iconColor ?? YanoljaColors.primary,
            ),
            if (widget.text != null) const SizedBox(width: 8),
          ],
          if (widget.text != null)
            Text(
              widget.text!,
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: widget.fontWeight,
                color: widget.textColor ?? YanoljaColors.textPrimary,
              ),
            ),
        ],
      ),
    );
  }
}

/// 🔘 **네오모피즘 아이콘 버튼**
/// 아이콘만 있는 원형 버튼
class NeumorphismIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;

  const NeumorphismIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 48,
    this.iconSize = 24,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphismCard(
      borderRadius: size / 2,
      backgroundColor: backgroundColor,
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Icon(
            icon,
            size: iconSize,
            color: iconColor ?? YanoljaColors.primary,
          ),
        ),
      ),
    );
  }
}

/// 📱 **네오모피즘 입력 필드**
/// 부드러운 그림자 효과가 있는 텍스트 입력 필드
class NeumorphismTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final int maxLines;

  const NeumorphismTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
  });

  @override
  State<NeumorphismTextField> createState() => _NeumorphismTextFieldState();
}

class _NeumorphismTextFieldState extends State<NeumorphismTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _isFocused ? YanoljaColors.surface : YanoljaColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isFocused ? YanoljaColors.primary : YanoljaColors.border,
          width: _isFocused ? 1.4 : 1,
        ),
      ),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() => _isFocused = hasFocus);
        },
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          style: const TextStyle(
            color: YanoljaColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            labelText: widget.labelText,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            hintStyle: const TextStyle(
              color: YanoljaColors.textTertiary,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            labelStyle: const TextStyle(
              color: YanoljaColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _isFocused
                        ? YanoljaColors.primary
                        : YanoljaColors.textTertiary,
                  )
                : null,
            suffixIcon: widget.suffixIcon != null
                ? GestureDetector(
                    onTap: widget.onSuffixIconTap,
                    child: Icon(
                      widget.suffixIcon,
                      color: YanoljaColors.textTertiary,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

/// 🏷️ **네오모피즘 칩**
/// 선택 가능한 태그 형태의 컴포넌트
class NeumorphismChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? selectedColor;
  final Color? unselectedColor;

  const NeumorphismChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? (selectedColor ?? YanoljaColors.primaryLight)
        : (unselectedColor ?? YanoljaColors.surface);
    final borderColor =
        isSelected ? YanoljaColors.primary : YanoljaColors.border;
    final fgColor =
        isSelected ? YanoljaColors.primary : YanoljaColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(YanoljaRadius.pill),
        splashColor: YanoljaColors.primary.withValues(alpha: 0.06),
        highlightColor: YanoljaColors.primary.withValues(alpha: 0.04),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(YanoljaRadius.pill),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: fgColor),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: fgColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🏷️ **야놀자 배지**
/// 상태/특가 정보를 표시하는 플랫 핑크 배지 (기본 핑크 배경 + 화이트 텍스트).
/// `useGradient` 파라미터는 호환성을 위해 유지하나, 야놀자 플랫 스타일에선 단색으로 처리합니다.
class NeumorphismBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final bool useGradient;

  const NeumorphismBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 10,
    this.useGradient = false, // 야놀자는 단색 배지를 사용
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? YanoljaColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(YanoljaRadius.sm),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: textColor ?? Colors.white,
        ),
      ),
    );
  }
}