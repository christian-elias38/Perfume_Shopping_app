import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/supabase_config.dart';

class SupabaseService {
  static bool _initialized = false;
  static bool _isReachable = false;
  static String _statusMessage = 'Initializing...';

  static bool get isInitialized => _initialized;
  static bool get isReachable => _isReachable;
  static bool get isOfflineDemoMode => !_initialized || !_isReachable;
  static String get statusMessage => _statusMessage;

  static SupabaseClient? get client {
    if (_initialized && _isReachable) {
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
      _statusMessage = 'Supabase unconfigured. Operating in Rich Offline Demo Mode.';
      debugPrint('[Supabase] $_statusMessage');
      _initialized = false;
      _isReachable = false;
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      _initialized = true;

      // Test endpoint reachability with a short timeout
      final reachable = await _checkReachability(SupabaseConfig.supabaseUrl);
      if (reachable) {
        _isReachable = true;
        _statusMessage = 'Connected to Live Supabase Backend';
        debugPrint('[Supabase] $_statusMessage');
      } else {
        _isReachable = false;
        _statusMessage = 'Supabase host unreachable. Operating in Rich Offline Demo Mode.';
        debugPrint('[Supabase] $_statusMessage');
      }
    } catch (e) {
      _initialized = false;
      _isReachable = false;
      _statusMessage = 'Supabase connection error: $e. Running in Demo Mode.';
      debugPrint('[Supabase] $_statusMessage');
    }
  }

  static Future<bool> _checkReachability(String urlStr) async {
    try {
      final uri = Uri.parse(urlStr);
      final host = uri.host;
      if (host.isEmpty) return false;

      // DNS / Socket reachability test with 2.5s timeout
      final result = await InternetAddress.lookup(host).timeout(
        const Duration(milliseconds: 2500),
        onTimeout: () => [],
      );

      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

