import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<fb.User?> get authStateChanges => _auth.authStateChanges();
  fb.User? get currentUser => _auth.currentUser;

  Future<fb.UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<fb.UserCredential> signUp(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<void> signOut() => _auth.signOut();

  Future<void> createUserDoc(String uid, Map<String, dynamic> data) =>
      _db.collection('users').doc(uid).set({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });

  Stream<DocumentSnapshot> userDocStream(String uid) =>
      _db.collection('users').doc(uid).snapshots();
}
