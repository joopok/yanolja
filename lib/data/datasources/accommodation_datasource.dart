import '../models/accommodation_model.dart';

abstract class AccommodationDataSource {
  Future<List<AccommodationModel>> getAllAccommodations();
  Future<AccommodationModel> getAccommodationById(String id);
}