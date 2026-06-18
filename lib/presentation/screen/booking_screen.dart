import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/data/model/booking.dart';
import 'package:yanolja_clone/presentation/provider/booking_provider.dart';

class BookingScreen extends ConsumerWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: YanoljaColors.background,
        appBar: AppBar(
          title: const Text(
            '내 예약',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          elevation: 0,
          bottom: const TabBar(
            labelColor: YanoljaColors.primary,
            unselectedLabelColor: YanoljaColors.textSecondary,
            indicatorColor: YanoljaColors.primary,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            unselectedLabelStyle:
                TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            tabs: [
              Tab(text: '예정된 여행'),
              Tab(text: '지난 여행'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookingList(context, ref, upcomingBookingsProvider),
            _buildBookingList(context, ref, pastBookingsProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(
    BuildContext context,
    WidgetRef ref,
    AutoDisposeProvider<AsyncValue<List<Booking>>> provider,
  ) {
    final bookingsAsync = ref.watch(provider);

    return bookingsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: YanoljaColors.primary),
      ),
      error: (err, stack) => Center(
        child: Text(
          '오류: $err',
          style: const TextStyle(color: YanoljaColors.textSecondary),
        ),
      ),
      data: (bookings) {
        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    color: YanoljaColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    size: 40,
                    color: YanoljaColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '예약 내역이 없어요',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: YanoljaColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '새로운 여행을 계획해보세요!',
                  style: TextStyle(
                    fontSize: 14,
                    color: YanoljaColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return _BookingCard(booking: booking);
          },
        );
      },
    );
  }
}

// 야놀자 스타일 예약 카드 (플랫 + 헤어라인 보더)
class _BookingCard extends StatelessWidget {
  final Booking booking;

  const _BookingCard({required this.booking});

  // 상태별 라벨/색상 (야놀자 핑크·그린·그레이 톤)
  ({String label, Color color, Color bg}) _statusStyle() {
    switch (booking.status) {
      case 'upcoming':
        return (
          label: '예정',
          color: YanoljaColors.primary,
          bg: YanoljaColors.primaryLight,
        );
      case 'completed':
        return (
          label: '완료',
          color: YanoljaColors.success,
          bg: const Color(0xFFE7F8F1),
        );
      default:
        return (
          label: '취소',
          color: YanoljaColors.textTertiary,
          bg: YanoljaColors.surfaceAlt,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _statusStyle();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: YanoljaColors.surface,
        borderRadius: BorderRadius.circular(YanoljaRadius.lg),
        border: Border.all(color: YanoljaColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: YanoljaColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(YanoljaRadius.md),
                  child: CachedNetworkImage(
                    imageUrl: booking.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 80,
                      height: 80,
                      color: YanoljaColors.surfaceAlt,
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 80,
                      height: 80,
                      color: YanoljaColors.surfaceAlt,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: YanoljaColors.textTertiary,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 상태 배지
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: status.bg,
                          borderRadius:
                              BorderRadius.circular(YanoljaRadius.sm),
                        ),
                        child: Text(
                          status.label,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: status.color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        booking.accommodationName,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: YanoljaColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.event_outlined,
                            size: 14,
                            color: YanoljaColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${DateFormat('yyyy.MM.dd').format(booking.checkInDate)} - ${DateFormat('yyyy.MM.dd').format(booking.checkOutDate)} (${booking.numberOfNights}박)',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: YanoljaColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(
              height: 1,
              thickness: 1,
              color: YanoljaColors.divider,
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '총 결제 금액',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: YanoljaColors.textSecondary,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      YanoljaFormat.price(booking.totalPrice),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: YanoljaColors.primary,
                      ),
                    ),
                    const Text(
                      '원',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: YanoljaColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
