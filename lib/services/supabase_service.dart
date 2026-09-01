import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/supabase_config.dart';

class SupabaseService {
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static SupabaseClient? get client {
    if (_initialized) {
      try {
        return Supabase.instance.client;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      debugPrint('Supabase credentials not configured. Running in Demo Mock Mode.');
      _initialized = false;
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      _initialized = true;
      debugPrint('Supabase initialized successfully!');
    } catch (e) {
      debugPrint('Failed to initialize Supabase: $e. Falling back to Demo Mock Mode.');
      _initialized = false;
    }
  }
}
