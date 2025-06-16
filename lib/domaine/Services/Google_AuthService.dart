import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'UserService.dart';


class GoogleAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: "614447342372-qqu5jklfsui0c08a2lj71l6i26qsnplv.apps.googleusercontent.com",
  );

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print("❌ Google sign-in aborted by user.");
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        await UserService().saveUserToLocalStorage(
          user.displayName ?? 'Unknown',
          user.email ?? 'No Email',
        );
        print("✅ Google user signed in: ${user.displayName}");

      }

      return userCredential;
    } catch (e) {
      print("⚠️ Google Sign-In Error: $e");
      return null;
    }
  }

  /// Check if there's a currently signed-in user
  Future<User?> checkIfUserIsSignedIn() async {
    final User? user = _firebaseAuth.currentUser;
    if (user != null) {
      print("👤 User already signed in: ${user.displayName ?? 'No Name'}");
    } else {
      print("🔍 No user is currently signed in.");
    }
    return user;
  }
}