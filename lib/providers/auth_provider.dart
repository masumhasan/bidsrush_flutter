import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Initialize and check auth status
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isAuth = await _authService.isAuthenticated()
          .timeout(const Duration(seconds: 5), onTimeout: () => false);
      if (isAuth) {
        _user = await _authService.getCurrentUser()
            .timeout(const Duration(seconds: 5), onTimeout: () => null);
        if (_user != null) {
          final token = await _authService.getToken();
          if (token != null) {
            _apiService.setAuthToken(token);
          }
        }
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Auth initialization error: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Sign in
  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.signIn(email: email, password: password);
      if (_user != null) {
        final token = await _authService.getToken();
        if (token != null) {
          _apiService.setAuthToken(token);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = 'Sign in failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      if (_user != null) {
        final token = await _authService.getToken();
        if (token != null) {
          _apiService.setAuthToken(token);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = 'Sign up failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _apiService.clearAuthToken();
      _user = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Sign out error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? email,
    String? fullName,
    String? mobileNumber,
    String? address,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUserData = await _apiService.updateProfile(
        email: email,
        fullName: fullName,
        mobileNumber: mobileNumber,
        address: address,
      );

      // Update local user model
      _user = UserModel.fromJson(updatedUserData);
      
      // Update stored user data
      await _authService.updateStoredUser(_user!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update user after email change
  Future<void> updateUserAfterEmailChange(
    Map<String, dynamic> userData,
    String newToken,
  ) async {
    try {
      // Update user model
      _user = UserModel.fromJson(userData);
      
      // Update stored user data
      await _authService.updateStoredUser(_user!);
      
      // Update token
      await _authService.saveToken(newToken);
      _apiService.setAuthToken(newToken);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user after email change: $e');
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
