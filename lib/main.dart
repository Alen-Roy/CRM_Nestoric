import 'package:crm/features/auth/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(ProviderScope(child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.white,
        selectionColor: Colors.white24,
        selectionHandleColor: Colors.white,
      ),
    );

    return MaterialApp(
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.montserratTextTheme(baseTheme.textTheme),
        primaryTextTheme: GoogleFonts.montserratTextTheme(
          baseTheme.primaryTextTheme,
        ),
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
