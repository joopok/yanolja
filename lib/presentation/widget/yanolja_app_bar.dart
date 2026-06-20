import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';

enum YanoljaAppBarVariant { main, sub, detail, modal }

/// NOL 앱 전역에서 재사용하는 일반 AppBar.
///
/// - `main`: 하단 탭 루트 화면용, 뒤로가기 없음
/// - `sub`: 서브 화면용, 뒤로가기 있음
/// - `modal`: 로그인/회원가입처럼 닫기 동작이 어울리는 화면용
class YanoljaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool useCloseButton;
  final String? fallbackRoute;
  final VoidCallback? onBackPress;
  final Color backgroundColor;
  final Color foregroundColor;
  final double titleOpacity;
  final double toolbarHeight;
  final PreferredSizeWidget? bottom;
  final YanoljaAppBarVariant variant;

  const YanoljaAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.showBackButton = true,
    this.useCloseButton = false,
    this.fallbackRoute,
    this.onBackPress,
    this.backgroundColor = YanoljaColors.background,
    this.foregroundColor = YanoljaColors.textPrimary,
    this.titleOpacity = 1,
    this.toolbarHeight = 58,
    this.bottom,
    this.variant = YanoljaAppBarVariant.sub,
  });

  const YanoljaAppBar.main({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.backgroundColor = YanoljaColors.background,
    this.foregroundColor = YanoljaColors.textPrimary,
    this.bottom,
  })  : leading = null,
        showBackButton = false,
        useCloseButton = false,
        fallbackRoute = null,
        onBackPress = null,
        titleOpacity = 1,
        toolbarHeight = 62,
        variant = YanoljaAppBarVariant.main;

  const YanoljaAppBar.sub({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.fallbackRoute,
    this.onBackPress,
    this.backgroundColor = YanoljaColors.background,
    this.foregroundColor = YanoljaColors.textPrimary,
    this.bottom,
  })  : leading = null,
        showBackButton = true,
        useCloseButton = false,
        titleOpacity = 1,
        toolbarHeight = 58,
        variant = YanoljaAppBarVariant.sub;

  const YanoljaAppBar.modal({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.fallbackRoute,
    this.onBackPress,
    this.backgroundColor = YanoljaColors.background,
    this.foregroundColor = YanoljaColors.textPrimary,
    this.bottom,
  })  : leading = null,
        showBackButton = true,
        useCloseButton = true,
        titleOpacity = 1,
        toolbarHeight = 58,
        variant = YanoljaAppBarVariant.modal;

  @override
  Widget build(BuildContext context) {
    final hasLeading = leading != null || showBackButton;

    return AppBar(
      toolbarHeight: toolbarHeight,
      backgroundColor: backgroundColor,
      surfaceTintColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: YanoljaColors.shadow,
      leading: leading ?? _buildDefaultLeading(context),
      automaticallyImplyLeading: false,
      titleSpacing: hasLeading ? 0 : 20,
      centerTitle: false,
      title: Opacity(
        opacity: titleOpacity.clamp(0.0, 1.0).toDouble(),
        child: _YanoljaAppBarTitle(
          title: title,
          subtitle: subtitle,
          variant: variant,
          color: foregroundColor,
        ),
      ),
      actions: _withActionGap(actions),
      bottom: bottom,
    );
  }

  Widget? _buildDefaultLeading(BuildContext context) {
    if (!showBackButton) return null;
    return IconButton(
      tooltip: useCloseButton ? '닫기' : '뒤로',
      icon: Icon(
        useCloseButton ? Icons.close_rounded : Icons.arrow_back_ios_new_rounded,
        size: useCloseButton ? 24 : 20,
      ),
      onPressed: () => _handleBack(context),
    );
  }

  void _handleBack(BuildContext context) {
    if (onBackPress != null) {
      onBackPress!();
      return;
    }
    HapticFeedback.selectionClick();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(fallbackRoute ?? '/home');
    }
  }

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(toolbarHeight + bottomHeight);
  }
}

/// NOL 앱 전역에서 재사용하는 SliverAppBar.
///
/// CustomScrollView를 쓰는 메인/서브/상세 화면은 이 위젯을 사용합니다.
class YanoljaSliverAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool useCloseButton;
  final String? fallbackRoute;
  final bool pinned;
  final bool floating;
  final bool snap;
  final VoidCallback? onBackPress;
  final Color backgroundColor;
  final Color foregroundColor;
  final double titleOpacity;
  final double toolbarHeight;
  final double? expandedHeight;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  final YanoljaAppBarVariant variant;

  const YanoljaSliverAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.showBackButton = true,
    this.useCloseButton = false,
    this.fallbackRoute,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.onBackPress,
    this.backgroundColor = YanoljaColors.background,
    this.foregroundColor = YanoljaColors.textPrimary,
    this.titleOpacity = 1,
    this.toolbarHeight = 58,
    this.expandedHeight,
    this.flexibleSpace,
    this.bottom,
    this.variant = YanoljaAppBarVariant.sub,
  });

  const YanoljaSliverAppBar.main({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.backgroundColor = YanoljaColors.background,
    this.foregroundColor = YanoljaColors.textPrimary,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.bottom,
  })  : leading = null,
        showBackButton = false,
        useCloseButton = false,
        fallbackRoute = null,
        onBackPress = null,
        titleOpacity = 1,
        toolbarHeight = 62,
        expandedHeight = null,
        flexibleSpace = null,
        variant = YanoljaAppBarVariant.main;

  const YanoljaSliverAppBar.sub({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.fallbackRoute,
    this.onBackPress,
    this.backgroundColor = YanoljaColors.background,
    this.foregroundColor = YanoljaColors.textPrimary,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.bottom,
  })  : leading = null,
        showBackButton = true,
        useCloseButton = false,
        titleOpacity = 1,
        toolbarHeight = 58,
        expandedHeight = null,
        flexibleSpace = null,
        variant = YanoljaAppBarVariant.sub;

  const YanoljaSliverAppBar.detail({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.fallbackRoute,
    this.onBackPress,
    this.backgroundColor = YanoljaColors.background,
    this.foregroundColor = YanoljaColors.textPrimary,
    this.titleOpacity = 1,
    required this.expandedHeight,
    required this.flexibleSpace,
  })  : subtitle = null,
        showBackButton = true,
        useCloseButton = false,
        pinned = true,
        floating = false,
        snap = false,
        toolbarHeight = 58,
        bottom = null,
        variant = YanoljaAppBarVariant.detail;

  @override
  Widget build(BuildContext context) {
    final hasLeading = leading != null || showBackButton;

    return SliverAppBar(
      toolbarHeight: toolbarHeight,
      expandedHeight: expandedHeight,
      pinned: pinned,
      floating: floating,
      snap: snap,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: YanoljaColors.shadow,
      backgroundColor: backgroundColor,
      surfaceTintColor: backgroundColor,
      foregroundColor: foregroundColor,
      leadingWidth: hasLeading ? 60 : null,
      leading: leading ?? _buildDefaultLeading(context),
      automaticallyImplyLeading: false,
      titleSpacing: hasLeading ? 0 : 20,
      centerTitle: false,
      title: Opacity(
        opacity: titleOpacity.clamp(0.0, 1.0).toDouble(),
        child: _YanoljaAppBarTitle(
          title: title,
          subtitle: subtitle,
          variant: variant,
          color: foregroundColor,
        ),
      ),
      actions: _withActionGap(actions),
      flexibleSpace: flexibleSpace,
      bottom: bottom,
    );
  }

  Widget? _buildDefaultLeading(BuildContext context) {
    if (!showBackButton) return null;
    return IconButton(
      tooltip: useCloseButton ? '닫기' : '뒤로',
      icon: Icon(
        useCloseButton ? Icons.close_rounded : Icons.arrow_back_ios_new_rounded,
        size: useCloseButton ? 24 : 20,
      ),
      onPressed: () => _handleBack(context),
    );
  }

  void _handleBack(BuildContext context) {
    if (onBackPress != null) {
      onBackPress!();
      return;
    }
    HapticFeedback.selectionClick();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(fallbackRoute ?? '/home');
    }
  }
}

class _YanoljaAppBarTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final YanoljaAppBarVariant variant;
  final Color color;

  const _YanoljaAppBarTitle({
    required this.title,
    required this.subtitle,
    required this.variant,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final titleSize = switch (variant) {
      YanoljaAppBarVariant.main => 24.0,
      YanoljaAppBarVariant.sub => 21.0,
      YanoljaAppBarVariant.detail => 19.0,
      YanoljaAppBarVariant.modal => 19.0,
    };

    final titleWidget = Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: titleSize,
        fontWeight: FontWeight.w900,
        color: color,
        height: 1.08,
      ),
    );

    if (subtitle == null || subtitle!.isEmpty) {
      return titleWidget;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleWidget,
        const SizedBox(height: 3),
        Text(
          subtitle!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: color.withValues(alpha: 0.62),
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

List<Widget>? _withActionGap(List<Widget>? actions) {
  if (actions == null || actions.isEmpty) return actions;
  return [
    ...actions,
    const SizedBox(width: 6),
  ];
}
