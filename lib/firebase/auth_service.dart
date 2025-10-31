import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(); // ✅ old API uses this

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 🔹 Email Login
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint("Login error: ${e.message}");
      rethrow;
    }
  }

  // 🔹 Email Registration
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'username': username,
          'createdAt': FieldValue.serverTimestamp(),
          'profileImage': '',
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint("Register error: ${e.message}");
      rethrow;
    }
  }

  // 🔹 Google Sign-In (✅ correct for google_sign_in v6.2.1)
  Future<User?> signInWithGoogle() async {
    try {
      // Start the Google sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      // Obtain the auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      // Save user info to Firestore if new
      if (user != null) {
        final userDoc = _firestore.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          await userDoc.set({
            'uid': user.uid,
            'email': user.email,
            'username': user.displayName ?? 'User',
            'profileImage': user.photoURL ?? '',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return user;
    } catch (e) {
      debugPrint("Google sign-in error: $e");
      rethrow;
    }
  }

  // 🔹 Logout
  Future<void> signOut() async {
    await _googleSignIn.signOut(); // ✅ old API logout
    await _auth.signOut();
  }
}
