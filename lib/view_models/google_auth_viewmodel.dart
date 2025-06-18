import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/Google_AuthService.dart';

class GoogleAuthViewModel extends ChangeNotifier {
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  bool _isLoading = false;
  String? _error;
  User? _user;

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = await _googleAuthService.signInWithGoogle();
      if (credential != null) {
        _user = credential.user;
        return true;
      } else {
        _error = "Google sign-in failed or was canceled.";
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
