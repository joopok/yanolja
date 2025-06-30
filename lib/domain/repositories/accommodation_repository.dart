import '../entities/accommodation_entity.dart';

abstract class AccommodationRepository {
  Future<List<AccommodationEntity>> getAllAccommodations();
  Future<AccommodationEntity> getAccommodationById(String id);
  Future<List<AccommodationEntity>> getAccommodationsByCategory(String category);
  Future<List<AccommodationEntity>> searchAccommodations(String query);
  Future<List<AccommodationEntity>> getPopularAccommodations();
  Future<List<AccommodationEntity>> getNewAccommodations();
  Future<List<AccommodationEntity>> getAccommodationsByLocation(String location);
  Future<List<AccommodationEntity>> getRecommendedAccommodations(String userId);
}