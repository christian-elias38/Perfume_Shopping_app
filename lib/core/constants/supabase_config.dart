
class SupabaseConfig {
  // Replace these credentials with your Supabase Project Settings -> API credentials
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  static bool get isConfigured {
    return supabaseUrl.startsWith('https://') && 
           supabaseAnonKey.length > 20 && 
           !supabaseUrl.contains('YOUR_SUPABASE');
  }
}
