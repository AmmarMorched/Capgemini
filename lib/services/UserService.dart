import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/Users.dart';



class UserService {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;


  // Sign up a new user and store their info in Firestore and local session
  Future<bool> signup(Users user) async {
    try {
      // Create user on Firebase
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(
        email: user.usrEmail!,
        password: user.usrPassword!,
      );

      // Save additional user info in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': user.usrName,
        'email': user.usrEmail,
        'phone': user.phone,
        'createdAt': FieldValue.serverTimestamp(),
        'profileImageUrl': '',
      }).then((_) {
        print("User information successfully added to Firestore");
      }).catchError((error) {
        print("Error saving user information to Firestore: $error");
      });
      await saveUserToLocalStorage(user.usrName, user.usrEmail);

      return true;
    } catch (e) {
      print("Signup Error: $e");
      return false;
    }
  }

  // Save session locally (excluding password for security)
  Future<void> saveUserToLocalStorage(String username, String email) async {
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

  // Get current user from Firebase
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // Get user session data from SharedPreferences
  static Future<Map<String, String?>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString('username'),
      'email': prefs.getString('userEmail'),
    };
  }

  // Log out: Firebase + local session
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears all local session keys
    print("User logged out.");
  }

  // Static helper to check login status
  static Future<bool> isLoggedIn() async {
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


  // Get current Firebase user’s email
  Future<String?> getCurrentUserEmail() async {
    return _firebaseAuth.currentUser?.email ?? 'No Email';
  }

  Future<String?> getCurrentUserName() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      if (user.providerData.any((provider) =>
      provider.providerId == 'google.com')) {
        return user.displayName?? 'GUEST';
      } else {
        try {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          if (userDoc.exists && userDoc.data() is Map<String, dynamic>) {
            final userData = userDoc.data() as Map<String, dynamic>;
            return userData['name'] ?? 'GUEST'; // This will return the username stored in Firestore
          } else {
            return 'Guest'; // In case no username is found in Firestore
          }
        } catch (e) {
          print("Error fetching username: $e");
          return 'Guest'; // Default if there's an error
        }
      }
    }
  }

  Future<String?> getCurrentUserPhone() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data() is Map<String, dynamic>) {
          final userData = userDoc.data() as Map<String, dynamic>;
          return userData['phone']?.toString() ?? 'N/A';
        }
      } catch (e) {
        print("Error fetching phone number: $e");
      }
    }
    return null;
  }

  Future<void> updateUserProfile({required String name, required int phone}) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'name': name,
        'phone': phone,
      });
      print("✅ User profile updated");
    }
  }
  // Save Base64 string to Firestore
  Future<void> saveProfileImageAsBase64(String base64Image) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'profileImageBase64': base64Image,
    });
    print("✅ Profile image saved as Base64");
  }

// Get Base64 from Firestore
  Future<String?> getProfileImageAsBase64() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    final snapshot = await _firestore.collection('users').doc(user.uid).get();

    return snapshot.data()?['profileImageBase64'] as String?;
  }

// Future<Uint8List?> getProfileImageFromFirestore() async {
//   final user = _firebaseAuth.currentUser;
//   if (user == null) return null;
//
//   try {
//     final snapshot = await _firestore.collection('users').doc(user.uid).get();
//
//     var data = snapshot.data();
//     if (data != null && data.containsKey('profileImage')) {
//       var imageData = data['profileImage'];
//       // if (imageData is Uint8List) {
//       //   print("✅ Profile image loaded from Firestore");
//       //   return imageData;
//       // }
//     }
//
//     print("❌ No image found in Firestore");
//     return null;
//   } catch (e) {
//     print("❌ Error fetching profile image: $e");
//     return null;
//   }
// }

// Helper to fetch image directly
// Future<Unit8List> getProfileImage() async {
//   return await getProfileImageFromFirestore();
// }

}