import 'package:firebase_auth/firebase_auth.dart';
import 'google_auth_interface.dart';

/// Stub implementation for platforms lacking specific support
class GoogleAuthImplementation implements GoogleAuthPlatform {
  @override
  Future<UserCredential?> signIn(FirebaseAuth auth) async {
    return await auth.signInAnonymously();
  }

  @override
  Future<void> signOut(FirebaseAuth auth) async {
    // Nothing to do for stub
  }
}
