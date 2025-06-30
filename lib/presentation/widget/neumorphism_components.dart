import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🌟 네오모피즘 그림자 헬퍼
class NeumorphismHelper {
  static const _lightShadow = Color(0xFFFFFFFF);
  static const _darkShadow = Color(0xFFD1D1D4);
  
  /// 기본 네오모피즘 그림자 (돌출 효과)
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: _darkShadow.withValues(alpha: 0.5),
      offset: const Offset(6, 6),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: _lightShadow.withValues(alpha: 0.9),
      offset: const Offset(-6, -6),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  /// 눌린 네오모피즘 그림자 (인셋 효과)
  static List<BoxShadow> get pressedShadow => [
    BoxShadow(
      color: _darkShadow.withValues(alpha: 0.6),
      offset: const Offset(3, 3),
      blurRadius: 6,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: _lightShadow.withValues(alpha: 0.7),
      offset: const Offset(-3, -3),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];

  /// 부드러운 네오모피즘 그림자 (미묘한 효과)
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: _darkShadow.withValues(alpha: 0.3),
      offset: const Offset(4, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: _lightShadow.withValues(alpha: 0.8),
      offset: const Offset(-4, -4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  /// 강한 네오모피즘 그림자 (강조 효과)
  static List<BoxShadow> get boldShadow => [
    BoxShadow(
      color: _darkShadow.withValues(alpha: 0.7),
      offset: const Offset(8, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: _lightShadow.withValues(alpha: 0.9),
      offset: const Offset(-8, -8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];
}

/// 🎨 **네오모피즘 카드**
/// 부드러운 그림자 효과로 입체감을 표현하는 기본 카드 컴포넌트
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
    this.borderRadius = 20,
    this.isPressed = false,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.customShadow,
  });

  @override
  State<NeumorphismCard> createState() => _NeumorphismCardState();
}

class _NeumorphismCardState extends State<NeumorphismCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
      _animationController.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
      _animationController.reverse();
      widget.onTap?.call();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onLongPress: widget.onLongPress,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: widget.padding,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: widget.customShadow ??
                    (widget.isPressed || _isPressed
                        ? NeumorphismHelper.pressedShadow
                        : NeumorphismHelper.elevatedShadow),
              ),
              child: widget.child,
            ),
          ),
        );
      },
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
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return NeumorphismCard(
      isPressed: _isPressed,
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
              color: widget.iconColor ?? theme.colorScheme.primary,
            ),
            if (widget.text != null) const SizedBox(width: 8),
          ],
          if (widget.text != null)
            Text(
              widget.text!,
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: widget.fontWeight,
                color: widget.textColor ?? theme.colorScheme.onSurface,
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
    final theme = Theme.of(context);
    
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
            color: iconColor ?? theme.colorScheme.primary,
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
    final theme = Theme.of(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isFocused 
            ? NeumorphismHelper.pressedShadow
            : NeumorphismHelper.softShadow,
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
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 16,
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
              horizontal: 20,
              vertical: 16,
            ),
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            labelStyle: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: theme.colorScheme.onSurfaceVariant,
                  )
                : null,
            suffixIcon: widget.suffixIcon != null
                ? GestureDetector(
                    onTap: widget.onSuffixIconTap,
                    child: Icon(
                      widget.suffixIcon,
                      color: theme.colorScheme.onSurfaceVariant,
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
    final theme = Theme.of(context);
    
    return NeumorphismCard(
      isPressed: isSelected,
      borderRadius: 20,
      backgroundColor: isSelected 
          ? (selectedColor ?? theme.colorScheme.primary.withValues(alpha: 0.1))
          : (unselectedColor ?? theme.colorScheme.surfaceContainer),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: isSelected 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🌟 **네오모피즘 뱃지**
/// 🏷️ **네오모피즘 배지 - 그라데이션 에디션**
/// 아름다운 그라데이션으로 상태나 정보를 표시하는 배지
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
    this.useGradient = false, // 화이트 테마는 단색이 더 깔끔
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: useGradient ? null : backgroundColor ?? theme.colorScheme.primary,
        gradient: useGradient ? LinearGradient(
          colors: [
            backgroundColor ?? const Color(0xFF6B7280), // 모던 그레이
            backgroundColor?.withValues(alpha: 0.8) ?? const Color(0xFF9CA3AF), // 라이트 그레이
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ) : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: NeumorphismHelper.softShadow,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: textColor ?? (useGradient || backgroundColor != null ? Colors.white : const Color(0xFF111827)),
          shadows: useGradient ? const [
            Shadow(
              offset: Offset(0, 1),
              blurRadius: 2,
              color: Colors.black26,
            ),
          ] : null,
        ),
      ),
    );
  }
}