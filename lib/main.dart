import 'package:crm/core/theme/app_theme.dart';
import 'package:crm/features/auth/pages/login_page.dart';
import 'package:crm/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crm/features/client/features/shell/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ProviderScope(child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final user = snapshot.data;
            if (user == null) return const LoginPage();
            return const MainShell();
          }
          return const Scaffold(
            backgroundColor: Color(0xFFEEEFF8),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
            ),
          );
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
