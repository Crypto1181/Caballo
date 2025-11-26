import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Alpaca Broker API Service
/// 
/// This service handles all interactions with Alpaca's Broker API.
/// The Broker API is designed for businesses managing multiple user accounts.
/// 
/// Key Features:
/// - Account creation and management
/// - User onboarding (KYC/AML)
/// - Trading on behalf of users
/// - Funding operations (deposits/withdrawals)
/// - Market data access
/// - Portfolio and position management
class AlpacaService {
  static AlpacaService? _instance;
  static AlpacaService get instance => _instance ??= AlpacaService._();
  
  AlpacaService._();

  // Base URLs
  static const String _brokerApiBaseUrl = 'https://broker-api.sandbox.alpaca.markets'; // Sandbox
  // For production: 'https://broker-api.alpaca.markets'
  
  static const String _dataApiBaseUrl = 'https://data.sandbox.alpaca.markets'; // Market data sandbox
  // For production: 'https://data.alpaca.markets'

  // API Keys - These should be stored securely (environment variables, secure storage)
  String? _apiKeyId;
  String? _apiSecretKey;
  // Broker ID is stored but may be used in future Broker API endpoints
  // ignore: unused_field
  String? _brokerId;

  /// Initialize the service with API credentials
  /// 
  /// [apiKeyId] - Your Alpaca Client ID (for Broker API)
  /// [apiSecretKey] - Your Alpaca Client Secret (for Broker API)
  /// [brokerId] - Your Broker ID (optional, defaults to Client ID)
  /// [useProduction] - Set to true for production, false for sandbox
  void initialize({
    required String apiKeyId, // Client ID for Broker API
    required String apiSecretKey, // Client Secret for Broker API
    String? brokerId, // Optional, defaults to Client ID
    bool useProduction = false,
  }) {
    _apiKeyId = apiKeyId;
    _apiSecretKey = apiSecretKey;
    _brokerId = brokerId ?? apiKeyId;
    
    if (useProduction) {
      // Update base URLs for production
      // Note: You'll need to update the constants above for production
    }
  }

  /// Get authentication headers for Broker API
  Map<String, String> _getBrokerAuthHeaders() {
    if (_apiKeyId == null || _apiSecretKey == null) {
      throw Exception('AlpacaService not initialized. Call initialize() first.');
    }
    
    final credentials = base64Encode(utf8.encode('$_apiKeyId:$_apiSecretKey'));
    return {
      'Authorization': 'Basic $credentials',
      'Content-Type': 'application/json',
    };
  }

  /// Get authentication headers for Trading API
  Map<String, String> _getTradingAuthHeaders() {
    if (_apiKeyId == null || _apiSecretKey == null) {
      throw Exception('AlpacaService not initialized. Call initialize() first.');
    }
    
    return {
      'APCA-API-KEY-ID': _apiKeyId!,
      'APCA-API-SECRET-KEY': _apiSecretKey!,
      'Content-Type': 'application/json',
    };
  }

  // ============================================================================
  // BROKER API - Account Management
  // ============================================================================

  /// Create a new account for a user
  /// 
  /// Returns account details including account_id
  Future<Map<String, dynamic>> createAccount({
    required String contactEmail,
    required String contactPhoneNumber,
    required String contactAddress,
    required String contactCity,
    required String contactState,
    required String contactPostalCode,
    required String contactCountry,
    String? givenName,
    String? familyName,
    String? taxId,
    String? dateOfBirth,
    String? fundingSource,
  }) async {
    final url = Uri.parse('$_brokerApiBaseUrl/v1/accounts');
    
    final body = {
      'contact': {
        'email_address': contactEmail,
        'phone_number': contactPhoneNumber,
        'street_address': [contactAddress],
        'city': contactCity,
        'state': contactState,
        'postal_code': contactPostalCode,
        'country': contactCountry,
      },
      if (givenName != null) 'given_name': givenName,
      if (familyName != null) 'family_name': familyName,
      if (taxId != null) 'tax_id': taxId,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (fundingSource != null) 'funding_source': fundingSource,
    };

    try {
      final response = await http.post(
        url,
        headers: _getBrokerAuthHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create account: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error creating account: $e');
      rethrow;
    }
  }

  /// Get account details by account ID
  Future<Map<String, dynamic>> getAccount(String accountId) async {
    final url = Uri.parse('$_brokerApiBaseUrl/v1/accounts/$accountId');
    
    try {
      final response = await http.get(
        url,
        headers: _getBrokerAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get account: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error getting account: $e');
      rethrow;
    }
  }

  /// List all accounts
  Future<List<Map<String, dynamic>>> listAccounts({
    String? status,
    int? limit,
    String? sort,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (sort != null) queryParams['sort'] = sort;

    final url = Uri.parse('$_brokerApiBaseUrl/v1/accounts').replace(queryParameters: queryParams);
    
    try {
      final response = await http.get(
        url,
        headers: _getBrokerAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['accounts'] ?? []);
      } else {
        throw Exception('Failed to list accounts: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error listing accounts: $e');
      rethrow;
    }
  }

  /// Update account information
  Future<Map<String, dynamic>> updateAccount(
    String accountId, {
    Map<String, dynamic>? contact,
    String? givenName,
    String? familyName,
    String? taxId,
    String? dateOfBirth,
  }) async {
    final url = Uri.parse('$_brokerApiBaseUrl/v1/accounts/$accountId');
    
    final body = <String, dynamic>{};
    if (contact != null) body['contact'] = contact;
    if (givenName != null) body['given_name'] = givenName;
    if (familyName != null) body['family_name'] = familyName;
    if (taxId != null) body['tax_id'] = taxId;
    if (dateOfBirth != null) body['date_of_birth'] = dateOfBirth;

    try {
      final response = await http.patch(
        url,
        headers: _getBrokerAuthHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update account: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error updating account: $e');
      rethrow;
    }
  }

  // ============================================================================
  // BROKER API - Trading Operations
  // ============================================================================

  /// Place an order on behalf of a user account
  /// 
  /// [accountId] - The account ID to place the order for
  /// [symbol] - Stock symbol (e.g., 'AAPL', 'TSLA')
  /// [qty] - Quantity of shares
  /// [side] - 'buy' or 'sell'
  /// [type] - 'market', 'limit', 'stop', 'stop_limit'
  /// [timeInForce] - 'day', 'gtc', 'opg', 'cls', 'ioc', 'fok'
  /// [limitPrice] - Required for limit orders
  /// [stopPrice] - Required for stop orders
  Future<Map<String, dynamic>> placeOrder({
    required String accountId,
    required String symbol,
    required double qty,
    required String side, // 'buy' or 'sell'
    required String type, // 'market', 'limit', 'stop', 'stop_limit'
    required String timeInForce, // 'day', 'gtc', etc.
    double? limitPrice,
    double? stopPrice,
  }) async {
    final url = Uri.parse('$_brokerApiBaseUrl/v1/trading/accounts/$accountId/orders');
    
    final body = {
      'symbol': symbol,
      'qty': qty,
      'side': side,
      'type': type,
      'time_in_force': timeInForce,
      if (limitPrice != null) 'limit_price': limitPrice,
      if (stopPrice != null) 'stop_price': stopPrice,
    };

    try {
      final response = await http.post(
        url,
        headers: _getBrokerAuthHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to place order: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error placing order: $e');
      rethrow;
    }
  }

  /// Get all orders for an account
  Future<List<Map<String, dynamic>>> getOrders({
    required String accountId,
    String? status,
    int? limit,
    String? after,
    String? until,
    String? direction,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (after != null) queryParams['after'] = after;
    if (until != null) queryParams['until'] = until;
    if (direction != null) queryParams['direction'] = direction;

    final url = Uri.parse('$_brokerApiBaseUrl/v1/trading/accounts/$accountId/orders')
        .replace(queryParameters: queryParams);
    
    try {
      final response = await http.get(
        url,
        headers: _getBrokerAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['orders'] ?? []);
      } else {
        throw Exception('Failed to get orders: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error getting orders: $e');
      rethrow;
    }
  }

  /// Get a specific order by ID
  Future<Map<String, dynamic>> getOrder({
    required String accountId,
    required String orderId,
  }) async {
    final url = Uri.parse('$_brokerApiBaseUrl/v1/trading/accounts/$accountId/orders/$orderId');
    
    try {
      final response = await http.get(
        url,
        headers: _getBrokerAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get order: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error getting order: $e');
      rethrow;
    }
  }

  /// Cancel an order
  Future<void> cancelOrder({
    required String accountId,
    required String orderId,
  }) async {
    final url = Uri.parse('$_brokerApiBaseUrl/v1/trading/accounts/$accountId/orders/$orderId');
    
    try {
      final response = await http.delete(
        url,
        headers: _getBrokerAuthHeaders(),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to cancel order: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error canceling order: $e');
      rethrow;
    }
  }

  // ============================================================================
  // BROKER API - Positions
  // ============================================================================

  /// Get all positions for an account
  Future<List<Map<String, dynamic>>> getPositions({
    required String accountId,
  }) async {
    final url = Uri.parse('$_brokerApiBaseUrl/v1/trading/accounts/$accountId/positions');
    
    try {
      final response = await http.get(
        url,
        headers: _getBrokerAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['positions'] ?? []);
      } else {
        throw Exception('Failed to get positions: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error getting positions: $e');
      rethrow;
    }
  }

  /// Get a specific position by symbol
  Future<Map<String, dynamic>> getPosition({
    required String accountId,
    required String symbol,
  }) async {
    final url = Uri.parse('$_brokerApiBaseUrl/v1/trading/accounts/$accountId/positions/$symbol');
    
    try {
      final response = await http.get(
        url,
        headers: _getBrokerAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get position: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error getting position: $e');
      rethrow;
    }
  }

  /// Close a position (close all shares of a symbol)
  Future<Map<String, dynamic>> closePosition({
    required String accountId,
    required String symbol,
  }) async {
    final url = Uri.parse('$_brokerApiBaseUrl/v1/trading/accounts/$accountId/positions/$symbol');
    
    try {
      final response = await http.delete(
        url,
        headers: _getBrokerAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to close position: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error closing position: $e');
      rethrow;
    }
  }

  // ============================================================================
  // BROKER API - Account Portfolio
  // ============================================================================

  /// Get account portfolio (balances, buying power, etc.)
  Future<Map<String, dynamic>> getAccountPortfolio({
    required String accountId,
  }) async {
    final url = Uri.parse('$_brokerApiBaseUrl/v1/trading/accounts/$accountId/account');
    
    try {
      final response = await http.get(
        url,
        headers: _getBrokerAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get account portfolio: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error getting account portfolio: $e');
      rethrow;
    }
  }

  // ============================================================================
  // MARKET DATA API
  // ============================================================================

  /// Get latest quote for a symbol
  Future<Map<String, dynamic>> getLatestQuote(String symbol) async {
    final url = Uri.parse('$_dataApiBaseUrl/v2/stocks/$symbol/quotes/latest');
    
    try {
      final response = await http.get(
        url,
        headers: _getTradingAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['quote'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get quote: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error getting quote: $e');
      rethrow;
    }
  }

  /// Get latest trade for a symbol
  Future<Map<String, dynamic>> getLatestTrade(String symbol) async {
    final url = Uri.parse('$_dataApiBaseUrl/v2/stocks/$symbol/trades/latest');
    
    try {
      final response = await http.get(
        url,
        headers: _getTradingAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['trade'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get trade: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error getting trade: $e');
      rethrow;
    }
  }

  /// Get historical bars (OHLCV data) for a symbol
  /// 
  /// [symbol] - Stock symbol
  /// [timeframe] - '1Min', '5Min', '15Min', '30Min', '1Hour', '1Day'
  /// [start] - Start time (ISO 8601 format)
  /// [end] - End time (ISO 8601 format)
  /// [limit] - Maximum number of bars to return
  Future<List<Map<String, dynamic>>> getBars({
    required String symbol,
    required String timeframe,
    String? start,
    String? end,
    int? limit,
  }) async {
    final queryParams = <String, String>{
      'timeframe': timeframe,
    };
    if (start != null) queryParams['start'] = start;
    if (end != null) queryParams['end'] = end;
    if (limit != null) queryParams['limit'] = limit.toString();

    final url = Uri.parse('$_dataApiBaseUrl/v2/stocks/$symbol/bars')
        .replace(queryParameters: queryParams);
    
    try {
      final response = await http.get(
        url,
        headers: _getTradingAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['bars'] ?? []);
      } else {
        throw Exception('Failed to get bars: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error getting bars: $e');
      rethrow;
    }
  }

  /// Search for assets (stocks, ETFs, etc.)
  Future<List<Map<String, dynamic>>> searchAssets({
    String? query,
    String? assetClass,
    String? exchange,
    String? status,
  }) async {
    final queryParams = <String, String>{};
    if (query != null) queryParams['query'] = query;
    if (assetClass != null) queryParams['asset_class'] = assetClass;
    if (exchange != null) queryParams['exchange'] = exchange;
    if (status != null) queryParams['status'] = status;

    final url = Uri.parse('$_dataApiBaseUrl/v2/assets')
        .replace(queryParameters: queryParams);
    
    try {
      final response = await http.get(
        url,
        headers: _getTradingAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body) as List);
      } else {
        throw Exception('Failed to search assets: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error searching assets: $e');
      rethrow;
    }
  }
}

