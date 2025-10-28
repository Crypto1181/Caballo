import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:provider/provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/investing_screen.dart';
import 'screens/explore_crypto_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/rewards_screen.dart';
import 'utils/app_colors.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const CaballoApp(),
    ),
  );
}

class CaballoApp extends StatelessWidget {
  const CaballoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Caballo',
          themeMode: themeProvider.themeMode,
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
    RewardsScreen(),
    WalletScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SalomonBottomBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              selectedItemColor: const Color(0xFF00C853),
              unselectedItemColor: Colors.grey[600],
              items: [
                SalomonBottomBarItem(
                  icon: const Icon(Icons.trending_up),
                  title: const Text('Investing'),
                  selectedColor: const Color(0xFF00C853),
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.explore_outlined),
                  title: const Text('Explore'),
                  selectedColor: const Color(0xFF00C853),
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.card_giftcard_outlined),
                  title: const Text('Rewards'),
                  selectedColor: const Color(0xFF00C853),
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text('Wallet'),
                  selectedColor: const Color(0xFF00C853),
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.person_outline),
                  title: const Text('Profile'),
                  selectedColor: const Color(0xFF00C853),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
