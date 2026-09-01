import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

class AuthService {
  // Local mock user state for demo mode
  static UserModel? _mockCurrentUser = UserModel(
    id: 'demo-user-123',
    name: 'Eleanor Vance',
    email: 'eleanor@nicheperfumes.com',
    phone: '+1 (555) 234-5678',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  );

  static UserModel? get currentMockUser => _mockCurrentUser;

  User? get currentSupabaseUser {
    return SupabaseService.client?.auth.currentUser;
  }

  bool get isAuthenticated {
    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      return currentSupabaseUser != null;
    }
    return _mockCurrentUser != null;
  }

  Future<UserModel?> getCurrentUserProfile() async {
    final supaUser = currentSupabaseUser;
    if (supaUser != null && SupabaseService.client != null) {
      try {
        final response = await SupabaseService.client!
            .from('users')
            .select()
            .eq('id', supaUser.id)
            .maybeSingle();

        if (response != null) {
          return UserModel.fromJson(response);
        } else {
          return UserModel(
            id: supaUser.id,
            name: supaUser.userMetadata?['name'] ?? supaUser.email?.split('@').first ?? 'Fragrance Lover',
            email: supaUser.email ?? '',
          );
        }
      } catch (_) {
        return UserModel(
          id: supaUser.id,
          name: supaUser.email?.split('@').first ?? 'Fragrance Lover',
          email: supaUser.email ?? '',
        );
      }
    }
    return _mockCurrentUser;
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      final res = await SupabaseService.client!.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'phone': phone},
      );

      final user = res.user;
      if (user == null) throw Exception('Registration failed.');

      final newUser = UserModel(
        id: user.id,
        name: name,
        email: email,
        phone: phone,
      );

      // Insert profile if trigger hasn't completed
      try {
        await SupabaseService.client!.from('users').upsert(newUser.toJson());
      } catch (_) {}

      return newUser;
    } else {
      // Mock signup mode
      _mockCurrentUser = UserModel(
        id: 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        phone: phone,
        createdAt: DateTime.now(),
      );
      return _mockCurrentUser!;
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      final res = await SupabaseService.client!.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = res.user;
      if (user == null) throw Exception('Login failed.');

      final profile = await getCurrentUserProfile();
      return profile ?? UserModel(id: user.id, name: nameFromEmail(email), email: email);
    } else {
      _mockCurrentUser = UserModel(
        id: 'mock-user-123',
        name: nameFromEmail(email),
        email: email,
        phone: '+1 (555) 019-2831',
        createdAt: DateTime.now(),
      );
      return _mockCurrentUser!;
    }
  }

  Future<void> signOut() async {
    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      await SupabaseService.client!.auth.signOut();
    }
    _mockCurrentUser = null;
  }

  String nameFromEmail(String email) {
    if (!email.contains('@')) return 'Fragrance Lover';
    final part = email.split('@').first;
    if (part.isEmpty) return 'Fragrance Lover';
    return part[0].toUpperCase() + part.substring(1);
  }
}
