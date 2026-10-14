import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vclane_client/domain/entities/user.dart';
import 'package:vclane_client/data/datasources/auth_datasource.dart';
import 'package:vclane_client/data/datasources/user_firestore_datasource.dart';
import 'package:vclane_client/data/datasources/storage_datasource.dart';
import 'package:vclane_client/data/repositories/auth_repository_impl.dart';
import 'package:vclane_client/domain/repositories/auth_repository.dart';

sealed class AuthState {
  const AuthState();
}

class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return AuthDataSource(fb.FirebaseAuth.instance);
});

final userFirestoreDataSourceProvider = Provider<UserFirestoreDataSource>((
  ref,
) {
  return UserFirestoreDataSource(FirebaseFirestore.instance);
});

final storageDataSourceProvider = Provider<StorageDataSource>((ref) {
  return StorageDataSource(FirebaseStorage.instance);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authDataSourceProvider),
    ref.watch(userFirestoreDataSourceProvider),
  );
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final authProvider = Provider<AuthState>((ref) {
  final asyncUser = ref.watch(authStateProvider);
  return asyncUser.when(
    data: (user) =>
        user != null ? Authenticated(user) : const Unauthenticated(),
    loading: () => const AuthLoading(),
    error: (e, _) => AuthError(e.toString()),
  );
});
