import 'package:firebase_auth/firebase_auth.dart';
import 'google_auth_interface.dart';
// Conditional imports to select the correct implementation at compile time
import 'google_auth_stub.dart'
    if (dart.library.io) 'google_auth_mobile.dart'
    if (dart.library.html) 'google_auth_web.dart'
    if (dart.library.js_interop) 'google_auth_web.dart';

/// Helper class that exposes platform-specific Google Auth logic.
/// This acts as a facade, ensuring the google_sign_in plugin is not imported on Web.
class GoogleAuth {
  static final GoogleAuthPlatform _impl = GoogleAuthImplementation();

  /// Sign in using the best method for the current platform
  static Future<UserCredential?> signIn(FirebaseAuth auth) =>
      _impl.signIn(auth);

  /// Sign out from platform specific provider (if needed)
  static Future<void> signOut(FirebaseAuth auth) => _impl.signOut(auth);
}
