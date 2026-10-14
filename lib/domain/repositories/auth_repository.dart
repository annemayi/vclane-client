import 'package:vclane_client/domain/entities/user.dart';

abstract class AuthRepository {
  Stream<User?> authStateChanges();
  Future<User> signInWithEmailPassword(String email, String password);
  Future<void> signOut();
  Future<void> updateUserProfile({
    String? displayName,
    String? address,
    String? phoneNumber,
    String? photoUrl,
  });
}
