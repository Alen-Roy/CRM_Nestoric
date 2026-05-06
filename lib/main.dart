import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/core/theme/app_theme.dart';
import 'package:crm/features/admin/pages/admin_dashboard_page.dart';
import 'package:crm/features/auth/pages/login_page.dart';
import 'package:crm/firebase_options.dart';
import 'package:crm/features/client/features/shell/main_shell.dart';
import 'package:crm/viewmodels/user_role_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Transparent status bar + dark nav bar to match bottom nav
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:                    Colors.transparent,
    statusBarIconBrightness:           Brightness.dark,
    systemNavigationBarColor:          AppColors.background,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MainApp()));
}

/// Global navigator key — lets us navigate from anywhere (e.g. after logout)
/// without needing a BuildContext from inside the tree.
final navigatorKey = GlobalKey<NavigatorState>();

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ── Logout detection ──────────────────────────────────────────────────────
    // Watch the profile stream. When it transitions from a logged-in user
    // to null (sign-out), imperatively clear the ENTIRE navigator stack and
    // push LoginPage. This handles routes pushed on top of home: (e.g.
    // SettingsPage) that home: swapping alone cannot remove.
    ref.listen<AsyncValue<dynamic>>(currentUserProfileProvider, (prev, next) {
      // Had a logged-in user before, now null → signed out
      final hadUser = prev?.when(
        data:    (u) => u != null,
        loading: ()  => false,
        error:   (_, __) => false,
      ) ?? false;
      final hasUser = next.when(
        data:    (u) => u != null,
        loading: ()  => false,
        error:   (_, __) => false,
      );

      if (hadUser && !hasUser) {
        // ── Sign-out: clear stack → LoginPage ────────────────────────────────
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (_) => false,
        );
      } else if (!hadUser && hasUser) {
        // ── Sign-in: clear stack → correct dashboard ──────────────────────────
        next.whenData((profile) {
          final destination = (profile?.isAdmin == true)
              ? const AdminDashboardPage()
              : const MainShell();
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => destination),
            (_) => false,
          );
        });
      }
    });

    return MaterialApp(
      navigatorKey:               navigatorKey,
      title:                      'Nexify CRM',
      theme:                      AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: ref.watch(currentUserProfileProvider).when(
        // Loading — show premium splash
        loading: () => const _SplashScreen(),
        error:   (_, __) => const LoginPage(),
        data: (userProfile) {
          // Not logged in
          if (userProfile == null) return const LoginPage();
          // Admin → Admin dashboard
          if (userProfile.isAdmin) return const AdminDashboardPage();
          // Regular user → normal shell
          return const MainShell();
        },
      ),
    );
  }
}

/// Premium animated splash screen shown while Firebase initialises.
class _SplashScreen extends StatefulWidget {
  const _SplashScreen();
  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _fadeAnim;
  late final Animation<double>   _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Container(
                    width: 90, height: 90,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: AppColors.primarySoft, width: 1.5),
                    ),
                    child: Image.asset('assets/logo/logo.png'),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Nexify CRM',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your smart sales companion',
                    style: TextStyle(color: AppColors.textMid, fontSize: 14),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.textMid,
                      strokeWidth: 2,
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
