import '../models/user_model.dart';

abstract class UserDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> register(String email, String password, String name);
  Future<UserModel> getUserById(String userId);
  Future<UserModel> updateUser(UserModel user);
  Future<void> deleteUser(String userId);
  Future<void> logout();
  Future<UserModel> getCurrentUser();
  Future<void> addSavedAccommodation(String userId, String accommodationId);
  Future<void> removeSavedAccommodation(String userId, String accommodationId);
}
