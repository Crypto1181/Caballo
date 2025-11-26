// Stub implementation for flutter_inappwebview on web
// This file provides empty implementations to prevent compilation errors

import 'package:flutter/material.dart';

// Stub controller class
class InAppWebViewController {
  Future<dynamic> evaluateJavascript({required String source}) async {
    // Return null on web since we can't evaluate JavaScript
    return null;
  }
  
  Future<void> loadUrl({required String url}) async {
    // No-op on web
  }
}

// Stub options classes
class InAppWebViewOptions {
  final bool javaScriptEnabled;
  final bool transparentBackground;
  
  InAppWebViewOptions({
    this.javaScriptEnabled = true,
    this.transparentBackground = false,
  });
}

class InAppWebViewGroupOptions {
  final InAppWebViewOptions crossPlatform;
  
  InAppWebViewGroupOptions({
    required this.crossPlatform,
  });
}

// Stub widget
class InAppWebView extends StatelessWidget {
  final String? initialFile;
  final String? initialUrl;
  final InAppWebViewGroupOptions? initialOptions;
  final Function(InAppWebViewController)? onWebViewCreated;
  final Function(InAppWebViewController, String)? onLoadStop;
  
  const InAppWebView({
    super.key,
    this.initialFile,
    this.initialUrl,
    this.initialOptions,
    this.onWebViewCreated,
    this.onLoadStop,
  });
  
  @override
  Widget build(BuildContext context) {
    // Return a placeholder on web
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Text('WebView not available on web platform'),
      ),
    );
  }
}

