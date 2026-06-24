import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/data/model/booking.dart';
import 'package:yanolja_clone/presentation/provider/booking_provider.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_bottom_nav.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';

class BookingScreen extends ConsumerWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: YanoljaColors.surfaceAlt,
        bottomNavigationBar: const YanoljaBottomNav(selectedBranchIndex: 4),
        appBar: YanoljaAppBar.sub(
          title: '예약 내역',
          fallbackRoute: '/my-info',
          actions: [
            IconButton(
              onPressed: () => context.push('/service/support'),
              tooltip: '고객센터',
              icon: const Icon(
                Icons.support_agent_rounded,
                color: YanoljaColors.textPrimary,
                size: 22,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildTabBarHeader(context),
            Expanded(
              child: TabBarView(
                children: [
                  _buildBookingList(
                    context,
                    ref,
                    upcomingBookingsProvider,
                    isUpcoming: true,
                  ),
                  _buildBookingList(
                    context,
                    ref,
                    pastBookingsProvider,
                    isUpcoming: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBarHeader(BuildContext context) {
    return Container(
      color: YanoljaColors.background,
      padding: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Container(
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: YanoljaColors.surfaceAlt,
            borderRadius: BorderRadius.circular(YanoljaRadius.pill),
          ),
          child: TabBar(
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: YanoljaColors.primary,
              borderRadius: BorderRadius.circular(YanoljaRadius.pill),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: YanoljaColors.textSecondary,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            tabs: const [
              Tab(text: '예정된 여행'),
              Tab(text: '지난 여행'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingList(
    BuildContext context,
    WidgetRef ref,
    AutoDisposeProvider<AsyncValue<List<Booking>>> provider, {
    required bool isUpcoming,
  }) {
    final bookingsAsync = ref.watch(provider);

    return bookingsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: YanoljaColors.primary),
      ),
      error: (err, stack) => Center(
        child: Text(
          '예약 내역을 불러올 수 없어요',
          style: TextStyle(color: YanoljaColors.textSecondary),
        ),
      ),
      data: (bookings) {
        if (bookings.isEmpty) {
          return _buildEmptyState(context, isUpcoming: isUpcoming);
        }

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 34),
          children: [
            _BookingSummary(
              count: bookings.length,
              isUpcoming: isUpcoming,
            ),
            const SizedBox(height: 12),
            for (final booking in bookings) _BookingCard(booking: booking),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, {required bool isUpcoming}) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(22, 30, 22, 26),
          decoration: BoxDecoration(
            color: YanoljaColors.background,
            borderRadius: BorderRadius.circular(YanoljaRadius.lg),
            border: Border.all(color: YanoljaColors.border),
          ),
          child: Column(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: YanoljaColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isUpcoming
                      ? Icons.luggage_outlined
                      : Icons.event_available_outlined,
                  size: 34,
                  color: YanoljaColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isUpcoming ? '예정된 여행이 없어요' : '지난 여행이 없어요',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: YanoljaColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '지금 예약 가능한 숙소와 혜택을 바로 확인해보세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: YanoljaColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: YanoljaColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(YanoljaRadius.md),
                    ),
                  ),
                  child: const Text(
                    '숙소 둘러보기',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookingSummary extends StatelessWidget {
  final int count;
  final bool isUpcoming;

  const _BookingSummary({
    required this.count,
    required this.isUpcoming,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: YanoljaColors.background,
        borderRadius: BorderRadius.circular(YanoljaRadius.lg),
        border: Border.all(color: YanoljaColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isUpcoming
                  ? YanoljaColors.primaryLight
                  : YanoljaColors.surfaceAlt,
              borderRadius: BorderRadius.circular(YanoljaRadius.md),
            ),
            child: Icon(
              isUpcoming ? Icons.flight_takeoff_rounded : Icons.history_rounded,
              color: isUpcoming
                  ? YanoljaColors.primary
                  : YanoljaColors.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUpcoming ? '다가오는 여행 $count건' : '이용 완료 $count건',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: YanoljaColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isUpcoming ? '입실 전 예약 정보를 확인하세요' : '다시 예약하기 좋은 숙소를 모았어요',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: YanoljaColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;

  const _BookingCard({required this.booking});

  ({String label, Color color, Color bg}) _statusStyle() {
    switch (booking.status) {
      case 'upcoming':
        return (
          label: '예약완료',
          color: YanoljaColors.primary,
          bg: YanoljaColors.primaryLight,
        );
      case 'completed':
        return (
          label: '이용완료',
          color: YanoljaColors.success,
          bg: const Color(0xFFE7F8F1),
        );
      default:
        return (
          label: '취소완료',
          color: YanoljaColors.textSecondary,
          bg: YanoljaColors.surfaceAlt,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _statusStyle();
    final checkIn = DateFormat('M월 d일').format(booking.checkInDate);
    final checkOut = DateFormat('M월 d일').format(booking.checkOutDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: YanoljaColors.background,
        borderRadius: BorderRadius.circular(YanoljaRadius.lg),
        border: Border.all(color: YanoljaColors.border),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/detail/${booking.accommodationId}');
        },
        borderRadius: BorderRadius.circular(YanoljaRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: status.bg,
                      borderRadius: BorderRadius.circular(YanoljaRadius.sm),
                    ),
                    child: Text(
                      status.label,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        color: status.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Text(
                    'NOL 예약',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: YanoljaColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: YanoljaColors.textTertiary,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(YanoljaRadius.md),
                    child: CachedNetworkImage(
                      imageUrl: booking.imageUrl,
                      width: 92,
                      height: 92,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 92,
                        height: 92,
                        color: YanoljaColors.surfaceAlt,
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 92,
                        height: 92,
                        color: YanoljaColors.surfaceAlt,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: YanoljaColors.textTertiary,
                          size: 27,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.accommodationName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: YanoljaColors.textPrimary,
                            height: 1.25,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: YanoljaColors.textTertiary,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '$checkIn - $checkOut · ${booking.numberOfNights}박',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: YanoljaColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Text(
                              '총 결제금액',
                              style: TextStyle(
                                fontSize: 12,
                                color: YanoljaColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              '${YanoljaFormat.price(booking.totalPrice)}원',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: YanoljaColors.textPrimary,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.push('/service/inquiry'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: YanoljaColors.textPrimary,
                        side: const BorderSide(color: YanoljaColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(YanoljaRadius.sm),
                        ),
                      ),
                      child: const Text(
                        '문의',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.push(
                        '/detail/${booking.accommodationId}',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: YanoljaColors.textPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(YanoljaRadius.sm),
                        ),
                      ),
                      child: const Text(
                        '예약 상세',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
