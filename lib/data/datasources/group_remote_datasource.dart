import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vclane_client/domain/entities/group.dart';
import 'package:vclane_client/data/models/group_model.dart';
import 'package:vclane_client/core/constants/firestore_constants.dart';

class GroupRemoteDataSource {
  final FirebaseFirestore _firestore;

  GroupRemoteDataSource(this._firestore);

  Stream<List<Group>> watchGroups() {
    return _firestore
        .collection(FirestoreConstants.groups)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => GroupModel.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<Group?> watchGroup(String id) {
    return _firestore
        .collection(FirestoreConstants.groups)
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? GroupModel.fromFirestore(doc) : null);
  }
}
