import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../utils/translation_helper.dart';
import '../widgets/language_toggle.dart';
import '../providers/language_provider.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                color: AppColors.lightBackground,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Language toggle in top right
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: const LanguageToggle(),
                  ),
                ),
                const SizedBox(height: 24),
                // Title Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Consumer<LanguageProvider>(
                        builder: (context, lang, _) {
                          return Text(
                            context.t('welcome'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w300,
                              color: Colors.black87,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Caballo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Consumer<LanguageProvider>(
                        builder: (context, lang, _) {
                          return Text(
                            context.t('get_started'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Illustration Area
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Image.asset(
                      'assets/images/horse.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stack) => const SizedBox.shrink(),
                    ),
                  ),
                ),
            // Call to Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.black26),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        backgroundColor: AppColors.lightGreen,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Consumer<LanguageProvider>(
                        builder: (context, lang, _) {
                          return Text(
                            context.t('log_in'),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SignupScreen(),
                          ),
                        );
                      },
                      child: Consumer<LanguageProvider>(
                        builder: (context, lang, _) {
                          return Text(
                            context.t('sign_up'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

