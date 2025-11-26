import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../utils/translation_helper.dart';
import '../widgets/theme_language_controls.dart';
import 'signup_screen.dart';
import 'login_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      // Navigate to password screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LoginPasswordScreen(
            email: _emailController.text.trim(),
          ),
        ),
      );
    }
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  
                  // Top controls
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: isDark ? Colors.white : Colors.black,
                          size: 28,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const Spacer(),
                      ThemeLanguageControls(
                        spacing: 6,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Consumer<LanguageProvider>(
                      builder: (context, lang, _) {
                        return TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SignupScreen(),
                              ),
                            );
                          },
                          child: Text(
                            context.t('sign_up'),
                            style: const TextStyle(
                              color: Color(0xFF0052FF),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Logo
                  Center(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.asset(
                        horseAsset,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stack) => Icon(
                          Icons.currency_bitcoin,
                          color: isDark ? Colors.white : Colors.black,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Title
                  Consumer<LanguageProvider>(
                    builder: (context, lang, _) {
                      return Text(
                        context.t('sign_in_to_coinbase'),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Email label
                  Consumer<LanguageProvider>(
                    builder: (context, lang, _) {
                      return Text(
                        context.t('email'),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Email field
                  Consumer<LanguageProvider>(
                    builder: (context, lang, _) {
                      return TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: context.t('your_email_address'),
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white : Colors.black,
                        width: 2,
                      ),
                    ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, 
                            vertical: 16
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                
                const SizedBox(height: 40),
                
                // Continue button
                Consumer<LanguageProvider>(
                  builder: (context, lang, _) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          context.t('continue'),
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
                
                const SizedBox(height: 30),
                
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
                
                const SizedBox(height: 30),
                
                // Alternative sign-in options
                Consumer<LanguageProvider>(
                  builder: (context, lang, _) {
                    return Column(
                      children: [
                        _buildAlternativeButton(
                          icon: Icons.key,
                          label: context.t('sign_in_with_passkey'),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        _buildAlternativeButton(
                          icon: Icons.g_mobiledata,
                          label: context.t('sign_in_with_google'),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        _buildAlternativeButton(
                          icon: Icons.apple,
                          label: context.t('sign_in_with_apple'),
                          isDark: isDark,
                        ),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 60),
                
                // Privacy notice
                Consumer<LanguageProvider>(
                  builder: (context, lang, _) {
                    return RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 13,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(
                            text: context.t('cookie_policy_text'),
                          ),
                          TextSpan(
                            text: context.t('cookie_policy'),
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              color: Color(0xFF0052FF),
                            ),
                          ),
                          TextSpan(text: context.t('and')),
                          TextSpan(
                            text: context.t('privacy_policy'),
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              color: Color(0xFF0052FF),
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
              ],
            ),
              ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlternativeButton({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _handleContinue(),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
        ),
        icon: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: icon == Icons.g_mobiledata ? Colors.white : Colors.transparent,
          ),
          child: Icon(
            icon,
            color: icon == Icons.g_mobiledata 
                ? Colors.black 
                : (isDark ? Colors.white : Colors.black),
            size: 20,
          ),
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

