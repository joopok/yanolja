import '../models/accommodation_model.dart';
import 'accommodation_datasource.dart';
import 'mock_accommodation_api.dart';

class AccommodationLocalDataSource implements AccommodationDataSource {
  final MockAccommodationApi _api = MockAccommodationApi();

  @override
  Future<List<AccommodationModel>> getAllAccommodations() async {
    try {
      final rawData = await _api.fetchAccommodations();
      return rawData.map((data) => AccommodationModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch accommodations from local source: $e');
    }
  }

  @override
  Future<AccommodationModel> getAccommodationById(String id) async {
    try {
      final rawData = await _api.fetchAccommodationById(id);
      return AccommodationModel.fromMap(rawData);
    } catch (e) {
      throw Exception('Failed to fetch accommodation by id from local source: $e');
    }
  }
}