import '../../domain/entities/accommodation_entity.dart';
import '../../domain/repositories/accommodation_repository.dart';
import '../datasources/accommodation_datasource.dart';
import '../mappers/accommodation_mapper.dart';

class AccommodationRepositoryImpl implements AccommodationRepository {
  final AccommodationDataSource dataSource;

  AccommodationRepositoryImpl(this.dataSource);

  @override
  Future<List<AccommodationEntity>> getAllAccommodations() async {
    try {
      final models = await dataSource.getAllAccommodations();
      return AccommodationMapper.toEntityList(models);
    } catch (e) {
      throw Exception('Failed to get accommodations: $e');
    }
  }

  @override
  Future<AccommodationEntity> getAccommodationById(String id) async {
    try {
      final model = await dataSource.getAccommodationById(id);
      return AccommodationMapper.toEntity(model);
    } catch (e) {
      throw Exception('Failed to get accommodation by id: $e');
    }
  }

  @override
  Future<List<AccommodationEntity>> getAccommodationsByCategory(String category) async {
    try {
      final allAccommodations = await dataSource.getAllAccommodations();
      final filteredModels = allAccommodations
          .where((model) => model.category == category)
          .toList();
      return AccommodationMapper.toEntityList(filteredModels);
    } catch (e) {
      throw Exception('Failed to get accommodations by category: $e');
    }
  }

  @override
  Future<List<AccommodationEntity>> searchAccommodations(String query) async {
    try {
      final allAccommodations = await dataSource.getAllAccommodations();
      final searchResults = allAccommodations.where((model) {
        return model.name.toLowerCase().contains(query.toLowerCase()) ||
            model.address.toLowerCase().contains(query.toLowerCase()) ||
            model.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
      return AccommodationMapper.toEntityList(searchResults);
    } catch (e) {
      throw Exception('Failed to search accommodations: $e');
    }
  }

  @override
  Future<List<AccommodationEntity>> getPopularAccommodations() async {
    try {
      final allAccommodations = await dataSource.getAllAccommodations();
      final popularModels = allAccommodations
          .where((model) => model.isPopular)
          .toList();
      return AccommodationMapper.toEntityList(popularModels);
    } catch (e) {
      throw Exception('Failed to get popular accommodations: $e');
    }
  }

  @override
  Future<List<AccommodationEntity>> getNewAccommodations() async {
    try {
      final allAccommodations = await dataSource.getAllAccommodations();
      final newModels = allAccommodations
          .where((model) => model.isNew)
          .toList();
      return AccommodationMapper.toEntityList(newModels);
    } catch (e) {
      throw Exception('Failed to get new accommodations: $e');
    }
  }

  @override
  Future<List<AccommodationEntity>> getAccommodationsByLocation(String location) async {
    try {
      final allAccommodations = await dataSource.getAllAccommodations();
      final locationModels = allAccommodations
          .where((model) => model.address.contains(location))
          .toList();
      return AccommodationMapper.toEntityList(locationModels);
    } catch (e) {
      throw Exception('Failed to get accommodations by location: $e');
    }
  }

  @override
  Future<List<AccommodationEntity>> getRecommendedAccommodations(String userId) async {
    try {
      // 추천 로직은 나중에 구현
      final allAccommodations = await dataSource.getAllAccommodations();
      final recommendedModels = allAccommodations
          .where((model) => model.rating >= 4.5)
          .take(10)
          .toList();
      return AccommodationMapper.toEntityList(recommendedModels);
    } catch (e) {
      throw Exception('Failed to get recommended accommodations: $e');
    }
  }
}