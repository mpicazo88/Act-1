import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // add the details
    await addUserDetails(email, password);
  }

  Future<void> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);

        await _firebaseAuth.signInWithCredential(credential);

        // User logged in successfully
        // Add or update user details in Firestore
        final User? user = _firebaseAuth.currentUser;
        if (user != null) {
          await addUserDetails(user.email ?? '', '');
        }

        print('User logged in with Facebook');
      }
    } catch (e) {
      // Handle Facebook login errors here
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);

      // User logged in successfully
      // Add or update user details in Firestore
      final User? user = _firebaseAuth.currentUser;
      if (user != null) {
        await addUserDetails(user.email ?? '', '');
      }

      print('User logged in with Google');
    } catch (e) {
      // Handle Google login errors here
    }
  }

  Future<void> addUserDetails(String email, String password) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid) // Assuming the user is already signed in
        .set({
      'email': email,
      'password': password,
    });
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
