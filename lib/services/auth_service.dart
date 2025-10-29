import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return cred.user;
  }


  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user;
  }

  Future<void> signOut() async {
    try{
      await _auth.signOut();
    } catch(e) {
      log("Something went wrong");
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      log("Password reset email sent to $email");
      
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        log("No user found for that email.");
      } else if (e.code == 'invalid-email') {
        log("Invalid email address");
      } else {
        log("Error resetting password: ${e.message}");
      }
    } catch (e) {
      log("Something went wrong");
    }
  }
}