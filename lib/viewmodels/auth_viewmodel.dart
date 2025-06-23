import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_profile_model.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthState _state = AuthState.initial;
  String? _errorMessage;
  User? _currentUser;
  UserProfileModel? _userProfile;

  // Getters
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  UserProfileModel? get userProfile => _userProfile;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;

  AuthViewModel() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _authService.authStateChanges.listen((User? user) {
      _currentUser = user;
      if (user != null) {
        _userProfile = _authService.firebaseUserToProfile(user);
        _setState(AuthState.authenticated);
      } else {
        _userProfile = null;
        _setState(AuthState.unauthenticated);
      }
    });
  }

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _setState(AuthState.error);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Sign up with email and password
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _setState(AuthState.loading);
      clearError();

      final credential = await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );

      if (credential?.user != null) {
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setState(AuthState.loading);
      clearError();

      final credential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (credential?.user != null) {
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setState(AuthState.loading);
      clearError();

      final credential = await _authService.signInWithGoogle();

      if (credential?.user != null) {
        return true;
      } else {
        _setState(AuthState.unauthenticated);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setState(AuthState.loading);
      clearError();

      await _authService.resetPassword(email);
      _setState(AuthState.unauthenticated);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setState(AuthState.loading);
      await _authService.signOut();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    try {
      _setState(AuthState.loading);
      clearError();

      await _authService.deleteAccount();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Update user profile
  void updateUserProfile(UserProfileModel profile) {
    _userProfile = profile.copyWith(
      email: _currentUser?.email,
      firebaseUid: _currentUser?.uid,
    );
    notifyListeners();
  }
}
