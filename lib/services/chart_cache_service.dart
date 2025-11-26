import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

class ChartCacheService {
  static const String _tableName = 'chart_cache';
  static const Duration _cacheValidity1H = Duration(minutes: 5);
  static const Duration _cacheValidity1D = Duration(hours: 1);
  static const Duration _cacheValidity1W = Duration(hours: 6);
  static const Duration _cacheValidity1M = Duration(days: 1);
  static const Duration _cacheValidity1Y = Duration(days: 1);
  static const Duration _cacheValidityAll = Duration(days: 1);

  /// Get cache validity duration based on timeframe
  static Duration _getCacheValidity(String timeframe) {
    switch (timeframe.toUpperCase()) {
      case '1H':
        return _cacheValidity1H;
      case '1D':
        return _cacheValidity1D;
      case '1W':
        return _cacheValidity1W;
      case '1M':
        return _cacheValidity1M;
      case '1Y':
        return _cacheValidity1Y;
      case 'ALL':
        return _cacheValidityAll;
      default:
        return _cacheValidity1H;
    }
  }

  /// Get cached chart data if available and fresh
  static Future<List<Map<String, dynamic>>?> getCachedData(
    String symbol,
    String timeframe,
  ) async {
    try {
      final cacheKey = '${symbol}_$timeframe';
      final response = await SupabaseService.client
          .from(_tableName)
          .select()
          .eq('cache_key', cacheKey)
          .maybeSingle();

      if (response == null) return null;

      final cachedAt = DateTime.parse(response['cached_at'] as String);
      final validity = _getCacheValidity(timeframe);
      final now = DateTime.now();

      // Check if cache is still valid
      if (now.difference(cachedAt) > validity) {
        // Cache expired, delete it
        await SupabaseService.client
            .from(_tableName)
            .delete()
            .eq('cache_key', cacheKey);
        return null;
      }

      // Return cached data
      final dataJson = response['data'] as String;
      final List<dynamic> dataList = jsonDecode(dataJson);
      return dataList
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (e) {
      debugPrint('Error getting cached data: $e');
      return null;
    }
  }

  /// Store chart data in cache
  static Future<void> cacheData(
    String symbol,
    String timeframe,
    List<Map<String, dynamic>> data,
  ) async {
    try {
      final cacheKey = '${symbol}_$timeframe';
      final dataJson = jsonEncode(data);

      // Upsert: insert or update if exists
      await SupabaseService.client.from(_tableName).upsert({
        'cache_key': cacheKey,
        'symbol': symbol,
        'timeframe': timeframe,
        'data': dataJson,
        'cached_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error caching data: $e');
      // If table doesn't exist, we'll create it via migration
      // For now, just log the error
    }
  }

  /// Clear old cache entries (older than 7 days)
  static Future<void> clearOldCache() async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      await SupabaseService.client
          .from(_tableName)
          .delete()
          .lt('cached_at', sevenDaysAgo.toIso8601String());
    } catch (e) {
      debugPrint('Error clearing old cache: $e');
    }
  }

  /// Initialize the cache table (run this once)
  static Future<void> initializeTable() async {
    // This SQL should be run in Supabase SQL editor:
    // CREATE TABLE IF NOT EXISTS chart_cache (
    //   id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    //   cache_key TEXT UNIQUE NOT NULL,
    //   symbol TEXT NOT NULL,
    //   timeframe TEXT NOT NULL,
    //   data TEXT NOT NULL,
    //   cached_at TIMESTAMPTZ NOT NULL,
    //   updated_at TIMESTAMPTZ NOT NULL,
    //   created_at TIMESTAMPTZ DEFAULT NOW()
    // );
    // CREATE INDEX IF NOT EXISTS idx_chart_cache_key ON chart_cache(cache_key);
    // CREATE INDEX IF NOT EXISTS idx_chart_cache_symbol ON chart_cache(symbol);
    // CREATE INDEX IF NOT EXISTS idx_chart_cache_cached_at ON chart_cache(cached_at);
    
    debugPrint('Chart cache table initialization SQL should be run in Supabase SQL editor');
  }
}

