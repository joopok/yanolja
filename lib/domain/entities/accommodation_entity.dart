/// 숙소 정보를 나타내는 엔티티 클래스
/// 
/// Clean Architecture의 Domain 레이어에 속하는 순수한 비즈니스 모델입니다.
/// 숙소와 관련된 모든 핵심 정보를 포함하고 있으며,
/// 프레임워크나 외부 라이브러리에 의존하지 않습니다.
class AccommodationEntity {
  /// 숙소 고유 식별자
  final String id;
  
  /// 숙소 이름
  final String name;
  
  /// 숙소 주소
  final String address;
  
  /// 1박 기준 가격 (원 단위)
  final int price;
  
  /// 평점 (0.0 ~ 5.0)
  final double rating;
  
  /// 숙소 이미지 URL 목록
  final List<String> imageUrls;
  
  /// 숙소 상세 설명
  final String description;
  
  /// 숙소 카테고리 (호텔, 펜션, 리조트, 한옥)
  final String category;
  
  /// 편의시설 목록
  final List<String> amenities;
  
  /// 신규 숙소 여부
  final bool isNew;
  
  /// 인기 숙소 여부
  final bool isPopular;
  
  /// 리뷰 개수
  final int reviewCount;
  
  /// 도심으로부터의 거리 (km 단위)
  final double distanceFromCenter;
  
  /// WiFi 제공 여부
  final bool hasWifi;
  
  /// 주차장 제공 여부
  final bool hasParking;
  
  /// 조식 제공 여부
  final bool hasBreakfast;
  
  /// 체크인 시간 (HH:mm 형식)
  final String checkInTime;
  
  /// 체크아웃 시간 (HH:mm 형식)
  final String checkOutTime;
  
  /// 숙소 리뷰 목록
  final List<ReviewEntity> reviews;
  
  /// 위도 (선택적)
  final double? latitude;
  
  /// 경도 (선택적)
  final double? longitude;
  
  /// 주변 관광지 목록
  final List<AttractionEntity> nearbyAttractions;
  
  /// 주변 음식점 목록
  final List<RestaurantEntity> nearbyRestaurants;
  
  /// 계절별 이미지 (펜션 전용, 선택적)
  final SeasonalImagesEntity? seasonalImages;
  
  /// 숙소 테마 (예: '가족여행', '커플', '비즈니스' 등, 선택적)
  final String? theme;
  
  /// 태그 목록 (검색용, 선택적)
  final List<String>? tags;

  /// AccommodationEntity 생성자
  /// 
  /// 필수 필드와 선택적 필드로 구분되어 있습니다.
  /// @param id 숙소 고유 ID (필수)
  /// @param name 숙소 이름 (필수)
  /// @param address 숙소 주소 (필수)
  /// @param price 1박 가격 (필수)
  /// @param rating 평점 (필수)
  /// @param imageUrls 이미지 URL 목록 (필수)
  /// @param description 상세 설명 (필수)
  /// @param category 카테고리 (필수)
  /// @param amenities 편의시설 목록 (필수)
  /// @param isNew 신규 여부 (필수)
  /// @param isPopular 인기 여부 (필수)
  /// @param reviewCount 리뷰 개수 (필수)
  /// @param distanceFromCenter 도심 거리 (필수)
  /// @param hasWifi WiFi 여부 (필수)
  /// @param hasParking 주차 여부 (필수)
  /// @param hasBreakfast 조식 여부 (필수)
  /// @param checkInTime 체크인 시간 (필수)
  /// @param checkOutTime 체크아웃 시간 (필수)
  /// @param reviews 리뷰 목록 (선택적, 기본값: 빈 리스트)
  /// @param latitude 위도 (선택적)
  /// @param longitude 경도 (선택적)
  /// @param nearbyAttractions 주변 관광지 (선택적, 기본값: 빈 리스트)
  /// @param nearbyRestaurants 주변 음식점 (선택적, 기본값: 빈 리스트)
  /// @param seasonalImages 계절별 이미지 (선택적)
  /// @param theme 테마 (선택적)
  /// @param tags 태그 목록 (선택적)
  const AccommodationEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.price,
    required this.rating,
    required this.imageUrls,
    required this.description,
    required this.category,
    required this.amenities,
    required this.isNew,
    required this.isPopular,
    required this.reviewCount,
    required this.distanceFromCenter,
    required this.hasWifi,
    required this.hasParking,
    required this.hasBreakfast,
    required this.checkInTime,
    required this.checkOutTime,
    this.reviews = const [],
    this.latitude,
    this.longitude,
    this.nearbyAttractions = const [],
    this.nearbyRestaurants = const [],
    this.seasonalImages,
    this.theme,
    this.tags,
  });

  /// 동등성 비교 연산자 오버라이드
  /// 
  /// 두 AccommodationEntity 인스턴스가 같은 id를 가지면 동일한 것으로 간주합니다.
  /// @param other 비교할 객체
  /// @return bool 동일 여부
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccommodationEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  /// 해시코드 생성
  /// 
  /// id를 기반으로 해시코드를 생성합니다.
  /// @return int 해시코드 값
  @override
  int get hashCode => id.hashCode;
}

/// 숙소 리뷰 정보를 나타내는 엔티티 클래스
/// 
/// 사용자가 작성한 숙소 리뷰의 상세 정보를 포함합니다.
class ReviewEntity {
  /// 리뷰 고유 식별자
  final String id;
  
  /// 리뷰 작성자 이름
  final String userName;
  
  /// 리뷰 작성자 프로필 이미지 URL
  final String userAvatar;
  
  /// 리뷰 평점 (0.0 ~ 5.0)
  final double rating;
  
  /// 리뷰 내용
  final String comment;
  
  /// 리뷰 작성 날짜
  final DateTime date;
  
  /// 리뷰에 포함된 사진 URL 목록
  final List<String> photos;
  
  /// 도움이 되었어요 수
  final int likes;
  
  /// 도움이 되지 않았어요 수
  final int dislikes;

  /// ReviewEntity 생성자
  /// 
  /// @param id 리뷰 ID (필수)
  /// @param userName 작성자 이름 (필수)
  /// @param userAvatar 작성자 프로필 이미지 (필수)
  /// @param rating 평점 (필수)
  /// @param comment 리뷰 내용 (필수)
  /// @param date 작성 날짜 (필수)
  /// @param photos 사진 목록 (선택적, 기본값: 빈 리스트)
  /// @param likes 좋아요 수 (선택적, 기본값: 0)
  /// @param dislikes 싫어요 수 (선택적, 기본값: 0)
  const ReviewEntity({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
    this.photos = const [],
    this.likes = 0,
    this.dislikes = 0,
  });
}

/// 주변 관광지 정보를 나타내는 엔티티 클래스
/// 
/// 숙소 주변의 관광 명소 정보를 제공합니다.
class AttractionEntity {
  /// 관광지 이름
  final String name;
  
  /// 숙소로부터의 거리 (예: "500m", "1.2km")
  final String distance;
  
  /// 관광지 이미지 URL
  final String imageUrl;

  /// AttractionEntity 생성자
  /// 
  /// @param name 관광지 이름 (필수)
  /// @param distance 거리 표시 (필수)
  /// @param imageUrl 이미지 URL (필수)
  const AttractionEntity({
    required this.name,
    required this.distance,
    required this.imageUrl,
  });
}

/// 주변 음식점 정보를 나타내는 엔티티 클래스
/// 
/// 숙소 주변의 음식점 정보를 제공합니다.
class RestaurantEntity {
  /// 음식점 이름
  final String name;
  
  /// 음식 종류 (예: "한식", "일식", "중식", "양식" 등)
  final String cuisine;
  
  /// 숙소로부터의 거리 (예: "300m", "1km")
  final String distance;
  
  /// 음식점 이미지 URL
  final String imageUrl;

  /// RestaurantEntity 생성자
  /// 
  /// @param name 음식점 이름 (필수)
  /// @param cuisine 음식 종류 (필수)
  /// @param distance 거리 표시 (필수)
  /// @param imageUrl 이미지 URL (필수)
  const RestaurantEntity({
    required this.name,
    required this.cuisine,
    required this.distance,
    required this.imageUrl,
  });
}

/// 계절별 이미지 정보를 나타내는 엔티티 클래스
/// 
/// 펜션 등 계절별로 다른 분위기를 보여주는 숙소들을 위한 
/// 계절별 이미지 URL 목록을 관리합니다.
class SeasonalImagesEntity {
  /// 봄 시즌 이미지 URL 목록
  final List<String> spring;
  
  /// 여름 시즌 이미지 URL 목록
  final List<String> summer;
  
  /// 가을 시즌 이미지 URL 목록
  final List<String> autumn;
  
  /// 겨울 시즌 이미지 URL 목록
  final List<String> winter;

  /// SeasonalImagesEntity 생성자
  /// 
  /// 모든 계절의 이미지 목록은 필수값입니다.
  /// @param spring 봄 이미지 목록 (필수)
  /// @param summer 여름 이미지 목록 (필수)
  /// @param autumn 가을 이미지 목록 (필수)
  /// @param winter 겨울 이미지 목록 (필수)
  const SeasonalImagesEntity({
    required this.spring,
    required this.summer,
    required this.autumn,
    required this.winter,
  });
}