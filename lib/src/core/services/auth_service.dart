import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Auth state stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Sign Up with Email & Password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      // Create user profile in database
      if (response.user != null) {
        await _createUserProfile(response.user!, fullName);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Create user profile in profiles table
  Future<void> _createUserProfile(User user, String fullName) async {
    try {
      await _supabase.from('profiles').upsert({
        'id': user.id,
        'email': user.email,
        'full_name': fullName,
        'created_at': DateTime.now().toIso8601String(),
        'is_premium': false,
      });
    } catch (e) {
      // Profile might already exist, ignore error
      // print('Profile creation error: $e');
    }
  }

  // Sign In with Email & Password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign In with Google
  Future<bool> signInWithGoogle() async {
    try {
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.movieapp://login-callback/',
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign In with Apple
  Future<bool> signInWithApple() async {
    try {
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.movieapp://login-callback/',
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Forgot Password
  Future<void> forgotPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Update Password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      rethrow;
    }
  }

  // Get User Profile
  Future<UserModel?> getUserProfile() async {
    try {
      if (currentUser == null) return null;

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();

      debugPrint('Fetched profile data: $response');
      return UserModel.fromJson(response);
    } catch (e) {
      debugPrint('Get profile error: $e');
      return null;
    }
  }

  // Update User Profile
  Future<void> updateUserProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      if (currentUser == null) return;

      final updates = <String, dynamic>{
        'id': currentUser!.id,
        'email': currentUser!.email,
      };
      // Always update fullName and phone if provided (even if empty string)
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      // Only update avatarUrl if a new image was uploaded
      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        updates['avatar_url'] = avatarUrl;
      }

      // Use upsert to create the profile if it doesn't exist
      await _supabase
          .from('profiles')
          .upsert(updates, onConflict: 'id');
    } catch (e) {
      debugPrint('Update profile error: $e');
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    try {
      if (currentUser == null) return;

      // Delete profile first
      await _supabase.from('profiles').delete().eq('id', currentUser!.id);

      // Note: To fully delete the user, you need to call this from a server-side function
      await signOut();
    } catch (e) {
      rethrow;
    }
  }
}
