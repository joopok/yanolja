import '../../domain/entities/accommodation_entity.dart';
import '../models/accommodation_model.dart';

class AccommodationMapper {
  static AccommodationEntity toEntity(AccommodationModel model) {
    return AccommodationEntity(
      id: model.id,
      name: model.name,
      address: model.address,
      price: model.price,
      rating: model.rating,
      imageUrls: model.imageUrls,
      description: model.description,
      category: model.category,
      amenities: model.amenities,
      isNew: model.isNew,
      isPopular: model.isPopular,
      reviewCount: model.reviewCount,
      distanceFromCenter: model.distanceFromCenter,
      hasWifi: model.hasWifi,
      hasParking: model.hasParking,
      hasBreakfast: model.hasBreakfast,
      checkInTime: model.checkInTime,
      checkOutTime: model.checkOutTime,
      reviews: model.reviews.map((review) => ReviewMapper.toEntity(review)).toList(),
      latitude: model.latitude,
      longitude: model.longitude,
      nearbyAttractions: model.nearbyAttractions.map((attraction) => AttractionMapper.toEntity(attraction)).toList(),
      nearbyRestaurants: model.nearbyRestaurants.map((restaurant) => RestaurantMapper.toEntity(restaurant)).toList(),
      seasonalImages: model.seasonalImages != null ? SeasonalImagesMapper.toEntity(model.seasonalImages!) : null,
      theme: model.theme,
      tags: model.tags,
    );
  }

  static AccommodationModel toModel(AccommodationEntity entity) {
    return AccommodationModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      price: entity.price,
      rating: entity.rating,
      imageUrls: entity.imageUrls,
      description: entity.description,
      category: entity.category,
      amenities: entity.amenities,
      isNew: entity.isNew,
      isPopular: entity.isPopular,
      reviewCount: entity.reviewCount,
      distanceFromCenter: entity.distanceFromCenter,
      hasWifi: entity.hasWifi,
      hasParking: entity.hasParking,
      hasBreakfast: entity.hasBreakfast,
      checkInTime: entity.checkInTime,
      checkOutTime: entity.checkOutTime,
      reviews: entity.reviews.map((review) => ReviewMapper.toModel(review)).toList(),
      latitude: entity.latitude,
      longitude: entity.longitude,
      nearbyAttractions: entity.nearbyAttractions.map((attraction) => AttractionMapper.toModel(attraction)).toList(),
      nearbyRestaurants: entity.nearbyRestaurants.map((restaurant) => RestaurantMapper.toModel(restaurant)).toList(),
      seasonalImages: entity.seasonalImages != null ? SeasonalImagesMapper.toModel(entity.seasonalImages!) : null,
      theme: entity.theme,
      tags: entity.tags,
    );
  }

  static List<AccommodationEntity> toEntityList(List<AccommodationModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  static List<AccommodationModel> toModelList(List<AccommodationEntity> entities) {
    return entities.map((entity) => toModel(entity)).toList();
  }
}

class ReviewMapper {
  static ReviewEntity toEntity(ReviewModel model) {
    return ReviewEntity(
      id: model.id,
      userName: model.userName,
      userAvatar: model.userAvatar,
      rating: model.rating,
      comment: model.comment,
      date: model.date,
      photos: model.photos,
      likes: model.likes,
      dislikes: model.dislikes,
    );
  }

  static ReviewModel toModel(ReviewEntity entity) {
    return ReviewModel(
      id: entity.id,
      userName: entity.userName,
      userAvatar: entity.userAvatar,
      rating: entity.rating,
      comment: entity.comment,
      date: entity.date,
      photos: entity.photos,
      likes: entity.likes,
      dislikes: entity.dislikes,
    );
  }
}

class AttractionMapper {
  static AttractionEntity toEntity(AttractionModel model) {
    return AttractionEntity(
      name: model.name,
      distance: model.distance,
      imageUrl: model.imageUrl,
    );
  }

  static AttractionModel toModel(AttractionEntity entity) {
    return AttractionModel(
      name: entity.name,
      distance: entity.distance,
      imageUrl: entity.imageUrl,
    );
  }
}

class RestaurantMapper {
  static RestaurantEntity toEntity(RestaurantModel model) {
    return RestaurantEntity(
      name: model.name,
      cuisine: model.cuisine,
      distance: model.distance,
      imageUrl: model.imageUrl,
    );
  }

  static RestaurantModel toModel(RestaurantEntity entity) {
    return RestaurantModel(
      name: entity.name,
      cuisine: entity.cuisine,
      distance: entity.distance,
      imageUrl: entity.imageUrl,
    );
  }
}

class SeasonalImagesMapper {
  static SeasonalImagesEntity toEntity(SeasonalImagesModel model) {
    return SeasonalImagesEntity(
      spring: model.spring,
      summer: model.summer,
      autumn: model.autumn,
      winter: model.winter,
    );
  }

  static SeasonalImagesModel toModel(SeasonalImagesEntity entity) {
    return SeasonalImagesModel(
      spring: entity.spring,
      summer: entity.summer,
      autumn: entity.autumn,
      winter: entity.winter,
    );
  }
}