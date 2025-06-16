// data/repositories/user_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domaine/entities/User.dart';
import '../../domaine/repositories/userRepo.dart';
import '../service/firebaseService.dart';


class UserRepositoryImpl implements UserRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseUserService _firebaseUserService = FirebaseUserService();

  @override
  Future<bool> signup(Users user) async {
    try {
      UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: user.usrEmail,
        password: user.usrPassword,
      );
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': user.usrName,
        'email': user.usrEmail,
        'phone': user.phone,
        'createdAt': FieldValue.serverTimestamp(),
        'profileImageUrl': '',
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', user.usrName);
      await prefs.setString('userEmail', user.usrEmail);
      await prefs.setBool('isLoggedIn', true);
      return true;
    } catch (e) {
      print('Signup Error: $e');
      return false;
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Future<Map<String, String?>> getUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString('username'),
      'email': prefs.getString('userEmail'),
    };
  }

  @override
  Future<String?> getCurrentUserEmail() async {
    return _firebaseAuth.currentUser?.email ?? 'No Email';
  }


  @override
  Future<String?> getCurrentUserName() async {
    User? user = _firebaseAuth.currentUser;
    if (user == null) return null;
    try {
      final snapshot = await _firestore.collection('users').doc(user.uid).get();
      return (snapshot.data()?['name'] as String?) ?? 'Guest';
    } catch (_) {
      return 'Guest';
    }
  }

  @override
  Future<String?> getCurrentUserPhone() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    return snapshot.data()?['phone']?.toString();
  }

  @override
  Future<void> updateUserProfile({required String name, required int phone}) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'name': name,
        'phone': phone,
      });
    }
  }

  @override
  Future<void> saveProfileImageAsBase64(String base64Image) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'profileImageBase64': base64Image,
      });
    }
  }

  @override
  Future<void> saveProfileImageURL(String imageUrl) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'profileImageUrl': imageUrl,
      });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('userEmail', email);
    await prefs.setBool('isLoggedIn', true);
    print("Session saved for $username");
  }

  Future<bool> checkIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<bool> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

      // Fetch and cache user data
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        final snapshot = await _firestore.collection('users').doc(user.uid).get();
        final data = snapshot.data();
        if (data != null) {
          await saveUserToLocalStorage(data['name'], data['email']);
        }
      }

      return true;
    } catch (e) {
      print('Login error: $e');
      rethrow; // Rethrow so UI layer can show specific error messages
    }
  }

  @override
  Future<String?> getProfileImageAsBase64() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    return snapshot.data()?['profileImageBase64'];
  }

  @override
  Future<Users?> getCurrentUser() async  {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    // Get additional user data from Firestore
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (!snapshot.exists || snapshot.data() == null) return null;

    final data = snapshot.data()!;
    return Users(
      usrId: null, // Firestore doesn't have this, set to null or handle it differently
      usrName: data['name'] ?? 'Guest',
      usrPassword: '', // Never store password in Firestore
      usrEmail: data['email'] ?? firebaseUser.email ?? '',
      phone: data['phone'] ?? 0,
      profileImageUrl: data['profileImageUrl'],
    );
  }




}
