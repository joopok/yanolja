import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> signInWithGoogle();
  Future<UserEntity> signInWithEmail(String email, String password);
  Future<UserEntity> signUp(String email, String password, String name);
  Future<void> signOut();
  Future<void> updateUser(UserEntity user);
  Future<void> deleteUser(String userId);
  Future<List<String>> getSavedAccommodations(String userId);
  Future<void> saveAccommodation(String userId, String accommodationId);
  Future<void> removeSavedAccommodation(String userId, String accommodationId);
}