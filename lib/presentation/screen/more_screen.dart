import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';

class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanoljaColors.background,
      appBar: AppBar(
        title: const Text('더보기'),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildPromotionBanner(),

          // 빠른 서비스 (그리드)
          const YanoljaSectionHeader(
            title: '빠른 서비스',
            subtitle: '자주 사용하는 편리한 기능',
          ),
          _buildQuickServiceGrid(),

          _sectionGap(),

          // 여행 서비스
          const YanoljaSectionHeader(title: '여행 서비스'),
          _buildServiceList(const [
            _ServiceData(
              icon: Icons.map_outlined,
              title: '여행지 가이드',
              subtitle: '숨겨진 명소 찾기',
              badge: '추천',
            ),
            _ServiceData(
              icon: Icons.camera_alt_outlined,
              title: '포토스팟',
              subtitle: '인생샷 찍기 좋은 곳',
            ),
            _ServiceData(
              icon: Icons.restaurant_outlined,
              title: '맛집 추천',
              subtitle: '현지 맛집 베스트',
              badge: 'HOT',
            ),
            _ServiceData(
              icon: Icons.local_activity_outlined,
              title: '액티비티',
              subtitle: '특별한 체험 예약',
            ),
          ]),

          _sectionGap(),

          // 비즈니스 서비스
          const YanoljaSectionHeader(title: '비즈니스 서비스'),
          _buildServiceList(const [
            _ServiceData(
              icon: Icons.meeting_room_outlined,
              title: '회의실 예약',
              subtitle: '비즈니스 미팅공간',
            ),
            _ServiceData(
              icon: Icons.print_outlined,
              title: '문서 서비스',
              subtitle: '인쇄, 팩스, 스캔',
            ),
            _ServiceData(
              icon: Icons.wifi_tethering_rounded,
              title: '컨퍼런스',
              subtitle: '화상회의 지원',
            ),
            _ServiceData(
              icon: Icons.account_balance_outlined,
              title: '법인카드',
              subtitle: '비즈니스 결제 솔루션',
            ),
          ]),

          _sectionGap(),

          // 고객 지원
          const YanoljaSectionHeader(title: '고객 지원'),
          _buildServiceList(const [
            _ServiceData(
              icon: Icons.chat_bubble_outline_rounded,
              title: '24시간 채팅',
              subtitle: '실시간 고객상담',
              badge: 'LIVE',
            ),
            _ServiceData(
              icon: Icons.phone_outlined,
              title: '전화 상담',
              subtitle: '1588-1234',
            ),
            _ServiceData(
              icon: Icons.help_outline_rounded,
              title: 'FAQ',
              subtitle: '자주 묻는 질문',
            ),
            _ServiceData(
              icon: Icons.feedback_outlined,
              title: '의견 보내기',
              subtitle: '서비스 개선 제안',
            ),
          ]),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // 섹션 사이 회색 띠 구분
  Widget _sectionGap() {
    return Container(height: 8, color: YanoljaColors.surfaceAlt);
  }

  // 상단 프로모션 배너 (핑크 틴트, 플랫)
  Widget _buildPromotionBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: YanoljaColors.primaryLight,
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          border: Border.all(color: YanoljaColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: YanoljaColors.primary,
                borderRadius: BorderRadius.circular(YanoljaRadius.md),
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '첫 예약 특가',
                    style: TextStyle(
                      color: YanoljaColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    '최대 50% 할인 + 무료 쿠폰팩',
                    style: TextStyle(
                      color: YanoljaColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _showPromotionDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: YanoljaColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(YanoljaRadius.sm),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
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
    );
  }

  // 빠른 서비스 4열 그리드 (플랫 아이콘 + 라벨)
  Widget _buildQuickServiceGrid() {
    const items = <_QuickServiceData>[
      _QuickServiceData(icon: Icons.qr_code_scanner_rounded, label: 'QR체크인', isNew: true),
      _QuickServiceData(icon: Icons.directions_car_rounded, label: '렌터카'),
      _QuickServiceData(icon: Icons.local_taxi_rounded, label: '택시호출', isHot: true),
      _QuickServiceData(icon: Icons.flight_takeoff_rounded, label: '항공편'),
      _QuickServiceData(icon: Icons.train_rounded, label: 'KTX'),
      _QuickServiceData(icon: Icons.local_shipping_rounded, label: '짐배송', isNew: true),
      _QuickServiceData(icon: Icons.wifi_rounded, label: '와이파이'),
      _QuickServiceData(icon: Icons.translate_rounded, label: '번역'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        mainAxisSpacing: 20,
        crossAxisSpacing: 12,
        childAspectRatio: 0.82,
        children: items
            .map((item) => _buildQuickServiceItem(item))
            .toList(),
      ),
    );
  }

  Widget _buildQuickServiceItem(_QuickServiceData data) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showServiceDialog(data.label);
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: YanoljaColors.primaryLight,
                  borderRadius: BorderRadius.circular(YanoljaRadius.md),
                ),
                child: Icon(
                  data.icon,
                  color: YanoljaColors.primary,
                  size: 26,
                ),
              ),
              if (data.isNew || data.isHot)
                Positioned(
                  top: -4,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: YanoljaColors.primary,
                      borderRadius: BorderRadius.circular(YanoljaRadius.sm),
                    ),
                    child: Text(
                      data.isNew ? 'NEW' : 'HOT',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: YanoljaColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 야놀자식 설정 리스트 (ListTile 스타일 + 얇은 divider)
  Widget _buildServiceList(List<_ServiceData> services) {
    return Column(
      children: [
        for (int i = 0; i < services.length; i++) ...[
          _buildServiceListItem(services[i]),
          if (i != services.length - 1)
            const Divider(
              height: 1,
              thickness: 1,
              indent: 72,
              endIndent: 20,
              color: YanoljaColors.divider,
            ),
        ],
      ],
    );
  }

  Widget _buildServiceListItem(_ServiceData data) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _showServiceDialog(data.title);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: YanoljaColors.surfaceAlt,
                borderRadius: BorderRadius.circular(YanoljaRadius.sm),
              ),
              child: Icon(
                data.icon,
                color: YanoljaColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        data.title,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: YanoljaColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (data.badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: YanoljaColors.primaryLight,
                            borderRadius:
                                BorderRadius.circular(YanoljaRadius.sm),
                          ),
                          child: Text(
                            data.badge!,
                            style: const TextStyle(
                              color: YanoljaColors.primary,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: YanoljaColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: YanoljaColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showServiceDialog(String serviceName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: YanoljaColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: YanoljaColors.primaryLight,
                  borderRadius: BorderRadius.circular(YanoljaRadius.md),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: YanoljaColors.primary,
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
                    color: YanoljaColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            '$serviceName 서비스가 곧 출시됩니다!\n더 나은 서비스로 찾아뵙겠습니다.',
            style: const TextStyle(
              fontSize: 15,
              color: YanoljaColors.textSecondary,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '알림 받기',
                style: TextStyle(color: YanoljaColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: YanoljaColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(YanoljaRadius.sm),
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
          backgroundColor: YanoljaColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.card_giftcard_rounded,
                color: YanoljaColors.primary,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                '축하합니다!',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: YanoljaColors.textPrimary,
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
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: YanoljaColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• 최대 50% 할인 쿠폰\n• 무료 배송 쿠폰\n• VIP 멤버십 1개월',
                style: TextStyle(
                  fontSize: 14,
                  color: YanoljaColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '나중에',
                style: TextStyle(color: YanoljaColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSnackBar('쿠폰이 쿠폰함에 저장되었습니다!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: YanoljaColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(YanoljaRadius.sm),
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
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: YanoljaColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(YanoljaRadius.sm),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// 빠른 서비스 그리드 아이템 데이터
class _QuickServiceData {
  final IconData icon;
  final String label;
  final bool isNew;
  final bool isHot;

  const _QuickServiceData({
    required this.icon,
    required this.label,
    this.isNew = false,
    this.isHot = false,
  });
}

/// 설정 리스트 항목 데이터
class _ServiceData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;

  const _ServiceData({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
  });
}
