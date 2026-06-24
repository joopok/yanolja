import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';

/// NOL 스타일 하단 탭바.
///
/// StatefulShellRoute 안에서는 [onBranchTap]으로 branch 전환을 위임하고,
/// 일반 상세/카테고리 화면에서는 각 탭의 루트 경로로 이동합니다.
class YanoljaBottomNav extends StatelessWidget {
  final int selectedBranchIndex;
  final ValueChanged<int>? onBranchTap;

  const YanoljaBottomNav({
    super.key,
    required this.selectedBranchIndex,
    this.onBranchTap,
  });

  static const List<_YanoljaNavTab> _tabs = [
    _YanoljaNavTab(
      branch: 1,
      path: '/search',
      icon: Icons.search_rounded,
      activeIcon: Icons.search_rounded,
      label: '검색',
    ),
    _YanoljaNavTab(
      branch: 2,
      path: '/nearby',
      icon: Icons.near_me_outlined,
      activeIcon: Icons.near_me_rounded,
      label: '내주변',
    ),
    _YanoljaNavTab(
      branch: 0,
      path: '/home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: '홈',
    ),
    _YanoljaNavTab(
      branch: 3,
      path: '/saved',
      icon: Icons.favorite_border_rounded,
      activeIcon: Icons.favorite_rounded,
      label: '찜',
    ),
    _YanoljaNavTab(
      branch: 4,
      path: '/my-info',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: '마이',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: YanoljaColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: _tabs.map((tab) {
              final isSelected = selectedBranchIndex == tab.branch;
              return Expanded(
                child: _YanoljaNavItem(
                  tab: tab,
                  isSelected: isSelected,
                  onTap: () => _handleTap(context, tab),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, _YanoljaNavTab tab) {
    HapticFeedback.selectionClick();
    final callback = onBranchTap;
    if (callback != null) {
      callback(tab.branch);
      return;
    }
    context.go(tab.path);
  }
}

class _YanoljaNavTab {
  final int branch;
  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _YanoljaNavTab({
    required this.branch,
    required this.path,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _YanoljaNavItem extends StatelessWidget {
  final _YanoljaNavTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _YanoljaNavItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? YanoljaColors.primary : YanoljaColors.textSecondary;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: isSelected ? 1.04 : 1.0,
            duration: YanoljaMotion.base,
            curve: YanoljaMotion.curve,
            child: AnimatedContainer(
              duration: YanoljaMotion.base,
              curve: YanoljaMotion.curve,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 12 : 0,
                vertical: isSelected ? 4 : 0,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? YanoljaColors.primaryLight
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                border: Border.all(
                  color: isSelected
                      ? YanoljaColors.primary.withValues(alpha: 0.12)
                      : Colors.transparent,
                ),
              ),
              child: Icon(
                isSelected ? tab.activeIcon : tab.icon,
                size: 25,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tab.label,
            style: TextStyle(
              fontSize: 11,
              height: 1.0,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              color: color,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
