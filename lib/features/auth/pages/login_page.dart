import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/features/admin/pages/admin_dashboard_page.dart';
import 'package:crm/features/auth/pages/register_page.dart';
import 'package:crm/features/client/features/shell/main_shell.dart';
import 'package:crm/viewmodels/auth_viewmodel.dart';
import 'package:crm/viewmodels/user_role_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure       = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (_, next) async {
      if (next.status == AuthStatus.authenticated) {
        // Check the user's role in Firestore before navigating
        final profile = await ref.read(currentUserProfileProvider.future);
        if (!context.mounted) return;
        if (profile != null && profile.isAdmin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainShell()),
          );
        }
      }
      if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? 'Something went wrong'), behavior: SnackBarBehavior.floating),
        );
      }
    });

    final isLoading = ref.watch(authProvider).status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Top decorative section ─────────────────────────────────────
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 80, height: 80,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.primarySoft, width: 1.5),
                      ),
                      child: Image.asset('assets/logo/logo.png'),
                    ),
                    const SizedBox(height: 20),
                    const Text('Nexify CRM',
                        style: TextStyle(color: AppColors.textDark, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                    const SizedBox(height: 6),
                    Text('Your smart sales companion',
                        style: TextStyle(color: AppColors.textMid, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom form section ────────────────────────────────────────
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Welcome back',
                      style: TextStyle(color: AppColors.textDark, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  const Text('Sign in to continue',
                      style: TextStyle(color: AppColors.textMid, fontSize: 14)),
                  const SizedBox(height: 28),

                  // Email field
                  _label('Email address'),
                  _inputField(
                    controller: _emailCtrl,
                    hint: 'you@example.com',
                    icon: Symbols.mail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  _label('Password'),
                  _inputField(
                    controller: _passwordCtrl,
                    hint: '••••••••',
                    icon: Symbols.lock,
                    obscure: _obscure,
                    suffix: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textLight, size: 20),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Forgot password?',
                          style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Sign in button
                  _primaryButton(
                    isLoading: isLoading,
                    label: 'Sign In',
                    onPressed: () => ref.read(authProvider.notifier).login(
                      _emailCtrl.text.trim(), _passwordCtrl.text.trim(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Divider
                  Row(children: [
                    const Expanded(child: Divider(color: AppColors.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or continue with', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                    ),
                    const Expanded(child: Divider(color: AppColors.border)),
                  ]),
                  const SizedBox(height: 20),

                  // Google button
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(children: [
                            Icon(Icons.info_outline, color: Colors.white, size: 18),
                            SizedBox(width: 10),
                            Text('Google sign-in coming soon!'),
                          ]),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        SizedBox(width: 22, height: 22, child: Image.asset('assets/logo/google.png', errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 22))),
                        const SizedBox(width: 10),
                        const Text('Continue with Google', style: TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Sign up link
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                      child: Text.rich(TextSpan(
                        text: "Don't have an account? ",
                        style: const TextStyle(color: AppColors.textMid, fontSize: 14),
                        children: const [TextSpan(text: 'Sign up', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))],
                      )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(color: AppColors.textMid, fontSize: 13, fontWeight: FontWeight.w600)),
  );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textDark, fontSize: 15),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textLight),
        prefixIcon: Icon(icon, color: AppColors.textLight, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
    );
  }

  Widget _primaryButton({required bool isLoading, required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: isLoading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: AppColors.textDark, strokeWidth: 2))
              : Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}
