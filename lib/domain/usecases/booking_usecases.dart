import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class CreateBookingUseCase {
  final BookingRepository repository;

  CreateBookingUseCase(this.repository);

  Future<BookingEntity> call(BookingEntity booking) async {
    return await repository.createBooking(booking);
  }
}

class GetUserBookingsUseCase {
  final BookingRepository repository;

  GetUserBookingsUseCase(this.repository);

  Future<List<BookingEntity>> call(String userId) async {
    return await repository.getBookingsByUserId(userId);
  }
}

class CancelBookingUseCase {
  final BookingRepository repository;

  CancelBookingUseCase(this.repository);

  Future<void> call(String bookingId) async {
    return await repository.cancelBooking(bookingId);
  }
}

class GetBookingDetailUseCase {
  final BookingRepository repository;

  GetBookingDetailUseCase(this.repository);

  Future<BookingEntity> call(String id) async {
    return await repository.getBookingById(id);
  }
}