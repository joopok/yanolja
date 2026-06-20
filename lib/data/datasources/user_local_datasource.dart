import '../models/user_model.dart';
import 'user_datasource.dart';

class UserLocalDataSource implements UserDataSource {
  final Map<String, UserModel> _users = {};
  UserModel? _currentUser;

  @override
  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    final user = _users.values.firstWhere(
      (user) => user.email == email,
      orElse: () => throw Exception('User not found'),
    );

    _currentUser = UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      phoneNumber: user.phoneNumber,
      profileImageUrl: user.profileImageUrl,
      createdAt: user.createdAt,
      lastLoginAt: DateTime.now(),
      savedAccommodationIds: user.savedAccommodationIds,
      preferences: user.preferences,
    );

    return _currentUser!;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 700));

    const googleEmail = 'google.user@gmail.com';
    UserModel? existingUser;
    for (final user in _users.values) {
      if (user.email == googleEmail) {
        existingUser = user;
        break;
      }
    }

    final now = DateTime.now();
    final user = UserModel(
      id: existingUser?.id ?? 'google-${now.millisecondsSinceEpoch}',
      email: googleEmail,
      name: existingUser?.name ?? 'Google 사용자',
      phoneNumber: existingUser?.phoneNumber,
      profileImageUrl: existingUser?.profileImageUrl ??
          'https://lh3.googleusercontent.com/a/default-user=s128-c',
      createdAt: existingUser?.createdAt ?? now,
      lastLoginAt: now,
      savedAccommodationIds: existingUser?.savedAccommodationIds ?? const [],
      preferences: existingUser?.preferences,
    );

    _users[user.id] = user;
    _currentUser = user;
    return user;
  }

  @override
  Future<UserModel> register(String email, String password, String name) async {
    await Future.delayed(const Duration(seconds: 1));

    if (_users.values.any((user) => user.email == email)) {
      throw Exception('User already exists');
    }

    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      phoneNumber: null,
      profileImageUrl: null,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      savedAccommodationIds: [],
      preferences: null,
    );

    _users[user.id] = user;
    _currentUser = user;

    return user;
  }

  @override
  Future<UserModel> getUserById(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final user = _users[userId];
    if (user == null) {
      throw Exception('User not found');
    }
    return user;
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _users[user.id] = user;
    if (_currentUser?.id == user.id) {
      _currentUser = user;
    }
    return user;
  }

  @override
  Future<void> deleteUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final removedUser = _users.remove(userId);
    if (removedUser == null) {
      throw Exception('User not found');
    }
    if (_currentUser?.id == userId) {
      _currentUser = null;
    }
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }

  @override
  Future<UserModel> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_currentUser == null) {
      throw Exception('No user logged in');
    }
    return _currentUser!;
  }

  @override
  Future<void> addSavedAccommodation(
      String userId, String accommodationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final user = _users[userId];
    if (user == null) {
      throw Exception('User not found');
    }

    final updatedSavedIds = List<String>.from(user.savedAccommodationIds);
    if (!updatedSavedIds.contains(accommodationId)) {
      updatedSavedIds.add(accommodationId);
    }

    final updatedUser = UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      phoneNumber: user.phoneNumber,
      profileImageUrl: user.profileImageUrl,
      createdAt: user.createdAt,
      lastLoginAt: user.lastLoginAt,
      savedAccommodationIds: updatedSavedIds,
      preferences: user.preferences,
    );

    _users[userId] = updatedUser;
    if (_currentUser?.id == userId) {
      _currentUser = updatedUser;
    }
  }

  @override
  Future<void> removeSavedAccommodation(
      String userId, String accommodationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final user = _users[userId];
    if (user == null) {
      throw Exception('User not found');
    }

    final updatedSavedIds = List<String>.from(user.savedAccommodationIds);
    updatedSavedIds.remove(accommodationId);

    final updatedUser = UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      phoneNumber: user.phoneNumber,
      profileImageUrl: user.profileImageUrl,
      createdAt: user.createdAt,
      lastLoginAt: user.lastLoginAt,
      savedAccommodationIds: updatedSavedIds,
      preferences: user.preferences,
    );

    _users[userId] = updatedUser;
    if (_currentUser?.id == userId) {
      _currentUser = updatedUser;
    }
  }
}
