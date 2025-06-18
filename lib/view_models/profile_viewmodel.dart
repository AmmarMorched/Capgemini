import 'package:flutter/material.dart';

import '../services/UserService.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserService _userService = UserService();

  String? _name;
  String? _email;
  String? _phone;
  String? _base64Image;
  bool _isLoading = false;

  String? get name => _name;
  String? get email => _email;
  String? get phone => _phone;
  String? get base64Image => _base64Image;
  bool get isLoading => _isLoading;

  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();

    _name = await _userService.getCurrentUserName();
    _email = await _userService.getCurrentUserEmail();
    _phone = await _userService.getCurrentUserPhone();
    _base64Image = await _userService.getProfileImageAsBase64();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile(String name, String phone) async {
    await _userService.updateUserProfile(name: name, phone: int.parse(phone));
    await loadUserData(); // Refresh after update
  }

  Future<void> updateProfileImage(String base64) async {
    await _userService.saveProfileImageAsBase64(base64);
    _base64Image = base64;
    notifyListeners();
  }

  Future<void>logout() async{
    await _userService.logout();
  }
}
