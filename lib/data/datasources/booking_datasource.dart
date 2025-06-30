import '../models/booking_model.dart';

abstract class BookingDataSource {
  Future<List<BookingModel>> getUserBookings(String userId);
  Future<BookingModel> createBooking(BookingModel booking);
  Future<BookingModel> updateBookingStatus(String bookingId, String status);
  Future<void> cancelBooking(String bookingId);
  Future<BookingModel> getBookingById(String bookingId);
}