import 'package:flutter/material.dart';

// Stub version for platforms that don't support mobile_scanner
class QRScannerScreen extends StatefulWidget {
  final String amount;
  final String currency;

  const QRScannerScreen({
    super.key,
    required this.amount,
    required this.currency,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenStubState();
}

class _QRScannerScreenStubState extends State<QRScannerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Scanner')),
      body: const Center(
        child: Text('QR Scanner not available on this platform'),
      ),
    );
  }
}

