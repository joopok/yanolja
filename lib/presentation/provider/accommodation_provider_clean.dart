import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/accommodation_entity.dart';
import '../../domain/usecases/get_accommodations_usecase.dart';
import '../../data/repositories/accommodation_repository_impl.dart';
import '../../data/datasources/accommodation_local_datasource.dart';

// Repository Provider
final accommodationRepositoryProvider = Provider((ref) {
  return AccommodationRepositoryImpl(AccommodationLocalDataSource());
});

// UseCase Providers
final getAccommodationsUseCaseProvider = Provider((ref) {
  return GetAccommodationsUseCase(ref.watch(accommodationRepositoryProvider));
});

final getAccommodationsByCategoryProvider = Provider((ref) {
  return GetAccommodationsByCategory(ref.watch(accommodationRepositoryProvider));
});

final searchAccommodationsUseCaseProvider = Provider((ref) {
  return SearchAccommodationsUseCase(ref.watch(accommodationRepositoryProvider));
});

final getAccommodationDetailUseCaseProvider = Provider((ref) {
  return GetAccommodationDetailUseCase(ref.watch(accommodationRepositoryProvider));
});

final getPopularAccommodationsUseCaseProvider = Provider((ref) {
  return GetPopularAccommodationsUseCase(ref.watch(accommodationRepositoryProvider));
});

final getNewAccommodationsUseCaseProvider = Provider((ref) {
  return GetNewAccommodationsUseCase(ref.watch(accommodationRepositoryProvider));
});

// Data Providers
final accommodationListProvider = FutureProvider<List<AccommodationEntity>>((ref) async {
  final useCase = ref.watch(getAccommodationsUseCaseProvider);
  return await useCase();
});

final accommodationByIdProvider = FutureProvider.family<AccommodationEntity, String>((ref, id) async {
  final useCase = ref.watch(getAccommodationDetailUseCaseProvider);
  return await useCase(id);
});

final accommodationsByCategoryProvider = FutureProvider.family<List<AccommodationEntity>, String>((ref, category) async {
  final useCase = ref.watch(getAccommodationsByCategoryProvider);
  return await useCase(category);
});

final popularAccommodationsProvider = FutureProvider<List<AccommodationEntity>>((ref) async {
  final useCase = ref.watch(getPopularAccommodationsUseCaseProvider);
  return await useCase();
});

final newAccommodationsProvider = FutureProvider<List<AccommodationEntity>>((ref) async {
  final useCase = ref.watch(getNewAccommodationsUseCaseProvider);
  return await useCase();
});

final searchResultsProvider = FutureProvider.family<List<AccommodationEntity>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final useCase = ref.watch(searchAccommodationsUseCaseProvider);
  return await useCase(query);
});

// Category-specific providers
final hotelAccommodationsProvider = FutureProvider<List<AccommodationEntity>>((ref) async {
  return ref.watch(accommodationsByCategoryProvider('호텔').future);
});

final pensionAccommodationsProvider = FutureProvider<List<AccommodationEntity>>((ref) async {
  return ref.watch(accommodationsByCategoryProvider('펜션').future);
});

final resortAccommodationsProvider = FutureProvider<List<AccommodationEntity>>((ref) async {
  return ref.watch(accommodationsByCategoryProvider('리조트').future);
});

final hanokAccommodationsProvider = FutureProvider<List<AccommodationEntity>>((ref) async {
  return ref.watch(accommodationsByCategoryProvider('한옥').future);
});