import 'package:cloud_firestore/cloud_firestore.dart';
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
}
