import 'package:crm/core/widgets/large_text_field.dart';
import 'package:crm/core/widgets/submit_button.dart';
import 'package:crm/features/auth/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
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
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF96E1FF).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset('assets/logo/logo.png', scale: 3),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Create your account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sign up to your CRM account',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 56),

                  Text(
                    'Name',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  largeTextField(
                    hintText: 'Enter your name',
                    textController: emailController,
                    icon: Symbols.person,
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Email',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  largeTextField(
                    hintText: 'Enter your email',
                    textController: emailController,
                    icon: Symbols.mail,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Password',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  largeTextField(
                    hintText: 'Enter your password',
                    textController: passwordController,
                    icon: Symbols.lock,
                    obscureText: true,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFC56BFF), Color(0xFF96E1FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF96E1FF).withOpacity(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: submitButton(text: "Register", onPressed: () {}),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 24, top: 32),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return LoginPage();
                                  },
                                ),
                              );
                            },
                            child: Text.rich(
                              TextSpan(
                                text: "Already have an account? ",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 13,
                                ),
                                children: const [
                                  TextSpan(
                                    text: 'Login',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
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
