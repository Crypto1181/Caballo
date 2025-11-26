import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Configuration service for Alpaca API credentials
/// 
/// This service handles loading and storing Alpaca API credentials securely.
/// For production, consider using flutter_secure_storage instead.
class AlpacaConfig {
  static AlpacaConfig? _instance;
  static AlpacaConfig get instance => _instance ??= AlpacaConfig._();
  
  AlpacaConfig._();

  static const String _keyApiKeyId = 'alpaca_api_key_id';
  static const String _keyApiSecretKey = 'alpaca_api_secret_key';
  static const String _keyBrokerId = 'alpaca_broker_id';
  static const String _keyUseProduction = 'alpaca_use_production';

  String? _apiKeyId;
  String? _apiSecretKey;
  String? _brokerId;
  bool _useProduction = false;

  /// Initialize from SharedPreferences
  Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _apiKeyId = prefs.getString(_keyApiKeyId);
      _apiSecretKey = prefs.getString(_keyApiSecretKey);
      _brokerId = prefs.getString(_keyBrokerId);
      _useProduction = prefs.getBool(_keyUseProduction) ?? false;
    } catch (e) {
      debugPrint('Error loading Alpaca config: $e');
    }
  }

  /// Save credentials to SharedPreferences
  /// 
  /// For Broker API, use Client ID as apiKeyId and Client Secret as apiSecretKey.
  /// The Client ID can also be used as the brokerId.
  Future<void> saveCredentials({
    required String apiKeyId, // Client ID for Broker API
    required String apiSecretKey, // Client Secret for Broker API
    String? brokerId, // Optional, defaults to Client ID if not provided
    bool useProduction = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyApiKeyId, apiKeyId);
      await prefs.setString(_keyApiSecretKey, apiSecretKey);
      await prefs.setString(_keyBrokerId, brokerId ?? apiKeyId); // Use Client ID as Broker ID if not provided
      await prefs.setBool(_keyUseProduction, useProduction);
      
      _apiKeyId = apiKeyId;
      _apiSecretKey = apiSecretKey;
      _brokerId = brokerId ?? apiKeyId;
      _useProduction = useProduction;
    } catch (e) {
      debugPrint('Error saving Alpaca config: $e');
      rethrow;
    }
  }

  /// Clear stored credentials
  Future<void> clearCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyApiKeyId);
      await prefs.remove(_keyApiSecretKey);
      await prefs.remove(_keyBrokerId);
      await prefs.remove(_keyUseProduction);
      
      _apiKeyId = null;
      _apiSecretKey = null;
      _brokerId = null;
      _useProduction = false;
    } catch (e) {
      debugPrint('Error clearing Alpaca config: $e');
    }
  }

  /// Check if credentials are configured
  bool get isConfigured {
    return _apiKeyId != null && 
           _apiSecretKey != null && 
           _brokerId != null &&
           _apiKeyId!.isNotEmpty &&
           _apiSecretKey!.isNotEmpty &&
           _brokerId!.isNotEmpty;
  }

  /// Get API Key ID
  String? get apiKeyId => _apiKeyId;

  /// Get API Secret Key
  String? get apiSecretKey => _apiSecretKey;

  /// Get Broker ID
  String? get brokerId => _brokerId;

  /// Get production flag
  bool get useProduction => _useProduction;

  /// Set credentials directly (for testing or environment variables)
  /// 
  /// For Broker API, use Client ID as apiKeyId and Client Secret as apiSecretKey.
  void setCredentials({
    required String apiKeyId, // Client ID for Broker API
    required String apiSecretKey, // Client Secret for Broker API
    String? brokerId, // Optional, defaults to Client ID
    bool useProduction = false,
  }) {
    _apiKeyId = apiKeyId;
    _apiSecretKey = apiSecretKey;
    _brokerId = brokerId ?? apiKeyId;
    _useProduction = useProduction;
  }
}

