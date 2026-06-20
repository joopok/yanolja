import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_datasource.dart';
import '../mappers/user_mapper.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDataSource dataSource;

  UserRepositoryImpl(this.dataSource);

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final model = await dataSource.getCurrentUser();
      return UserMapper.toEntity(model);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      final model = await dataSource.signInWithGoogle();
      return UserMapper.toEntity(model);
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  @override
  Future<UserEntity> signInWithEmail(String email, String password) async {
    try {
      final model = await dataSource.login(email, password);
      return UserMapper.toEntity(model);
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  @override
  Future<UserEntity> signUp(String email, String password, String name) async {
    try {
      final model = await dataSource.register(email, password, name);
      return UserMapper.toEntity(model);
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await dataSource.logout();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    try {
      final model = UserMapper.toModel(user);
      await dataSource.updateUser(model);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await dataSource.deleteUser(userId);
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  @override
  Future<List<String>> getSavedAccommodations(String userId) async {
    try {
      final model = await dataSource.getUserById(userId);
      return model.savedAccommodationIds;
    } catch (e) {
      throw Exception('Failed to get saved accommodations: $e');
    }
  }

  @override
  Future<void> saveAccommodation(String userId, String accommodationId) async {
    try {
      await dataSource.addSavedAccommodation(userId, accommodationId);
    } catch (e) {
      throw Exception('Failed to save accommodation: $e');
    }
  }

  @override
  Future<void> removeSavedAccommodation(
      String userId, String accommodationId) async {
    try {
      await dataSource.removeSavedAccommodation(userId, accommodationId);
    } catch (e) {
      throw Exception('Failed to remove saved accommodation: $e');
    }
  }
}
