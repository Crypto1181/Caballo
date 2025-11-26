import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../widgets/order_placement_dialog.dart';

class StockDetailScreen extends StatefulWidget {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final bool isPositive;

  const StockDetailScreen({
    super.key,
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.isPositive,
  });

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  String _selectedPeriod = '1D';
  final List<String> _periods = ['1D', '1W', '1M', '3M', 'YTD', '1Y', '5Y'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: isDark ? Colors.white : Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.share_outlined, color: isDark ? Colors.white : Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stock header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.symbol,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.name,
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
                              '\$${widget.price.toStringAsFixed(2)}',
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
                                  widget.isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                                  size: 16,
                                  color: widget.isPositive ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    '\$${widget.change.abs().toStringAsFixed(2)} (${(widget.change / widget.price * 100).toStringAsFixed(2)}%)',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: widget.isPositive ? Colors.green : Colors.red,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Today',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Chart
                  SizedBox(
                    height: 300,
                    child: CustomPaint(
                      painter: _StockChartPainter(
                        isPositive: widget.isPositive,
                        isDark: isDark,
                      ),
                      child: Container(),
                    ),
                  ),
                  
                  // Period selector
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _periods.map((period) {
                        final isSelected = _selectedPeriod == period;
                        return InkWell(
                          onTap: () => setState(() => _selectedPeriod = period),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected 
                                ? const Color(0xFF00C853) 
                                : (isDark ? Colors.grey[900] : Colors.grey[100]),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              period,
                              style: TextStyle(
                                color: isSelected 
                                  ? Colors.white 
                                  : (isDark ? Colors.grey[400] : Colors.grey[700]),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Today's Volume
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.show_chart,
                          size: 20,
                          color: const Color(0xFF00C853),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Today's Volume",
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '8,403,350',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Stats section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildStatRow('Market Cap', '\$2.31T', isDark),
                        const SizedBox(height: 16),
                        _buildStatRow('52 Week High', '\$${(widget.price * 1.25).toStringAsFixed(2)}', isDark),
                        const SizedBox(height: 16),
                        _buildStatRow('52 Week Low', '\$${(widget.price * 0.75).toStringAsFixed(2)}', isDark),
                        const SizedBox(height: 16),
                        _buildStatRow('P/E Ratio', '28.64', isDark),
                        const SizedBox(height: 16),
                        _buildStatRow('Dividend Yield', '0.52%', isDark),
                        const SizedBox(height: 16),
                        _buildStatRow('Average Volume', '58.4M', isDark),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // About section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${widget.name} is a leading cryptocurrency and digital payment system. It operates on a decentralized network, allowing peer-to-peer transactions without the need for intermediaries.',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          
          // Bottom buy button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => OrderPlacementDialog(
                      symbol: widget.symbol,
                      name: widget.name,
                      currentPrice: widget.price,
                      isPositive: widget.isPositive,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Buy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}

class _StockChartPainter extends CustomPainter {
  final bool isPositive;
  final bool isDark;

  _StockChartPainter({required this.isPositive, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // Generate realistic chart data
    final random = math.Random(42); // Fixed seed for consistent chart
    final points = <Offset>[];
    
    for (int i = 0; i < 50; i++) {
      final x = (i / 49) * size.width;
      final baseY = size.height * 0.5;
      final noise = (random.nextDouble() - 0.5) * size.height * 0.3;
      final trend = isPositive ? -i * 2.0 : i * 2.0; // Upward or downward trend
      final y = baseY + noise + trend;
      points.add(Offset(x, y.clamp(size.height * 0.1, size.height * 0.9)));
    }

    // Draw gradient fill under the line
    final gradientPath = Path();
    gradientPath.moveTo(0, size.height);
    for (var point in points) {
      gradientPath.lineTo(point.dx, point.dy);
    }
    gradientPath.lineTo(size.width, size.height);
    gradientPath.close();

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          (isPositive ? Colors.green : Colors.orange).withOpacity(0.3),
          (isPositive ? Colors.green : Colors.orange).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(gradientPath, gradientPaint);

    // Draw the line
    final linePaint = Paint()
      ..color = isPositive ? Colors.green : Colors.orange
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path();
    linePath.moveTo(points[0].dx, points[0].dy);
    for (var point in points) {
      linePath.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(linePath, linePaint);

    // Draw current point indicator
    final lastPoint = points.last;
    final circlePaint = Paint()
      ..color = isPositive ? Colors.green : Colors.orange
      ..style = PaintingStyle.fill;

    canvas.drawCircle(lastPoint, 6, circlePaint);
    
    final outerCirclePaint = Paint()
      ..color = (isPositive ? Colors.green : Colors.orange).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(lastPoint, 12, outerCirclePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

