import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:yanolja_clone/data/model/booking.dart';
import 'package:yanolja_clone/presentation/provider/booking_provider.dart';

class BookingScreen extends ConsumerWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('내 예약'),
          bottom: TabBar(
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
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

  Widget _buildBookingList(BuildContext context, WidgetRef ref, AutoDisposeProvider<AsyncValue<List<Booking>>> provider) {
    final bookingsAsync = ref.watch(provider);
    final theme = Theme.of(context);

    return bookingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('오류: $err')),
      data: (bookings) {
        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_outlined, size: 80, color: theme.colorScheme.outline),
                const SizedBox(height: 24),
                Text(
                  '예약 내역이 없어요',
                  style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.8)),
                ),
                const SizedBox(height: 8),
                Text(
                  '새로운 여행을 계획해보세요!',
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(booking.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.accommodationName,
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${DateFormat('yyyy.MM.dd').format(booking.checkInDate)} - ${DateFormat('yyyy.MM.dd').format(booking.checkOutDate)} (${booking.numberOfNights}박)',
                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '총 결제 금액',
                          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${NumberFormat('#,###').format(booking.totalPrice)}원',
                          style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '상태: ${booking.status == 'upcoming' ? '예정' : booking.status == 'completed' ? '완료' : '취소'}',
                        style: theme.textTheme.bodySmall?.copyWith(color: booking.status == 'upcoming' ? Colors.blue : booking.status == 'completed' ? Colors.green : Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
