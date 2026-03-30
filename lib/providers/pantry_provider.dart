import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/pantry_service.dart';
import '../models/pantry_item_model.dart';
import 'auth_provider.dart';

part 'pantry_provider.g.dart';

/// Pantry service provider
@riverpod
PantryService pantryService(Ref ref) {
  return PantryService();
}

/// All pantry items for current user
@riverpod
Stream<List<PantryItem>> pantryItems(Ref ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value([]);
  }

  final service = ref.watch(pantryServiceProvider);
  return service.getPantryItems(user.uid);
}

/// Expiring pantry items
@riverpod
Stream<List<PantryItem>> expiringItems(Ref ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value([]);
  }

  final service = ref.watch(pantryServiceProvider);
  return service.getExpiringItems(user.uid);
}

/// Expired pantry items
@riverpod
Stream<List<PantryItem>> expiredItems(Ref ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value([]);
  }

  final service = ref.watch(pantryServiceProvider);
  return service.getExpiredItems(user.uid);
}
