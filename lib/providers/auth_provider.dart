import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

part 'auth_provider.g.dart';

/// Auth service provider
@riverpod
AuthService authService(Ref ref) {
  return AuthService();
}

/// Stream of Firebase auth state changes
@riverpod
Stream<User?> authState(Ref ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
}

/// Current user provider
@riverpod
User? currentUser(Ref ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenData((user) => user).value;
}

/// User profile stream provider
@riverpod
Stream<UserModel?> userProfile(Ref ref, String uid) {
  final authService = ref.watch(authServiceProvider);
  return authService.getUserProfileStream(uid);
}

/// Current user profile provider
@riverpod
Stream<UserModel?> currentUserProfile(Ref ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value(null);
  }
  return ref.watch(userProfileProvider(user.uid).future).asStream();
}
