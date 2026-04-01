import 'package:firebase_auth/firebase_auth.dart';
import 'google_auth_interface.dart';

/// Stub implementation for platforms lacking specific support
class GoogleAuthImplementation implements GoogleAuthPlatform {
  @override
  Future<UserCredential?> signIn(FirebaseAuth auth) async {
    print('Google Sign-In is not supported natively on this platform.');
    print('Falling back to Anonymous sign-in for development purposes.');
    return await auth.signInAnonymously();
  }

  @override
  Future<void> signOut(FirebaseAuth auth) async {
    // Nothing to do for stub
  }
}
