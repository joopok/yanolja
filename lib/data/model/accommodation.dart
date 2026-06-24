// 리뷰 데이터 구조를 정의하는 모델 클래스
class Review {
  final String id;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime date;
  final List<String> photos;
  final int likes;
  final int dislikes;

  Review({
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

  factory Review.fromMap(Map<String, dynamic> map) {
    final dateValue = map['date'];
    return Review(
      id: map['id']?.toString() ?? map['author']?.toString() ?? '',
      userName: map['userName'] ?? map['author'] ?? '실제 이용객',
      userAvatar: map['userAvatar'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      date: dateValue is String
          ? DateTime.tryParse(dateValue) ?? DateTime.now()
          : DateTime.now(),
      photos: List<String>.from(map['photos'] ?? []),
      likes: map['likes'] ?? 0,
      dislikes: map['dislikes'] ?? 0,
    );
  }
}

// 근처 가볼만한 곳 데이터 구조
class Attraction {
  final String name;
  final String distance;
  final String imageUrl;

  Attraction({
    required this.name,
    required this.distance,
    required this.imageUrl,
  });

  factory Attraction.fromMap(Map<String, dynamic> map) {
    return Attraction(
      name: map['name'] ?? '',
      distance: map['distance'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}

// 근처 맛집 데이터 구조
class Restaurant {
  final String name;
  final String cuisine;
  final String distance;
  final String imageUrl;

  Restaurant({
    required this.name,
    required this.cuisine,
    required this.distance,
    required this.imageUrl,
  });

  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      name: map['name'] ?? '',
      cuisine: map['cuisine'] ?? '',
      distance: map['distance'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}

// 계절별 이미지 데이터 구조
class SeasonalImages {
  final List<String> spring;
  final List<String> summer;
  final List<String> autumn;
  final List<String> winter;

  SeasonalImages({
    required this.spring,
    required this.summer,
    required this.autumn,
    required this.winter,
  });

  factory SeasonalImages.fromMap(Map<String, dynamic> map) {
    return SeasonalImages(
      spring: List<String>.from(map['spring'] ?? []),
      summer: List<String>.from(map['summer'] ?? []),
      autumn: List<String>.from(map['autumn'] ?? []),
      winter: List<String>.from(map['winter'] ?? []),
    );
  }
}

// 숙소 데이터 구조를 정의하는 모델 클래스
class Accommodation {
  final String id;
  final String name;
  final String address;
  final int price;
  final double rating;
  final List<String> imageUrls;
  final String description;
  final String category; // 호텔, 펜션, 리조트 등
  final List<String> amenities; // 편의시설
  final bool isNew; // 신규 여부
  final bool isPopular; // 인기 여부
  final int reviewCount; // 리뷰 개수
  final double distanceFromCenter; // 중심가로부터 거리 (km)
  final bool hasWifi;
  final bool hasParking;
  final bool hasBreakfast;
  final String checkInTime;
  final String checkOutTime;
  final List<Review> reviews;
  final double? latitude;
  final double? longitude;
  final List<Attraction> nearbyAttractions; // 근처 가볼만한 곳
  final List<Restaurant> nearbyRestaurants; // 근처 맛집
  final SeasonalImages? seasonalImages; // 계절별 이미지
  final String? theme; // 가족, 연인, 힐링, 럭셔리 등
  final List<String>? tags; // 태그들 (예: 온수풀, 바베큐, 개별테라스)

  Accommodation({
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

  factory Accommodation.fromMap(Map<String, dynamic> map) {
    return Accommodation(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      price: map['price'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      description: map['description'] ?? '상세 설명이 없습니다.',
      category: map['category'] ?? '호텔',
      amenities: List<String>.from(map['amenities'] ?? []),
      isNew: map['isNew'] ?? false,
      isPopular: map['isPopular'] ?? false,
      reviewCount: map['reviewCount'] ?? 0,
      distanceFromCenter: (map['distanceFromCenter'] ?? 0.0).toDouble(),
      hasWifi: map['hasWifi'] ?? false,
      hasParking: map['hasParking'] ?? false,
      hasBreakfast: map['hasBreakfast'] ?? false,
      checkInTime: map['checkInTime'] ?? '15:00',
      checkOutTime: map['checkOutTime'] ?? '11:00',
      reviews: (map['reviews'] as List<dynamic>?)
              ?.map((reviewMap) =>
                  Review.fromMap(reviewMap as Map<String, dynamic>))
              .toList() ??
          [],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      nearbyAttractions: (map['nearbyAttractions'] as List<dynamic>?)
              ?.map((attractionMap) =>
                  Attraction.fromMap(attractionMap as Map<String, dynamic>))
              .toList() ??
          [],
      nearbyRestaurants: (map['nearbyRestaurants'] as List<dynamic>?)
              ?.map((restaurantMap) =>
                  Restaurant.fromMap(restaurantMap as Map<String, dynamic>))
              .toList() ??
          [],
      seasonalImages: map['seasonalImages'] != null
          ? SeasonalImages.fromMap(map['seasonalImages'])
          : null,
      theme: map['theme'],
      tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
    );
  }
}
