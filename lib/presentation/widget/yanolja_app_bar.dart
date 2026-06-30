import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';

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

  /// 리딩(뒤로가기) 버튼을 배경·테두리 없는 플레인 아이콘으로 렌더할지 여부.
  final bool flatLeading;

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
    this.flatLeading = false,
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
        variant = YanoljaAppBarVariant.main,
        flatLeading = false;

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
    this.flatLeading = false,
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
        variant = YanoljaAppBarVariant.modal,
        flatLeading = false;

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
      leadingWidth: hasLeading ? 60 : null,
      leading: leading ?? _buildDefaultLeading(context),
      automaticallyImplyLeading: false,
      titleSpacing: hasLeading ? 0 : 20,
      centerTitle: false,
      title: Opacity(
        opacity: titleOpacity.clamp(0.0, 1.0).toDouble(),
        child: YanoljaEntrance(
          duration: YanoljaMotion.base,
          beginOffset: const Offset(0, 0.025),
          child: _YanoljaAppBarTitle(
            title: title,
            subtitle: subtitle,
            variant: variant,
            color: foregroundColor,
          ),
        ),
      ),
      actions: _buildActions(),
      bottom: bottom,
    );
  }

  List<Widget>? _buildActions() {
    final mergedActions = <Widget>[
      if (actions != null) ...actions!,
      if (variant == YanoljaAppBarVariant.main) const _YanoljaAllMenuAction(),
    ];

    if (mergedActions.isEmpty) return null;

    return [
      ...mergedActions,
      const SizedBox(width: 6),
    ];
  }

  Widget? _buildDefaultLeading(BuildContext context) {
    if (!showBackButton) return null;
    return _YanoljaBackButton(
      useCloseButton: useCloseButton,
      flat: flatLeading,
      onPressed: () => _handleBack(context),
    );
  }

  void _handleBack(BuildContext context) {
    HapticFeedback.selectionClick();
    if (onBackPress != null) {
      onBackPress!();
      return;
    }
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
        child: YanoljaEntrance(
          duration: YanoljaMotion.base,
          beginOffset: const Offset(0, 0.025),
          child: _YanoljaAppBarTitle(
            title: title,
            subtitle: subtitle,
            variant: variant,
            color: foregroundColor,
          ),
        ),
      ),
      actions: _buildActions(),
      flexibleSpace: flexibleSpace,
      bottom: bottom,
    );
  }

  List<Widget>? _buildActions() {
    final mergedActions = <Widget>[
      if (actions != null) ...actions!,
      if (variant == YanoljaAppBarVariant.main) const _YanoljaAllMenuAction(),
    ];

    if (mergedActions.isEmpty) return null;

    return [
      ...mergedActions,
      const SizedBox(width: 6),
    ];
  }

  Widget? _buildDefaultLeading(BuildContext context) {
    if (!showBackButton) return null;
    return _YanoljaBackButton(
      useCloseButton: useCloseButton,
      onPressed: () => _handleBack(context),
    );
  }

  void _handleBack(BuildContext context) {
    HapticFeedback.selectionClick();
    if (onBackPress != null) {
      onBackPress!();
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(fallbackRoute ?? '/home');
    }
  }
}

class _YanoljaBackButton extends StatelessWidget {
  final bool useCloseButton;
  final bool flat;
  final VoidCallback onPressed;

  const _YanoljaBackButton({
    required this.useCloseButton,
    required this.onPressed,
    this.flat = false,
  });

  @override
  Widget build(BuildContext context) {
    final icon =
        useCloseButton ? Icons.close_rounded : Icons.arrow_back_ios_new_rounded;
    final label = useCloseButton ? '닫기' : '이전 화면';

    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Center(
        child: Tooltip(
          message: label,
          child: Semantics(
            button: true,
            label: label,
            child: YanoljaPressable(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(YanoljaRadius.squircle),
              pressedScale: 0.94,
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: flat
                    ? null
                    : BoxDecoration(
                        color: YanoljaColors.surfaceAlt,
                        borderRadius:
                            BorderRadius.circular(YanoljaRadius.squircle),
                        border: Border.all(color: YanoljaColors.border),
                      ),
                child: Icon(
                  icon,
                  size: flat ? 22 : (useCloseButton ? 22 : 18),
                  color: YanoljaColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
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

class _YanoljaAllMenuAction extends StatelessWidget {
  const _YanoljaAllMenuAction();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '전체메뉴',
      child: Semantics(
        button: true,
        label: '전체메뉴 열기',
        child: YanoljaPressable(
          onTap: () {
            HapticFeedback.selectionClick();
            context.push('/all-categories');
          },
          borderRadius: BorderRadius.circular(YanoljaRadius.squircle),
          pressedScale: 0.94,
          child: Container(
            width: 38,
            height: 38,
            // 화면 우측 끝과 너무 붙지 않도록 여백 확보.
            // 기본 trailing(SizedBox 6) + 우측 14 = 화면 끝에서 20px,
            // 좌측 titleSpacing(20) 및 본문 패딩(20)과 시각적으로 정렬된다.
            margin: const EdgeInsets.only(left: 2, right: 14),
            // 배경색·테두리·그림자 없이 아이콘만 노출한다.
            alignment: Alignment.center,
            child: const Icon(
              Icons.menu_rounded,
              // 헤더의 다른 액션 아이콘과 동일하게: 검은색·size 24.
              color: YanoljaColors.textPrimary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
