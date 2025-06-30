import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yanolja_clone/data/model/booking.dart';
import 'package:yanolja_clone/data/repository/booking_repository.dart';

// BookingRepository 인스턴스를 제공하는 Provider
final bookingRepositoryProvider = Provider<BookingRepository>((ref) => BookingRepository());

// 모든 예약 목록을 비동기적으로 제공하는 Provider
final bookingListProvider = FutureProvider<List<Booking>>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.fetchBookings();
});

// 예정된 예약 목록을 제공하는 AutoDisposeProvider
final upcomingBookingsProvider = Provider.autoDispose<AsyncValue<List<Booking>>>((ref) {
  final bookingsAsync = ref.watch(bookingListProvider);
  return bookingsAsync.whenData((bookings) {
    final now = DateTime.now();
    return bookings.where((booking) => booking.checkInDate.isAfter(now) || booking.checkInDate.isAtSameMomentAs(now)).toList();
  });
});

// 지난 예약 목록을 제공하는 AutoDisposeProvider
final pastBookingsProvider = Provider.autoDispose<AsyncValue<List<Booking>>>((ref) {
  final bookingsAsync = ref.watch(bookingListProvider);
  return bookingsAsync.whenData((bookings) {
    final now = DateTime.now();
    return bookings.where((booking) => booking.checkInDate.isBefore(now)).toList();
  });
});
