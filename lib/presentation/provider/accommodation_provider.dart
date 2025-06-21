import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/data/repository/accommodation_repository.dart';

// Repository 인스턴스를 제공하는 Provider
final accommodationRepositoryProvider =
    Provider<AccommodationRepository>((ref) => AccommodationRepository());

// 전체 숙소 목록을 비동기적으로 제공하는 Provider
// FutureProvider는 로딩, 에러 상태를 자동으로 관리해줍니다.
final accommodationListProvider = FutureProvider<List<Accommodation>>((ref) {
  final repository = ref.watch(accommodationRepositoryProvider);
  return repository.getAccommodations();
});

// ID를 받아 특정 숙소 하나를 제공하는 Provider
// .family를 사용하여 파라미터를 받을 수 있습니다.
final accommodationDetailProvider =
    FutureProvider.family<Accommodation, String>((ref, id) {
  final repository = ref.watch(accommodationRepositoryProvider);
  return repository.getAccommodationById(id);
});
