import 'package:yanolja_clone/data/datasource/mock_accommodation_api.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';

// 데이터 소스와 UI 사이의 다리 역할
class AccommodationRepository {
  final MockAccommodationApi _api = MockAccommodationApi();

  Future<List<Accommodation>> getAccommodations() async {
    final List<Map<String, dynamic>> data = await _api.fetchAccommodations();
    return data.map((item) => Accommodation.fromMap(item)).toList();
  }

  Future<Accommodation> getAccommodationById(String id) async {
    final Map<String, dynamic> data = await _api.fetchAccommodationById(id);
    return Accommodation.fromMap(data);
  }
}
