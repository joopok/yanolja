import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

class MainShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late AnimationController _navAnimationController;
  late AnimationController _pulseController;
  
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _navScaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // 🎬 TikTok/Instagram 스타일 애니메이션 초기화
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fabScaleAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    );

    _navAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _navScaleAnimation = CurvedAnimation(
      parent: _navAnimationController,
      curve: Curves.easeOutBack,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // 🎪 애니메이션 시작
    _navAnimationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _navAnimationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _goToBranch(int index) {
    // Instagram 스타일 햅틱 피드백
    HapticFeedback.selectionClick();
    
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: widget.navigationShell,
      extendBody: true, // Material 3 스타일
      bottomNavigationBar: _buildGlassMorphismNavBar(theme),
      floatingActionButton: _buildTikTokStyleFAB(theme),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  /// 🌟 Glass Morphism Navigation Bar
  Widget _buildGlassMorphismNavBar(ThemeData theme) {
    return ScaleTransition(
      scale: _navScaleAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.1),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              // 🎨 투명도 높여서 더 선명한 배경
              color: theme.colorScheme.surface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
                width: 1.5,
              ),
              // 🌟 더 세련된 그림자 효과
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: NavigationBar(
              height: 80,
              elevation: 0,
              backgroundColor: Colors.transparent,
              indicatorColor: theme.colorScheme.primaryContainer.withOpacity(0.8),
              surfaceTintColor: Colors.transparent,
              selectedIndex: widget.navigationShell.currentIndex,
              onDestinationSelected: _goToBranch,
              destinations: [
                _buildAnimatedDestination(
                  context: context,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: '홈',
                  index: 0,
                ),
                _buildAnimatedDestination(
                  context: context,
                  icon: Icons.search_outlined,
                  selectedIcon: Icons.search_rounded,
                  label: '검색',
                  index: 1,
                ),
                const SizedBox.shrink(), // FAB 공간
                _buildAnimatedDestination(
                  context: context,
                  icon: Icons.hotel_outlined,
                  selectedIcon: Icons.hotel_rounded,
                  label: '호텔',
                  index: 2,
                ),
                _buildAnimatedDestination(
                  context: context,
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  label: '마이',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🎯 Instagram 스타일 애니메이션 목적지
  NavigationDestination _buildAnimatedDestination({
    required BuildContext context,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = widget.navigationShell.currentIndex == index;
    final theme = Theme.of(context);
    
    return NavigationDestination(
      icon: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.9 + (0.2 * value),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isSelected 
                    ? Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        width: 1,
                      )
                    : null,
              ),
              child: Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
          );
        },
      ),
      selectedIcon: Icon(selectedIcon),
      label: label,
    );
  }

  /// 🚀 TikTok 스타일 Floating Action Button
  Widget _buildTikTokStyleFAB(ThemeData theme) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6C63FF),
                  Color.fromARGB(255, 37, 4, 249),
                  Color.fromARGB(255, 1, 79, 246),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: theme.colorScheme.secondary.withOpacity(0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () => _showTikTokStyleMenuSheet(context),
              backgroundColor: Colors.transparent,
              elevation: 0,
              splashColor: Colors.white.withOpacity(0.3),
              highlightElevation: 0,
              child: Stack(
                children: [
                  // 배경 글로우 효과
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 아이콘
                  const Center(
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 🎪 TikTok 스타일 메뉴 시트
  void _showTikTokStyleMenuSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      builder: (context) => _buildInstagramStyleBottomSheet(context),
    );
  }

  /// 📱 Instagram 스타일 바텀시트
  Widget _buildInstagramStyleBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 300),
          child: Opacity(
            opacity: value,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 핸들바
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // 헤더
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF6C63FF),
                                Color.fromARGB(255, 37, 4, 249),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.menu_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '더 많은 기능',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 메뉴 그리드
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GridView.count(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _buildMenuCard(
                            context,
                            icon: Icons.favorite_outline_rounded,
                            title: '찜한 숙소',
                            subtitle: '내가 찜한 숙소들',
                            color: const Color(0xFFE91E63),
                            onTap: () {
                              Navigator.pop(context);
                              _showComingSoonDialog(context, '찜한 숙소');
                            },
                          ),
                          _buildMenuCard(
                            context,
                            icon: Icons.history_rounded,
                            title: '예약 내역',
                            subtitle: '나의 예약 기록',
                            color: const Color(0xFF2196F3),
                            onTap: () {
                              Navigator.pop(context);
                              _showComingSoonDialog(context, '예약 내역');
                            },
                          ),
                          _buildMenuCard(
                            context,
                            icon: Icons.card_giftcard_rounded,
                            title: '쿠폰함',
                            subtitle: '할인 쿠폰 모음',
                            color: const Color(0xFF4CAF50),
                            onTap: () {
                              Navigator.pop(context);
                              _showComingSoonDialog(context, '쿠폰함');
                            },
                          ),
                          _buildMenuCard(
                            context,
                            icon: Icons.support_agent_rounded,
                            title: '고객센터',
                            subtitle: '문의 및 도움말',
                            color: const Color(0xFFFF9800),
                            onTap: () {
                              Navigator.pop(context);
                              _showComingSoonDialog(context, '고객센터');
                            },
                          ),
                          _buildMenuCard(
                            context,
                            icon: Icons.settings_outlined,
                            title: '설정',
                            subtitle: '앱 환경설정',
                            color: const Color(0xFF607D8B),
                            onTap: () {
                              Navigator.pop(context);
                              _showComingSoonDialog(context, '설정');
                            },
                          ),
                          _buildMenuCard(
                            context,
                            icon: Icons.info_outline_rounded,
                            title: '앱 정보',
                            subtitle: '버전 및 정보',
                            color: const Color(0xFF9C27B0),
                            onTap: () {
                              Navigator.pop(context);
                              _showComingSoonDialog(context, '앱 정보');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 🎨 Instagram 스타일 메뉴 카드
  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onTap();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: color.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    HapticFeedback.mediumImpact();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기능 준비중'),
        content: Text('$feature 기능을 준비중입니다.\n조금만 기다려주세요! 🚀'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
} 