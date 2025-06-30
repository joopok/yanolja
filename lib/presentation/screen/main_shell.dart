import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _buildMaterial3NavigationBar(context, theme),
    );
  }

  Widget _buildMaterial3NavigationBar(BuildContext context, ThemeData theme) {
    return NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) => _onTap(context, index),
      backgroundColor: theme.navigationBarTheme.backgroundColor,
      surfaceTintColor: theme.navigationBarTheme.surfaceTintColor,
      elevation: theme.navigationBarTheme.elevation,
      height: theme.navigationBarTheme.height,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home_rounded),
          label: '홈',
        ),
        NavigationDestination(
          icon: const Icon(Icons.search_outlined),
          selectedIcon: const Icon(Icons.search_rounded),
          label: '검색',
        ),
        NavigationDestination(
          icon: const Icon(Icons.favorite_border_outlined),
          selectedIcon: const Icon(Icons.favorite_rounded),
          label: '찜',
        ),
        NavigationDestination(
          icon: const Icon(Icons.calendar_today_outlined),
          selectedIcon: const Icon(Icons.calendar_today_rounded),
          label: '예약',
        ),
        NavigationDestination(
          icon: const Icon(Icons.more_horiz_outlined),
          selectedIcon: const Icon(Icons.more_horiz_rounded),
          label: '더보기',
        ),
      ],
    );
  }

  Widget _buildModernBottomNav(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          // Glass morphism 효과를 위한 그림자
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 32,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          // Glass morphism 배경
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.95),
                Colors.white.withValues(alpha: 0.85),
                Colors.grey.shade50.withValues(alpha: 0.9),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
            // Subtle inner border
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: SafeArea(
            top: false,
            child: Container(
              height: 76,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    context: context,
                    index: 0,
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: '홈',
                    isSelected: navigationShell.currentIndex == 0,
                    theme: theme,
                  ),
                  _buildNavItem(
                    context: context,
                    index: 1,
                    icon: Icons.search_outlined,
                    activeIcon: Icons.search_rounded,
                    label: '검색',
                    isSelected: navigationShell.currentIndex == 1,
                    theme: theme,
                  ),
                  // Floating center button
                  _buildCenterFloatingButton(context, theme),
                  _buildNavItem(
                    context: context,
                    index: 2,
                    icon: Icons.favorite_border_outlined,
                    activeIcon: Icons.favorite_rounded,
                    label: '찜',
                    isSelected: navigationShell.currentIndex == 2,
                    theme: theme,
                  ),
                  _buildNavItem(
                    context: context,
                    index: 3,
                    icon: Icons.person_outline,
                    activeIcon: Icons.person_rounded,
                    label: '내 정보',
                    isSelected: navigationShell.currentIndex == 3,
                    theme: theme,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterFloatingButton(BuildContext context, ThemeData theme) {
    final isSelected = navigationShell.currentIndex == 4;
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: GestureDetector(
            onTap: () => _onTap(context, 4),
            child: Container(
              width: 56,
              height: 56,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected 
                      ? [
                          const Color(0xFF6C63FF),
                          const Color.fromARGB(255, 37, 4, 249),
                          const Color.fromARGB(255, 1, 79, 246),
                        ]
                      : [
                          const Color(0xFF6B7280),
                          const Color(0xFF9CA3AF),
                        ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isSelected 
                        ? const Color(0xFF6366F1) 
                        : const Color(0xFF6B7280)
                    ).withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? Icons.more_horiz_rounded : Icons.more_horiz_outlined,
                    key: ValueKey(isSelected),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required ThemeData theme,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTap(context, index),
          borderRadius: BorderRadius.circular(20),
          splashColor: theme.colorScheme.primary.withValues(alpha: 0.12),
          highlightColor: theme.colorScheme.primary.withValues(alpha: 0.08),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isSelected 
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Modern icon container
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  tween: Tween(begin: 0, end: isSelected ? 1 : 0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 1 + (0.1 * value),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected 
                              ? theme.colorScheme.primary.withValues(alpha: 0.15)
                              : Colors.transparent,
                        ),
                        child: Icon(
                          isSelected ? activeIcon : icon,
                          size: 24,
                          color: isSelected 
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                // Modern label
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected 
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    letterSpacing: -0.2,
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Modern indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  margin: const EdgeInsets.only(top: 2),
                  width: isSelected ? 4 : 0,
                  height: isSelected ? 4 : 0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
} 