import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GrokService {
  static GrokService? _instance;
  static GrokService get instance => _instance ??= GrokService._();
  
  GrokService._();

  static const String _baseUrl = 'https://grok-api.p.rapidapi.com';
  static const String _apiKey = 'cfd42cb60fmsh596e3adef1f26a9p16f12bjsn720e2168c172';
  static const String _model = 'grok3-mini';

  // Rate limits
  static const int _maxRequestsPerMonth = 1000; // Hard limit
  static const int _maxTokensPerMonth = 2000; // Free tier limit
  static const double _costPerRequest = 0.001; // $0.001 per request

  // Keys for SharedPreferences
  static const String _keyRequestCount = 'grok_request_count';
  static const String _keyTokenCount = 'grok_token_count';
  static const String _keyLastResetDate = 'grok_last_reset_date';
  static const String _keyTotalCost = 'grok_total_cost';

  /// Check if we need to reset monthly counters
  Future<void> _checkAndResetMonthlyCounters() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetDateStr = prefs.getString(_keyLastResetDate);
    
    if (lastResetDateStr == null) {
      // First time, set current date
      await prefs.setString(_keyLastResetDate, DateTime.now().toIso8601String());
      await prefs.setInt(_keyRequestCount, 0);
      await prefs.setInt(_keyTokenCount, 0);
      await prefs.setDouble(_keyTotalCost, 0.0);
      return;
    }

    final lastResetDate = DateTime.parse(lastResetDateStr);
    final now = DateTime.now();
    
    // Reset if a new month has started
    if (now.year > lastResetDate.year || now.month > lastResetDate.month) {
      await prefs.setString(_keyLastResetDate, now.toIso8601String());
      await prefs.setInt(_keyRequestCount, 0);
      await prefs.setInt(_keyTokenCount, 0);
      debugPrint('Grok API: Monthly counters reset');
    }
  }

  /// Get current usage statistics
  Future<Map<String, dynamic>> getUsageStats() async {
    await _checkAndResetMonthlyCounters();
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'requestCount': prefs.getInt(_keyRequestCount) ?? 0,
      'tokenCount': prefs.getInt(_keyTokenCount) ?? 0,
      'totalCost': prefs.getDouble(_keyTotalCost) ?? 0.0,
      'maxRequests': _maxRequestsPerMonth,
      'maxTokens': _maxTokensPerMonth,
      'remainingRequests': _maxRequestsPerMonth - (prefs.getInt(_keyRequestCount) ?? 0),
      'remainingTokens': _maxTokensPerMonth - (prefs.getInt(_keyTokenCount) ?? 0),
    };
  }

  /// Check if we can make a request (rate limit check)
  Future<RateLimitStatus> checkRateLimit() async {
    await _checkAndResetMonthlyCounters();
    final prefs = await SharedPreferences.getInstance();
    
    final requestCount = prefs.getInt(_keyRequestCount) ?? 0;
    final tokenCount = prefs.getInt(_keyTokenCount) ?? 0;
    
    // Check hard request limit
    if (requestCount >= _maxRequestsPerMonth) {
      return RateLimitStatus(
        canProceed: false,
        reason: 'Monthly request limit reached ($_maxRequestsPerMonth requests)',
        remainingRequests: 0,
        remainingTokens: _maxTokensPerMonth - tokenCount,
      );
    }
    
    // Check token limit
    if (tokenCount >= _maxTokensPerMonth) {
      return RateLimitStatus(
        canProceed: false,
        reason: 'Monthly token limit reached ($_maxTokensPerMonth tokens)',
        remainingRequests: _maxRequestsPerMonth - requestCount,
        remainingTokens: 0,
      );
    }
    
    // Check if approaching limits (warnings)
    final requestWarning = requestCount >= (_maxRequestsPerMonth * 0.9);
    final tokenWarning = tokenCount >= (_maxTokensPerMonth * 0.9);
    
    return RateLimitStatus(
      canProceed: true,
      reason: requestWarning || tokenWarning 
          ? 'Approaching monthly limits' 
          : 'OK',
      remainingRequests: _maxRequestsPerMonth - requestCount,
      remainingTokens: _maxTokensPerMonth - tokenCount,
      isWarning: requestWarning || tokenWarning,
    );
  }

  /// Update usage counters after a request
  Future<void> _updateUsageCounters(int tokensUsed) async {
    await _checkAndResetMonthlyCounters();
    final prefs = await SharedPreferences.getInstance();
    
    final currentRequests = prefs.getInt(_keyRequestCount) ?? 0;
    final currentTokens = prefs.getInt(_keyTokenCount) ?? 0;
    final currentCost = prefs.getDouble(_keyTotalCost) ?? 0.0;
    
    await prefs.setInt(_keyRequestCount, currentRequests + 1);
    await prefs.setInt(_keyTokenCount, currentTokens + tokensUsed);
    await prefs.setDouble(_keyTotalCost, currentCost + _costPerRequest);
    
    debugPrint('Grok API: Request #${currentRequests + 1}, Tokens: $tokensUsed, Total: ${currentTokens + tokensUsed}');
  }

  /// Send a chat message and get response
  Future<String> sendMessage(List<Map<String, String>> messages) async {
    // Check rate limits first
    final rateLimitStatus = await checkRateLimit();
    if (!rateLimitStatus.canProceed) {
      return "⚠️ API Limit Reached: ${rateLimitStatus.reason}. Please try again next month.";
    }

    try {
      // Prepare request body
      final requestBody = {
        'messages': messages,
      };

      // Make API request
      final response = await http.post(
        Uri.parse('$_baseUrl/$_model'),
        headers: {
          'Content-Type': 'application/json',
          'x-rapidapi-host': 'grok-api.p.rapidapi.com',
          'x-rapidapi-key': _apiKey,
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Parse response based on Grok JSON structure
        final choices = jsonResponse['choices'] as List<dynamic>;
        if (choices.isNotEmpty) {
          final message = choices[0]['message'] as Map<String, dynamic>;
          final content = message['content'] as String?;
          
          // Get token usage for rate limiting
          final usage = jsonResponse['usage'] as Map<String, dynamic>?;
          final totalTokens = usage?['total_tokens'] as int? ?? 0;
          
          // Update usage counters
          await _updateUsageCounters(totalTokens);
          
          if (content != null && content.isNotEmpty) {
            return content;
          }
        }
        
        return "Sorry, I couldn't generate a response.";
      } else if (response.statusCode == 429) {
        return "⚠️ Rate limit exceeded. Please wait a moment before trying again.";
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return "⚠️ API authentication failed. Please check your API key.";
      } else {
        final errorBody = response.body;
        debugPrint('Grok API Error (${response.statusCode}): $errorBody');
        return "⚠️ Error: ${response.statusCode}. Please try again later.";
      }
    } catch (e) {
      debugPrint('Grok API Exception: $e');
      return "⚠️ Connection error: ${e.toString()}. Please check your internet connection.";
    }
  }

  /// Reset usage counters (for testing/admin purposes)
  Future<void> resetUsageCounters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastResetDate, DateTime.now().toIso8601String());
    await prefs.setInt(_keyRequestCount, 0);
    await prefs.setInt(_keyTokenCount, 0);
    await prefs.setDouble(_keyTotalCost, 0.0);
    debugPrint('Grok API: Usage counters reset');
  }
}

class RateLimitStatus {
  final bool canProceed;
  final String reason;
  final int remainingRequests;
  final int remainingTokens;
  final bool isWarning;

  RateLimitStatus({
    required this.canProceed,
    required this.reason,
    required this.remainingRequests,
    required this.remainingTokens,
    this.isWarning = false,
  });
}

