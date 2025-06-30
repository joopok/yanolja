import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/user_usecases.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/datasources/user_local_datasource.dart';

// Repository Provider
final userRepositoryProvider = Provider((ref) {
  return UserRepositoryImpl(UserLocalDataSource());
});

// UseCase Providers
final signInWithEmailUseCaseProvider = Provider((ref) {
  return SignInWithEmailUseCase(ref.watch(userRepositoryProvider));
});

final signUpUseCaseProvider = Provider((ref) {
  return SignUpUseCase(ref.watch(userRepositoryProvider));
});

final signOutUseCaseProvider = Provider((ref) {
  return SignOutUseCase(ref.watch(userRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider((ref) {
  return GetCurrentUserUseCase(ref.watch(userRepositoryProvider));
});

// Note: UpdateUserUseCase not implemented in domain layer yet

final getSavedAccommodationsUseCaseProvider = Provider((ref) {
  return GetSavedAccommodationsUseCase(ref.watch(userRepositoryProvider));
});

final saveAccommodationUseCaseProvider = Provider((ref) {
  return SaveAccommodationUseCase(ref.watch(userRepositoryProvider));
});

final removeSavedAccommodationUseCaseProvider = Provider((ref) {
  return RemoveSavedAccommodationUseCase(ref.watch(userRepositoryProvider));
});

// State Providers
final currentUserProvider = StateNotifierProvider<UserNotifier, AsyncValue<UserEntity?>>((ref) {
  return UserNotifier(ref);
});

final savedAccommodationsProvider = StateNotifierProvider<SavedAccommodationsNotifier, AsyncValue<List<String>>>((ref) {
  return SavedAccommodationsNotifier(ref);
});

// State Notifiers
class UserNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final Ref ref;

  UserNotifier(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() async {
    try {
      final useCase = ref.read(getCurrentUserUseCaseProvider);
      final user = await useCase();
      state = AsyncValue.data(user);
    } catch (e) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final useCase = ref.read(signInWithEmailUseCaseProvider);
      final user = await useCase(email, password);
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    state = const AsyncValue.loading();
    try {
      final useCase = ref.read(signUpUseCaseProvider);
      final user = await useCase(email, password, name);
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signOut() async {
    try {
      final useCase = ref.read(signOutUseCaseProvider);
      await useCase();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateUser(UserEntity user) async {
    try {
      final repository = ref.read(userRepositoryProvider);
      await repository.updateUser(user);
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

class SavedAccommodationsNotifier extends StateNotifier<AsyncValue<List<String>>> {
  final Ref ref;

  SavedAccommodationsNotifier(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() async {
    final userAsync = ref.read(currentUserProvider);
    userAsync.when(
      data: (user) async {
        if (user != null) {
          try {
            final useCase = ref.read(getSavedAccommodationsUseCaseProvider);
            final savedIds = await useCase(user.id);
            state = AsyncValue.data(savedIds);
          } catch (e) {
            state = const AsyncValue.data([]);
          }
        } else {
          state = const AsyncValue.data([]);
        }
      },
      loading: () => state = const AsyncValue.loading(),
      error: (error, stack) => state = const AsyncValue.data([]),
    );
  }

  Future<void> saveAccommodation(String accommodationId) async {
    final userAsync = ref.read(currentUserProvider);
    final user = userAsync.value;
    if (user == null) return;

    try {
      final useCase = ref.read(saveAccommodationUseCaseProvider);
      await useCase(user.id, accommodationId);
      
      final currentList = state.value ?? [];
      state = AsyncValue.data([...currentList, accommodationId]);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> removeSavedAccommodation(String accommodationId) async {
    final userAsync = ref.read(currentUserProvider);
    final user = userAsync.value;
    if (user == null) return;

    try {
      final useCase = ref.read(removeSavedAccommodationUseCaseProvider);
      await useCase(user.id, accommodationId);
      
      final currentList = state.value ?? [];
      state = AsyncValue.data(currentList.where((id) => id != accommodationId).toList());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  bool isSaved(String accommodationId) {
    return state.value?.contains(accommodationId) ?? false;
  }
}