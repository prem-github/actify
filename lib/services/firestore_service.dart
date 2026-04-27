import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FirestoreService {
  FirebaseFirestore get instance;
}

class FirebaseFirestoreService implements FirestoreService {
  FirebaseFirestoreService(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  FirebaseFirestore get instance => _firestore;
}

