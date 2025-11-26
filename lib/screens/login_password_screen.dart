import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../utils/translation_helper.dart';
import '../widgets/theme_language_controls.dart';
import '../services/supabase_service.dart';

class LoginPasswordScreen extends StatefulWidget {
  final String email;

  const LoginPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<LoginPasswordScreen> createState() => _LoginPasswordScreenState();
}

class _LoginPasswordScreenState extends State<LoginPasswordScreen> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = SupabaseService.client;
      final response = await supabase.auth.signInWithPassword(
        email: widget.email.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        if (response.user != null) {
          // Login successful
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const MainScreen(),
            ),
          );
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Login failed. Please try again.';
          });
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          String errorMsg = e.message;
          if (errorMsg.contains('Invalid login credentials') ||
              errorMsg.contains('Invalid credentials') ||
              errorMsg.contains('Email not confirmed')) {
            errorMsg = 'Invalid email or password';
          } else if (errorMsg.contains('Email not confirmed')) {
            errorMsg = 'Please confirm your email address before signing in';
          } else if (errorMsg.contains('Too many requests')) {
            errorMsg = 'Too many login attempts. Please try again later.';
          }
          _errorMessage = errorMsg;
        });
      }
      debugPrint('Login AuthException: ${e.message}');
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          String errorMsg = e.toString();
          if (errorMsg.contains('Invalid login credentials') ||
              errorMsg.contains('Invalid credentials')) {
            errorMsg = 'Invalid email or password';
          } else if (errorMsg.contains('network') ||
                     errorMsg.contains('connection') ||
                     errorMsg.contains('timeout')) {
            errorMsg = 'Network error. Please check your connection and try again.';
          } else {
            errorMsg = 'An error occurred: ${e.toString()}';
          }
          _errorMessage = errorMsg;
        });
      }
      debugPrint('Login error: $e');
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

                  // Top controls
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
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

                  const SizedBox(height: 8),

                  // Email display
                  Text(
                    widget.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Password label
                  Consumer<LanguageProvider>(
                    builder: (context, lang, _) {
                      return Text(
                        context.t('password'),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
                            vertical: 16,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
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
                            return 'Please enter your password';
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
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: Consumer<LanguageProvider>(
                      builder: (context, lang, _) {
                        return TextButton(
                          onPressed: () {
                            // TODO: Implement forgot password
                          },
                          child: Text(
                            context.t('forgot_password'),
                            style: const TextStyle(
                              color: Color(0xFF0052FF),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Continue button
                  Consumer<LanguageProvider>(
                    builder: (context, lang, _) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.white : Colors.black,
                            disabledBackgroundColor:
                                (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
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
                                        isDark ? Colors.black : Colors.white),
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

