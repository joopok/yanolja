class Booking {
  final String id;
  final String accommodationId;
  final String accommodationName;
  final String imageUrl;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfNights;
  final int totalPrice;
  final String status; // 'upcoming', 'completed', 'cancelled'

  Booking({
    required this.id,
    required this.accommodationId,
    required this.accommodationName,
    required this.imageUrl,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfNights,
    required this.totalPrice,
    required this.status,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      accommodationId: map['accommodationId'],
      accommodationName: map['accommodationName'],
      imageUrl: map['imageUrl'],
      checkInDate: DateTime.parse(map['checkInDate']),
      checkOutDate: DateTime.parse(map['checkOutDate']),
      numberOfNights: map['numberOfNights'],
      totalPrice: map['totalPrice'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accommodationId': accommodationId,
      'accommodationName': accommodationName,
      'imageUrl': imageUrl,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'numberOfNights': numberOfNights,
      'totalPrice': totalPrice,
      'status': status,
    };
  }
}
