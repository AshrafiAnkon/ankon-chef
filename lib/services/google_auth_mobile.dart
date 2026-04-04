import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'google_auth_interface.dart';

/// Mobile implementation using google_sign_in plugin
class GoogleAuthImplementation implements GoogleAuthPlatform {
  @override
  Future<UserCredential?> signIn(FirebaseAuth auth) async {
    // Fallback for unsupported desktop platforms during development
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      return await auth.signInAnonymously();
    }

    // google_sign_in 7.0+ uses singleton instance and initial authentication
    final googleUser = await GoogleSignIn.instance.authenticate();

    // In 7.0+, ID token is available after authenticate()
    // but Access Token must be obtained via authorizaton
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    // Firebase Auth often requires the accessToken as well.
    // Try to authorize default scopes to get the token.
    final authorization = await googleUser.authorizationClient.authorizeScopes(
      [],
    );
    final accessToken = authorization.accessToken;

    final credential = GoogleAuthProvider.credential(
      accessToken: accessToken,
      idToken: googleAuth.idToken,
    );

    return auth.signInWithCredential(credential);
  }

  @override
  Future<void> signOut(FirebaseAuth auth) async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      // Nothing to sign out from Google plugin on unsupported platforms
      return;
    }
    await GoogleSignIn.instance.signOut();
  }
}
