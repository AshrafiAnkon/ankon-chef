import 'dart:typed_data';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import '../models/recipe_model.dart';

/// Service for managing recipes
class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all recipes for a user
  Stream<List<Recipe>> getRecipes(String userId) {
    return _firestore
        .collection('recipes')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final recipes = snapshot.docs
              .map((doc) => Recipe.fromFirestore(doc))
              .toList();
          // Sort locally to avoid needing a composite index
          recipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return recipes;
        });
  }

  /// Get recipe by ID
  Future<Recipe?> getRecipeById(String recipeId) async {
    final doc = await _firestore.collection('recipes').doc(recipeId).get();
    return doc.exists ? Recipe.fromFirestore(doc) : null;
  }

  /// Create a new recipe
  Future<String> createRecipe({
    required String userId,
    required String name,
    required List<String> ingredientIds,
    required String instructions,
    required List<String> tags,
    int? prepTime,
    int? cookTime,
    int? calories,
    Map<String, String>? ingredientQuantities,
    String? youtubeUrl,
    Uint8List? imageBytes,
    String? imageUrl,
  }) async {
    String? finalImageUrl = imageUrl;

    // Process image to Base64 if provided
    if (imageBytes != null) {
      finalImageUrl = await _processImage(imageBytes);
    }

    final now = DateTime.now();
    final docRef = _firestore.collection('recipes').doc();

    final recipe = Recipe(
      id: docRef.id,
      userId: userId,
      name: name,
      ingredientIds: ingredientIds,
      instructions: instructions,
      imageUrl: finalImageUrl,
      youtubeUrl: youtubeUrl,
      tags: tags,
      prepTime: prepTime,
      cookTime: cookTime,
      calories: calories,
      ingredientQuantities: ingredientQuantities,
      createdAt: now,
      updatedAt: now,
    );

    await docRef.set(recipe.toFirestore()).timeout(const Duration(seconds: 15));
    return docRef.id;
  }

  /// Update an existing recipe
  Future<void> updateRecipe({
    required String recipeId,
    String? name,
    List<String>? ingredientIds,
    String? instructions,
    List<String>? tags,
    int? prepTime,
    int? cookTime,
    int? calories,
    Map<String, String>? ingredientQuantities,
    String? youtubeUrl,
    Uint8List? imageBytes,
    String? imageUrl,
    bool deleteImage = false,
  }) async {
    final docRef = _firestore.collection('recipes').doc(recipeId);
    final doc = await docRef.get().timeout(const Duration(seconds: 10));

    if (!doc.exists) {
      throw Exception('Recipe not found');
    }

    final recipe = Recipe.fromFirestore(doc);
    String? finalImageUrl = imageUrl ?? recipe.imageUrl;

    // Remove old image if requested
    if (deleteImage) {
      finalImageUrl = null;
    }

    // Process new image if provided
    if (imageBytes != null) {
      finalImageUrl = await _processImage(imageBytes);
    }

    final updates = <String, dynamic>{
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };

    if (name != null) updates['name'] = name;
    if (ingredientIds != null) updates['ingredientIds'] = ingredientIds;
    if (instructions != null) updates['instructions'] = instructions;
    if (tags != null) updates['tags'] = tags;
    if (prepTime != null) updates['prepTime'] = prepTime;
    if (cookTime != null) updates['cookTime'] = cookTime;
    if (calories != null) updates['calories'] = calories;
    if (ingredientQuantities != null) {
      updates['ingredientQuantities'] = ingredientQuantities;
    }
    updates['youtubeUrl'] = youtubeUrl;
    updates['imageUrl'] = finalImageUrl;

    await docRef.update(updates).timeout(const Duration(seconds: 15));
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String recipeId, bool isFavorite) async {
    await _firestore.collection('recipes').doc(recipeId).update({
      'isFavorite': isFavorite,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Delete a recipe
  Future<void> deleteRecipe(String recipeId) async {
    await _firestore
        .collection('recipes')
        .doc(recipeId)
        .delete()
        .timeout(const Duration(seconds: 10));
  }

  /// Search recipes by name
  Stream<List<Recipe>> searchRecipesByName(String userId, String query) {
    return _firestore
        .collection('recipes')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final allRecipes = snapshot.docs
              .map((doc) => Recipe.fromFirestore(doc))
              .toList();

          // Filter by name (Firestore doesn't support case-insensitive search)
          final filtered = allRecipes
              .where(
                (recipe) =>
                    recipe.name.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();

          // Sort by creation date
          filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return filtered;
        });
  }

  /// Filter recipes that can be made with current ingredients
  Stream<List<Recipe>> getRecipesWithCurrentIngredients(
    String userId,
    List<String> currentIngredientIds,
  ) {
    // If the user has no ingredients, they can't make any recipes
    if (currentIngredientIds.isEmpty) return Stream.value([]);

    return _firestore
        .collection('recipes')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final allRecipes = snapshot.docs
          .map((doc) => Recipe.fromFirestore(doc))
          .toList();

      return allRecipes.where((recipe) {
        // Skip recipes with no ingredients
        if (recipe.ingredientIds.isEmpty) return false;

        // Check if all recipe ingredients are in user's current ingredients
        return recipe.ingredientIds.every(
          (ingredientId) => currentIngredientIds.contains(ingredientId),
        );
      }).toList();
    }).handleError((e) {
      debugPrint('Error fetching recipes: $e');
      // If we get a permission denied error or other error, return empty list
      // instead of crashing the UI
      return <Recipe>[];
    });
  }

  /// Get recipes that need 1-2 additional ingredients
  Stream<List<Recipe>> getRecipesWithFewMissingIngredients(
    String userId,
    List<String> currentIngredientIds,
  ) {
    return _firestore
        .collection('recipes')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final allRecipes = snapshot.docs
          .map((doc) => Recipe.fromFirestore(doc))
          .toList();

      return allRecipes.where((recipe) {
        final missingIngredients = recipe.ingredientIds
            .where((id) => !currentIngredientIds.contains(id))
            .toList();

        // Return recipes missing 1 or 2 ingredients
        return missingIngredients.isNotEmpty &&
            missingIngredients.length <= 2 &&
            recipe.ingredientIds.length > missingIngredients.length;
      }).toList();
    }).handleError((e) {
      debugPrint('Error fetching missing ingredient recipes: $e');
      return <Recipe>[];
    });
  }

  /// Get missing ingredients for a recipe
  List<String> getMissingIngredients(
    Recipe recipe,
    List<String> currentIngredientIds,
  ) {
    return recipe.ingredientIds
        .where((id) => !currentIngredientIds.contains(id))
        .toList();
  }

  /// Process image: Minify to WebP and convert to Base64 (max 15KB)
  Future<String> _processImage(Uint8List imageBytes) async {
    try {
      img.Image? decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) return '';

      img.Image image = decodedImage;

      // Resize to a maximum dimension of 400px first to start small
      if (image.width > 400 || image.height > 400) {
        if (image.width > image.height) {
          image = img.copyResize(image, width: 400);
        } else {
          image = img.copyResize(image, height: 400);
        }
      }

      int quality = 80;
      Uint8List compressed;

      // Iterate to get it under 15KB
      do {
        compressed = Uint8List.fromList(img.encodeJpg(image, quality: quality));
        if (compressed.lengthInBytes <= 15360) break; // 15KB

        quality -= 15;
        if (quality < 5) {
          // If still too large, resize further
          image = img.copyResize(
            image,
            width: (image.width * 0.8).toInt(),
            height: (image.height * 0.8).toInt(),
          );
          quality = 70;
        }
      } while (quality > 5 && image.width > 50);

      return 'data:image/jpeg;base64,${base64Encode(compressed)}';
    } catch (e) {
      debugPrint('Error processing image: $e');
      return '';
    }
  }
}
