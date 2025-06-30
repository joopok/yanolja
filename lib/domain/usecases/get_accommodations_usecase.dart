import '../entities/accommodation_entity.dart';
import '../repositories/accommodation_repository.dart';

class GetAccommodationsUseCase {
  final AccommodationRepository repository;

  GetAccommodationsUseCase(this.repository);

  Future<List<AccommodationEntity>> call() async {
    return await repository.getAllAccommodations();
  }
}

class GetAccommodationsByCategory {
  final AccommodationRepository repository;

  GetAccommodationsByCategory(this.repository);

  Future<List<AccommodationEntity>> call(String category) async {
    return await repository.getAccommodationsByCategory(category);
  }
}

class SearchAccommodationsUseCase {
  final AccommodationRepository repository;

  SearchAccommodationsUseCase(this.repository);

  Future<List<AccommodationEntity>> call(String query) async {
    return await repository.searchAccommodations(query);
  }
}

class GetAccommodationDetailUseCase {
  final AccommodationRepository repository;

  GetAccommodationDetailUseCase(this.repository);

  Future<AccommodationEntity> call(String id) async {
    return await repository.getAccommodationById(id);
  }
}

class GetPopularAccommodationsUseCase {
  final AccommodationRepository repository;

  GetPopularAccommodationsUseCase(this.repository);

  Future<List<AccommodationEntity>> call() async {
    return await repository.getPopularAccommodations();
  }
}

class GetNewAccommodationsUseCase {
  final AccommodationRepository repository;

  GetNewAccommodationsUseCase(this.repository);

  Future<List<AccommodationEntity>> call() async {
    return await repository.getNewAccommodations();
  }
}