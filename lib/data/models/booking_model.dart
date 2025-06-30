import '../../domain/entities/booking_entity.dart';

class BookingModel {
  final String id;
  final String userId;
  final String accommodationId;
  final String accommodationName;
  final String accommodationImageUrl;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfGuests;
  final int numberOfRooms;
  final double totalPrice;
  final BookingStatus status;
  final DateTime createdAt;
  final String? specialRequests;
  final String? phoneNumber;
  final String? email;

  BookingModel({
    required this.id,
    required this.userId,
    required this.accommodationId,
    required this.accommodationName,
    required this.accommodationImageUrl,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfGuests,
    required this.numberOfRooms,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.specialRequests,
    this.phoneNumber,
    this.email,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      accommodationId: map['accommodationId'] as String,
      accommodationName: map['accommodationName'] as String,
      accommodationImageUrl: map['accommodationImageUrl'] as String,
      checkInDate: DateTime.parse(map['checkInDate'] as String),
      checkOutDate: DateTime.parse(map['checkOutDate'] as String),
      numberOfGuests: map['numberOfGuests'] as int,
      numberOfRooms: map['numberOfRooms'] as int,
      totalPrice: (map['totalPrice'] as num).toDouble(),
      status: BookingStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => BookingStatus.pending,
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
      specialRequests: map['specialRequests'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      email: map['email'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'accommodationId': accommodationId,
      'accommodationName': accommodationName,
      'accommodationImageUrl': accommodationImageUrl,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'numberOfGuests': numberOfGuests,
      'numberOfRooms': numberOfRooms,
      'totalPrice': totalPrice,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'specialRequests': specialRequests,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }
}