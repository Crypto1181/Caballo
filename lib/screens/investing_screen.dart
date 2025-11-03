import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'stock_detail_screen.dart';
import 'crypto_detail_screen.dart';
import 'menu_drawer_screen.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import '../widgets/language_toggle.dart';
import '../utils/translation_helper.dart';
import '../providers/language_provider.dart';

class InvestingScreen extends StatefulWidget {
  const InvestingScreen({super.key});

  @override
  State<InvestingScreen> createState() => _InvestingScreenState();
}

class _InvestingScreenState extends State<InvestingScreen> {
  String _selectedPeriod = '1D';
  InAppWebViewController? _chartController;
  bool _chartReady = false;

  // Watchlist data
  final List<Map<String, dynamic>> _watchlist = [
    {
      'coinId': 'bitcoin',
      'symbol': 'BTC',
      'name': 'Bitcoin',
      'icon': '₿',
      'iconColor': Colors.orange,
      'price': '\$111,362.18',
      'change': -2.96,
      'isPositive': false,
    },
    {
      'coinId': 'ethereum',
      'symbol': 'ETH',
      'name': 'Ethereum',
      'icon': 'Ξ',
      'iconColor': Colors.blue,
      'price': '\$3,245.67',
      'change': 1.45,
      'isPositive': true,
    },
    {
      'coinId': 'solana',
      'symbol': 'SOL',
      'name': 'Solana',
      'icon': '◎',
      'iconColor': Colors.purple,
      'price': '\$156.89',
      'change': 3.21,
      'isPositive': true,
    },
    {
      'coinId': 'cardano',
      'symbol': 'ADA',
      'name': 'Cardano',
      'icon': '₳',
      'iconColor': Colors.teal,
      'price': '\$0.52',
      'change': -0.87,
      'isPositive': false,
    },
    {
      'coinId': 'dogecoin',
      'symbol': 'DOGE',
      'name': 'Dogecoin',
      'icon': 'Ð',
      'iconColor': Colors.amber,
      'price': '\$0.083',
      'change': 2.34,
      'isPositive': true,
    },
    {
      'coinId': 'polygon',
      'symbol': 'MATIC',
      'name': 'Polygon',
      'icon': '⬟',
      'iconColor': Colors.indigo,
      'price': '\$0.89',
      'change': -1.12,
      'isPositive': false,
    },
    {
      'coinId': 'binancecoin',
      'symbol': 'BNB',
      'name': 'BNB',
      'icon': 'BNB',
      'iconColor': Colors.yellow,
      'price': '\$612.45',
      'change': 0.56,
      'isPositive': true,
    },
    {
      'coinId': 'ripple',
      'symbol': 'XRP',
      'name': 'Ripple',
      'icon': '✕',
      'iconColor': Colors.blueGrey,
      'price': '\$0.62',
      'change': 1.89,
      'isPositive': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with menu, search, notifications, language toggle
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
                    const LanguageToggle(),
                    const SizedBox(width: 8),
          IconButton(
                      icon: Icon(Icons.notifications_outlined, color: isDark ? Colors.white : Colors.black),
            onPressed: () {},
          ),
        ],
      ),
              ),
              
              // Portfolio balance
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                    Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                          Text(
                            '\$0.00',
                    style: TextStyle(
                              fontSize: 48,
                      fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '\$0.00 (0.00%) 1D',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Up arrow button
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.keyboard_arrow_up,
                          color: isDark ? Colors.white : Colors.black,
                          size: 28,
                        ),
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
                  ),
                ],
              ),
            ),
              
              const SizedBox(height: 24),
              
              // TradingView Chart
              Container(
                height: 200,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: InAppWebView(
                    initialFile: 'assets/html/chart.html',
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        javaScriptEnabled: true,
                        transparentBackground: true,
                      ),
                    ),
                    onWebViewCreated: (c) => _chartController = c,
                    onLoadStop: (c, url) async {
                      await _initChart(isDark);
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Time period selector
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPeriodButton('1H'),
                    _buildPeriodButton('1D'),
                    _buildPeriodButton('1W'),
                    _buildPeriodButton('1M'),
                    _buildPeriodButton('1Y'),
                    _buildPeriodButton('All'),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Promotional banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[100],
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
                                context.t('pay_anyone'),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Consumer<LanguageProvider>(
                            builder: (context, lang, _) {
                              return Text(
                                context.t('send_crypto'),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: Colors.blue,
                        size: 32,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: isDark ? Colors.grey[500] : Colors.grey),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Crypto section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Icon(Icons.show_chart, size: 24, color: isDark ? Colors.white : Colors.black),
                    const SizedBox(width: 12),
                    Consumer<LanguageProvider>(
                      builder: (context, lang, _) {
                        return Text(
                          context.t('crypto_section'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    Consumer<LanguageProvider>(
                      builder: (context, lang, _) {
                        return TextButton(
                          onPressed: () {},
                          child: Text(
                            context.t('buy'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
            const SizedBox(height: 16),
              
              // Cash section with APY
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                      children: [
                        Container(
                      width: 40,
                      height: 40,
                          decoration: BoxDecoration(
                        color: Colors.green[100],
                        shape: BoxShape.circle,
                          ),
                      child: Icon(Icons.account_balance_wallet, color: Colors.green[700], size: 20),
                        ),
                    const SizedBox(width: 12),
                    Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Consumer<LanguageProvider>(
                                builder: (context, lang, _) {
                                  return Text(
                                    context.t('cash'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                  );
                                },
                              ),
                              Consumer<LanguageProvider>(
                                builder: (context, lang, _) {
                                  return Text(
                                    '· ${context.t('earn_apy')}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                    Consumer<LanguageProvider>(
                      builder: (context, lang, _) {
                        return TextButton(
                          onPressed: () {},
                          child: Text(
                            context.t('deposit'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Watchlist section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Consumer<LanguageProvider>(
                      builder: (context, lang, _) {
                        return Text(
                          context.t('watchlist'),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward, color: isDark ? Colors.white : Colors.black),
                      onPressed: () {},
            ),
          ],
        ),
      ),
              
              const SizedBox(height: 8),
              
              // Watchlist items
              ..._buildWatchlistItems(isDark),
              
              const SizedBox(height: 16),
              
              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
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
                              context.t('deposit'),
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
                      flex: 2,
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
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String period) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedPeriod == period;
    
    return InkWell(
      onTap: () async {
        setState(() => _selectedPeriod = period);
        if (_chartReady) await _updateChartPeriod(period);
      },
      child: Text(
        period,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected 
            ? Colors.blue 
            : (isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
      ),
    );
  }

  Future<void> _initChart(bool isDark) async {
    if (_chartReady) return;
    for (int i = 0; i < 40; i++) {
      try {
        final res = await _chartController?.evaluateJavascript(source: 'typeof initChart === "function"');
        if (res == true || res == 'true' || res?.toString() == 'true') {
          setState(() => _chartReady = true);
          await _updateChartPeriod(_selectedPeriod, isDark: isDark);
          return;
        }
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 125));
    }
  }

  Future<void> _updateChartPeriod(String period, {bool? isDark}) async {
    if (!_chartReady) return;
    final tfMap = {'1H': '1h', '1D': '1d', '1W': '1w', '1M': '1m', '1Y': '1y', 'All': '1M'};
    final binanceTf = tfMap[period] ?? '1d';
    try {
      final data = await _fetchBinanceKlines(symbol: 'BTCUSDT', interval: binanceTf, limit: 100);
      final dark = isDark ?? Theme.of(context).brightness == Brightness.dark;
      final options = {'dark': dark, 'type': 'line', 'fit': true, 'series': {'color': Colors.blue.value.toRadixString(16)}};
      final lineData = data.map((e) => {'time': e['time'], 'value': e['close']}).toList();
      await _chartController?.evaluateJavascript(source: "initChart(${jsonEncode(lineData)}, ${jsonEncode(options)});");
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> _fetchBinanceKlines({required String symbol, required String interval, int limit = 100}) async {
    final uri = Uri.parse('https://api.binance.com/api/v3/klines?symbol=$symbol&interval=$interval&limit=$limit');
    final resp = await http.get(uri);
    if (resp.statusCode != 200) throw Exception('HTTP ${resp.statusCode}');
    final List<dynamic> rows = jsonDecode(resp.body) as List<dynamic>;
    return rows.map<Map<String, dynamic>>((e) {
      final openTimeMs = (e[0] as num).toInt();
      return {'time': (openTimeMs / 1000).round(), 'open': double.parse(e[1].toString()), 'high': double.parse(e[2].toString()), 'low': double.parse(e[3].toString()), 'close': double.parse(e[4].toString()), 'volume': double.tryParse(e[5].toString()) ?? 0};
    }).toList();
  }

  List<Widget> _buildWatchlistItems(bool isDark) {
    return _watchlist.map((coin) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => Scaffold(
                  body: CryptoDetailScreen(
                    coinId: coin['coinId'] as String,
                    symbolLabel: coin['symbol'] as String,
                    displayName: coin['name'] as String,
                  ),
                  bottomNavigationBar: const _BottomNavPlaceholder(),
                ),
                fullscreenDialog: false,
              ),
            );
          },
          child: Row(
            children: [
              // Crypto icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: coin['iconColor'] as Color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: (coin['icon'] as String).length > 2
                      ? Text(
                          coin['icon'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          coin['icon'] as String,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coin['name'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      coin['symbol'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Mini chart
              CustomPaint(
                size: const Size(80, 35),
                painter: _MiniChartPainter(
                  isPositive: coin['isPositive'] as bool,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    coin['price'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    '${coin['isPositive'] as bool ? '↑' : '↓'} ${(coin['change'] as num).abs().toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: coin['isPositive'] as bool ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

// Bottom nav placeholder with AI tab like main.dart
class _BottomNavPlaceholder extends StatelessWidget {
  const _BottomNavPlaceholder();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 'Home', 0, true, isDark, context),
              _buildNavItem(Icons.show_chart, 'Trade', 1, false, isDark, context),
              _buildNavItem(Icons.auto_awesome, 'AI', 2, false, isDark, context),
              _buildNavItem(Icons.credit_card, 'Pay', 3, false, isDark, context),
              _buildNavItem(Icons.receipt_long_outlined, 'Transactions', 4, false, isDark, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, bool isSelected, bool isDark, BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: index == 0 ? () => Navigator.pop(context) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? (isDark ? Colors.white : Colors.black) : Colors.grey[600],
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? (isDark ? Colors.white : Colors.black) : Colors.grey[700],
                  height: 1.2,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Chart painter for main portfolio chart
class _ChartPainter extends CustomPainter {
  final bool isDark;
  
  _ChartPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Create a flat line since portfolio is $0.00
    final centerY = size.height / 2;
    path.moveTo(0, centerY);
    
    // Add slight variations for visual interest
    for (var i = 0; i <= 20; i++) {
      final x = (size.width / 20) * i;
      final y = centerY + (i % 3 == 0 ? 5 : -5);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
    
    // Draw dots pattern
    final dotPaint = Paint()
      ..color = isDark ? Colors.grey[800]! : Colors.grey[200]!
      ..style = PaintingStyle.fill;
      
    for (var x = 0.0; x < size.width; x += 20) {
      for (var y = 0.0; y < size.height; y += 20) {
        canvas.drawCircle(Offset(x, y), 1, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Mini chart painter for watchlist items
class _MiniChartPainter extends CustomPainter {
  final bool isPositive;
  
  _MiniChartPainter({required this.isPositive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isPositive ? Colors.green : Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Downward trending for Bitcoin
    path.moveTo(0, size.height * 0.2);
    path.lineTo(size.width * 0.2, size.height * 0.3);
    path.lineTo(size.width * 0.4, size.height * 0.5);
    path.lineTo(size.width * 0.6, size.height * 0.4);
    path.lineTo(size.width * 0.8, size.height * 0.6);
    path.lineTo(size.width, size.height * 0.7);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
