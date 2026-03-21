import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/mock_data.dart';

class SeedService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> seedCreators() async {
    final batch = _db.batch();
    for (final creator in mockCreators) {
      final docRef = _db.collection('creators').doc();
      batch.set(docRef, {
        ...creator.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> seedAdminUser(String uid) async {
    await _db.collection('users').doc(uid).set({
      'name': 'Tobi Fluck',
      'email': 'tobi@kelele.com',
      'role': 'admin',
      'initials': 'TF',
      'bookmarks': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Creates the admin account in Firebase Auth + Firestore, or upgrades
  /// an existing account to admin. Returns true if successful.
  Future<bool> ensureAdminAccount() async {
    try {
      // Try to create the auth account
      UserCredential cred;
      try {
        cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: 'tobi@kelele.com',
          password: 'admin123',
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // Account exists — sign in to get UID, then upgrade role
          cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: 'tobi@kelele.com',
            password: 'admin123',
          );
        } else {
          rethrow;
        }
      }
      await seedAdminUser(cred.user!.uid);
      return true;
    } catch (_) {
      return false;
    }
  }
}
