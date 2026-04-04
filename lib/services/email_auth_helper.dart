import 'package:firebase_auth/firebase_auth.dart';
import 'email_auth_interface.dart';
import 'email_auth_implementation.dart';

/// Helper class that exposes email auth logic.
/// This acts as a facade for consistent API across the application.
class EmailAuth {
  static final EmailAuthPlatform _impl = EmailAuthImplementation();

  /// Sign in with email and password
  static Future<UserCredential?> signInWithEmail(
    FirebaseAuth auth,
    String email,
    String password,
  ) => _impl.signInWithEmail(auth, email, password);

  /// Sign up with email, password and display name
  static Future<UserCredential?> signUpWithEmail(
    FirebaseAuth auth,
    String email,
    String password,
    String displayName,
  ) => _impl.signUpWithEmail(auth, email, password, displayName);

  /// Get friendly error message from Firebase auth error code
  static String getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'Email is already registered. Please sign in instead.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'User account has been disabled.';
      case 'user-not-found':
        return 'Email not found. Please sign up first.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'operation-not-allowed':
        return 'Email sign-in is currently disabled.';
      default:
        return 'Authentication error: $code';
    }
  }
}
