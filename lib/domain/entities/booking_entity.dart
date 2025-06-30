/// 예약 정보를 나타내는 엔티티 클래스
/// 
/// Clean Architecture의 Domain 레이어에 속하는 순수한 비즈니스 모델입니다.
/// 예약과 관련된 모든 핵심 정보를 포함하고 있으며,
/// 프레임워크나 외부 라이브러리에 의존하지 않습니다.
class BookingEntity {
  /// 예약 고유 식별자
  final String id;
  
  /// 예약한 숙소의 고유 ID
  final String accommodationId;
  
  /// 예약한 숙소의 이름
  final String accommodationName;
  
  /// 예약을 생성한 사용자의 고유 ID
  final String userId;
  
  /// 체크인 날짜 및 시간
  final DateTime checkInDate;
  
  /// 체크아웃 날짜 및 시간
  final DateTime checkOutDate;
  
  /// 투숙객 수
  final int guests;
  
  /// 예약 총 금액 (원 단위)
  final int totalPrice;
  
  /// 예약 상태 (대기중, 확정, 취소됨, 완료됨)
  final BookingStatus status;
  
  /// 예약 생성 일시
  final DateTime createdAt;
  
  /// 숙소 이미지 URL 목록 (예약 내역 화면 표시용)
  final List<String> accommodationImages;
  
  /// 숙소 주소 (예약 확인서용)
  final String accommodationAddress;

  /// BookingEntity 생성자
  /// 
  /// 모든 필드는 필수값으로 설정되어 있습니다.
  /// @param id 예약 고유 ID
  /// @param accommodationId 숙소 ID
  /// @param accommodationName 숙소 이름
  /// @param userId 사용자 ID
  /// @param checkInDate 체크인 날짜
  /// @param checkOutDate 체크아웃 날짜
  /// @param guests 투숙객 수
  /// @param totalPrice 총 금액
  /// @param status 예약 상태
  /// @param createdAt 생성 일시
  /// @param accommodationImages 숙소 이미지 목록
  /// @param accommodationAddress 숙소 주소
  const BookingEntity({
    required this.id,
    required this.accommodationId,
    required this.accommodationName,
    required this.userId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guests,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.accommodationImages,
    required this.accommodationAddress,
  });

  /// 동등성 비교 연산자 오버라이드
  /// 
  /// 두 BookingEntity 인스턴스가 같은 id를 가지면 동일한 것으로 간주합니다.
  /// @param other 비교할 객체
  /// @return bool 동일 여부
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  /// 해시코드 생성
  /// 
  /// id를 기반으로 해시코드를 생성합니다.
  /// @return int 해시코드 값
  @override
  int get hashCode => id.hashCode;
}

/// 예약 상태를 나타내는 열거형
/// 
/// 예약의 생명주기를 관리하기 위한 상태값들입니다.
enum BookingStatus {
  /// 예약 대기 중 (결제 대기 등)
  pending,
  
  /// 예약 확정됨
  confirmed,
  
  /// 예약 취소됨
  cancelled,
  
  /// 예약 완료됨 (체크아웃 완료)
  completed,
}