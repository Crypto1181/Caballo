import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../widgets/theme_language_controls.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/translation_helper.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  List<OnboardingPage> _getPages(BuildContext context) {
    return [
      OnboardingPage(
        lottiePath: 'assets/Bitcoin trade.json',
        titleKey: 'try_crypto_earn',
        descriptionKey: 'first_buy_reward',
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      OnboardingPage(
        lottiePath: 'assets/Graph 1.json',
        titleKey: 'track_prices',
        descriptionKey: 'price_alerts',
        gradient: const LinearGradient(
          colors: [Color(0xFF1F2937), Color(0xFF374151)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      OnboardingPage(
        lottiePath: 'assets/Wyda graph animation.json',
        titleKey: 'buy_sell_hold',
        descriptionKey: 'buy_sell_easy',
        gradient: const LinearGradient(
          colors: [Color(0xFF065F46), Color(0xFF10B981)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final horseAsset = isDark
        ? 'assets/images/dark mode.png'
        : 'assets/images/for light mode.jpeg';

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with toggles
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Logo
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Image.asset(
                      horseAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stack) => Icon(
                        Icons.currency_bitcoin,
                        color: isDark ? Colors.white : Colors.black,
                        size: 48,
                      ),
                    ),
                  ),
                  const Spacer(),
                  ThemeLanguageControls(
                    spacing: 8,
                  ),
                ],
              ),
            ),

            // Browse assets text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Consumer<LanguageProvider>(
                builder: (context, lang, _) {
                  return Text(
                    context.t('browse_assets'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 40),

            // PageView with onboarding screens
            Expanded(
              child: Consumer<LanguageProvider>(
                builder: (context, lang, _) {
                  final pages = _getPages(context);
                  return PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      return _buildOnboardingPage(
                        pages[index],
                        isDark,
                        context,
                      );
                    },
                  );
                },
              ),
            ),

            // Page indicators
            Consumer<LanguageProvider>(
              builder: (context, lang, _) {
                final pages = _getPages(context);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(pages.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? (isDark ? Colors.white : Colors.black)
                              : (isDark ? Colors.grey[600] : Colors.grey[400]),
                        ),
                      );
                    }),
                  ),
                );
              },
            ),

            // Get started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Consumer<LanguageProvider>(
                builder: (context, lang, _) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SignupScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        context.t('get_started'),
                        style: TextStyle(
                          color: isDark ? Colors.black : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // OR divider
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Consumer<LanguageProvider>(
                    builder: (context, lang, _) {
                      return Text(
                        context.t('or'),
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    thickness: 1,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Google sign in button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    backgroundColor: isDark
                        ? Colors.grey[800]
                        : Colors.grey[100],
                  ),
                  icon: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.g_mobiledata,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  label: Consumer<LanguageProvider>(
                    builder: (context, lang, _) {
                      return Text(
                        context.t('continue_with_google'),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Sign in link
            Consumer<LanguageProvider>(
              builder: (context, lang, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.t('already_have_account'),
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 15,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        context.t('sign_in'),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(
    OnboardingPage page,
    bool isDark,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: page.gradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie animation
          Expanded(
            flex: 3,
            child: Lottie.asset(
              page.lottiePath,
              fit: BoxFit.contain,
              repeat: true,
              animate: true,
            ),
          ),

          const SizedBox(height: 20),

          // Title
          Consumer<LanguageProvider>(
            builder: (context, lang, _) {
              return Text(
                context.t(page.titleKey),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Description
          Consumer<LanguageProvider>(
            builder: (context, lang, _) {
              return Text(
                context.t(page.descriptionKey),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              );
            },
          ),

          if (page.titleKey == 'try_crypto_earn') ...[
            const SizedBox(height: 16),
            Consumer<LanguageProvider>(
              builder: (context, lang, _) {
                return Text(
                  context.t('terms_apply'),
                  style: const TextStyle(
                    color: Color(0xFF0052FF),
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String lottiePath;
  final String titleKey;
  final String descriptionKey;
  final LinearGradient gradient;

  OnboardingPage({
    required this.lottiePath,
    required this.titleKey,
    required this.descriptionKey,
    required this.gradient,
  });
}
