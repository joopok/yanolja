import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';

class MainShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  void _goToBranch(int index) {
    HapticFeedback.selectionClick();

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanoljaColors.background,
      body: widget.navigationShell,
      bottomNavigationBar: _buildNavBar(),
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  /// 🌸 야놀자 플랫 하단 네비게이션 바
  Widget _buildNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: YanoljaColors.surface,
        border: Border(
          top: BorderSide(color: YanoljaColors.border, width: 1),
        ),
      ),
      child: NavigationBar(
        height: 64,
        elevation: 0,
        backgroundColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: _goToBranch,
        destinations: [
          _buildDestination(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: '홈',
            index: 0,
          ),
          _buildDestination(
            icon: Icons.search_outlined,
            selectedIcon: Icons.search_rounded,
            label: '검색',
            index: 1,
          ),
          const SizedBox.shrink(), // FAB 공간
          _buildDestination(
            icon: Icons.hotel_outlined,
            selectedIcon: Icons.hotel_rounded,
            label: '호텔',
            index: 2,
          ),
          _buildDestination(
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
            label: '마이',
            index: 3,
          ),
        ],
      ),
    );
  }

  /// 🎯 야놀자 스타일 네비 목적지 (선택 시 핑크 강조)
  NavigationDestination _buildDestination({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = widget.navigationShell.currentIndex == index;

    return NavigationDestination(
      icon: Icon(
        isSelected ? selectedIcon : icon,
        color:
            isSelected ? YanoljaColors.primary : YanoljaColors.textTertiary,
        size: 24,
      ),
      selectedIcon: Icon(
        selectedIcon,
        color: YanoljaColors.primary,
        size: 24,
      ),
      label: label,
    );
  }

  /// 🌸 야놀자 핑크 플로팅 액션 버튼 (플랫)
  Widget _buildFab() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: YanoljaColors.primary,
        boxShadow: [
          BoxShadow(
            color: YanoljaColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _showMenuSheet(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        splashColor: Colors.white.withValues(alpha: 0.2),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  void _showMenuSheet(BuildContext context) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      builder: (context) => _buildBottomSheet(context),
    );
  }

  /// 📱 야놀자 스타일 메뉴 바텀시트 (플랫)
  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: YanoljaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 핸들바
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            decoration: BoxDecoration(
              color: YanoljaColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: YanoljaColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.menu_rounded,
                    color: YanoljaColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  '더 많은 기능',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: YanoljaColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: YanoljaColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 메뉴 그리드
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildMenuCard(
                    context,
                    icon: Icons.favorite_outline_rounded,
                    title: '찜한 숙소',
                    subtitle: '내가 찜한 숙소들',
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
    );
  }

  /// 🎨 야놀자 스타일 메뉴 카드 (플랫 + 헤어라인 보더)
  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: YanoljaColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: YanoljaColors.border, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: YanoljaColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: YanoljaColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: YanoljaColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: YanoljaColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기능 준비중'),
        content: Text('$feature 기능을 준비중입니다.\n조금만 기다려주세요!'),
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
