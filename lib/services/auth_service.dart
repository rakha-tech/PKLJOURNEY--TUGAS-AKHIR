// lib/services/auth_service.dart
// Wrapper Supabase Auth + profile fetch dari tabel `users`.

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';

class AuthService {
  final _client = Supabase.instance.client;

  /// Login dengan username (otomatis dipetakan ke `@pkljourney.sch.id`) atau email & password.
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final normalized = email.trim().toLowerCase();
    final resolvedEmail = normalized.contains('@')
        ? normalized
        : '$normalized@pkljourney.sch.id';

    final response = await _client.auth.signInWithPassword(
      email: resolvedEmail,
      password: password,
    );
    final authUser = response.user;
    if (authUser == null) {
      throw const AuthException('Login gagal. Periksa email dan password.');
    }
    return _fetchProfile(authUser.id);
  }

  /// Ambil profil user yang sudah login (dipanggil saat app dibuka kembali).
  Future<AppUser?> currentUser() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;
    try {
      return await _fetchProfile(authUser.id);
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<AppUser> _fetchProfile(String userId) async {
    final data = await _client
        .from('users')
        .select('*, roles(role_name)')
        .eq('user_id', userId)
        .single();
    return AppUser.fromMap(data);
  }

  /// Update profil (nama, email, phone) di tabel users.
  Future<AppUser> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
  }) async {
    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (phone != null) updates['phone'] = phone;
    if (updates.isEmpty) return (await currentUser())!;

    final data = await _client
        .from('users')
        .update(updates)
        .eq('user_id', userId)
        .select('*, roles(role_name)')
        .single();
    return AppUser.fromMap(data);
  }
}
