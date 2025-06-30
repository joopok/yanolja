/// 사용자 정보를 나타내는 엔티티 클래스
/// 
/// Clean Architecture의 Domain 레이어에 속하는 순수한 비즈니스 모델입니다.
/// 앱 사용자의 기본 정보와 찜한 숙소 목록을 관리합니다.
/// Firebase Auth와 연동되어 사용됩니다.
class UserEntity {
  /// 사용자 고유 식별자 (Firebase UID)
  final String id;
  
  /// 사용자 이메일 주소
  final String email;
  
  /// 사용자 이름 (표시명)
  final String name;
  
  /// 사용자 프로필 사진 URL (선택적)
  /// Google 로그인 시 프로필 사진이 제공됩니다.
  final String? photoUrl;
  
  /// 계정 생성 일시
  final DateTime createdAt;
  
  /// 사용자가 찜한 숙소 ID 목록
  /// 찜한 숙소의 ID들을 저장하여 빠른 조회를 가능하게 합니다.
  final List<String> savedAccommodations;

  /// UserEntity 생성자
  /// 
  /// Firebase Auth에서 제공하는 사용자 정보를 기반으로 생성됩니다.
  /// @param id 사용자 고유 ID (필수)
  /// @param email 이메일 주소 (필수)
  /// @param name 사용자 이름 (필수)
  /// @param photoUrl 프로필 사진 URL (선택적)
  /// @param createdAt 계정 생성일 (필수)
  /// @param savedAccommodations 찜한 숙소 목록 (선택적, 기본값: 빈 리스트)
  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.createdAt,
    this.savedAccommodations = const [],
  });

  /// 동등성 비교 연산자 오버라이드
  /// 
  /// 두 UserEntity 인스턴스가 같은 id를 가지면 동일한 것으로 간주합니다.
  /// @param other 비교할 객체
  /// @return bool 동일 여부
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  /// 해시코드 생성
  /// 
  /// id를 기반으로 해시코드를 생성합니다.
  /// @return int 해시코드 값
  @override
  int get hashCode => id.hashCode;
}