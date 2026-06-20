import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';

/// 비밀번호 찾기 화면
///
/// 가입한 이메일을 입력하면 재설정 링크 발송을 안내합니다. (mock 동작)
/// 로그인·회원가입 화면과 동일한 NOL 디자인 언어(중앙 정렬 헤더 + 동일 폼)를
/// 유지합니다.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isSent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanoljaColors.background,
      appBar: const YanoljaAppBar.sub(
        title: '비밀번호 찾기',
        fallbackRoute: '/login',
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          child: _isSent ? _buildSentView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      key: const ValueKey('form'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          _buildHeader(),
          const SizedBox(height: 36),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _emailController,
              decoration: _inputDecoration(
                label: '이메일',
                icon: Icons.email_outlined,
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) return '이메일을 입력해주세요.';
                if (!v.contains('@') || !v.contains('.')) {
                  return '올바른 이메일 형식이 아니에요.';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
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
                      '재설정 링크 받기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 18),
          _buildHelp(),
        ],
      ),
    );
  }

  /// 헤더 — 중앙 정렬 아이콘 배지 + 제목 + 안내 (로그인/회원가입과 동일 톤)
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: YanoljaColors.primaryLight,
            borderRadius: BorderRadius.circular(YanoljaRadius.xl),
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            color: YanoljaColors.primary,
            size: 36,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          '비밀번호 찾기',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: YanoljaColors.textPrimary,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '가입하신 이메일로 비밀번호 재설정 링크를 보내드려요',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            fontWeight: FontWeight.w500,
            color: YanoljaColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildHelp() {
    return const Text(
      '이메일이 오지 않으면 스팸함을 확인해주세요.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 11.5,
        height: 1.4,
        color: YanoljaColors.textTertiary,
      ),
    );
  }

  Widget _buildSentView() {
    return Padding(
      key: const ValueKey('sent'),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Center(
            child: Container(
              width: 84,
              height: 84,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: YanoljaColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_read_rounded,
                color: YanoljaColors.primary,
                size: 42,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '이메일을 확인해주세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: YanoljaColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${_emailController.text.trim()} 으로\n비밀번호 재설정 링크를 보냈어요',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: YanoljaColors.textSecondary,
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/login');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: YanoljaColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                ),
              ),
              child: const Text(
                '로그인으로 돌아가기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() => _isSent = false),
            style: TextButton.styleFrom(
              foregroundColor: YanoljaColors.textSecondary,
            ),
            child: const Text(
              '다른 이메일로 다시 보내기',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
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
}
