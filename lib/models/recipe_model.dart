import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Recipe model
class Recipe extends Equatable {
  final String id;
  final String userId;
  final String name;
  final List<String> ingredientIds; // list of ingredient IDs
  final String instructions;
  final String? imageUrl;
  final List<String> tags;
  final int? prepTime; // in minutes
  final int? cookTime; // in minutes
  final int? calories;
  final Map<String, String>? ingredientQuantities; // ingredientId -> quantity string (e.g. "4 cups")
  final String? youtubeUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;

  const Recipe({
    required this.id,
    required this.userId,
    required this.name,
    required this.ingredientIds,
    required this.instructions,
    this.imageUrl,
    required this.tags,
    this.prepTime,
    this.cookTime,
    this.calories,
    this.ingredientQuantities,
    this.youtubeUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
  });

  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Recipe(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      ingredientIds: List<String>.from(data['ingredientIds'] as List),
      instructions: data['instructions'] as String,
      imageUrl: data['imageUrl'] as String?,
      tags: List<String>.from(data['tags'] as List),
      prepTime: data['prepTime'] as int?,
      cookTime: data['cookTime'] as int?,
      calories: data['calories'] as int?,
      ingredientQuantities: data['ingredientQuantities'] != null 
          ? Map<String, String>.from(data['ingredientQuantities'] as Map)
          : null,
      youtubeUrl: data['youtubeUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isFavorite: data['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'ingredientIds': ingredientIds,
      'instructions': instructions,
      'imageUrl': imageUrl,
      'tags': tags,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'calories': calories,
      'ingredientQuantities': ingredientQuantities,
      'youtubeUrl': youtubeUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isFavorite': isFavorite,
    };
  }

  Recipe copyWith({
    String? id,
    String? userId,
    String? name,
    List<String>? ingredientIds,
    String? instructions,
    String? imageUrl,
    List<String>? tags,
    int? prepTime,
    int? cookTime,
    int? calories,
    Map<String, String>? ingredientQuantities,
    String? youtubeUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
  }) {
    return Recipe(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      ingredientIds: ingredientIds ?? this.ingredientIds,
      instructions: instructions ?? this.instructions,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      calories: calories ?? this.calories,
      ingredientQuantities: ingredientQuantities ?? this.ingredientQuantities,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    ingredientIds,
    instructions,
    imageUrl,
    tags,
    prepTime,
    cookTime,
    calories,
    ingredientQuantities,
    youtubeUrl,
    createdAt,
    updatedAt,
    isFavorite,
  ];
}
