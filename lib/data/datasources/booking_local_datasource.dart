import '../models/booking_model.dart';
import 'booking_datasource.dart';
import '../../domain/entities/booking_entity.dart';

class BookingLocalDataSource implements BookingDataSource {
  final List<BookingModel> _bookings = [];

  @override
  Future<List<BookingModel>> getUserBookings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _bookings.where((booking) => booking.userId == userId).toList();
  }

  @override
  Future<BookingModel> createBooking(BookingModel booking) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _bookings.add(booking);
    return booking;
  }

  @override
  Future<BookingModel> updateBookingStatus(String bookingId, String status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index == -1) {
      throw Exception('Booking not found');
    }
    
    final booking = _bookings[index];
    final updatedBooking = BookingModel(
      id: booking.id,
      userId: booking.userId,
      accommodationId: booking.accommodationId,
      accommodationName: booking.accommodationName,
      accommodationImageUrl: booking.accommodationImageUrl,
      checkInDate: booking.checkInDate,
      checkOutDate: booking.checkOutDate,
      numberOfGuests: booking.numberOfGuests,
      numberOfRooms: booking.numberOfRooms,
      totalPrice: booking.totalPrice,
      status: BookingStatus.values.firstWhere((s) => s.name == status),
      createdAt: booking.createdAt,
      specialRequests: booking.specialRequests,
      phoneNumber: booking.phoneNumber,
      email: booking.email,
    );
    
    _bookings[index] = updatedBooking;
    return updatedBooking;
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    await updateBookingStatus(bookingId, 'cancelled');
  }

  @override
  Future<BookingModel> getBookingById(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final booking = _bookings.firstWhere(
      (booking) => booking.id == bookingId,
      orElse: () => throw Exception('Booking not found'),
    );
    return booking;
  }
}