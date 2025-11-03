import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'stock_detail_screen.dart';
import 'menu_drawer_screen.dart';
import '../widgets/language_toggle.dart';
import '../utils/translation_helper.dart';
import '../providers/language_provider.dart';

class ExploreCryptoScreen extends StatefulWidget {
  const ExploreCryptoScreen({super.key});

  @override
  State<ExploreCryptoScreen> createState() => _ExploreCryptoScreenState();
}

class _ExploreCryptoScreenState extends State<ExploreCryptoScreen> {
  String _selectedFilter = 'Trending';

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
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search',
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
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const LanguageToggle(),
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
                      context.t('trade'),
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
            Consumer<LanguageProvider>(
              builder: (context, lang, _) {
                return SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _buildFilterChip(context.t('trending')),
                      const SizedBox(width: 8),
                      _buildFilterChip(context.t('top_volume')),
                      const SizedBox(width: 8),
                      _buildFilterChip(context.t('top_gainers')),
                      const SizedBox(width: 8),
                      _buildFilterChip(context.t('top_losers')),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Crypto list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildCryptoItem(
                    'Virtuals Protocol',
                    'VIRTUAL',
                    '56K trades',
                    '\$962M mcap',
                    2.25,
                    true,
                    Colors.teal,
                  ),
                  _buildCryptoItem(
                    'Zora',
                    'ZORA',
                    '29K trades',
                    '\$358M mcap',
                    9.95,
                    false,
                    Colors.blue,
                  ),
                  _buildCryptoItem(
                    'Aerodrome Finance',
                    'AERO',
                    '7K trades',
                    '\$860M mcap',
                    0.89,
                    true,
                    Colors.lightBlue,
                  ),
                  _buildCryptoItem(
                    'Sapien',
                    'SAPIEN',
                    '24K trades',
                    '\$41M mcap',
                    23.81,
                    true,
                    Colors.blue[900]!,
                  ),
                  _buildCryptoItem(
                    'tokenbot',
                    'TOKENBOT',
                    '2.2K trades',
                    '\$109M mcap',
                    5.45,
                    false,
                    Colors.purple,
                  ),
                  _buildCryptoItem(
                    'GAME by Virtuals',
                    'GAME',
                    '8.8K trades',
                    '\$39M mcap',
                    16.13,
                    true,
                    Colors.cyan,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Browse all button
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
              child: Text(
                      'Browse all',
                style: TextStyle(
                        fontSize: 16,
                  fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
            
            // Buy & sell button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Buy & sell',
                style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedFilter == label;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
          color: isSelected 
            ? (isDark ? Colors.grey[800] : Colors.grey[900])
            : (isDark ? Colors.grey[900] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected 
              ? Colors.white
              : (isDark ? Colors.grey[400] : Colors.grey[700]),
          ),
        ),
      ),
    );
  }

  Widget _buildCryptoItem(
    String name,
    String symbol,
    String trades,
    String mcap,
    double changePercent,
    bool isPositive,
    Color iconColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StockDetailScreen(
              symbol: symbol,
              name: name,
              price: 100.0,
              change: changePercent,
              isPositive: isPositive,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  symbol[0],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Name and details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  name,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$symbol · $trades',
              style: TextStyle(
                fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
            ),
            
            // Market cap and change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  mcap,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 14,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                Text(
                      '${changePercent.toStringAsFixed(2)}%',
                      style: TextStyle(
                    fontSize: 14,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                  ),
                  ],
                ),
              ],
            ),
          ],
          ),
      ),
    );
  }
}
