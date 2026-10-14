import 'failures.dart';

Failure handleError(Object error) {
  if (error is Failure) return error;
  if (error.toString().contains('SocketException')) {
    return const NetworkFailure('No internet connection');
  }
  if (error.toString().contains('FirebaseAuthException')) {
    return AuthFailure(error.toString());
  }
  return UnexpectedFailure('An unexpected error occurred');
}

String mapFailureToMessage(Failure failure) {
  return switch (failure) {
    ServerFailure(message: final m) => m,
    AuthFailure(message: final m) => m,
    NetworkFailure(message: final m) => m,
    UnexpectedFailure(message: final m) => m,
  };
}
