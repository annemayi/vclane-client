import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vclane_client/core/constants/firestore_constants.dart';
import 'package:vclane_client/data/models/user_model.dart';
import 'package:vclane_client/domain/entities/user.dart';

class UserFirestoreDataSource {
  final FirebaseFirestore _firestore;

  UserFirestoreDataSource(this._firestore);

  Future<User?> getUserProfile(String uid) async {
    final doc = await _firestore
        .collection(FirestoreConstants.users)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> createUserProfile(User user) async {
    await _firestore
        .collection(FirestoreConstants.users)
        .doc(user.id)
        .set(UserModel.toFirestore(user));
  }

  Future<void> updateUserProfile(
    String uid, {
    String? displayName,
    String? address,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    final updates = <String, dynamic>{};
    if (displayName != null) updates['displayName'] = displayName;
    if (address != null) updates['address'] = address;
    if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    if (updates.isEmpty) return;
    await _firestore
        .collection(FirestoreConstants.users)
        .doc(uid)
        .update(updates);
  }
}
