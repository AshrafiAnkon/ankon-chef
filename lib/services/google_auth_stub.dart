import 'package:firebase_auth/firebase_auth.dart';
import 'google_auth_interface.dart';

/// Stub implementation for platforms lacking specific support
class GoogleAuthImplementation implements GoogleAuthPlatform {
  @override
  Future<UserCredential?> signIn(FirebaseAuth auth) {
    throw UnimplementedError(
      'Google Sign In not implemented for this platform',
    );
  }

  @override
  Future<void> signOut(FirebaseAuth auth) {
    throw UnimplementedError(
      'Google Sign In not implemented for this platform',
    );
  }
}
