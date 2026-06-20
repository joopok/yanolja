import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';

/// 프로필 수정 화면
///
/// 닉네임, 이메일, 휴대폰 번호를 편집하고 저장합니다. (mock 저장)
/// 저장 시 안내 후 이전 화면(마이)으로 돌아갑니다.
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'NOL 회원');
  final _emailController = TextEditingController(text: 'doshyun@gmail.com');
  final _phoneController = TextEditingController(text: '010-1234-5678');
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String get _initial {
    final name = _nameController.text.trim();
    return name.isEmpty ? 'N' : name.characters.first;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text(
            '프로필이 저장되었어요',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: YanoljaColors.textPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(YanoljaRadius.md),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanoljaColors.surfaceAlt,
      appBar: const YanoljaAppBar.sub(
        title: '프로필 수정',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
          children: [
            _buildAvatarHeader(),
            const SizedBox(height: 8),
            _buildSection(
              title: '기본 정보',
              children: [
                _buildField(
                  label: '닉네임',
                  controller: _nameController,
                  icon: Icons.person_outline_rounded,
                  onChanged: (_) => setState(() {}),
                  validator: (value) =>
                      (value?.trim().isEmpty ?? true) ? '닉네임을 입력해주세요.' : null,
                ),
                _buildField(
                  label: '이메일',
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return '이메일을 입력해주세요.';
                    if (!v.contains('@') || !v.contains('.')) {
                      return '올바른 이메일 형식이 아니에요.';
                    }
                    return null;
                  },
                ),
                _buildField(
                  label: '휴대폰 번호',
                  controller: _phoneController,
                  icon: Icons.phone_iphone_rounded,
                  keyboardType: TextInputType.phone,
                  isLast: true,
                  validator: (value) => (value?.trim().isEmpty ?? true)
                      ? '휴대폰 번호를 입력해주세요.'
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: YanoljaColors.background,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: YanoljaColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: YanoljaColors.primaryLight,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(YanoljaRadius.md),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      '저장하기',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarHeader() {
    return Container(
      color: YanoljaColors.background,
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      YanoljaColors.primary,
                      YanoljaColors.primaryPurple,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: YanoljaColors.border, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.photo_camera_rounded,
                    size: 16,
                    color: YanoljaColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _pickAvatarColorHint,
            style: TextButton.styleFrom(
              foregroundColor: YanoljaColors.primary,
            ),
            child: const Text(
              '사진 변경',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }

  void _pickAvatarColorHint() {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text(
            '프로필 사진은 닉네임 첫 글자로 자동 생성돼요',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: YanoljaColors.textPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(YanoljaRadius.md),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      color: YanoljaColors.background,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: YanoljaColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
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
            borderSide:
                const BorderSide(color: YanoljaColors.primary, width: 1.2),
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
