import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'supabase_service.dart';

/// Privy Service for wallet management
/// 
/// This service handles:
/// - Embedded MPC wallet creation via Privy API
/// - Wallet address retrieval
/// - KYC token storage
/// 
/// Note: Privy doesn't have an official Flutter SDK yet, so we use their REST API
/// For production, you may want to create wallets via your backend
class PrivyService {
  static PrivyService? _instance;
  static PrivyService get instance => _instance ??= PrivyService._();
  
  PrivyService._();

  // Privy API credentials - should be stored securely
  String? _appId;
  String? _appSecret;
  String? _baseUrl = 'https://api.privy.io';
  bool _initialized = false;

  /// Initialize Privy service with credentials
  /// 
  /// [appId] - Your Privy App ID from privy.io dashboard
  /// [appSecret] - Your Privy App Secret
  /// [useProduction] - Set to true for production, false for development
  void initialize({
    required String appId,
    required String appSecret,
    bool useProduction = false,
  }) {
    _appId = appId;
    _appSecret = appSecret;
    _initialized = true;
    // Privy uses same API for dev/prod, but you can set different base URLs if needed
    if (useProduction) {
      _baseUrl = 'https://api.privy.io';
    }
  }

  /// Check if Privy service is initialized
  bool get isInitialized => _initialized;

  /// Get authentication headers for Privy API
  Map<String, String> _getAuthHeaders() {
    if (_appId == null || _appSecret == null) {
      throw Exception('PrivyService not initialized. Call initialize() first.');
    }
    
    final credentials = base64Encode(utf8.encode('$_appId:$_appSecret'));
    return {
      'Authorization': 'Basic $credentials',
      'privy-app-id': _appId!,
      'Content-Type': 'application/json',
    };
  }

  /// Create an embedded MPC wallet for a user
  /// 
  /// This should be called after user signs up in Supabase
  /// Returns wallet address and ID
  /// 
  /// Note: In production, this should be done via your backend
  /// to keep App Secret secure
  Future<Map<String, dynamic>> createEmbeddedWallet({
    required String userId, // Supabase user ID
    String chain = 'ethereum', // Default to Ethereum
  }) async {
    if (_appId == null || _appSecret == null) {
      throw Exception('PrivyService not initialized. Call initialize() first.');
    }

    try {
      // Create wallet via Privy API
      // Note: This is a simplified version. Actual Privy API may differ
      // You should check Privy docs for exact endpoint structure
      final url = Uri.parse('$_baseUrl/v1/wallets');
      
      final body = {
        'owner': {
          'type': 'user',
          'id': userId,
        },
        'chain': chain,
        'custody': 'embedded-mpc',
      };

      final response = await http.post(
        url,
        headers: _getAuthHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        final walletId = data['id'] as String?;
        final walletAddress = data['address'] as String?;
        
        if (walletId != null && walletAddress != null) {
          // Save to Supabase
          await _saveWalletToSupabase(userId, walletId, walletAddress);
          
          return {
            'wallet_id': walletId,
            'wallet_address': walletAddress,
            'status': 'ready',
          };
        } else {
          throw Exception('Invalid wallet response from Privy');
        }
      } else {
        throw Exception('Failed to create wallet: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error creating Privy wallet: $e');
      rethrow;
    }
  }

  /// Get wallet info for a user
  /// 
  /// Returns wallet address and ID from Supabase
  Future<Map<String, dynamic>?> getWalletInfo(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('profiles')
          .select('privy_wallet_id, privy_wallet_address')
          .eq('id', userId)
          .maybeSingle();

      if (response != null && 
          response['privy_wallet_address'] != null) {
        return {
          'wallet_id': response['privy_wallet_id'] as String?,
          'wallet_address': response['privy_wallet_address'] as String,
        };
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting wallet info: $e');
      return null;
    }
  }

  /// Save wallet info to Supabase profiles table
  Future<void> _saveWalletToSupabase(
    String userId,
    String walletId,
    String walletAddress,
  ) async {
    try {
      await SupabaseService.client.from('profiles').update({
        'privy_wallet_id': walletId,
        'privy_wallet_address': walletAddress,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      debugPrint('✅ Wallet info saved to Supabase');
    } catch (e) {
      debugPrint('❌ Error saving wallet to Supabase: $e');
      rethrow;
    }
  }

  /// Check if user has a wallet
  Future<bool> hasWallet(String userId) async {
    final walletInfo = await getWalletInfo(userId);
    return walletInfo != null && walletInfo['wallet_address'] != null;
  }

  /// Get wallet address for current user
  Future<String?> getCurrentUserWalletAddress() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return null;
    
    final walletInfo = await getWalletInfo(userId);
    return walletInfo?['wallet_address'] as String?;
  }

  /// Save KYC token to Supabase
  /// 
  /// This should be called when Privy KYC is completed
  Future<void> saveKycToken(String userId, String kycToken) async {
    try {
      await SupabaseService.client.from('profiles').update({
        'privy_kyc_token': kycToken,
        'kyc_status': 'completed',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      debugPrint('✅ KYC token saved to Supabase');
    } catch (e) {
      debugPrint('❌ Error saving KYC token: $e');
      rethrow;
    }
  }

  /// Check if user has completed KYC
  Future<bool> hasCompletedKyc(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('profiles')
          .select('kyc_status, privy_kyc_token')
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        final status = response['kyc_status'] as String?;
        final token = response['privy_kyc_token'] as String?;
        return status == 'completed' && token != null && token.isNotEmpty;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error checking KYC status: $e');
      return false;
    }
  }
}
