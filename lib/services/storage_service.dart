import 'package:firebase_storage/firebase_storage.dart';

abstract class StorageService {
  FirebaseStorage get instance;
}

class FirebaseStorageService implements StorageService {
  FirebaseStorageService(this._storage);

  final FirebaseStorage _storage;

  @override
  FirebaseStorage get instance => _storage;
}

