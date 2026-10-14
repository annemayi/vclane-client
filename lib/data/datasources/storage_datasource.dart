import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageDataSource {
  final FirebaseStorage _storage;

  StorageDataSource(this._storage);

  static const String _profileImagesPath = 'profile_images';

  Future<String> uploadProfileImage(String uid, File file) async {
    final ref = _storage.ref().child('$_profileImagesPath/$uid.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }
}
