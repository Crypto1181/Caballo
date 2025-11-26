import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_screen.dart';
import 'generate_qr_screen.dart';
import 'order_history_screen.dart';
import '../utils/translation_helper.dart';
import '../providers/language_provider.dart';
import '../services/supabase_service.dart';

class MenuDrawerScreen extends StatelessWidget {
  const MenuDrawerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: Icon(Icons.help_outline, color: isDark ? Colors.white : Colors.black, size: 28),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Section
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        );
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.grey[300],
                            child: Icon(Icons.person, size: 32, color: Colors.grey[600]),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  SupabaseService.currentUser?.email?.split('@').first ?? 'User',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                Text(
                                  SupabaseService.currentUser?.email ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Promotional Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.grey[900],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Consumer<LanguageProvider>(
                                  builder: (context, lang, _) {
                                    return Text(
                                      context.t('premium_card'),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                                Consumer<LanguageProvider>(
                                  builder: (context, lang, _) {
                                    return Text(
                                      context.t('premium_card_desc'),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.white70,
                                        height: 1.4,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                Consumer<LanguageProvider>(
                                  builder: (context, lang, _) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        context.t('learn_more'),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 80,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '💳',
                                style: TextStyle(fontSize: 32),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // TRADE Section
                    Consumer<LanguageProvider>(
                      builder: (context, lang, _) {
                        return Text(
                          context.t('trade_section'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[600] : Colors.grey[500],
                            letterSpacing: 1,
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Consumer<LanguageProvider>(
                      builder: (context, lang, _) {
                        return Column(
                          children: [
                            _buildMenuItem(
                              icon: Icons.bar_chart,
                              title: context.t('advanced'),
                              hasToggle: true,
                              isDark: isDark,
                            ),
                            _buildMenuItem(
                              icon: Icons.workspace_premium,
                              title: context.t('caballo_one'),
                              isDark: isDark,
                            ),
                            _buildMenuItem(
                              icon: Icons.repeat,
                              title: context.t('recurring_buys'),
                              isDark: isDark,
                            ),
                            _buildMenuItem(
                              icon: Icons.trending_up,
                              title: context.t('limit_orders'),
                              isDark: isDark,
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const OrderHistoryScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildMenuItem(
                              icon: Icons.show_chart,
                              title: context.t('derivatives'),
                              isDark: isDark,
                            ),
                          ],
                        );
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // EARN Section
                    Consumer<LanguageProvider>(
                      builder: (context, lang, _) {
                        return Text(
                          context.t('earn_section'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[600] : Colors.grey[500],
                            letterSpacing: 1,
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Consumer<LanguageProvider>(
                      builder: (context, lang, _) {
                        return Column(
                          children: [
                            _buildMenuItem(
                              icon: Icons.account_balance_wallet,
                              title: context.t('cash_menu'),
                              trailing: context.t('earn_apy'),
                              trailingColor: Colors.green,
                              isDark: isDark,
                            ),
                            _buildMenuItem(
                              icon: Icons.volunteer_activism,
                              title: context.t('lending'),
                              trailing: context.t('earn_percent'),
                              trailingColor: Colors.green,
                              isDark: isDark,
                            ),
                            _buildMenuItem(
                              icon: Icons.percent,
                              title: context.t('staking'),
                              trailing: context.t('earn_staking'),
                              trailingColor: Colors.green,
                              isDark: isDark,
                            ),
                          ],
                        );
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // TEST Section (Developer Tools)
                    Consumer<LanguageProvider>(
                      builder: (context, lang, _) {
                        return Text(
                          context.t('testing'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[600] : Colors.grey[500],
                            letterSpacing: 1,
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Consumer<LanguageProvider>(
                      builder: (context, lang, _) {
                        return _buildMenuItem(
                          context: context,
                          icon: Icons.qr_code,
                          title: context.t('generate_qr'),
                          trailing: context.t('test_scanner'),
                          trailingColor: Colors.orange,
                          isDark: isDark,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const GenerateQRScreen()),
                            );
                          },
                        );
                      },
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? trailing,
    Color? trailingColor,
    bool hasToggle = false,
    required bool isDark,
    BuildContext? context,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap ?? () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: isDark ? Colors.white : Colors.black,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: trailingColor ?? (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
              if (hasToggle)
                Switch(
                  value: false,
                  onChanged: (value) {},
                  activeThumbColor: Colors.blue,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

