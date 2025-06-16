import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> signUpUser(String email, String password, String username, int phone) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save extra user info in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': username,
        'email': email,
        'phone': phone,
      });

      return true;
    } catch (e) {
      print('FirebaseUserService signUpUser error: $e');
      return false;
    }
  }

// You can add more methods like loginUser, logoutUser, etc.
}
