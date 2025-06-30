import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class SignInWithGoogleUseCase {
  final UserRepository repository;

  SignInWithGoogleUseCase(this.repository);

  Future<UserEntity> call() async {
    return await repository.signInWithGoogle();
  }
}

class SignInWithEmailUseCase {
  final UserRepository repository;

  SignInWithEmailUseCase(this.repository);

  Future<UserEntity> call(String email, String password) async {
    return await repository.signInWithEmail(email, password);
  }
}

class SignUpUseCase {
  final UserRepository repository;

  SignUpUseCase(this.repository);

  Future<UserEntity> call(String email, String password, String name) async {
    return await repository.signUp(email, password, name);
  }
}

class SignOutUseCase {
  final UserRepository repository;

  SignOutUseCase(this.repository);

  Future<void> call() async {
    return await repository.signOut();
  }
}

class GetCurrentUserUseCase {
  final UserRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<UserEntity?> call() async {
    return await repository.getCurrentUser();
  }
}

class SaveAccommodationUseCase {
  final UserRepository repository;

  SaveAccommodationUseCase(this.repository);

  Future<void> call(String userId, String accommodationId) async {
    return await repository.saveAccommodation(userId, accommodationId);
  }
}

class RemoveSavedAccommodationUseCase {
  final UserRepository repository;

  RemoveSavedAccommodationUseCase(this.repository);

  Future<void> call(String userId, String accommodationId) async {
    return await repository.removeSavedAccommodation(userId, accommodationId);
  }
}

class GetSavedAccommodationsUseCase {
  final UserRepository repository;

  GetSavedAccommodationsUseCase(this.repository);

  Future<List<String>> call(String userId) async {
    return await repository.getSavedAccommodations(userId);
  }
}