import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';

/// NOL(야놀자) 스타일 메인 셸
///
/// 실제 NOL 앱처럼 플랫한 흰색 하단 탭바를 사용합니다.
/// - 탭: 검색 / 내주변 / 홈 / 찜 / 마이
/// - 선택 시 진한 텍스트, 미선택 시 회색
/// - 상단 헤어라인 구분선, 부동 버튼/글래스 효과 없음
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

  /// 화면에 노출되는 탭 정의 (branch: 라우터 브랜치 인덱스)
  static const List<_NavTab> _tabs = [
    _NavTab(
      branch: 1,
      icon: Icons.search_rounded,
      activeIcon: Icons.search_rounded,
      label: '검색',
    ),
    _NavTab(
      branch: 2,
      icon: Icons.near_me_outlined,
      activeIcon: Icons.near_me_rounded,
      label: '내주변',
    ),
    _NavTab(
      branch: 0,
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: '홈',
    ),
    _NavTab(
      branch: 3,
      icon: Icons.favorite_border_rounded,
      activeIcon: Icons.favorite_rounded,
      label: '찜',
    ),
    _NavTab(
      branch: 4,
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: '마이',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: navigationShell,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
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
          height: 58,
          child: Row(
            children: _tabs.map((tab) {
              final isSelected = navigationShell.currentIndex == tab.branch;
              return Expanded(
                child: _NavItem(
                  tab: tab,
                  isSelected: isSelected,
                  onTap: () => _onTap(tab.branch),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _onTap(int branchIndex) {
    HapticFeedback.selectionClick();
    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }
}

class _NavTab {
  final int branch;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavTab({
    required this.branch,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _NavItem extends StatelessWidget {
  final _NavTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? YanoljaColors.textPrimary : YanoljaColors.textSecondary;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: isSelected ? 1.04 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: Icon(
              isSelected ? tab.activeIcon : tab.icon,
              size: 25,
              color: color,
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
