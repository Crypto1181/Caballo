import 'supabase_service.dart';

/// Service to manage virtual balances (ledger system)
/// 
/// This tracks user balances in the app before funds are settled
/// and transferred to Alpaca accounts.
class VirtualBalanceService {
  static VirtualBalanceService? _instance;
  static VirtualBalanceService get instance => _instance ??= VirtualBalanceService._();

  VirtualBalanceService._();

  /// Get current virtual balance for the authenticated user
  Future<Map<String, dynamic>?> getBalance() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await SupabaseService.client
          .from('virtual_balances')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        // No balance record exists, return default
        return {
          'user_id': userId,
          'currency': 'USD',
          'available': 0.0,
          'pending': 0.0,
          'updated_at': DateTime.now().toIso8601String(),
        };
      }

      return {
        'user_id': response['user_id'],
        'currency': response['currency'] ?? 'USD',
        'available': (response['available'] as num?)?.toDouble() ?? 0.0,
        'pending': (response['pending'] as num?)?.toDouble() ?? 0.0,
        'updated_at': response['updated_at'],
      };
    } catch (e) {
      throw Exception('Failed to get balance: $e');
    }
  }

  /// Refresh balance from database
  /// Call this after deposits/withdrawals to get latest balance
  Future<void> refreshBalance() async {
    // This is handled by getBalance() which always fetches fresh data
    // But we can add a cache invalidation mechanism here if needed
  }

  /// Get total balance (available + pending)
  Future<double> getTotalBalance() async {
    final balance = await getBalance();
    if (balance == null) return 0.0;
    return (balance['available'] as double) + (balance['pending'] as double);
  }

  /// Get available balance only
  Future<double> getAvailableBalance() async {
    final balance = await getBalance();
    if (balance == null) return 0.0;
    return balance['available'] as double;
  }

  /// Get pending balance
  Future<double> getPendingBalance() async {
    final balance = await getBalance();
    if (balance == null) return 0.0;
    return balance['pending'] as double;
  }
}

