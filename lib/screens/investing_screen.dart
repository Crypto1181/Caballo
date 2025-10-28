import 'package:flutter/material.dart';
import 'stock_detail_screen.dart';

class InvestingScreen extends StatelessWidget {
  const InvestingScreen({super.key});

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Investing',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.search, color: isDark ? Colors.white : Colors.black),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.notifications_outlined, color: isDark ? Colors.white : Colors.black),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Create watchlist card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[900] : Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.add, size: 28, color: isDark ? Colors.grey[400] : Colors.black87),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Create watchlist or screener',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Crypto to watch section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[900] : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.purple[300]!, Colors.purple[500]!],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.currency_bitcoin,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Crypto to watch',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.white : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '6 items',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDark ? Colors.grey[400] : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_up, color: isDark ? Colors.grey[500] : Colors.grey[600]),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Divider(height: 1, thickness: 1),
                            const SizedBox(height: 16),
                            // Crypto list
                            _buildCryptoItem(context, 'BTC', 'Bitcoin', 115530.50, true),
                            _buildCryptoItem(context, 'ETH', 'Ethereum', 4211.94, false),
                            _buildCryptoItem(context, 'SOL', 'Solana', 202.31, false),
                            _buildCryptoItem(context, 'DOGE', 'Dogecoin', 0.204729, false),
                            _buildCryptoItem(context, 'XRP', 'XRP', 2.68, false),
                            _buildCryptoItem(context, 'PEPE', 'Pepe', 0.00000732, false),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // First list section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.amber[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.emoji_events_outlined,
                                color: Colors.amber[800],
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                'First list',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCryptoItem(BuildContext context, String symbol, String name, double price, bool isPositive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StockDetailScreen(
                symbol: symbol,
                name: name,
                price: price,
                change: isPositive ? 12.50 : -8.30,
                isPositive: isPositive,
              ),
            ),
          );
        },
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symbol,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Mini chart
            CustomPaint(
              size: const Size(80, 35),
              painter: _MiniChartPainter(isPositive: isPositive),
            ),
            const SizedBox(width: 12),
            // Price button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isPositive ? const Color(0xFF00C853) : Colors.orange[600],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '\$${price < 1 ? price.toStringAsFixed(price < 0.01 ? 8 : 2) : price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Mini chart painter for crypto items
class _MiniChartPainter extends CustomPainter {
  final bool isPositive;
  
  _MiniChartPainter({required this.isPositive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isPositive ? const Color(0xFF00C853) : Colors.orange[600]!
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Generate a simple chart path
    if (isPositive) {
      // Upward trending
      path.moveTo(0, size.height * 0.7);
      path.lineTo(size.width * 0.2, size.height * 0.5);
      path.lineTo(size.width * 0.4, size.height * 0.6);
      path.lineTo(size.width * 0.6, size.height * 0.3);
      path.lineTo(size.width * 0.8, size.height * 0.4);
      path.lineTo(size.width, size.height * 0.2);
    } else {
      // Downward or sideways
      path.moveTo(0, size.height * 0.3);
      path.lineTo(size.width * 0.2, size.height * 0.4);
      path.lineTo(size.width * 0.4, size.height * 0.5);
      path.lineTo(size.width * 0.6, size.height * 0.4);
      path.lineTo(size.width * 0.8, size.height * 0.6);
      path.lineTo(size.width, size.height * 0.5);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

