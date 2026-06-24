import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/provider/auth_provider.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';

/// NOL(야놀자) 회원가입 화면
///
/// 실제 NOL 로그인/회원가입 화면을 분석해 동일한 디자인 언어로 재현했습니다.
/// - 흰 배경 + 회색 테두리의 pill 소셜 버튼(카카오·네이버·구글·애플)
/// - "이메일로 가입하기"를 누르면 이메일 가입 폼으로 전환
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _emailMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ===================== 가입 동작 (목업) =====================

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);
    final auth = ref.read(authProvider);
    final result = await auth.signUpWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (!mounted) return;

    if (result != null) {
      _showSnackBar(result);
      setState(() => _isLoading = false);
      return;
    }
    _onJoined();
  }

  Future<void> _joinWithGoogle() async {
    setState(() => _isLoading = true);
    final auth = ref.read(authProvider);
    final result = await auth.signInWithGoogle();
    if (!mounted) return;

    if (result != null) {
      _showSnackBar(result);
      setState(() => _isLoading = false);
      return;
    }
    _onJoined();
  }

  /// 카카오·네이버·Apple 등 소셜 가입 (목업, 가입=로그인 처리)
  Future<void> _joinWithProvider(String email) async {
    setState(() => _isLoading = true);
    final auth = ref.read(authProvider);
    final result = await auth.signInWithProvider(email);
    if (!mounted) return;

    if (result != null) {
      _showSnackBar(result);
      setState(() => _isLoading = false);
      return;
    }
    _onJoined();
  }

  /// 가입 성공 후 홈으로 이동합니다.
  void _onJoined() => context.go('/home');

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanoljaColors.background,
      appBar: const YanoljaAppBar.sub(
        title: '회원가입',
        fallbackRoute: '/login',
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: Column(
            children: [
              const SizedBox(height: 4),
              _buildLogo(),
              const SizedBox(height: 24),
              _buildHeadline(),
              const SizedBox(height: 34),
              AnimatedSize(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child:
                    _emailMode ? _buildEmailSection() : _buildSocialSection(),
              ),
              const SizedBox(height: 18),
              _buildLoginLink(),
              const SizedBox(height: 28),
              _buildPromoBanner(),
              const SizedBox(height: 18),
              _buildTerms(),
            ],
          ),
        ),
      ),
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
              TextSpan(text: '지금 가입하고 '),
              TextSpan(
                text: 'NOL',
                style: TextStyle(color: YanoljaColors.primaryPurple),
              ),
              TextSpan(text: ' 혜택받기'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          '간편하게 가입하고\n국내·해외 특가 혜택을 만나보세요',
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

  // ----- 소셜 가입 섹션 -----

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
                  '이메일로 가입하기',
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
      onTap: () => _joinWithProvider('kakao.user@kakao.com'),
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
      onTap: () => _joinWithProvider('naver.user@naver.com'),
    );
  }

  Widget _googleButton() {
    return _socialButton(
      icon: const Icon(Icons.g_mobiledata_rounded,
          size: 26, color: Color(0xFF4285F4)),
      text: '구글로 시작하기',
      onTap: _joinWithGoogle,
    );
  }

  Widget _appleButton() {
    return _socialButton(
      icon: const Icon(Icons.apple, size: 21, color: Colors.black),
      text: '애플로 시작하기',
      onTap: () => _joinWithProvider('apple.user@icloud.com'),
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

  // ----- 이메일 가입 섹션 -----

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
            validator: (value) {
              if (value?.isEmpty ?? true) return '비밀번호를 입력해주세요.';
              if (value!.length < 6) return '비밀번호는 6자 이상이어야 합니다.';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: _inputDecoration(
              label: '비밀번호 확인',
              icon: Icons.verified_user_outlined,
            ),
            obscureText: true,
            validator: (value) {
              if (value != _passwordController.text) {
                return '비밀번호가 일치하지 않습니다.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _signUp,
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
                      '가입하기',
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
                '간편 가입으로 돌아가기',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----- 하단 공통 -----

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '이미 계정이 있으신가요?',
          style: TextStyle(
            fontSize: 13.5,
            color: YanoljaColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/login');
                  }
                },
          style: TextButton.styleFrom(
            foregroundColor: YanoljaColors.primary,
          ),
          child: const Text(
            '로그인',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
      '가입 시 이용약관 및 개인정보처리방침에 동의하게 됩니다.',
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
