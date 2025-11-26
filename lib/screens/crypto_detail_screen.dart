import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import '../providers/language_provider.dart';
import '../utils/translation_helper.dart';
import '../widgets/theme_language_controls.dart';
import '../services/chart_cache_service.dart';

class CryptoDetailScreen extends StatefulWidget {
  final String coinId; // coingecko id e.g. 'bitcoin'
  final String symbolLabel; // e.g. 'BTC'
  final String displayName; // e.g. 'Bitcoin'
  final String iconSymbol;
  final Color iconColor;

  const CryptoDetailScreen({
    super.key,
    required this.coinId,
    required this.symbolLabel,
    required this.displayName,
    this.iconSymbol = '₿',
    this.iconColor = Colors.orange,
  });

  @override
  State<CryptoDetailScreen> createState() => _CryptoDetailScreenState();
}

class _CryptoDetailScreenState extends State<CryptoDetailScreen> {
  InAppWebViewController? _controller;
  bool _loading = true;
  String? _error;
  String _tf = '1H';
  String _seriesType = 'candlestick';
  WebSocketChannel? _ws;
  bool _chartInitialized = false;
  String _selectedTab = 'Balance';
  double _currentPrice = 0;
  double _priceChange = 0;
  double _priceChangePercent = 0;
  // ignore: unused_field
  final String _rapidApiKey =
      'cfd42cb60fmsh596e3adef1f26a9p16f12bjsn720e2168c172';
  // ignore: unused_field
  final String _rapidApiHost = 'trade-bloom-real-time.p.rapidapi.com';
  final Map<String, Map<String, List<Map<String, dynamic>>>> _klinesCache = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.bolt_outlined,
              color: isDark ? Colors.white : Colors.black,
              size: 24,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.star_outline,
              color: isDark ? Colors.white : Colors.black,
              size: 24,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.share_outlined,
              color: isDark ? Colors.white : Colors.black,
              size: 24,
            ),
            onPressed: () {},
          ),
          ThemeLanguageControls(spacing: 4),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bitcoin Header with logo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.symbolLabel,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.displayName,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentPrice > 0
                                  ? '\$${_currentPrice.toStringAsFixed(2)}'
                                  : 'Loading...',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  _priceChange >= 0
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  size: 16,
                                  color: _priceChange >= 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _currentPrice > 0
                                      ? '\$${_priceChange.abs().toStringAsFixed(2)} (${_priceChangePercent.abs().toStringAsFixed(2)}%)'
                                      : '',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _priceChange >= 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Bitcoin logo
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: widget.iconColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        widget.iconSymbol,
                        style: TextStyle(
                          fontSize: widget.iconSymbol.length > 2 ? 20 : 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Full height chart
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  InAppWebView(
                    initialFile: 'assets/html/chart.html',
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        javaScriptEnabled: true,
                        transparentBackground: true,
                      ),
                    ),
                    onWebViewCreated: (c) => _controller = c,
                    onLoadStop: (c, url) async {
                      if (mounted)
                        setState(() {
                          _loading = false;
                        });
                      _fetchPrice();
                      _waitForInit().then((_) async {
                        await _injectData(isDark);
                        _startLive();
                      });
                    },
                  ),
                  if (_loading)
                    const Center(child: CircularProgressIndicator()),
                  if (_error != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Period selector buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final tf in ['1H', '1D', '1W', '1M', '1Y', 'All'])
                    _buildTfButton(tf, isDark),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Balance and Insights tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildTabButton('Balance', isDark),
                  const SizedBox(width: 24),
                  _buildTabButton('Insights', isDark),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Balance/Insights content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildTabContent(isDark),
            ),
            const SizedBox(height: 24),
            // Transactions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transactions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'September',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTransactionItem(
                    'Sold BTC',
                    'Sep 20, 2025',
                    -107.06,
                    -0.000932,
                    isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Buy & Sell buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Consumer<LanguageProvider>(
                        builder: (context, lang, _) {
                          return Text(
                            context.t('transfer_button'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
                          borderRadius: BorderRadius.circular(12),
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String tab, bool isDark) {
    final selected = _selectedTab == tab;
    return InkWell(
      onTap: () => setState(() => _selectedTab = tab),
      child: Text(
        tab,
        style: TextStyle(
          fontSize: 16,
          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          color: selected
              ? Colors.blue
              : (isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildTabContent(bool isDark) {
    if (_selectedTab == 'Balance') {
      return Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '₿',
                style: TextStyle(
                  fontSize: 24,
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
                  '\$0.00',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  '0 BTC',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return Text(
      'Insights coming soon...',
      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
    );
  }

  Widget _buildTransactionItem(
    String title,
    String date,
    double usd,
    double btc,
    bool isDark,
  ) {
    final isNegative = usd < 0;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              '₿',
              style: TextStyle(
                fontSize: 20,
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
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              isNegative
                  ? '\$${usd.abs().toStringAsFixed(2)}'
                  : '\$${usd.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            Text(
              isNegative ? '-${btc.abs()} BTC' : '$btc BTC',
              style: const TextStyle(fontSize: 14, color: Colors.red),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTfButton(String tf, bool isDark) {
    final selected = _tf == tf;
    return InkWell(
      onTap: () async {
        if (_tf == tf) return;
        setState(() {
          _tf = tf;
          _loading = true;
          _error = null;
        });
        _ws?.sink.close(ws_status.normalClosure);
        _chartInitialized = false;
        await _injectData(Theme.of(context).brightness == Brightness.dark);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? Colors.white : Colors.black)
              : (isDark ? Colors.grey[900] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          tf.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            color: selected
                ? Colors.white
                : (isDark ? Colors.grey[400] : Colors.grey[700]),
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _fetchPrice() async {
    try {
      // Use Binance ticker for reliable price data
      final symbol = '${widget.symbolLabel}USDT';
      final uri = Uri.parse(
        'https://api.binance.com/api/v3/ticker/24hr?symbol=$symbol',
      );
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final map = jsonDecode(resp.body) as Map<String, dynamic>;
        final currentPrice =
            double.tryParse(map['lastPrice']?.toString() ?? '') ?? 0.0;
        final openPrice =
            double.tryParse(map['openPrice']?.toString() ?? '') ?? 0.0;
        if (currentPrice > 0 && openPrice > 0) {
          final change = currentPrice - openPrice;
          final changePercent = (change / openPrice) * 100;
          if (mounted) {
            setState(() {
              _currentPrice = currentPrice;
              _priceChange = change;
              _priceChangePercent = changePercent;
            });
          }
        }
      }
    } catch (e) {
      print('Price fetch error: $e');
      // Fallback: try to get price from CoinGecko
      try {
        final uri = Uri.parse(
          'https://api.coingecko.com/api/v3/simple/price?ids=${widget.coinId}&vs_currencies=usd&include_24hr_change=true',
        );
        final resp = await http.get(uri);
        if (resp.statusCode == 200) {
          final map = jsonDecode(resp.body) as Map<String, dynamic>;
          final coinData = map[widget.coinId] as Map<String, dynamic>?;
          if (coinData != null) {
            final price =
                double.tryParse(coinData['usd']?.toString() ?? '') ?? 0.0;
            final changePercent =
                double.tryParse(coinData['usd_24h_change']?.toString() ?? '') ??
                0.0;
            if (price > 0 && mounted) {
              setState(() {
                _currentPrice = price;
                _priceChange = price * (changePercent / 100);
                _priceChangePercent = changePercent;
              });
            }
          }
        }
      } catch (_) {}
    }
  }

  Future<void> _waitForInit() async {
    for (int i = 0; i < 40; i++) {
      try {
        final res = await _controller?.evaluateJavascript(
          source: 'typeof initChart === "function"',
        );
        if (res == true || res == 'true' || res?.toString() == 'true') return;
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 125));
    }
  }

  String _getBinanceInterval(String tf) {
    switch (tf.toUpperCase()) {
      case '1H':
        return '1h';
      case '1D':
        return '1d';
      case '1W':
        return '1w';
      case '1M':
        return '1M';
      case '1Y':
        return '1M'; // Binance doesn't have 1Y, use 1M with more data
      case 'ALL':
        return '1M';
      default:
        return '1h';
    }
  }

  int _getDataLimit(String tf) {
    switch (tf.toUpperCase()) {
      case '1H':
        return 168; // 1 week of hourly data
      case '1D':
        return 365; // 1 year of daily data
      case '1W':
        return 104; // 2 years of weekly data
      case '1M':
        return 60; // 5 years of monthly data
      case '1Y':
        return 120; // 10 years of monthly data
      case 'ALL':
        return 500; // Max historical data
      default:
        return 200;
    }
  }

  Future<void> _injectData(bool isDark) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Try Binance first (most reliable with proper OHLCV)
      List<Map<String, dynamic>> data;
      final symbol = '${widget.symbolLabel}USDT'.toUpperCase();
      final interval = _getBinanceInterval(_tf);
      final limit = _getDataLimit(_tf);
      
      // Check in-memory cache first
      if (_klinesCache[symbol] != null && _klinesCache[symbol]![_tf] != null) {
        data = _klinesCache[symbol]![_tf]!;
        // Use cached data immediately, then refresh in background
        _loadChartWithData(data, isDark);
        // Refresh in background
        _refreshDataInBackground(symbol, interval, limit, isDark);
        return;
      }
      
      // Check Supabase cache
      final cachedData = await ChartCacheService.getCachedData(symbol, _tf);
      if (cachedData != null && cachedData.isNotEmpty) {
        data = cachedData;
        // Store in memory cache
        _klinesCache.putIfAbsent(symbol, () => {})[_tf] = data;
        // Use cached data immediately, then refresh in background
        _loadChartWithData(data, isDark);
        // Refresh in background
        _refreshDataInBackground(symbol, interval, limit, isDark);
        return;
      }
      
      // No cache, fetch fresh data
      try {
        data = await _fetchBinanceKlines(
          symbol: symbol,
          interval: interval,
          limit: limit,
        );
        // Cache the data
        await ChartCacheService.cacheData(symbol, _tf, data);
      } catch (binanceError) {
        print('Binance failed, trying CoinGecko: $binanceError');
        // Fallback to CoinGecko
        int days = 30;
        if (_tf == '1H') {
          days = 7;
        } else if (_tf == '1D')
          days = 365;
        else if (_tf == '1W')
          days = 730;
        else if (_tf == '1M' || _tf == '1Y' || _tf == 'ALL')
          days = 3650;
        data = await _fetchCoinGeckoOhlc(widget.coinId, 'usd', days);
        // Cache CoinGecko data too
        await ChartCacheService.cacheData(symbol, _tf, data);
      }
      // Store in memory cache
      _klinesCache.putIfAbsent(symbol, () => {})[_tf] = data;

      if (data.isEmpty) throw Exception('No data received');

      _loadChartWithData(data, isDark);
    } catch (e) {
      print('Chart data fetch failed: $e');
      if (mounted)
        setState(() {
          _error = 'Failed to load chart data: ${e.toString()}';
          _loading = false;
        });
    }
  }

  /// Load chart with data (extracted for reuse)
  void _loadChartWithData(List<Map<String, dynamic>> data, bool isDark) {
    final options = {
      'dark': isDark,
      'type': _seriesType,
      'fit': true,
      'series': {
        'upColor': '#26a69a',
        'downColor': '#ef5350',
        'borderVisible': false,
        'wickUpColor': '#26a69a',
        'wickDownColor': '#ef5350',
      },
    };

    final volume = data
        .map(
          (e) => ({
            'time': e['time'],
            'value': e['volume'] ?? 0,
            'color': ((e['close'] as num) >= (e['open'] as num))
                ? '#26a69a'
                : '#ef5350',
          }),
        )
        .toList();

    final script =
        "initChart(${jsonEncode(data)}, ${jsonEncode(options)}, ${jsonEncode(volume)});";
    _controller?.evaluateJavascript(source: script);

    _chartInitialized = true;
    _startLive();
    if (mounted)
      setState(() {
        _loading = false;
      });
  }

  /// Refresh data in background without blocking UI
  Future<void> _refreshDataInBackground(
    String symbol,
    String interval,
    int limit,
    bool isDark,
  ) async {
    try {
      List<Map<String, dynamic>> data;
      try {
        data = await _fetchBinanceKlines(
          symbol: symbol,
          interval: interval,
          limit: limit,
        );
        // Cache the fresh data
        await ChartCacheService.cacheData(symbol, _tf, data);
      } catch (binanceError) {
        print('Background refresh Binance failed: $binanceError');
        // Fallback to CoinGecko
        int days = 30;
        if (_tf == '1H') {
          days = 7;
        } else if (_tf == '1D')
          days = 365;
        else if (_tf == '1W')
          days = 730;
        else if (_tf == '1M' || _tf == '1Y' || _tf == 'ALL')
          days = 3650;
        data = await _fetchCoinGeckoOhlc(widget.coinId, 'usd', days);
        await ChartCacheService.cacheData(symbol, _tf, data);
      }
      
      // Update memory cache
      _klinesCache.putIfAbsent(symbol, () => {})[_tf] = data;
      
      // Update chart if still initialized (don't force update, let user switch timeframes)
      // The chart will update naturally when user switches timeframes
    } catch (e) {
      print('Background refresh failed: $e');
      // Don't show error to user, just log it
    }
  }

  void _startLive() {
    _ws?.sink.close(ws_status.normalClosure);
    if (!_chartInitialized) return;

    final symbol = '${widget.symbolLabel}USDT'.toLowerCase();
    final interval = _getBinanceInterval(_tf);
    // Use tick stream + kline stream for real-time updates
    final url = Uri.parse(
      'wss://stream.binance.com:9443/stream?streams=$symbol@ticker/$symbol@kline_$interval',
    );
    _ws = WebSocketChannel.connect(url);
    _ws!.stream.listen((event) {
      try {
        final map = jsonDecode(event as String) as Map<String, dynamic>;
        final stream = map['stream'] as String?;
        if (stream?.contains('@ticker') ?? false) {
          // Real-time tick updates (prices, volume)
          final data = map['data'] as Map<String, dynamic>?;
          if (data == null) return;
          final close = double.parse(data['c'] ?? '0');
          final vol = double.tryParse(data['v'] ?? '0') ?? 0;
          final now = (DateTime.now().millisecondsSinceEpoch / 1000).round();
          _controller?.evaluateJavascript(
            source:
                "updatePrice(${jsonEncode({'time': now, 'price': close, 'volume': vol})});",
          );
        } else if (stream?.contains('@kline') ?? false) {
          // Candlestick bar completion
          final k = map['data']?['k'] as Map<String, dynamic>?;
          if (k == null) return;
          final t = (k['t'] as num).toInt();
          final open = double.parse(k['o']);
          final high = double.parse(k['h']);
          final low = double.parse(k['l']);
          final close = double.parse(k['c']);
          final vol = double.parse(k['v']);
          final isClosed = k['x'] == true;
          final bar = {
            'time': (t / 1000).round(),
            'open': open,
            'high': high,
            'low': low,
            'close': close,
            'isClosed': isClosed,
          };
          final volBar = {
            'time': (t / 1000).round(),
            'value': vol,
            'color': close >= open ? '#26a69a' : '#ef5350',
          };
          _controller?.evaluateJavascript(
            source: "updateBar(${jsonEncode(bar)}, ${jsonEncode(volBar)});",
          );
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _ws?.sink.close(ws_status.normalClosure);
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchCoinGeckoOhlc(
    String coinId,
    String vsCurrency,
    int days,
  ) async {
    final uri = Uri.parse(
      'https://api.coingecko.com/api/v3/coins/$coinId/ohlc?vs_currency=$vsCurrency&days=$days',
    );
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}');
    }
    final List<dynamic> rows = jsonDecode(resp.body) as List<dynamic>;
    return rows.map<Map<String, dynamic>>((e) {
      final tsMs = (e[0] as num).toInt();
      return {
        'time': (tsMs / 1000).round(),
        'open': (e[1] as num).toDouble(),
        'high': (e[2] as num).toDouble(),
        'low': (e[3] as num).toDouble(),
        'close': (e[4] as num).toDouble(),
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _fetchBinanceKlines({
    required String symbol,
    required String interval,
    int limit = 200,
  }) async {
    final uri = Uri.parse(
      'https://api.binance.com/api/v3/klines?symbol=$symbol&interval=$interval&limit=$limit',
    );
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      final errorBody = resp.body;
      throw Exception('Binance API error ${resp.statusCode}: $errorBody');
    }
    final List<dynamic> rows = jsonDecode(resp.body) as List<dynamic>;
    if (rows.isEmpty) {
      throw Exception('No klines data from Binance');
    }
    return rows.map<Map<String, dynamic>>((e) {
      // Binance returns: [ openTime, open, high, low, close, volume, closeTime, ... ]
      final openTimeMs = (e[0] as num).toInt();
      return {
        'time': (openTimeMs / 1000).round(),
        'open': double.parse(e[1].toString()),
        'high': double.parse(e[2].toString()),
        'low': double.parse(e[3].toString()),
        'close': double.parse(e[4].toString()),
        'volume': double.tryParse(e[5].toString()) ?? 0,
      };
    }).toList();
  }
}
