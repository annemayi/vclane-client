import 'package:vclane_client/domain/entities/user.dart';
import 'package:vclane_client/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<User> execute(String email, String password) {
    return repository.signInWithEmailPassword(email, password);
  }
}
