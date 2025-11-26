import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

/// Backend Service for calling Supabase Edge Functions
/// 
/// This service handles all backend API calls:
/// - Creating deposits (Stripe PaymentIntent)
/// - Creating Alpaca accounts
/// - Placing orders
/// - Getting order history
class BackendService {
  static BackendService? _instance;
  static BackendService get instance => _instance ??= BackendService._();
  
  BackendService._();

  // Get Supabase project URL
  String get _baseUrl => SupabaseService.supabaseUrl;
  
  /// Get authentication headers with user token
  Future<Map<String, String>> _getAuthHeaders() async {
    final session = SupabaseService.client.auth.currentSession;
    if (session == null) {
      throw Exception('User not authenticated');
    }
    
    return {
      'Authorization': 'Bearer ${session.accessToken}',
      'Content-Type': 'application/json',
    };
  }

  /// Create a deposit (Stripe PaymentIntent)
  /// 
  /// Returns client_secret for Flutter Stripe SDK
  Future<Map<String, dynamic>> createDeposit({
    required double amount,
  }) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final url = Uri.parse('$_baseUrl/functions/v1/deposit');
    
    final body = {
      'amount': amount,
      'userId': userId,
    };

    try {
      final response = await http.post(
        url,
        headers: await _getAuthHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['error'] ?? 'Failed to create deposit');
      }
    } catch (e) {
      debugPrint('Error creating deposit: $e');
      rethrow;
    }
  }

  /// Create Alpaca account for user
  /// 
  /// This should be called during onboarding after collecting KYC info
  Future<Map<String, dynamic>> createAlpacaAccount({
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
  }) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final url = Uri.parse('$_baseUrl/functions/v1/create-alpaca-account');
    
    final body = {
      'userId': userId,
      'contactEmail': contactEmail,
      'contactPhoneNumber': contactPhoneNumber,
      'contactAddress': contactAddress,
      'contactCity': contactCity,
      'contactState': contactState,
      'contactPostalCode': contactPostalCode,
      'contactCountry': contactCountry,
      if (givenName != null) 'givenName': givenName,
      if (familyName != null) 'familyName': familyName,
      if (taxId != null) 'taxId': taxId,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
    };

    try {
      final response = await http.post(
        url,
        headers: await _getAuthHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['error'] ?? 'Failed to create Alpaca account');
      }
    } catch (e) {
      debugPrint('Error creating Alpaca account: $e');
      rethrow;
    }
  }

  /// Place an order via Alpaca
  /// 
  /// This forwards the order to Alpaca Broker API via backend
  Future<Map<String, dynamic>> placeOrder({
    required String symbol,
    required double qty,
    required String side, // 'buy' or 'sell'
    required String type, // 'market', 'limit', 'stop', 'stop_limit'
    required String timeInForce, // 'day', 'gtc', etc.
    double? limitPrice,
    double? stopPrice,
  }) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final url = Uri.parse('$_baseUrl/functions/v1/place_order');
    
    final body = {
      'userId': userId,
      'symbol': symbol,
      'qty': qty,
      'side': side,
      'type': type,
      'timeInForce': timeInForce,
      if (limitPrice != null) 'limitPrice': limitPrice,
      if (stopPrice != null) 'stopPrice': stopPrice,
    };

    try {
      final response = await http.post(
        url,
        headers: await _getAuthHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['error'] ?? 'Failed to place order');
      }
    } catch (e) {
      debugPrint('Error placing order: $e');
      rethrow;
    }
  }

  /// Get order history for current user
  /// 
  /// [status] - 'all', 'open', or 'closed'
  /// [limit] - Maximum number of orders to return
  Future<List<Map<String, dynamic>>> getOrders({
    String status = 'all',
    int limit = 50,
  }) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final url = Uri.parse('$_baseUrl/functions/v1/get-orders')
        .replace(queryParameters: {
      'status': status,
      'limit': limit.toString(),
    });

    try {
      final response = await http.get(
        url,
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['orders'] ?? []);
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['error'] ?? 'Failed to get orders');
      }
    } catch (e) {
      debugPrint('Error getting orders: $e');
      rethrow;
    }
  }
}

