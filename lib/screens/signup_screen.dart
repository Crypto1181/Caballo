import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../utils/translation_helper.dart';
import '../widgets/theme_language_controls.dart';
import '../services/supabase_service.dart';
import '../services/privy_service.dart';
import 'onboarding_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = SupabaseService.client;
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        if (response.user != null) {
          // Signup successful - create Privy wallet and Alpaca account
          final userId = response.user!.id;
          
          try {
            // Create Privy embedded wallet
            if (PrivyService.instance.isInitialized) {
              await PrivyService.instance.createEmbeddedWallet(
                userId: userId,
                chain: 'ethereum',
              );
              debugPrint('✅ Privy wallet created');
            } else {
              debugPrint('⚠️ Privy not initialized, skipping wallet creation');
            }

            // Create Alpaca account (you'll need to collect KYC info first)
            // For now, we'll skip this and do it later in onboarding
            // TODO: Collect KYC info and create Alpaca account
            
          } catch (e) {
            debugPrint('⚠️ Error creating wallet/account: $e');
            // Continue anyway - user can complete setup later
          }

          // Navigate to onboarding screen to collect KYC info
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Please check your email to confirm your account.';
          });
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Extract meaningful error message
          String errorMsg = e.message;
          if (errorMsg.contains('User already registered') ||
              errorMsg.contains('already registered') ||
              errorMsg.contains('already exists')) {
            errorMsg = 'An account with this email already exists';
          } else if (errorMsg.contains('Password') ||
              errorMsg.contains('password') ||
              errorMsg.contains('6 characters')) {
            errorMsg = 'Password must be at least 6 characters';
          } else if (errorMsg.contains('Invalid email')) {
            errorMsg = 'Please enter a valid email address';
          }
          _errorMessage = errorMsg;
        });
      }
      debugPrint('Signup AuthException: ${e.message}');
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          String errorMsg = e.toString();
          if (errorMsg.contains('User already registered') ||
              errorMsg.contains('already registered') ||
              errorMsg.contains('already exists')) {
            errorMsg = 'An account with this email already exists';
          } else if (errorMsg.contains('Password') ||
              errorMsg.contains('password') ||
              errorMsg.contains('6 characters')) {
            errorMsg = 'Password must be at least 6 characters';
          } else if (errorMsg.contains('network') ||
              errorMsg.contains('connection') ||
              errorMsg.contains('timeout')) {
            errorMsg =
                'Network error. Please check your connection and try again.';
          } else {
            errorMsg = 'An error occurred: ${e.toString()}';
          }
          _errorMessage = errorMsg;
        });
      }
      debugPrint('Signup error: $e');
      debugPrint('Stack trace: $stackTrace');
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

                  // Top section with close button
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
                      ThemeLanguageControls(spacing: 6),
                    ],
                  ),

                  const SizedBox(height: 60),

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
                        context.t('create_your_account'),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  Consumer<LanguageProvider>(
                    builder: (context, lang, _) {
                      return Text(
                        context.t('access_coinbase'),
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.grey[600],
                          height: 1.4,
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
                          fillColor: isDark
                              ? Colors.grey[900]
                              : Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
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
                            vertical: 16,
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

                  const SizedBox(height: 24),

                  // Password label
                  Consumer<LanguageProvider>(
                    builder: (context, lang, _) {
                      return Text(
                        context.t('create_password'),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // Password description
                  Consumer<LanguageProvider>(
                    builder: (context, lang, _) {
                      return Text(
                        context.t('password_description'),
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Password field
                  Consumer<LanguageProvider>(
                    builder: (context, lang, _) {
                      return TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: context.t('password'),
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Colors.grey[900]
                              : Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
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
                            vertical: 16,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      );
                    },
                  ),

                  // Error message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ],

                  const SizedBox(height: 40),

                  // Continue button
                  Consumer<LanguageProvider>(
                    builder: (context, lang, _) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.white : Colors.black,
                            disabledBackgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isDark ? Colors.black : Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
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

                  const SizedBox(height: 60),

                  // Terms and Privacy notice
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
                            TextSpan(text: context.t('account_certify')),
                            TextSpan(
                              text: context.t('privacy_policy'),
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                                color: Color(0xFF0052FF),
                              ),
                            ),
                            TextSpan(text: context.t('and')),
                            TextSpan(
                              text: context.t('financial_privacy_notice'),
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

                  const SizedBox(height: 30),

                  // Cookie notice
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
                            TextSpan(text: context.t('cookie_policy_text')),
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
}
