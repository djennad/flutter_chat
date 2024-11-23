import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;

  User? get user => _user;

  bool get isAuthenticated => _user != null;

  Future<void> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      _user = userCredential.user;
      
      // Add user to Firestore
      await _firestore.collection('users').doc(_user!.uid).set({
        'username': email.split('@')[0], // Using part of email as username
        'email': email,
        'lastSeen': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'isOnline': true,
      });

      notifyListeners();
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      _user = userCredential.user;
      
      // Update user's last seen and online status
      if (_user != null) {
        await _firestore.collection('users').doc(_user!.uid).update({
          'lastSeen': FieldValue.serverTimestamp(),
          'isOnline': true,
        });
      }

      notifyListeners();
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (_user != null) {
      await _firestore.collection('users').doc(_user!.uid).update({
        'lastSeen': FieldValue.serverTimestamp(),
        'isOnline': false,
      });
    }
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }
}
