import 'package:vclane_client/domain/entities/user.dart';
import 'package:vclane_client/domain/repositories/auth_repository.dart';
import 'package:vclane_client/data/datasources/auth_datasource.dart';
import 'package:vclane_client/data/datasources/user_firestore_datasource.dart';
import 'package:vclane_client/data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;
  final UserFirestoreDataSource _userFirestoreDataSource;

  AuthRepositoryImpl(this._dataSource, this._userFirestoreDataSource);

  @override
  Stream<User?> authStateChanges() {
    return _dataSource.authStateChanges().asyncMap((authUser) async {
      if (authUser == null) return null;
      final profile = await _userFirestoreDataSource.getUserProfile(
        authUser.id,
      );
      if (profile == null) return authUser;
      return UserModel.mergeWithProfile(authUser, profile);
    });
  }

  @override
  Future<User> signInWithEmailPassword(String email, String password) async {
    final authUser = await _dataSource.signInWithEmailPassword(email, password);
    final profile = await _userFirestoreDataSource.getUserProfile(authUser.id);
    if (profile == null) return authUser;
    return UserModel.mergeWithProfile(authUser, profile);
  }

  @override
  Future<void> signOut() => _dataSource.signOut();

  @override
  Future<void> updateUserProfile({
    String? displayName,
    String? address,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    final uid = _dataSource.getCurrentUserId();
    if (uid == null) throw Exception('User not authenticated');
    await _userFirestoreDataSource.updateUserProfile(
      uid,
      displayName: displayName,
      address: address,
      phoneNumber: phoneNumber,
      photoUrl: photoUrl,
    );
  }
}
