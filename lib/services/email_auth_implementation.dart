import 'package:firebase_auth/firebase_auth.dart';
import 'email_auth_interface.dart';

/// Default implementation for email authentication
class EmailAuthImplementation implements EmailAuthPlatform {
  @override
  Future<UserCredential?> signInWithEmail(
    FirebaseAuth auth,
    String email,
    String password,
  ) async {
    try {
      return await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserCredential?> signUpWithEmail(
    FirebaseAuth auth,
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(displayName);
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }
}
