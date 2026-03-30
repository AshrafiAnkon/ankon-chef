import 'package:firebase_auth/firebase_auth.dart';
import 'google_auth_interface.dart';

/// Web implementation using Firebase Auth popup
class GoogleAuthImplementation implements GoogleAuthPlatform {
  @override
  Future<UserCredential?> signIn(FirebaseAuth auth) async {
    // On Web, we use signInWithPopup which doesn't need a separate Google Sign In Client ID
    // configuration in index.html, preventing "ClientID not set" errors.
    final provider = GoogleAuthProvider();
    return await auth.signInWithPopup(provider);
  }

  @override
  Future<void> signOut(FirebaseAuth auth) async {
    // No need to sign out of GoogleSignIn plugin on web
    // Just Firebase signOut (handled by caller)
  }
}
