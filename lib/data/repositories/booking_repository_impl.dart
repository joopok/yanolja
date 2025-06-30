import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_datasource.dart';
import '../mappers/booking_mapper.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingDataSource dataSource;

  BookingRepositoryImpl(this.dataSource);

  @override
  Future<List<BookingEntity>> getBookingsByUserId(String userId) async {
    try {
      final models = await dataSource.getUserBookings(userId);
      return BookingMapper.toEntityList(models);
    } catch (e) {
      throw Exception('Failed to get user bookings: $e');
    }
  }

  @override
  Future<BookingEntity> createBooking(BookingEntity booking) async {
    try {
      final model = BookingMapper.toModel(booking);
      final createdModel = await dataSource.createBooking(model);
      return BookingMapper.toEntity(createdModel);
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  @override
  Future<BookingEntity> updateBooking(BookingEntity booking) async {
    try {
      final updatedModel = await dataSource.updateBookingStatus(booking.id, booking.status.name);
      return BookingMapper.toEntity(updatedModel);
    } catch (e) {
      throw Exception('Failed to update booking: $e');
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      await dataSource.cancelBooking(bookingId);
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  @override
  Future<BookingEntity> getBookingById(String bookingId) async {
    try {
      final model = await dataSource.getBookingById(bookingId);
      return BookingMapper.toEntity(model);
    } catch (e) {
      throw Exception('Failed to get booking by id: $e');
    }
  }
}