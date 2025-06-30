import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/presentation/provider/auth_provider.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final auth = ref.read(authProvider);
      final result = await auth.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
      // On successful sign up, the auth state change will handle navigation.
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('여행을 시작해볼까요?', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('새로운 계정을 만들어주세요.', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: '이메일', prefixIcon: Icon(Icons.email_outlined)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value?.isEmpty ?? true) ? '이메일을 입력해주세요.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: '비밀번호', prefixIcon: Icon(Icons.lock_outline)),
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return '비밀번호를 입력해주세요.';
                    if (value!.length < 6) return '비밀번호는 6자 이상이어야 합니다.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(labelText: '비밀번호 확인', prefixIcon: Icon(Icons.lock_outline)),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) return '비밀번호가 일치하지 않습니다.';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _signUp,
                        child: const Text('회원가입 완료'),
                      ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('이미 계정이 있으신가요?'),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('로그인'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
