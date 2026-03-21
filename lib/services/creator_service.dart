import 'package:cloud_firestore/cloud_firestore.dart';

class CreatorService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference get _creators => _db.collection('creators');

  Stream<QuerySnapshot> creatorsStream() => _creators.snapshots();

  Future<DocumentReference> addCreator(Map<String, dynamic> data) =>
      _creators.add({...data, 'createdAt': FieldValue.serverTimestamp()});

  Future<void> updateCreator(String id, Map<String, dynamic> data) =>
      _creators.doc(id).update({...data, 'updatedAt': FieldValue.serverTimestamp()});

  Future<void> updateStatus(String id, Map<String, dynamic> statusFields) =>
      _creators.doc(id).update({
        ...statusFields,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> togglePublic(String id, bool isPublic) =>
      _creators.doc(id).update({
        'isPublic': isPublic,
        'updatedAt': FieldValue.serverTimestamp(),
      });
}
