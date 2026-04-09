import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/core/widgets/large_text_field.dart';
import 'package:crm/core/widgets/submit_button.dart';
import 'package:crm/features/auth/pages/login_page.dart';
import 'package:crm/features/client/features/shell/main_shell.dart';
import 'package:crm/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainShell()));
      }
      if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.errorMessage ?? 'Something went wrong')));
      }
    });
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.18), blurRadius: 20, offset: const Offset(0, 8))],
                          ),
                          child: Image.asset('assets/logo/logo.png'),
                        ),
                        const SizedBox(height: 24),
                        const Text('Create your account', style: TextStyle(color: AppColors.textDark, fontSize: 28, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        const Text('Sign up to your CRM account', style: TextStyle(color: AppColors.textMid, fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 52),
                  const Text('Name', style: TextStyle(color: AppColors.textMid, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  largeTextField(hintText: 'Enter your name', textController: nameController, icon: Symbols.person),
                  const SizedBox(height: 20),
                  const Text('Email', style: TextStyle(color: AppColors.textMid, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  largeTextField(hintText: 'Enter your email', textController: emailController, icon: Symbols.mail),
                  const SizedBox(height: 20),
                  const Text('Password', style: TextStyle(color: AppColors.textMid, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  largeTextField(hintText: 'Enter your password', textController: passwordController, icon: Symbols.lock, obscureText: true),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.30), blurRadius: 18, offset: const Offset(0, 8))],
                      ),
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : submitButton(
                              text: 'Register',
                              onPressed: () => ref.read(authProvider.notifier).register(emailController.text.trim(), passwordController.text.trim(), nameController.text.trim()),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24, top: 28),
                    child: Center(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage())),
                        child: Text.rich(
                          TextSpan(
                            text: 'Already have an account? ',
                            style: const TextStyle(color: AppColors.textMid, fontSize: 13),
                            children: const [
                              TextSpan(text: 'Login', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
