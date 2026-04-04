import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'google_auth_helper.dart';

/// Authentication service for handling user sign in/out
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Use platform-specific Google Auth helper
      // This implementation avoids importing google_sign_in package on Web
      final UserCredential? userCredential = await GoogleAuth.signIn(_auth);

      if (userCredential != null && userCredential.user != null) {
        await createOrUpdateUserProfile(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  /// Create or update user profile in Firestore
  Future<void> createOrUpdateUserProfile(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get().timeout(
      const Duration(seconds: 10),
    );

    if (!docSnapshot.exists) {
      // Create new user profile
      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'Unknown User',
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
      );
      await userDoc
          .set(userModel.toFirestore())
          .timeout(const Duration(seconds: 10));
    } else {
      // Update existing user profile
      await userDoc
          .update({
            'displayName': user.displayName ?? 'Unknown User',
            'photoUrl': user.photoURL,
            'email': user.email ?? '',
          })
          .timeout(const Duration(seconds: 10));
    }
  }

  /// Get user profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Stream of user profile
  Stream<UserModel?> getUserProfileStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleAuth.signOut(_auth);
  }
}
