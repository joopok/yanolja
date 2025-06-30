import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutBack,
    );
    _contentAnimation = CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeOutQuart,
    );

    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _contentAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // 헤더 영역
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(),
              collapseMode: CollapseMode.pin,
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0),
              child: Container(
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
              ),
            ),
          ),

          // 콘텐츠 영역
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFFF8FAFC),
              child: Column(
                children: [
                  _buildQuickServices(),
                  const SizedBox(height: 24),
                  _buildTravelServices(),
                  const SizedBox(height: 24),
                  _buildBusinessServices(),
                  const SizedBox(height: 24),
                  _buildSupportServices(),
                  const SizedBox(height: 24),
                  _buildPromotionBanner(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _headerAnimation.value,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667EEA),
                  Color(0xFF764BA2),
                  Color(0xFF6B73FF),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  
                  // 메인 아이콘
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.widgets_outlined,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 타이틀과 서브타이틀
                  Text(
                    '더 보기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    '여행이 더 쉬워지는 다양한 서비스',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 상태 표시
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatusChip('신규 서비스 4개', Icons.fiber_new_rounded),
                      const SizedBox(width: 16),
                      _buildStatusChip('인기 기능 8개', Icons.trending_up_rounded),
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

  Widget _buildStatusChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickServices() {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _contentAnimation.value)),
          child: Opacity(
            opacity: _contentAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.flash_on_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '빠른 서비스',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              Text(
                                '자주 사용하는 편리한 기능들',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                      children: [
                        _buildQuickServiceItem(
                          icon: Icons.qr_code_scanner_rounded,
                          label: 'QR체크인',
                          color: const Color(0xFF3B82F6),
                          isNew: true,
                        ),
                        _buildQuickServiceItem(
                          icon: Icons.directions_car_rounded,
                          label: '렌터카',
                          color: const Color(0xFF10B981),
                        ),
                        _buildQuickServiceItem(
                          icon: Icons.local_taxi_rounded,
                          label: '택시호출',
                          color: const Color(0xFFFFB74D),
                          isHot: true,
                        ),
                        _buildQuickServiceItem(
                          icon: Icons.flight_takeoff_rounded,
                          label: '항공편',
                          color: const Color(0xFF8B5CF6),
                        ),
                        _buildQuickServiceItem(
                          icon: Icons.train_rounded,
                          label: 'KTX',
                          color: const Color(0xFFEF4444),
                        ),
                        _buildQuickServiceItem(
                          icon: Icons.local_shipping_rounded,
                          label: '짐배송',
                          color: const Color(0xFF06B6D4),
                          isNew: true,
                        ),
                        _buildQuickServiceItem(
                          icon: Icons.wifi_rounded,
                          label: '와이파이',
                          color: const Color(0xFF84CC16),
                        ),
                        _buildQuickServiceItem(
                          icon: Icons.translate_rounded,
                          label: '번역',
                          color: const Color(0xFFF59E0B),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickServiceItem({
    required IconData icon,
    required String label,
    required Color color,
    bool isNew = false,
    bool isHot = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showServiceDialog(label);
      },
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color,
                      color.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              if (isNew || isHot) ...[
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isNew ? const Color(0xFFEF4444) : const Color(0xFFFFB74D),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isNew ? 'NEW' : 'HOT',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTravelServices() {
    return _buildServiceSection(
      title: '여행 서비스',
      subtitle: '여행을 더 편리하게',
      icon: Icons.travel_explore_rounded,
      iconColor: const Color(0xFF10B981),
      services: [
        {
          'icon': Icons.map_outlined,
          'title': '여행지 가이드',
          'subtitle': '숨겨진 명소 찾기',
          'color': const Color(0xFF3B82F6),
          'isRecommended': true,
        },
        {
          'icon': Icons.camera_alt_outlined,
          'title': '포토스팟',
          'subtitle': '인생샷 찍기 좋은 곳',
          'color': const Color(0xFFFF6B6B),
        },
        {
          'icon': Icons.restaurant_outlined,
          'title': '맛집 추천',
          'subtitle': '현지 맛집 베스트',
          'color': const Color(0xFFFFB74D),
          'isHot': true,
        },
        {
          'icon': Icons.local_activity_outlined,
          'title': '액티비티',
          'subtitle': '특별한 체험 예약',
          'color': const Color(0xFF8B5CF6),
        },
      ],
    );
  }

  Widget _buildBusinessServices() {
    return _buildServiceSection(
      title: '비즈니스 서비스',
      subtitle: '출장과 업무를 위한',
      icon: Icons.business_center_rounded,
      iconColor: const Color(0xFF6B7280),
      services: [
        {
          'icon': Icons.meeting_room_outlined,
          'title': '회의실 예약',
          'subtitle': '비즈니스 미팅공간',
          'color': const Color(0xFF1F2937),
        },
        {
          'icon': Icons.print_outlined,
          'title': '문서 서비스',
          'subtitle': '인쇄, 팩스, 스캔',
          'color': const Color(0xFF059669),
        },
        {
          'icon': Icons.wifi_tethering_rounded,
          'title': '컨퍼런스',
          'subtitle': '화상회의 지원',
          'color': const Color(0xFF7C3AED),
        },
        {
          'icon': Icons.account_balance_outlined,
          'title': '법인카드',
          'subtitle': '비즈니스 결제 솔루션',
          'color': const Color(0xFFDC2626),
        },
      ],
    );
  }

  Widget _buildSupportServices() {
    return _buildServiceSection(
      title: '고객 지원',
      subtitle: '언제든 도움을 드려요',
      icon: Icons.headset_mic_rounded,
      iconColor: const Color(0xFFFF6B6B),
      services: [
        {
          'icon': Icons.chat_bubble_outline_rounded,
          'title': '24시간 채팅',
          'subtitle': '실시간 고객상담',
          'color': const Color(0xFF10B981),
          'isLive': true,
        },
        {
          'icon': Icons.phone_outlined,
          'title': '전화 상담',
          'subtitle': '1588-1234',
          'color': const Color(0xFF3B82F6),
        },
        {
          'icon': Icons.help_outline_rounded,
          'title': 'FAQ',
          'subtitle': '자주 묻는 질문',
          'color': const Color(0xFFFFB74D),
        },
        {
          'icon': Icons.feedback_outlined,
          'title': '의견 보내기',
          'subtitle': '서비스 개선 제안',
          'color': const Color(0xFF8B5CF6),
        },
      ],
    );
  }

  Widget _buildServiceSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required List<Map<String, dynamic>> services,
  }) {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _contentAnimation.value)),
          child: Opacity(
            opacity: _contentAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            icon,
                            color: iconColor,
                            size: 24,
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              Text(
                                subtitle,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  ...services.map((service) => _buildServiceListItem(
                    icon: service['icon'] as IconData,
                    title: service['title'] as String,
                    subtitle: service['subtitle'] as String,
                    color: service['color'] as Color,
                    isRecommended: service['isRecommended'] ?? false,
                    isHot: service['isHot'] ?? false,
                    isLive: service['isLive'] ?? false,
                    onTap: () => _showServiceDialog(service['title'] as String),
                  )).toList(),
                  
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildServiceListItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isRecommended = false,
    bool isHot = false,
    bool isLive = false,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      if (isRecommended || isHot || isLive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isLive
                                ? const Color(0xFF10B981)
                                : isHot
                                    ? const Color(0xFFFFB74D)
                                    : const Color(0xFF3B82F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isLive
                                ? 'LIVE'
                                : isHot
                                    ? 'HOT'
                                    : '추천',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
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
              Icons.chevron_right_rounded,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionBanner() {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _contentAnimation.value)),
          child: Opacity(
            opacity: _contentAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFD700),
                    Color(0xFFFFB74D),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB74D).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.card_giftcard_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '첫 예약 특가',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '최대 50% 할인 + 무료 쿠폰팩',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _showPromotionDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFFFB74D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      '받기',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
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

  void _showServiceDialog(String serviceName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF667EEA),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  serviceName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            '$serviceName 서비스가 곧 출시됩니다!\n더 나은 서비스로 찾아뵙겠습니다.',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('알림 받기'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showPromotionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.celebration_rounded,
                color: Color(0xFFFFB74D),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                '축하합니다!',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '첫 예약 특가 쿠폰을 받았습니다!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• 최대 50% 할인 쿠폰\n• 무료 배송 쿠폰\n• VIP 멤버십 1개월',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('나중에'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSnackBar('쿠폰이 쿠폰함에 저장되었습니다!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB74D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('쿠폰 받기'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
} 