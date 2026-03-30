import 'package:firebase_auth/firebase_auth.dart';

/// Abstract interface for Google Sign In platform implementations
abstract class GoogleAuthPlatform {
  Future<UserCredential?> signIn(FirebaseAuth auth);
  Future<void> signOut(FirebaseAuth auth);
}
