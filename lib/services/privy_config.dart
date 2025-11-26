import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Configuration service for Privy API credentials
/// 
/// This service handles loading and storing Privy API credentials securely.
class PrivyConfig {
  static PrivyConfig? _instance;
  static PrivyConfig get instance => _instance ??= PrivyConfig._();
  
  PrivyConfig._();

  static const String _keyAppId = 'privy_app_id';
  static const String _keyAppSecret = 'privy_app_secret';
  static const String _keyUseProduction = 'privy_use_production';

  String? _appId;
  String? _appSecret;
  bool _useProduction = false;

  /// Initialize from SharedPreferences
  Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _appId = prefs.getString(_keyAppId);
      _appSecret = prefs.getString(_keyAppSecret);
      _useProduction = prefs.getBool(_keyUseProduction) ?? false;
    } catch (e) {
      debugPrint('Error loading Privy config: $e');
    }
  }

  /// Save credentials to SharedPreferences
  Future<void> saveCredentials({
    required String appId,
    required String appSecret,
    bool useProduction = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAppId, appId);
      await prefs.setString(_keyAppSecret, appSecret);
      await prefs.setBool(_keyUseProduction, useProduction);
      
      _appId = appId;
      _appSecret = appSecret;
      _useProduction = useProduction;
    } catch (e) {
      debugPrint('Error saving Privy config: $e');
      rethrow;
    }
  }

  /// Clear stored credentials
  Future<void> clearCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyAppId);
      await prefs.remove(_keyAppSecret);
      await prefs.remove(_keyUseProduction);
      
      _appId = null;
      _appSecret = null;
      _useProduction = false;
    } catch (e) {
      debugPrint('Error clearing Privy config: $e');
    }
  }

  /// Check if credentials are configured
  bool get isConfigured {
    return _appId != null && 
           _appSecret != null &&
           _appId!.isNotEmpty &&
           _appSecret!.isNotEmpty;
  }

  /// Get App ID
  String? get appId => _appId;

  /// Get App Secret
  String? get appSecret => _appSecret;

  /// Get production flag
  bool get useProduction => _useProduction;

  /// Set credentials directly (for testing or environment variables)
  void setCredentials({
    required String appId,
    required String appSecret,
    bool useProduction = false,
  }) {
    _appId = appId;
    _appSecret = appSecret;
    _useProduction = useProduction;
  }
}

