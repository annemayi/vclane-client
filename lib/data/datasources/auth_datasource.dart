import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:vclane_client/domain/entities/user.dart';
import 'package:vclane_client/data/models/user_model.dart';

class AuthDataSource {
  final fb.FirebaseAuth _auth;

  AuthDataSource(this._auth);

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges().map((fbUser) {
      if (fbUser == null) return null;
      return UserModel.fromFirebase(fbUser);
    });
  }

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  Future<User> signInWithEmailPassword(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return UserModel.fromFirebase(result.user);
  }

  Future<void> signOut() => _auth.signOut();
}
