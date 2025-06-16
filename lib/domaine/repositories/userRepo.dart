import '../entities/User.dart';

abstract class UserRepository {
  Future<bool> signup(Users user);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<Map<String, String?>> getUserFromStorage();
  Future<String?> getCurrentUserName();
  Future<String?> getCurrentUserPhone();
  Future<String?> getCurrentUserEmail();
  Future<void> saveUserToLocalStorage(String username, String email);
  Future<bool> checkIfLoggedIn();
  Future<Users?> getCurrentUser();
  Future<bool> login(String email, String password);
  Future<void> updateUserProfile({required String name, required int phone});
  Future<void> saveProfileImageAsBase64(String base64Image);
  Future<String?> getProfileImageAsBase64();
}