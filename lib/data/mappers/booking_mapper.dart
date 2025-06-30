import '../../domain/entities/booking_entity.dart';
import '../models/booking_model.dart';

class BookingMapper {
  static BookingEntity toEntity(BookingModel model) {
    return BookingEntity(
      id: model.id,
      userId: model.userId,
      accommodationId: model.accommodationId,
      accommodationName: model.accommodationName,
      checkInDate: model.checkInDate,
      checkOutDate: model.checkOutDate,
      guests: model.numberOfGuests,
      totalPrice: model.totalPrice.toInt(),
      status: model.status,
      createdAt: model.createdAt,
      accommodationImages: [model.accommodationImageUrl],
      accommodationAddress: '',
    );
  }

  static BookingModel toModel(BookingEntity entity) {
    return BookingModel(
      id: entity.id,
      userId: entity.userId,
      accommodationId: entity.accommodationId,
      accommodationName: entity.accommodationName,
      accommodationImageUrl: entity.accommodationImages.isNotEmpty ? entity.accommodationImages.first : '',
      checkInDate: entity.checkInDate,
      checkOutDate: entity.checkOutDate,
      numberOfGuests: entity.guests,
      numberOfRooms: 1,
      totalPrice: entity.totalPrice.toDouble(),
      status: entity.status,
      createdAt: entity.createdAt,
      specialRequests: null,
      phoneNumber: null,
      email: null,
    );
  }

  static List<BookingEntity> toEntityList(List<BookingModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  static List<BookingModel> toModelList(List<BookingEntity> entities) {
    return entities.map((entity) => toModel(entity)).toList();
  }
}