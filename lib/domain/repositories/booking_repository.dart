import '../entities/booking_entity.dart';

abstract class BookingRepository {
  Future<List<BookingEntity>> getBookingsByUserId(String userId);
  Future<BookingEntity> createBooking(BookingEntity booking);
  Future<BookingEntity> updateBooking(BookingEntity booking);
  Future<void> cancelBooking(String bookingId);
  Future<BookingEntity> getBookingById(String id);
}