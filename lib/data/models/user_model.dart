import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:vclane_client/domain/entities/user.dart';

class UserModel {
  static User fromFirebase(fb.User? fbUser) {
    if (fbUser == null) throw Exception('User not authenticated');
    return User(
      id: fbUser.uid,
      email: fbUser.email ?? '',
      displayName: fbUser.displayName ?? 'User',
      photoUrl: fbUser.photoURL,
    );
  }

  static User fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      email: (data['email'] as String?) ?? '',
      displayName: (data['displayName'] as String?) ?? 'User',
      photoUrl: data['photoUrl'] as String?,
      address: (data['address'] as String?) ?? '',
      phoneNumber: (data['phoneNumber'] as String?) ?? '',
      role: (data['role'] as String?) ?? 'operator',
    );
  }

  static User mergeWithProfile(User authUser, User profile) {
    return User(
      id: authUser.id,
      email: authUser.email,
      displayName: profile.displayName.isNotEmpty
          ? profile.displayName
          : authUser.displayName,
      photoUrl: authUser.photoUrl ?? profile.photoUrl,
      address: profile.address,
      phoneNumber: profile.phoneNumber,
      role: profile.role,
    );
  }

  static Map<String, dynamic> toFirestore(User user) {
    return {
      'displayName': user.displayName,
      'email': user.email,
      'photoUrl': user.photoUrl ?? '',
      'address': user.address,
      'phoneNumber': user.phoneNumber,
      'role': user.role,
    };
  }
}
