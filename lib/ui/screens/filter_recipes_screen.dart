import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/pantry_ingredient_multi_select.dart';
import '../../providers/filter_recipe_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../models/recipe_model.dart';
import '../../models/ingredient_model.dart';

class FilterRecipesScreen extends ConsumerStatefulWidget {
  const FilterRecipesScreen({super.key});

  @override
  ConsumerState<FilterRecipesScreen> createState() =>
      _FilterRecipesScreenState();
}

class _FilterRecipesScreenState extends ConsumerState<FilterRecipesScreen> {
  bool _pantryIngredientsOnly = false;
  bool _filterByChoice = false;
  List<String> _selectedIngredientIds = [];
  bool _matchAll = true; // true = all, false = any

  void _clearFilters() {
    setState(() {
      _pantryIngredientsOnly = false;
      _filterByChoice = false;
      _selectedIngredientIds = [];
      _matchAll = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pantryIngredientsAsync = ref.watch(pantryIngredientsProvider);
    final userRecipesAsync = ref.watch(userRecipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Recipes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/home'),
            tooltip: 'Home',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterOptions(pantryIngredientsAsync),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: userRecipesAsync.when(
              data: (allRecipes) {
                // Apply filters in UI
                List<Recipe> recipes = allRecipes;
                if (_pantryIngredientsOnly ||
                    (_filterByChoice && _selectedIngredientIds.isNotEmpty)) {
                  // Get pantry ingredient IDs if needed
                  final pantryItemsAsync = ref.watch(pantryIngredientsProvider);
                  final pantryIngredientIds = pantryItemsAsync.maybeWhen(
                    data: (ingredients) => ingredients.map((i) => i.id).toSet(),
                    orElse: () => <String>{},
                  );
                  if (_pantryIngredientsOnly) {
                    recipes = recipes
                        .where(
                          (recipe) => recipe.ingredientIds.every(
                            (id) => pantryIngredientIds.contains(id),
                          ),
                        )
                        .toList();
                  }
                  if (_filterByChoice && _selectedIngredientIds.isNotEmpty) {
                    recipes = recipes.where((recipe) {
                      if (_matchAll) {
                        return _selectedIngredientIds.every(
                          (id) => recipe.ingredientIds.contains(id),
                        );
                      } else {
                        return _selectedIngredientIds.any(
                          (id) => recipe.ingredientIds.contains(id),
                        );
                      }
                    }).toList();
                  }
                }
                if (recipes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.filter_list_off,
                          size: 80,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No recipes match your filters',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filter options',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _clearFilters,
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Clear Filters'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: [
                    // Filter Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: AppColors.surface,
                      child: Row(
                        children: [
                          const Icon(Icons.filter_list, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${recipes.length} recipe${recipes.length == 1 ? '' : 's'} found',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Recipes Grid
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(userRecipesProvider);
                        },
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: MediaQuery.of(context).size.width > 600
                                ? 3
                                : 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: recipes.length,
                          itemBuilder: (context, index) {
                            return RecipeCard(recipe: recipes[index]);
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions(
    AsyncValue<List<Ingredient>> pantryIngredientsAsync,
  ) {
    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pantry Ingredients Only
          CheckboxListTile(
            title: Text(
              'Pantry Ingredients Only',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Show only recipes where all required ingredients are in my pantry',
              style: AppTextStyles.bodySmall,
            ),
            value: _pantryIngredientsOnly,
            onChanged: (value) {
              setState(() {
                _pantryIngredientsOnly = value ?? false;
              });
            },
            activeColor: AppColors.primary,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          
          const Divider(height: 1),

          // Filter by Choice
          CheckboxListTile(
            title: Text(
              'Filter by Choice',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Select ingredients to filter',
              style: AppTextStyles.bodySmall,
            ),
            value: _filterByChoice,
            onChanged: (value) {
              setState(() {
                _filterByChoice = value ?? false;
                if (!_filterByChoice) {
                  _selectedIngredientIds = [];
                }
              });
            },
            activeColor: AppColors.primary,
            controlAffinity: ListTileControlAffinity.leading,
          ),

          if (_filterByChoice)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: pantryIngredientsAsync.when(
                data: (pantryIngredients) {
                  if (pantryIngredients.isEmpty) {
                    return Text(
                      'No ingredients in your pantry. Add ingredients to your pantry first.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedIngredientIds.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedIngredientIds.map((id) {
                            final ingredient = pantryIngredients.firstWhere(
                              (ing) => ing.id == id,
                              orElse: () => Ingredient(
                                id: id,
                                name: 'Unknown',
                                category: '',
                              ),
                            );

                            return Chip(
                              label: Text(ingredient.name),
                              onDeleted: () {
                                setState(() {
                                  _selectedIngredientIds.remove(id);
                                });
                              },
                              deleteIcon: const Icon(
                                Icons.close,
                                size: 18,
                              ),
                              backgroundColor: AppColors.primaryLight
                                  .withValues(alpha: 0.2),
                              labelStyle: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.primary),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                      ],

                      Row(
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.arrow_drop_down),
                            label: Text(
                              _selectedIngredientIds.isEmpty
                                  ? 'Select ingredients'
                                  : '${_selectedIngredientIds.length} selected',
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => Padding(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(
                                      context,
                                    ).viewInsets.bottom,
                                  ),
                                  child: SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.75,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: PantryIngredientMultiSelect(
                                        pantryIngredients:
                                            pantryIngredients,
                                        selectedIngredientIds:
                                            _selectedIngredientIds,
                                        onSelectionChanged: (ids) {
                                          setState(() {
                                            _selectedIngredientIds = ids;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const Spacer(),
                          Text(
                            'Match: ',
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(width: 8),
                          const Text('All'),
                          Switch(
                            value: _matchAll,
                            onChanged: _selectedIngredientIds.isEmpty
                                ? null
                                : (value) {
                                    setState(() {
                                      _matchAll = value;
                                    });
                                  },
                            activeThumbColor: AppColors.primary,
                          ),
                          const Text('Any'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _matchAll
                            ? 'Show recipes that contain ALL selected ingredients'
                            : 'Show recipes that contain ANY selected ingredient',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text(
                  'Error loading pantry ingredients: $error',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class RecipeCard extends ConsumerWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/recipes/${recipe.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            AspectRatio(
              aspectRatio: 4 / 3,
              child: recipe.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: recipe.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.border,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.border,
                        child: const Icon(Icons.restaurant_menu, size: 48),
                      ),
                    )
                  : Container(
                      color: AppColors.primaryLight.withValues(alpha: 0.2),
                      child: const Icon(
                        Icons.restaurant_menu,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
            ),

            // Recipe Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: AppTextStyles.h4,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${recipe.ingredientIds.length} ingredients',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (recipe.tags.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: recipe.tags.take(2).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tag,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
