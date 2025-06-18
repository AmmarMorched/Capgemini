import 'package:flutter/foundation.dart';
import '../models/Users.dart';
import '../services/UserService.dart';

class AuthViewModel extends ChangeNotifier {
  final UserService _userService = UserService();

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _userService.login(email, password);
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signup(Users user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final success = await _userService.signup(user);

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> isLoggedIn() async => await UserService.isLoggedIn();

  Future<void> logout() async {
    await _userService.logout();
    notifyListeners();
  }
}
