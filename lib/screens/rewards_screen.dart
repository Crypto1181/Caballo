import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF006844), // Dark green background
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Main Content with PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildPage1(),
                  _buildPage2(),
                  _buildPage3(),
                ],
              ),
            ),
            // Pagination dots
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.green.shade300
                          : Colors.green.shade300.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
            // Bottom CTA button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Get started',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  // Page 1: IRA Growth Chart
  Widget _buildPage1() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              '*Hypothetical illustration',
              style: TextStyle(
                color: Colors.green.shade300,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'GROWTH POTENTIAL',
                  style: TextStyle(
                    color: Colors.green.shade300,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00A843),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'IRA CONTRIBUTIONS',
                  style: TextStyle(
                    color: Colors.green.shade300,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Growth chart illustration
            _buildGrowthChart(),
            const SizedBox(height: 60),
            // Call to action
            Text(
              'Put your money\nto work',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green.shade300,
                fontSize: 38,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Maxing out your IRA contributions every year could grow to over \$1,000,000+ in 35 years.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green.shade300,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: Text(
                'Returns aren\'t guaranteed',
                style: TextStyle(
                  color: Colors.green.shade300,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.green.shade300,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Page 2: 1% Reward
  Widget _buildPage2() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Circular graphic
            CustomPaint(
              size: const Size(220, 220),
              painter: _CircularGraphicPainter(),
            ),
            const SizedBox(height: 80),
            // Call to action
            Text(
              'Get rewarded\nwith 1% extra',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green.shade300,
                fontSize: 38,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Transfer any amount from outside accounts, IRAs, or old 401(k)s. We\'ll add 1%. No cap.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green.shade300,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: Text(
                'Limitations apply',
                style: TextStyle(
                  color: Colors.green.shade300,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.green.shade300,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Page 3: Tax Advantages
  Widget _buildPage3() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Tax graphic
            CustomPaint(
              size: const Size(300, 180),
              painter: _TaxGraphicPainter(),
            ),
            const SizedBox(height: 80),
            // Call to action
            Text(
              'All with tax\nadvantages',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green.shade300,
                fontSize: 38,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Earnings have tax-deferred or tax-free growth potential, so you\'ll keep more of what you invest.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green.shade300,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthChart() {
    return SizedBox(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildBar(40, 30),
          const SizedBox(width: 16),
          _buildBar(65, 45),
          const SizedBox(width: 16),
          _buildBar(95, 65),
          const SizedBox(width: 16),
          _buildBar(130, 85, showLabel: true),
        ],
      ),
    );
  }

  Widget _buildBar(double growthHeight, double contributionHeight, {bool showLabel = false}) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (showLabel)
            Text(
              '\$1M',
              style: TextStyle(
                color: Colors.green.shade300,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            const SizedBox(height: 14),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final total = growthHeight + contributionHeight;
                final availableHeight = constraints.maxHeight;
                final scale = total > availableHeight ? availableHeight / total : 1.0;
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: double.infinity,
                      height: (growthHeight * scale).clamp(10, double.infinity),
                      decoration: BoxDecoration(
                        color: Colors.green.shade300,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: (contributionHeight * scale).clamp(10, double.infinity),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A843),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 12,
            child: CustomPaint(
              painter: _TickMarksPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painters for graphics
class _CircularGraphicPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw multiple rotating ellipses
    for (int i = 0; i < 3; i++) {
      paint.color = i == 1 ? const Color(0xFF00C853) : Colors.green.shade800;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * 0.6);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: size.width * 0.8,
          height: size.height * 0.4,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TaxGraphicPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw curved text paths representing "TAXES TAXES"
    final path1 = Path()
      ..moveTo(size.width * 0.1, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.2,
        size.width * 0.5,
        size.height * 0.3,
      );

    final path2 = Path()
      ..moveTo(size.width * 0.5, size.height * 0.3)
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.4,
        size.width * 0.9,
        size.height * 0.2,
      );

    // Draw dashed curves
    _drawDashedPath(canvas, path1, paint);
    _drawDashedPath(canvas, path2, paint);

    // Draw text "TAXES" along paths
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'TAXES TAXE',
        style: TextStyle(
          color: Colors.green.shade300,
          fontSize: 36,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    canvas.save();
    canvas.translate(size.width * 0.05, size.height * 0.35);
    canvas.rotate(-0.2);
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final dashWidth = 10.0;
    final dashSpace = 8.0;
    final metric = path.computeMetrics().first;
    var distance = 0.0;

    while (distance < metric.length) {
      final start = metric.getTangentForOffset(distance)!.position;
      distance += dashWidth;
      final end = metric.getTangentForOffset(distance)!.position;
      canvas.drawLine(start, end, paint);
      distance += dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TickMarksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.shade300
      ..strokeWidth = 1.0;

    for (int i = 0; i < 8; i++) {
      final x = size.width * i / 7;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, 10),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

