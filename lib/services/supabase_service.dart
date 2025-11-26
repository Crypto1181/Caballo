import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://kjaazaxqxjvoyvzvyauj.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtqYWF6YXhxeGp2b3l2enZ5YXVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM2MDk4MTMsImV4cCI6MjA3OTE4NTgxM30.cqh3DcWu7_zTk0PNxnmdYQWQSal5yE9UCynnqRmxGDI';

  /// Initialize Supabase
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    } catch (e) {
      throw Exception('Failed to initialize Supabase: $e');
    }
  }

  /// Get the Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  /// Get the current user
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Sign out the current user
  static Future<void> signOut() async {
    await client.auth.signOut();
  }
}

