import 'package:yanolja_clone/data/model/booking.dart';

class BookingRepository {
  // 가상 예약 데이터
  final List<Booking> _mockBookings = [
    Booking(
      id: 'b1',
      accommodationId: '1',
      accommodationName: '파크 하얏트 서울',
      imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      checkInDate: DateTime(2025, 7, 10),
      checkOutDate: DateTime(2025, 7, 13),
      numberOfNights: 3,
      totalPrice: 1050000,
      status: 'upcoming',
    ),
    Booking(
      id: 'b2',
      accommodationId: '2',
      accommodationName: '해운대 그랜드 호텔',
      imageUrl: 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      checkInDate: DateTime(2025, 8, 1),
      checkOutDate: DateTime(2025, 8, 5),
      numberOfNights: 4,
      totalPrice: 720000,
      status: 'upcoming',
    ),
    Booking(
      id: 'b3',
      accommodationId: '3',
      accommodationName: '제주 애월 감성 펜션',
      imageUrl: 'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      checkInDate: DateTime(2025, 5, 1),
      checkOutDate: DateTime(2025, 5, 3),
      numberOfNights: 2,
      totalPrice: 240000,
      status: 'completed',
    ),
    Booking(
      id: 'b4',
      accommodationId: '4',
      accommodationName: '경주 황리단길 한옥스테이',
      imageUrl: 'https://images.unsplash.com/photo-1445019980597-93e8fb7ce46b?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      checkInDate: DateTime(2024, 12, 24),
      checkOutDate: DateTime(2024, 12, 26),
      numberOfNights: 2,
      totalPrice: 170000,
      status: 'completed',
    ),
    Booking(
      id: 'b5',
      accommodationId: '5',
      accommodationName: '강릉 오션뷰 리조트',
      imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      checkInDate: DateTime(2025, 9, 15),
      checkOutDate: DateTime(2025, 9, 18),
      numberOfNights: 3,
      totalPrice: 600000,
      status: 'upcoming',
    ),
    Booking(
      id: 'b6',
      accommodationId: '6',
      accommodationName: '홍대 부티크 호텔',
      imageUrl: 'https://images.unsplash.com/photo-1566665797739-1674de7a421a?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      checkInDate: DateTime(2025, 1, 5),
      checkOutDate: DateTime(2025, 1, 7),
      numberOfNights: 2,
      totalPrice: 190000,
      status: 'completed',
    ),
  ];

  Future<List<Booking>> fetchBookings() async {
    await Future.delayed(const Duration(milliseconds: 500)); // 네트워크 지연 시뮬레이션
    return _mockBookings;
  }

  Future<Booking?> getBookingById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockBookings.firstWhere((booking) => booking.id == id);
  }
}
