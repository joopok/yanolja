import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/provider/auth_provider.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_confirm_dialog.dart';

/// NOL(야놀자) 로그인 화면
///
/// 실제 NOL 로그인 화면을 분석해 재현했습니다.
/// - 흰 배경 + 회색 테두리의 pill 소셜 버튼(카카오·네이버·구글·애플)
/// - "이메일로 시작하기"를 누르면 이메일 로그인 폼으로 전환
/// - 하단 신규가입 혜택 배너
///
/// 기능: `<` 백버튼 없음, 하드웨어 백 차단 + 앱 종료 확인.
class LoginScreen extends ConsumerStatefulWidget {
  /// 로그아웃 직후 진입 여부. true이면 로그인 성공 시 홈으로 이동합니다.
  final bool fromLogout;

  const LoginScreen({super.key, this.fromLogout = false});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _emailMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ===================== 인증 동작 (목업) =====================

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);
    final auth = ref.read(authProvider);
    final result = await auth.signInWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (!mounted) return;

    if (result != null) {
      _showSnackBar(result);
      setState(() => _isLoading = false);
      return;
    }
    _leaveLogin();
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    final auth = ref.read(authProvider);
    final result = await auth.signInWithGoogle();
    if (!mounted) return;

    if (result != null) {
      _showSnackBar(result);
      setState(() => _isLoading = false);
      return;
    }
    _leaveLogin();
  }

  /// 카카오·네이버·Apple 등 소셜 로그인 (목업)
  Future<void> _signInWithProvider(String email) async {
    setState(() => _isLoading = true);
    final auth = ref.read(authProvider);
    final result = await auth.signInWithProvider(email);
    if (!mounted) return;

    if (result != null) {
      _showSnackBar(result);
      setState(() => _isLoading = false);
      return;
    }
    _leaveLogin();
  }

  /// 로그인 성공 후 화면 이동.
  void _leaveLogin() {
    if (widget.fromLogout) {
      context.go('/home');
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  /// 하드웨어 백 등으로 화면을 벗어나려 할 때 앱 종료 여부를 확인합니다.
  Future<void> _confirmExit() async {
    final shouldExit = await showYanoljaConfirmDialog(
      context: context,
      icon: Icons.exit_to_app_rounded,
      title: '앱 종료',
      message: '야놀자(NOL)를 종료할까요?',
      confirmText: '종료',
      isDestructive: true,
    );
    if (shouldExit) {
      await SystemNavigator.pop();
    }
  }

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    final scaffold = AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: YanoljaColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            child: Column(
              children: [
                const SizedBox(height: 12),
                _buildLogo(),
                const SizedBox(height: 28),
                _buildHeadline(),
                const SizedBox(height: 36),
                // 소셜 ↔ 이메일 전환
                AnimatedSize(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child:
                      _emailMode ? _buildEmailSection() : _buildSocialSection(),
                ),
                const SizedBox(height: 18),
                _buildFooterLinks(),
                const SizedBox(height: 28),
                _buildPromoBanner(),
                const SizedBox(height: 18),
                _buildTerms(),
              ],
            ),
          ),
        ),
      ),
    );

    // 로그인 화면에서는 백(안드로이드 하드웨어 백 포함)을 막고 앱 종료를 확인합니다.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _confirmExit();
      },
      child: scaffold,
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: YanoljaColors.primary,
        borderRadius: BorderRadius.circular(YanoljaRadius.xl),
      ),
      child: const Text(
        'NOL',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  /// "놀수록 놀라운 세상, NOL" + 서브카피 (실제 NOL 카피)
  Widget _buildHeadline() {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: YanoljaColors.textPrimary,
              letterSpacing: -0.5,
            ),
            children: [
              TextSpan(text: '놀수록 놀라운 세상, '),
              TextSpan(
                text: 'NOL',
                style: TextStyle(color: YanoljaColors.primaryPurple),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          '새로워진 NOL에서\n더 많은 즐거움과 혜택을 만나보세요',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            fontWeight: FontWeight.w500,
            color: YanoljaColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ----- 소셜 로그인 섹션 -----

  Widget _buildSocialSection() {
    return Column(
      key: const ValueKey('social'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _kakaoButton(),
        const SizedBox(height: 11),
        _naverButton(),
        const SizedBox(height: 11),
        _googleButton(),
        const SizedBox(height: 11),
        _appleButton(),
        const SizedBox(height: 14),
        Center(
          child: TextButton(
            onPressed:
                _isLoading ? null : () => setState(() => _emailMode = true),
            style: TextButton.styleFrom(
              foregroundColor: YanoljaColors.textSecondary,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '이메일로 시작하기',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                SizedBox(width: 2),
                Icon(Icons.chevron_right_rounded, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _kakaoButton() {
    return _socialButton(
      icon: const Icon(Icons.chat_bubble_rounded,
          size: 19, color: Color(0xFF191600)),
      text: '카카오로 시작하기',
      onTap: () => _signInWithProvider('kakao.user@kakao.com'),
    );
  }

  Widget _naverButton() {
    return _socialButton(
      icon: const Text(
        'N',
        style: TextStyle(
          color: Color(0xFF03C75A),
          fontSize: 19,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
      text: '네이버로 시작하기',
      onTap: () => _signInWithProvider('naver.user@naver.com'),
    );
  }

  Widget _googleButton() {
    return _socialButton(
      icon: const Icon(Icons.g_mobiledata_rounded,
          size: 26, color: Color(0xFF4285F4)),
      text: '구글로 시작하기',
      onTap: _signInWithGoogle,
    );
  }

  Widget _appleButton() {
    return _socialButton(
      icon: const Icon(Icons.apple, size: 21, color: Colors.black),
      text: '애플로 시작하기',
      onTap: () => _signInWithProvider('apple.user@icloud.com'),
    );
  }

  /// 실제 NOL 스타일 소셜 버튼 — 흰 배경 + 회색 테두리 + pill + 좌측 아이콘
  Widget _socialButton({
    required Widget icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 52,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(YanoljaRadius.pill),
        child: InkWell(
          onTap: _isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(YanoljaRadius.pill),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(YanoljaRadius.pill),
              border: Border.all(color: YanoljaColors.border),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(left: 20, child: icon),
                Text(
                  text,
                  style: const TextStyle(
                    color: YanoljaColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----- 이메일 로그인 섹션 -----

  Widget _buildEmailSection() {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('email'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: _inputDecoration(
              label: '이메일',
              icon: Icons.email_outlined,
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) =>
                (value?.trim().isEmpty ?? true) ? '이메일을 입력해주세요.' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            decoration: _inputDecoration(
              label: '비밀번호',
              icon: Icons.lock_outline_rounded,
            ),
            obscureText: true,
            validator: (value) =>
                (value?.isEmpty ?? true) ? '비밀번호를 입력해주세요.' : null,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: YanoljaColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: YanoljaColors.primaryLight,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: TextButton(
              onPressed:
                  _isLoading ? null : () => setState(() => _emailMode = false),
              style: TextButton.styleFrom(
                foregroundColor: YanoljaColors.textSecondary,
              ),
              child: const Text(
                '간편 로그인으로 돌아가기',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----- 하단 공통 -----

  /// 비밀번호 찾기 · 회원가입
  Widget _buildFooterLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: _isLoading ? null : () => context.push('/forgot-password'),
          style: TextButton.styleFrom(
            foregroundColor: YanoljaColors.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 10),
          ),
          child: const Text(
            '비밀번호 찾기',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
        ),
        Container(width: 1, height: 12, color: YanoljaColors.border),
        TextButton(
          onPressed: _isLoading ? null : () => context.push('/signup'),
          style: TextButton.styleFrom(
            foregroundColor: YanoljaColors.textPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 10),
          ),
          child: const Text(
            '회원가입',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  /// 신규가입 혜택 배너 (실제 NOL 하단 배너)
  Widget _buildPromoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: YanoljaSpacing.m),
      decoration: BoxDecoration(
        color: YanoljaColors.primaryLight,
        borderRadius: BorderRadius.circular(YanoljaRadius.lg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '처음이니까, 국내 10% 할인',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: YanoljaColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'NOL 신규가입 웰컴 혜택',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: YanoljaColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: YanoljaColors.primary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTerms() {
    return const Text(
      '개인정보 처리 사항은 개인정보 처리방침에서 확인하세요.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 11.5,
        height: 1.4,
        color: YanoljaColors.textTertiary,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: YanoljaColors.textSecondary, size: 21),
      filled: true,
      fillColor: YanoljaColors.surfaceAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(YanoljaRadius.md),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(YanoljaRadius.md),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(YanoljaRadius.md),
        borderSide: const BorderSide(color: YanoljaColors.primary, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(YanoljaRadius.md),
        borderSide: const BorderSide(color: YanoljaColors.sale, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(YanoljaRadius.md),
        borderSide: const BorderSide(color: YanoljaColors.sale, width: 1.2),
      ),
      labelStyle: const TextStyle(
        color: YanoljaColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: YanoljaSpacing.m, vertical: YanoljaSpacing.m),
    );
  }

  void _showSnackBar(String message) {
    YanoljaToast.show(
      context,
      message,
      icon: Icons.info_rounded,
    );
  }
}
