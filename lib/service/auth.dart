import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> sendPasswordResetEmail({required String email}) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
    // İstersen dil:
    FirebaseAuth.instance.setLanguageCode('tr');
  }

  Stream<User?> authState() => _auth.authStateChanges();

  Future<UserCredential> signUpWithName({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Update FirebaseAuth display name
    await cred.user!.updateDisplayName(name.trim());

    // Store basic profile in Firestore
    final uid = cred.user!.uid;
    await _db.collection('users').doc(uid).set({
      'displayName': name.trim(),
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Refresh local user (some platforms cache displayName until reload)
    await cred.user!.reload();

    return cred;
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() => _auth.signOut();

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final provider =
          GoogleAuthProvider()
            ..setCustomParameters({'prompt': 'select_account'});
      return _auth.signInWithPopup(provider);
    }
    final account = await GoogleSignIn.instance.authenticate();
    final googleAuth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }
}
