import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

class UserMapper {
  static UserEntity toEntity(UserModel model) {
    return UserEntity(
      id: model.id,
      email: model.email,
      name: model.name,
      photoUrl: model.profileImageUrl,
      createdAt: model.createdAt,
      savedAccommodations: model.savedAccommodationIds,
    );
  }

  static UserModel toModel(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      phoneNumber: null,
      profileImageUrl: entity.photoUrl,
      createdAt: entity.createdAt,
      lastLoginAt: null,
      savedAccommodationIds: entity.savedAccommodations,
      preferences: null,
    );
  }

  static List<UserEntity> toEntityList(List<UserModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  static List<UserModel> toModelList(List<UserEntity> entities) {
    return entities.map((entity) => toModel(entity)).toList();
  }
}