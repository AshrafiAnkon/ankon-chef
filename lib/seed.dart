import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/ingredient_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // print('Initializing Firebase...');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // print('Seeding ingredients...');
  final ingredientService = IngredientService();

  try {
    await ingredientService.seedIngredients();
    // print('✅ Successfully seeded all ingredients!');
  } catch (e) {
    // print('❌ Error seeding ingredients: $e');
  }

  // print('You can now close this app.');
}
