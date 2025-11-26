import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'menu_drawer_screen.dart';
import '../widgets/theme_language_controls.dart';
import '../utils/translation_helper.dart';
import '../providers/language_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ignore: unused_field
  String _selectedFilter = 'All';

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
                children: [
                  IconButton(
                    icon: Icon(Icons.menu, color: isDark ? Colors.white : Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MenuDrawerScreen(),
                          fullscreenDialog: true,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Consumer<LanguageProvider>(
                        builder: (context, lang, _) {
                          return TextField(
                            decoration: InputDecoration(
                              hintText: context.t('search'),
                              hintStyle: TextStyle(
                                color: isDark ? Colors.grey[600] : Colors.grey[400],
                                fontSize: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: isDark ? Colors.grey[600] : Colors.grey[400],
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            style: TextStyle(color: isDark ? Colors.white : Colors.black),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const ThemeLanguageControls(),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.notifications_outlined, color: isDark ? Colors.white : Colors.black),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Consumer<LanguageProvider>(
                  builder: (context, lang, _) {
                    return Text(
                      context.t('transactions'),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Filter chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildFilterChip(Icons.filter_list, null),
                  const SizedBox(width: 8),
                  Consumer<LanguageProvider>(
                    builder: (context, lang, _) {
                      return _buildFilterChip(null, context.t('type'));
                    },
                  ),
                  const SizedBox(width: 8),
                  Consumer<LanguageProvider>(
                    builder: (context, lang, _) {
                      return _buildFilterChip(null, context.t('status'));
                    },
                  ),
                  const SizedBox(width: 8),
                  Consumer<LanguageProvider>(
                    builder: (context, lang, _) {
                      return _buildFilterChip(null, context.t('asset'));
                    },
                  ),
                  const SizedBox(width: 8),
                  Consumer<LanguageProvider>(
                    builder: (context, lang, _) {
                      return _buildFilterChip(null, context.t('date'));
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Transactions list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  // Month header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'September',
              style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  
                  Consumer<LanguageProvider>(
                    builder: (context, lang, _) {
                      return Column(
                        children: [
                          _buildTransactionItem(
                            context.t('withdrew_funds'),
                            'Sep 20, 2025',
                            '-\$105.05',
                            '-105.05 USD',
                            Colors.blue,
                            Icons.attach_money,
                          ),
                          _buildTransactionItem(
                            context.t('sold_btc'),
                            'Sep 20, 2025',
                            '-\$107.06',
                            '-0.000932 BTC',
                            Colors.orange,
                            Icons.currency_bitcoin,
                          ),
                        ],
                      );
                    },
                  ),
                  
                  Consumer<LanguageProvider>(
                    builder: (context, lang, _) {
                      return _buildTransactionItem(
                        context.t('withdrew_funds'),
                        'Sep 19, 2025',
                        '-\$99.07',
                        '-99.07 USD',
                        Colors.blue,
                        Icons.attach_money,
                      );
                    },
                  ),
                  
                  _buildTransactionItem(
                    'Sold ETH',
                    'Sep 19, 2025',
                    '-\$100.96',
                    '-0.0229 ETH',
                    Colors.purple,
                    Icons.currency_exchange,
                  ),
                  
                  _buildTransactionItem(
                    'Withdrew funds',
                    'Sep 19, 2025',
                    '-\$101.77',
                    '-101.77 USD',
                    Colors.blue,
                    Icons.attach_money,
                  ),
                  
                  _buildTransactionItem(
                    'Sold XRP',
                    'Sep 19, 2025',
                    '-\$103.71',
                    '-34.90 XRP',
                    Colors.grey[700]!,
                    Icons.currency_exchange,
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
            
            // Action buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
              children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Consumer<LanguageProvider>(
                        builder: (context, lang, _) {
                          return Text(
                            context.t('transfer_button'),
                  style: TextStyle(
                    fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Consumer<LanguageProvider>(
                        builder: (context, lang, _) {
                          return Text(
                            context.t('buy_sell_button'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                  ),
                ),
              ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(IconData? icon, String? label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label ?? 'All'),
              child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 18,
                color: isDark ? Colors.white : Colors.black,
              ),
            if (label != null) ...[
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    String title,
    String date,
    String amount,
    String cryptoAmount,
    Color iconColor,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNegative = amount.startsWith('-');
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
          // Icon
                    Container(
            width: 48,
            height: 48,
                      decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Title and date
          Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                            style: TextStyle(
                              fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
          
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isNegative 
                    ? (isDark ? Colors.white : Colors.black)
                    : Colors.green,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                cryptoAmount,
                  style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
