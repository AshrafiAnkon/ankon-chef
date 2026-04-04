import 'package:firebase_auth/firebase_auth.dart';

/// Abstract interface for Email authentication
abstract class EmailAuthPlatform {
  Future<UserCredential?> signInWithEmail(
    FirebaseAuth auth,
    String email,
    String password,
  );
  Future<UserCredential?> signUpWithEmail(
    FirebaseAuth auth,
    String email,
    String password,
    String displayName,
  );
}
