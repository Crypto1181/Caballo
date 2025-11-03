import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../utils/translation_helper.dart';
import '../main.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/language_toggle.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String? _country;
  int _currentStep = 0;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  List<Widget> _buildProgressBars(bool isDark) {
    return List.generate(
      6,
      (i) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          height: 3,
          decoration: BoxDecoration(
            color: i <= _currentStep ? AppColors.primaryGreen : (isDark ? Colors.grey[800] : Colors.grey[300]),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.background : Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => themeProvider.toggleTheme(),
        backgroundColor: const Color(0xFF00C853),
        child: Icon(
          isDark ? Icons.light_mode : Icons.dark_mode,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (_currentStep > 0) {
                        setState(() => _currentStep--);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<LanguageProvider>(
                          builder: (context, lang, _) {
                            return Text(
                              context.t('create_account'),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: _buildProgressBars(isDark),
                        ),
                      ],
                    ),
                  ),
                  const LanguageToggle(),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    if (_currentStep == 0) _buildStep1Country(isDark),
                    if (_currentStep == 1) _buildStep2Email(isDark),
                    if (_currentStep == 2) _buildStep3Name(isDark),
                    if (_currentStep == 3) _buildStep4Password(isDark),
                    if (_currentStep == 4) _buildStep5Confirm(isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1Country(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<LanguageProvider>(
          builder: (context, lang, _) {
            return Text(
              context.t('where_live'),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Consumer<LanguageProvider>(
          builder: (context, lang, _) {
            return Text(
              context.t('choose_country'),
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            );
          },
        ),
        const SizedBox(height: 30),
        GestureDetector(
          onTap: () async {
            final result = await showModalBottomSheet<String>(
              context: context,
              backgroundColor: isDark ? Colors.grey[900] : Colors.white,
              builder: (context) => Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Consumer<LanguageProvider>(
                      builder: (context, lang, _) {
                        final countries = [
                          context.t('united_states'),
                          context.t('canada'),
                          context.t('united_kingdom'),
                          context.t('mexico'),
                          context.t('other'),
                        ];
                        final countryKeys = ['United States', 'Canada', 'United Kingdom', 'Mexico', 'Other'];
                        
                        return Column(
                          children: List.generate(countries.length, (index) {
                            return ListTile(
                              title: Text(
                                countries[index],
                                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                              ),
                              onTap: () => Navigator.of(context).pop(countryKeys[index]),
                            );
                          }),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
            if (result != null) setState(() => _country = result);
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer<LanguageProvider>(
                  builder: (context, lang, _) {
                    return Text(
                      _country ?? context.t('select_country'),
                      style: TextStyle(
                        color: _country == null 
                          ? (isDark ? Colors.grey[500] : Colors.grey[400]) 
                          : (isDark ? Colors.white : Colors.black),
                      ),
                    );
                  },
                ),
                Icon(Icons.arrow_drop_down, color: isDark ? Colors.grey[500] : Colors.grey[400]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 300),
        ElevatedButton(
          onPressed: _country == null ? null : () => setState(() => _currentStep = 1),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Consumer<LanguageProvider>(
            builder: (context, lang, _) {
              return Text(
                context.t('continue'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildStep2Email(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<LanguageProvider>(
          builder: (context, lang, _) {
            return Text(
              context.t('whats_email'),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Consumer<LanguageProvider>(
          builder: (context, lang, _) {
            return Text(
              context.t('email_description'),
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            );
          },
        ),
        const SizedBox(height: 30),
        Consumer<LanguageProvider>(
          builder: (context, lang, _) {
            return TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: context.t('email'),
                hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                filled: true,
                fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primaryGreen),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 300),
        ElevatedButton(
          onPressed: () => setState(() => _currentStep = 2),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Consumer<LanguageProvider>(
            builder: (context, lang, _) {
              return Text(
                context.t('continue'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildStep3Name(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<LanguageProvider>(
          builder: (context, lang, _) {
            return Text(
              context.t('whats_name'),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Consumer<LanguageProvider>(
          builder: (context, lang, _) {
            return Text(
              context.t('name_description'),
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            );
          },
        ),
        const SizedBox(height: 30),
        Consumer<LanguageProvider>(
          builder: (context, lang, _) {
            return TextField(
              controller: _nameController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: context.t('full_name'),
                hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                filled: true,
                fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primaryGreen),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 300),
        ElevatedButton(
          onPressed: () => setState(() => _currentStep = 3),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Consumer<LanguageProvider>(
            builder: (context, lang, _) {
              return Text(
                context.t('continue'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildStep4Password(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<LanguageProvider>(
          builder: (context, lang, _) {
            return Text(
              context.t('create_password'),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Consumer<LanguageProvider>(
          builder: (context, lang, _) {
            return Text(
              context.t('password_description'),
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            );
          },
        ),
        const SizedBox(height: 30),
        Consumer<LanguageProvider>(
          builder: (context, lang, _) {
            return TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: context.t('password'),
                hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                filled: true,
                fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primaryGreen),
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 300),
        ElevatedButton(
          onPressed: () => setState(() => _currentStep = 4),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Consumer<LanguageProvider>(
            builder: (context, lang, _) {
              return Text(
                context.t('continue'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildStep5Confirm(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<LanguageProvider>(
          builder: (context, lang, _) {
            return Text(
              context.t('all_set'),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Consumer<LanguageProvider>(
          builder: (context, lang, _) {
            final name = _nameController.text.isEmpty ? 'there' : _nameController.text.split(' ').first;
            return Text(
              '${context.t('welcome_user')}, $name!',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            );
          },
        ),
        const SizedBox(height: 48),
        Center(
          child: Image.asset(
            'assets/images/icon.png',
            height: 120,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stack) => const Icon(
              Icons.check_circle,
              size: 120,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
        const SizedBox(height: 300),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const MainScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Consumer<LanguageProvider>(
            builder: (context, lang, _) {
              return Text(
                context.t('start_trading'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
