import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/ingredient_service.dart';
import '../models/ingredient_model.dart';
import 'auth_provider.dart';

part 'ingredient_provider.g.dart';

/// Ingredient service provider
@riverpod
IngredientService ingredientService(Ref ref) {
  return IngredientService();
}

/// All ingredients provider
@riverpod
Stream<List<Ingredient>> allIngredients(Ref ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value([]);
  }

  final service = ref.watch(ingredientServiceProvider);
  return service.allIngredients;
}

/// Ingredients by category provider
@riverpod
Stream<List<Ingredient>> ingredientsByCategory(Ref ref, String category) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value([]);
  }

  final service = ref.watch(ingredientServiceProvider);
  return service.getIngredientsByCategory(category);
}

/// Current user ingredients provider
@riverpod
Stream<List<UserIngredient>> currentUserIngredients(Ref ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value([]);
  }

  final service = ref.watch(ingredientServiceProvider);
  return service.getCurrentIngredients(user.uid);
}

/// Current ingredient IDs provider (for filtering)
@riverpod
Future<List<String>> currentIngredientIds(Ref ref) async {
  final ingredientsAsync = ref.watch(currentUserIngredientsProvider);
  
  if (ingredientsAsync.value == null) {
    final initial = await ref.watch(currentUserIngredientsProvider.future);
    return initial.map((i) => i.ingredientId).toList();
  }
  
  return ingredientsAsync.value!.map((i) => i.ingredientId).toList();
}

