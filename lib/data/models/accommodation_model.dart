class AccommodationModel {
  final String id;
  final String name;
  final String address;
  final int price;
  final double rating;
  final List<String> imageUrls;
  final String description;
  final String category;
  final List<String> amenities;
  final bool isNew;
  final bool isPopular;
  final int reviewCount;
  final double distanceFromCenter;
  final bool hasWifi;
  final bool hasParking;
  final bool hasBreakfast;
  final String checkInTime;
  final String checkOutTime;
  final List<ReviewModel> reviews;
  final double? latitude;
  final double? longitude;
  final List<AttractionModel> nearbyAttractions;
  final List<RestaurantModel> nearbyRestaurants;
  final SeasonalImagesModel? seasonalImages;
  final String? theme;
  final List<String>? tags;

  AccommodationModel({
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

  factory AccommodationModel.fromMap(Map<String, dynamic> map) {
    return AccommodationModel(
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
          ?.map((reviewMap) => ReviewModel.fromMap(reviewMap as Map<String, dynamic>))
          .toList() ?? [],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      nearbyAttractions: (map['nearbyAttractions'] as List<dynamic>?)
          ?.map((attractionMap) => AttractionModel.fromMap(attractionMap as Map<String, dynamic>))
          .toList() ?? [],
      nearbyRestaurants: (map['nearbyRestaurants'] as List<dynamic>?)
          ?.map((restaurantMap) => RestaurantModel.fromMap(restaurantMap as Map<String, dynamic>))
          .toList() ?? [],
      seasonalImages: map['seasonalImages'] != null 
          ? SeasonalImagesModel.fromMap(map['seasonalImages']) 
          : null,
      theme: map['theme'],
      tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'price': price,
      'rating': rating,
      'imageUrls': imageUrls,
      'description': description,
      'category': category,
      'amenities': amenities,
      'isNew': isNew,
      'isPopular': isPopular,
      'reviewCount': reviewCount,
      'distanceFromCenter': distanceFromCenter,
      'hasWifi': hasWifi,
      'hasParking': hasParking,
      'hasBreakfast': hasBreakfast,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'reviews': reviews.map((review) => review.toMap()).toList(),
      'latitude': latitude,
      'longitude': longitude,
      'nearbyAttractions': nearbyAttractions.map((attraction) => attraction.toMap()).toList(),
      'nearbyRestaurants': nearbyRestaurants.map((restaurant) => restaurant.toMap()).toList(),
      'seasonalImages': seasonalImages?.toMap(),
      'theme': theme,
      'tags': tags,
    };
  }
}

class ReviewModel {
  final String id;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime date;
  final List<String> photos;
  final int likes;
  final int dislikes;

  ReviewModel({
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

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      userName: map['userName'] ?? '',
      userAvatar: map['userAvatar'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      photos: List<String>.from(map['photos'] ?? []),
      likes: map['likes'] ?? 0,
      dislikes: map['dislikes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
      'photos': photos,
      'likes': likes,
      'dislikes': dislikes,
    };
  }
}

class AttractionModel {
  final String name;
  final String distance;
  final String imageUrl;

  AttractionModel({
    required this.name,
    required this.distance,
    required this.imageUrl,
  });

  factory AttractionModel.fromMap(Map<String, dynamic> map) {
    return AttractionModel(
      name: map['name'] ?? '',
      distance: map['distance'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'distance': distance,
      'imageUrl': imageUrl,
    };
  }
}

class RestaurantModel {
  final String name;
  final String cuisine;
  final String distance;
  final String imageUrl;

  RestaurantModel({
    required this.name,
    required this.cuisine,
    required this.distance,
    required this.imageUrl,
  });

  factory RestaurantModel.fromMap(Map<String, dynamic> map) {
    return RestaurantModel(
      name: map['name'] ?? '',
      cuisine: map['cuisine'] ?? '',
      distance: map['distance'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cuisine': cuisine,
      'distance': distance,
      'imageUrl': imageUrl,
    };
  }
}

class SeasonalImagesModel {
  final List<String> spring;
  final List<String> summer;
  final List<String> autumn;
  final List<String> winter;

  SeasonalImagesModel({
    required this.spring,
    required this.summer,
    required this.autumn,
    required this.winter,
  });

  factory SeasonalImagesModel.fromMap(Map<String, dynamic> map) {
    return SeasonalImagesModel(
      spring: List<String>.from(map['spring'] ?? []),
      summer: List<String>.from(map['summer'] ?? []),
      autumn: List<String>.from(map['autumn'] ?? []),
      winter: List<String>.from(map['winter'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'spring': spring,
      'summer': summer,
      'autumn': autumn,
      'winter': winter,
    };
  }
}