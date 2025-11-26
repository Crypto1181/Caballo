import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/welcome_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/investing_screen.dart';
import 'screens/explore_crypto_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'utils/app_colors.dart';
import 'utils/translation_helper.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'services/supabase_service.dart';
import 'services/alpaca_config.dart';
import 'services/alpaca_service.dart';
import 'services/privy_config.dart';
import 'services/privy_service.dart';
import 'services/stripe_config.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
// Uncomment the line below and run once to configure your credentials
// import 'utils/configure_alpaca.dart';
import 'utils/configure_privy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService.initialize();

  // Load Alpaca configuration from storage
  await AlpacaConfig.instance.loadFromStorage();

  // Initialize Alpaca Service if credentials are available
  if (AlpacaConfig.instance.isConfigured) {
    AlpacaService.instance.initialize(
      apiKeyId: AlpacaConfig.instance.apiKeyId!,
      apiSecretKey: AlpacaConfig.instance.apiSecretKey!,
      brokerId: AlpacaConfig.instance.brokerId,
      useProduction: AlpacaConfig.instance.useProduction,
    );
  }

  // Load Privy configuration from storage
  await PrivyConfig.instance.loadFromStorage();

  // Initialize Privy Service if credentials are available
  if (PrivyConfig.instance.isConfigured) {
    PrivyService.instance.initialize(
      appId: PrivyConfig.instance.appId!,
      appSecret: PrivyConfig.instance.appSecret!,
      useProduction: PrivyConfig.instance.useProduction,
    );
  }

  // Load Stripe configuration from storage
  await StripeConfig.instance.loadFromStorage();

  // Initialize Stripe if configured
  if (StripeConfig.instance.isConfigured) {
    Stripe.publishableKey = StripeConfig.instance.publishableKey!;
    Stripe.merchantIdentifier = 'merchant.caballo';
    // Note: For production, you may want to set Stripe.instance.applySettings()
  }

  // Uncomment the line below to configure Alpaca credentials (run once)
  // await configureAlpacaCredentials();

  // Configure Privy credentials (run once, then comment back out)
  // await configurePrivyCredentials();

  // Add error handler for web
  if (kIsWeb) {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Flutter Error: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');
    };
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const CaballoApp(),
    ),
  );
}

class CaballoApp extends StatelessWidget {
  const CaballoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Caballo',
          themeMode: themeProvider.themeMode,
          locale: languageProvider.locale,
          supportedLocales: const [Locale('en'), Locale('es')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: AppColors.primaryGreen,
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: AppColors.primaryGreen,
            scaffoldBackgroundColor: AppColors.background,
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
          ),
          home: const WelcomeScreen(),
        );
      },
    );
  }
}

/// Main screen with bottom navigation after login/signup
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    InvestingScreen(),
    ExploreCryptoScreen(),
    AiChatScreen(),
    WalletScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.background : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  icon: Icons.home_outlined,
                  labelKey: 'home',
                  index: 0,
                  isDark: isDark,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.show_chart,
                  labelKey: 'trade',
                  index: 1,
                  isDark: isDark,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.auto_awesome,
                  labelKey: 'ai',
                  index: 2,
                  isDark: isDark,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.credit_card,
                  labelKey: 'pay',
                  index: 3,
                  isDark: isDark,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.receipt_long_outlined,
                  labelKey: 'transactions',
                  index: 4,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String labelKey,
    required int index,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? (isDark ? Colors.white : Colors.black)
                    : Colors.grey[600],
                size: 22,
              ),
              const SizedBox(height: 2),
              Consumer<LanguageProvider>(
                builder: (context, lang, _) {
                  return Text(
                    context.t(labelKey),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? (isDark ? Colors.white : Colors.black)
                          : Colors.grey[700],
                      height: 1.2,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
