import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _status == AuthStatus.authenticated;

  AuthProvider() {
    _init();
  }

  void _init() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((event) async {
      if (event.session != null) {
        _status = AuthStatus.authenticated;
        await _loadUserProfile();
      } else {
        _status = AuthStatus.unauthenticated;
        _user = null;
      }
      notifyListeners();
    });

    // Check initial auth state
    if (_authService.isLoggedIn) {
      _status = AuthStatus.authenticated;
      _loadUserProfile();
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> _loadUserProfile() async {
    _user = await _authService.getUserProfile();
    notifyListeners();
  }

  // Sign Up
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      _status = AuthStatus.authenticated;
      await _loadUserProfile();
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'An unexpected error occurred';
      notifyListeners();
      return false;
    }
  }

  // Sign In
  Future<bool> signIn({required String email, required String password}) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      await _authService.signIn(email: email, password: password);

      _status = AuthStatus.authenticated;
      await _loadUserProfile();
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'An unexpected error occurred';
      notifyListeners();
      return false;
    }
  }

  // Sign In with Google
  Future<bool> signInWithGoogle() async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final success = await _authService.signInWithGoogle();
      return success;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Google sign in failed';
      notifyListeners();
      return false;
    }
  }

  // Forgot Password
  Future<bool> forgotPassword(String email) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      await _authService.forgotPassword(email);

      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'An unexpected error occurred';
      notifyListeners();
      return false;
    }
  }

  // Update Profile
  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      await _authService.updateUserProfile(
        fullName: fullName,
        phone: phone,
        avatarUrl: avatarUrl,
      );
      await _loadUserProfile();
      notifyListeners(); // Notify listeners after successful update
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile';
      notifyListeners();
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _status = AuthStatus.unauthenticated;
      _user = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to sign out';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
