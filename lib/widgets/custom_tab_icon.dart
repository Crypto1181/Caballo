import 'package:flutter/material.dart';

class CustomTabIcon {
  static Widget buildIcon(int index, bool isSelected) {
    switch (index) {
      case 0:
        // Chart icon for Investing
        return Icon(
          isSelected ? Icons.show_chart : Icons.show_chart_outlined,
          size: 24,
        );
      case 1:
        // Bitcoin/Crypto icon
        return _buildBitcoinIcon(isSelected);
      case 2:
        // Rewards/Infinity icon
        return _buildInfinityIcon(isSelected);
      case 3:
        // Wallet icon
        return Icon(
          isSelected ? Icons.account_balance_wallet : Icons.account_balance_wallet_outlined,
          size: 24,
        );
      case 4:
        // Profile icon
        return Icon(
          isSelected ? Icons.person : Icons.person_outline,
          size: 24,
        );
      default:
        return const Icon(Icons.circle);
    }
  }

  static Widget _buildBitcoinIcon(bool isSelected) {
    return CustomPaint(
      size: const Size(24, 24),
      painter: _BitcoinIconPainter(isSelected),
    );
  }

  static Widget _buildInfinityIcon(bool isSelected) {
    return CustomPaint(
      size: const Size(24, 24),
      painter: _InfinityIconPainter(isSelected),
    );
  }
}

class _BitcoinIconPainter extends CustomPainter {
  final bool isSelected;

  _BitcoinIconPainter(this.isSelected);

  @override
  void paint(Canvas canvas, Size size) {
    final color = isSelected ? Colors.green : Colors.grey[600]!;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw "B" shape for Bitcoin
    final path = Path();
    
    // Vertical line
    path.moveTo(size.width * 0.3, size.height * 0.2);
    path.lineTo(size.width * 0.3, size.height * 0.8);
    
    // Top semi-circle
    path.moveTo(size.width * 0.3, size.height * 0.2);
    path.arcToPoint(
      Offset(size.width * 0.7, size.height * 0.4),
      radius: Radius.circular(size.height * 0.2),
      clockwise: true,
    );
    
    // Middle to bottom
    path.moveTo(size.width * 0.3, size.height * 0.5);
    path.lineTo(size.width * 0.7, size.height * 0.5);
    
    // Bottom semi-circle
    path.moveTo(size.width * 0.3, size.height * 0.5);
    path.arcToPoint(
      Offset(size.width * 0.7, size.height * 0.8),
      radius: Radius.circular(size.height * 0.2),
      clockwise: true,
    );
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InfinityIconPainter extends CustomPainter {
  final bool isSelected;

  _InfinityIconPainter(this.isSelected);

  @override
  void paint(Canvas canvas, Size size) {
    final color = isSelected ? Colors.green : Colors.grey[600]!;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    
    // Draw infinity symbol
    path.moveTo(size.width * 0.2, size.height * 0.5);
    
    // Left loop
    path.arcToPoint(
      Offset(size.width * 0.8, size.height * 0.5),
      radius: Radius.circular(size.height * 0.2),
    );
    
    // Right loop
    path.arcToPoint(
      Offset(size.width * 0.2, size.height * 0.5),
      radius: Radius.circular(size.height * 0.2),
    );
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

