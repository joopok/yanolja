import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱 사용자 모델
///
/// 이 프로젝트는 Firebase가 비활성화(GoogleService-Info.plist 미포함)되어 있어
/// 실제 FirebaseAuth 대신 목업(mock) 인증을 사용합니다.
/// 따라서 Firebase `User` 타입 대신 가벼운 [AppUser] 모델을 사용합니다.
class AppUser {
  final String email;
  final String displayName;

  const AppUser({required this.email, required this.displayName});
}

/// 인증 상태 관리 (Firebase 미설정 환경을 위한 목업 인증)
///
/// 기본값을 로그인 상태로 두어 Firebase 없이도 마이 화면이
/// 정상적으로 전체 UI를 표시하도록 합니다.
class AuthNotifier extends StateNotifier<AppUser?> {
  AuthNotifier() : super(_defaultUser);

  /// 데모용 기본 로그인 사용자
  static const AppUser _defaultUser = AppUser(
    email: 'guest@nol.com',
    displayName: 'NOL러',
  );

  /// 이메일 기반 로그인 (목업)
  void signIn(String email) {
    final trimmed = email.trim();
    final safeEmail = trimmed.isEmpty ? 'guest@nol.com' : trimmed;
    final name =
        safeEmail.contains('@') ? safeEmail.split('@').first : safeEmail;
    state =
        AppUser(email: safeEmail, displayName: name.isEmpty ? 'NOL러' : name);
  }

  /// 로그아웃
  void signOut() => state = null;
}

/// 현재 로그인 상태를 보유하는 Provider
final authStateProvider =
    StateNotifierProvider<AuthNotifier, AppUser?>((ref) => AuthNotifier());

/// 기존 `.when(data/loading/error)` 호출부와 호환되도록 AsyncValue로 래핑한 Provider
///
/// 목업 인증은 동기적으로 상태가 결정되므로 항상 `AsyncValue.data`를 반환합니다.
final authStateChangesProvider = Provider<AsyncValue<AppUser?>>((ref) {
  return AsyncValue.data(ref.watch(authStateProvider));
});

/// 인증 동작(로그인/회원가입/로그아웃)을 제공하는 Provider
final authProvider = Provider<AuthProvider>((ref) => AuthProvider(ref));

/// 인증 로직을 관리하는 AuthProvider (목업)
///
/// 모든 메서드는 성공 시 `null`, 실패 시 한국어 에러 메시지(String)를 반환합니다.
/// (기존 FirebaseAuth 기반 API 시그니처를 그대로 유지합니다.)
class AuthProvider {
  final Ref _ref;

  AuthProvider(this._ref);

  /// 이메일/비밀번호 회원가입 (목업)
  Future<String?> signUpWithEmailAndPassword(
      String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 350));
    if (email.isEmpty || password.isEmpty) {
      return '이메일과 비밀번호를 입력해주세요.';
    }
    if (!email.contains('@')) {
      return '유효하지 않은 이메일 형식입니다.';
    }
    if (password.length < 6) {
      return '비밀번호는 6자 이상이어야 합니다.';
    }
    _ref.read(authStateProvider.notifier).signIn(email);
    return null;
  }

  /// 이메일/비밀번호 로그인 (목업)
  Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 350));
    if (email.isEmpty || password.isEmpty) {
      return '이메일과 비밀번호를 입력해주세요.';
    }
    if (password.length < 6) {
      return '비밀번호는 6자 이상이어야 합니다.';
    }
    _ref.read(authStateProvider.notifier).signIn(email);
    return null;
  }

  /// Google 로그인 (목업)
  Future<String?> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 350));
    _ref.read(authStateProvider.notifier).signIn('google.user@gmail.com');
    return null;
  }

  /// 소셜 로그인 (목업) — 카카오·네이버·Apple 등
  ///
  /// 실제 SDK 연동 없이 전달된 이메일로 로그인 상태를 만듭니다.
  Future<String?> signInWithProvider(String providerEmail) async {
    await Future.delayed(const Duration(milliseconds: 350));
    _ref.read(authStateProvider.notifier).signIn(providerEmail);
    return null;
  }

  /// 로그아웃
  Future<void> signOut() async {
    _ref.read(authStateProvider.notifier).signOut();
  }
}
