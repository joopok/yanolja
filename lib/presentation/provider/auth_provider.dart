import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// FirebaseAuth 인스턴스를 제공하는 Provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

// 로그인 상태를 실시간으로 감지하는 StreamProvider
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// 인증 로직을 관리하는 AuthProvider
final authProvider = Provider<AuthProvider>((ref) {
  return AuthProvider(ref.watch(firebaseAuthProvider));
});

class AuthProvider {
  final FirebaseAuth _auth;

  AuthProvider(this._auth);

  // 이메일/비밀번호로 회원가입
  Future<String?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // 성공 시 null 반환
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code); // 에러 메시지 반환
    } catch (e) {
      return '알 수 없는 오류가 발생했습니다.';
    }
  }

  // 이메일/비밀번호로 로그인
  Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // 성공 시 null 반환
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code); // 에러 메시지 반환
    } catch (e) {
      return '알 수 없는 오류가 발생했습니다.';
    }
  }

  // Google로 로그인 (임시 비활성화)
  Future<String?> signInWithGoogle() async {
    return 'Google 로그인이 현재 사용할 수 없습니다. 이메일/비밀번호로 로그인해주세요.';
  }

  // 에러 코드에 따른 메시지 반환
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'invalid-email':
        return '유효하지 않은 이메일 형식입니다.';
      case 'weak-password':
        return '비밀번호는 6자 이상이어야 합니다.';
      case 'user-not-found':
        return '등록되지 않은 이메일입니다.';
      case 'wrong-password':
        return '비밀번호가 일치하지 않습니다.';
      case 'network-request-failed':
        return '네트워크 연결을 확인해주세요.';
      case 'too-many-requests':
        return '로그인 시도 횟수가 너무 많습니다. 잠시 후 다시 시도해주세요.';
      default:
        return '로그인/회원가입에 실패했습니다. 다시 시도해주세요.';
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
    // Google Sign-In은 임시로 비활성화
  }
}
