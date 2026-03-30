import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_saver_finder/models/ingredient_model.dart';
import 'package:recipe_saver_finder/ui/widgets/ingredient_multi_select.dart';

void main() {
  final testIngredients = [
    const Ingredient(id: '1', name: 'Tomato', category: 'Vegetable'),
    const Ingredient(id: '2', name: 'Potato', category: 'Vegetable'),
    const Ingredient(id: '3', name: 'Chicken', category: 'Meat'),
  ];

  testWidgets('IngredientMultiSelect renders and filters', (
    WidgetTester tester,
  ) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IngredientMultiSelect(
            allIngredients: testIngredients,
            selectedIngredientIds: const [],
            onSelectionChanged: (_) {},
            onAddIngredient: (_) async => null,
          ),
        ),
      ),
    );

    // Verify initial state
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Tomato'), findsNothing); // List not shown yet

    // Enter search text
    await tester.enterText(find.byType(TextField), 'Tom');
    await tester.pump();

    // Verify list is shown and filtered
    expect(find.text('Tomato'), findsOneWidget);
    expect(find.text('Potato'), findsNothing);
    expect(find.text('Chicken'), findsNothing);

    // Enter search text that matches nothing
    await tester.enterText(find.byType(TextField), 'Unicorn');
    await tester.pump();

    // Verify "Add" option appears
    expect(find.text('Add "Unicorn"'), findsOneWidget);
  });
}
