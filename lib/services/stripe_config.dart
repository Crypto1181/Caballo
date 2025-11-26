import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Configuration service for Stripe
/// 
/// Stores Stripe publishable key for client-side payment processing
class StripeConfig {
  static StripeConfig? _instance;
  static StripeConfig get instance => _instance ??= StripeConfig._();

  StripeConfig._();

  static const String _keyPublishableKey = 'stripe_publishable_key';
  static const String _keyUseProduction = 'stripe_use_production';

  String? _publishableKey;
  bool _useProduction = false;

  /// Initialize from SharedPreferences
  Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _publishableKey = prefs.getString(_keyPublishableKey);
      _useProduction = prefs.getBool(_keyUseProduction) ?? false;
    } catch (e) {
      debugPrint('Error loading Stripe config: $e');
    }
  }

  /// Save publishable key
  Future<void> savePublishableKey({
    required String publishableKey,
    bool useProduction = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyPublishableKey, publishableKey);
      await prefs.setBool(_keyUseProduction, useProduction);

      _publishableKey = publishableKey;
      _useProduction = useProduction;
    } catch (e) {
      debugPrint('Error saving Stripe config: $e');
      rethrow;
    }
  }

  /// Get publishable key
  String? get publishableKey => _publishableKey;

  /// Check if configured
  bool get isConfigured => _publishableKey != null && _publishableKey!.isNotEmpty;

  /// Get production flag
  bool get useProduction => _useProduction;

  /// Clear stored credentials
  Future<void> clearCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyPublishableKey);
      await prefs.remove(_keyUseProduction);

      _publishableKey = null;
      _useProduction = false;
    } catch (e) {
      debugPrint('Error clearing Stripe config: $e');
    }
  }
}

