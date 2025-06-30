import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/presentation/provider/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _menuAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _menuAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _menuAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );
    _menuAnimation = CurvedAnimation(
      parent: _menuAnimationController,
      curve: Curves.easeOutQuart,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    );

    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _menuAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _menuAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: authState.when(
        data: (user) {
          if (user != null) {
            // 로그인 상태
            return CustomScrollView(
              slivers: [
                // Modern Profile Header
                SliverAppBar(
                  expandedHeight: 280,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildModernProfileHeader(user.email ?? '사용자'),
                    collapseMode: CollapseMode.pin,
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -30),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFFAFBFC),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildQuickActions(),
                          const SizedBox(height: 28),
                          _buildStatsSection(),
                          const SizedBox(height: 28),
                          _buildMainMenu(),
                          const SizedBox(height: 100),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: _buildLogoutButton(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // 로그아웃 상태
            return _buildLoggedOutView(context, theme);
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('오류 발생: $error')),
      ),
    );
  }

  Widget _buildModernProfileHeader(String userEmail) {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6C63FF).withOpacity(_headerAnimation.value),
                const Color.fromARGB(255, 37, 4, 249).withOpacity(_headerAnimation.value),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background Pattern
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1557683316-973673baf926?w=500',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Glass overlay
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),
              ),
              // Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Profile Row
                      Row(
                        children: [
                          // Profile Image
                          Hero(
                            tag: 'profile-image',
                            child: Transform.scale(
                              scale: _headerAnimation.value,
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&w=1780&auto=format&fit=crop',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          // User Info
                          Expanded(
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userEmail.split('@')[0], // 이메일 앞부분만 표시
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userEmail,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.2),
                                          Colors.white.withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.workspace_premium,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'VIP 회원',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      // Member Info
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildInfoItem('가입일', '2024.01.15'),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white.withOpacity(0.2),
                              ),
                              _buildInfoItem('회원등급', 'VIP'),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white.withOpacity(0.2),
                              ),
                              _buildInfoItem('누적 예약', '24회'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return AnimatedBuilder(
      animation: _menuAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _menuAnimation.value)),
          child: Opacity(
            opacity: _menuAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.edit_note_rounded,
                      label: '프로필 수정',
                      gradient: const [Color(0xFF667EEA), Color(0xFF764BA2)],
                      onTap: () => _handleProfileEdit(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.favorite_rounded,
                      label: '찜한 숙소',
                      gradient: const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                      onTap: () => context.push('/saved'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.receipt_long_rounded,
                      label: '예약 내역',
                      gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                      onTap: () => context.push('/bookings'),
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

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return AnimatedBuilder(
      animation: _menuAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _menuAnimation.value)),
          child: Opacity(
            opacity: _menuAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '나의 여행 통계',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.hotel_rounded,
                          value: '24',
                          label: '총 예약',
                          color: const Color(0xFF5E72E4),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 60,
                        color: Colors.grey[200],
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.star_rounded,
                          value: '4.8',
                          label: '평균 평점',
                          color: const Color(0xFFFFB74D),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 60,
                        color: Colors.grey[200],
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.loyalty_rounded,
                          value: '15.2K',
                          label: '포인트',
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMainMenu() {
    final menuItems = [
      {
        'icon': Icons.campaign_rounded,
        'title': '공지사항',
        'subtitle': '새로운 소식을 확인하세요',
        'color': const Color(0xFF5E72E4),
      },
      {
        'icon': Icons.local_offer_rounded,
        'title': '이벤트 & 쿠폰',
        'subtitle': '진행 중인 이벤트 3개',
        'color': const Color(0xFFFF6B6B),
      },
      {
        'icon': Icons.support_agent_rounded,
        'title': '고객센터',
        'subtitle': '24시간 상담 가능',
        'color': const Color(0xFF10B981),
      },
      {
        'icon': Icons.shield_rounded,
        'title': '개인정보 보호',
        'subtitle': '보안 설정 관리',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'icon': Icons.settings_rounded,
        'title': '앱 설정',
        'subtitle': '알림 및 계정 설정',
        'color': const Color(0xFF6B7280),
      },
    ];

    return AnimatedBuilder(
      animation: _menuAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _menuAnimation.value)),
          child: Opacity(
            opacity: _menuAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: menuItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return _buildMenuItem(
                    icon: item['icon'] as IconData,
                    title: item['title'] as String,
                    subtitle: item['subtitle'] as String,
                    color: item['color'] as Color,
                    isLast: index == menuItems.length - 1,
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _showSnackBar(title);
        },
        borderRadius: isLast
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              )
            : BorderRadius.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.1),
                      color.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Consumer(builder: (context, ref, child) {
      return Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              _showLogoutDialog(context, ref);
            },
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '로그아웃',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void _handleProfileEdit() {
    _showSnackBar('프로필 수정');
  }

  void _handleFavorites() {
    _showSnackBar('찜한 숙소');
  }

  void _handleBookingHistory() {
    _showSnackBar('예약 내역');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              '$message 페이지로 이동합니다.',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            '로그아웃',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          content: const Text(
            '정말 로그아웃 하시겠습니까?',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(authProvider).signOut();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  _showSnackBar('로그아웃되었습니다');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('로그아웃'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoggedOutView(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.lock_outline_rounded, size: 80, color: theme.colorScheme.secondary),
          const SizedBox(height: 16),
          Text(
            '로그인이 필요해요',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '로그인하고 찜 목록과 예약 내역을 관리하세요.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () => context.push('/login'),
            child: const Text('로그인'),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context.push('/signup'),
            child: const Text('회원가입'),
          ),
        ],
      ),
    );
  }
}
