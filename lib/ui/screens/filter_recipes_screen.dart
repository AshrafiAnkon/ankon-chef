import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/pantry_ingredient_multi_select.dart';
import '../../providers/filter_recipe_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../models/ingredient_model.dart';
import '../../models/recipe_model.dart';
import '../widgets/recipe_image.dart';

class FilterRecipesScreen extends ConsumerStatefulWidget {
  const FilterRecipesScreen({super.key});

  @override
  ConsumerState<FilterRecipesScreen> createState() =>
      _FilterRecipesScreenState();
}

class _FilterRecipesScreenState extends ConsumerState<FilterRecipesScreen> {
  bool _pantryMatch = false;

  bool _ingredientsToggle = true;
  bool _matchAll = true;
  List<String> _selectedIngredientIds = [];

  final TextEditingController _tagSearchController = TextEditingController();
  String _tagSearchQuery = '';
  List<String> _selectedTags = [];

  bool _nutritionToggle = true;
  double _maxPrepTime = 30; // up to 120
  double _maxCookTime = 45; // up to 240
  double _maxCalories = 800; // up to 2000

  bool _showFavorites = false;

  @override
  void initState() {
    super.initState();
    // Intentionally empty post frame
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_tagSearchController.text.isEmpty && _selectedTags.isEmpty && !_pantryMatch) {
      final activeFilters = ref.read(activeFilterOptionsProvider);
      _pantryMatch = activeFilters.pantryIngredientsOnly;
      _ingredientsToggle = activeFilters.filterByChoice;
      _matchAll = activeFilters.matchAll;
      _selectedIngredientIds = List.from(activeFilters.selectedIngredientIds);
      _selectedTags = List.from(activeFilters.tags);
      _nutritionToggle = activeFilters.filterByNutritionTime;
      _maxPrepTime = activeFilters.maxPrepTime?.toDouble() ?? 30.0;
      _maxCookTime = activeFilters.maxCookTime?.toDouble() ?? 45.0;
      _maxCalories = activeFilters.maxCalories?.toDouble() ?? 800.0;
      _showFavorites = activeFilters.showOnlyFavorites;
    }
  }

  @override
  void dispose() {
    _tagSearchController.dispose();
    super.dispose();
  }

  void _updateGlobalFilters() {
    final filterOptions = FilterOptions(
      pantryIngredientsOnly: _pantryMatch,
      filterByChoice: _ingredientsToggle,
      selectedIngredientIds: _ingredientsToggle ? _selectedIngredientIds : [],
      matchAll: _matchAll,
      tags: _selectedTags,
      filterByNutritionTime: _nutritionToggle,
      maxPrepTime: _nutritionToggle ? _maxPrepTime.toInt() : null,
      maxCookTime: _nutritionToggle ? _maxCookTime.toInt() : null,
      maxCalories: _nutritionToggle ? _maxCalories.toInt() : null,
      showOnlyFavorites: _showFavorites,
    );
    ref.read(activeFilterOptionsProvider.notifier).updateOptions(filterOptions);
  }

  void _clearFilters() {
    setState(() {
      _pantryMatch = false;
      _ingredientsToggle = false;
      _matchAll = true;
      _selectedIngredientIds = [];
      _selectedTags = [];
      _tagSearchController.clear();
      _tagSearchQuery = '';
      _nutritionToggle = false;
      _maxPrepTime = 30;
      _maxCookTime = 45;
      _maxCalories = 800;
      _showFavorites = false;
    });
    _updateGlobalFilters();
  }

  @override
  Widget build(BuildContext context) {
    final recipeIngredientsAsync = ref.watch(allRecipeIngredientsProvider);
    final filteredAsync = ref.watch(filteredRecipesProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 80,
          bottom: 32,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              _buildPantryMatchSection(),
              const SizedBox(height: 32),
              _buildIngredientsSection(recipeIngredientsAsync),
              const SizedBox(height: 32),
              _buildFilterByTagsSection(),
              const SizedBox(height: 32),
              _buildNutritionalAndTimeSection(),
              const SizedBox(height: 32),
              _buildFavoritesSection(),
              const SizedBox(height: 48),
              _buildFilteredRecipes(filteredAsync),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AppBar(
            backgroundColor: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
            elevation: 0,
            toolbarHeight: 80,
            titleSpacing: 0,
            automaticallyImplyLeading: false,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.close, color: AppColors.outline),
                      onPressed: () => context.pop(),
                      splashRadius: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Filters',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearFilters,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.tertiary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      'Clear',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPantryMatchSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pantry Match',
                  style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  'Only show recipes using what you have.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          _CustomSwitch(
            value: _pantryMatch,
            onChanged: (v) {
              setState(() => _pantryMatch = v);
              _updateGlobalFilters();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection(AsyncValue<List<Ingredient>> recipeIngredientsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ingredients',
              style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
            ),
            _CustomSwitch(
              value: _ingredientsToggle,
              onChanged: (v) {
                setState(() => _ingredientsToggle = v);
                _updateGlobalFilters();
              },
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _ingredientsToggle
              ? Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Match All / Any
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildSegmentBtn('Match All', _matchAll),
                            _buildSegmentBtn('Match Any', !_matchAll),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Selected Chips
                      recipeIngredientsAsync.when(
                        data: (recipeIngredients) {
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              ..._selectedIngredientIds.map((id) {
                                final ingredient = recipeIngredients.firstWhere(
                                  (ing) => ing.id == id,
                                  orElse: () => Ingredient(
                                    id: id,
                                    name: 'Unknown',
                                    category: '',
                                  ),
                                );
                                return _buildIngredientChip(ingredient.name, id);
                              }),
                              _buildAddMoreButton(recipeIngredients),
                            ],
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (e, s) => Text('Error loading ingredients: $e'),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSegmentBtn(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() => _matchAll = text == 'Match All');
        _updateGlobalFilters();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          text,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientChip(String label, String id) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() => _selectedIngredientIds.remove(id));
              _updateGlobalFilters();
            },
            child: const Icon(
              Icons.close,
              size: 18,
              color: AppColors.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMoreButton(List<Ingredient> pantryIngredients) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: PantryIngredientMultiSelect(
                  pantryIngredients: pantryIngredients,
                  selectedIngredientIds: _selectedIngredientIds,
                  onSelectionChanged: (ids) {
                    setState(() {
                      _selectedIngredientIds = ids;
                    });
                    _updateGlobalFilters();
                  },
                ),
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.add,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Add More',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterByTagsSection() {
    final allTagsAsync = ref.watch(allRecipeTagsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter By Tags',
          style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: _tagSearchController,
            onChanged: (v) => setState(() => _tagSearchQuery = v),
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search tags...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.outline,
              ),
              prefixIcon: const Icon(Icons.search, color: AppColors.outline),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        allTagsAsync.when(
          data: (tags) {
            List<String> displayTags = [];
            if (_tagSearchQuery.isNotEmpty) {
              displayTags = tags
                  .where((t) => t.toLowerCase().contains(_tagSearchQuery.toLowerCase()))
                  .toList();
            } else {
              // Show top 5 tags + any currently selected tags
              final topTags = tags.take(5).toList();
              final Set<String> tagsToShow = {...topTags, ..._selectedTags};
              displayTags = tagsToShow.toList();
            }

            if (displayTags.isEmpty) {
              return Text(
                'No tags found.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
              );
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  for (var i = 0; i < displayTags.length; i++) ...[
                    _buildTagChip(displayTags[i]),
                    if (i < displayTags.length - 1) const SizedBox(width: 12),
                  ]
                ],
              ),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => Text('Error loading tags: $e', style: AppTextStyles.bodySmall),
        ),
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    final isSelected = _selectedTags.contains(tag);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedTags.remove(tag);
          } else {
            _selectedTags.add(tag);
          }
        });
        _updateGlobalFilters();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Text(
          tag,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.onSecondary : AppColors.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionalAndTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nutritional & Time',
              style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
            ),
            _CustomSwitch(
              value: _nutritionToggle,
              onChanged: (v) {
                setState(() => _nutritionToggle = v);
                _updateGlobalFilters();
              },
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _nutritionToggle
              ? Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      _buildSliderRow(
                        title: 'Max Prep Time',
                        valueText: '${_maxPrepTime.toInt()} min',
                        value: _maxPrepTime,
                        min: 0,
                        max: 120,
                        onChanged: (v) {
                          setState(() => _maxPrepTime = v);
                          _updateGlobalFilters();
                        },
                      ),
                      const SizedBox(height: 32),
                      _buildSliderRow(
                        title: 'Max Cook Time',
                        valueText: '${_maxCookTime.toInt()} min',
                        value: _maxCookTime,
                        min: 0,
                        max: 240,
                        onChanged: (v) {
                          setState(() => _maxCookTime = v);
                          _updateGlobalFilters();
                        },
                      ),
                      const SizedBox(height: 32),
                      _buildSliderRow(
                        title: 'Max Calories',
                        valueText: '${_maxCalories.toInt()} kcal',
                        value: _maxCalories,
                        min: 0,
                        max: 2000,
                        onChanged: (v) {
                          setState(() => _maxCalories = v);
                          _updateGlobalFilters();
                        },
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSliderRow({
    required String title,
    required String valueText,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.h4.copyWith(
                color: AppColors.onSurface,
                fontSize: 18,
              ),
            ),
            Text(
              valueText,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.surfaceContainerHighest,
            thumbColor: Colors.white,
            overlayColor: AppColors.primary.withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 12,
              elevation: 4,
            ),
            trackShape: const RoundedRectSliderTrackShape(),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.onTertiary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite,
              color: AppColors.tertiary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Show Only Favorites',
              style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
            ),
          ),
          _CustomSwitch(
            value: _showFavorites,
            onChanged: (v) {
              setState(() => _showFavorites = v);
              _updateGlobalFilters();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredRecipes(AsyncValue<List<Recipe>> filteredAsync) {
    return filteredAsync.when(
      data: (recipes) {
        if (recipes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(
                    Icons.filter_list_off,
                    size: 64,
                    color: AppColors.outline.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recipes found',
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your filters',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${recipes.length} Match${recipes.length == 1 ? '' : 'es'}',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...recipes.map((recipe) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _FilterRecipeCard(recipe: recipe),
                )),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, s) => Center(
        child: Text('Error: $e', style: AppTextStyles.bodyMedium),
      ),
    );
  }
}

class _FilterRecipeCard extends StatelessWidget {
  final Recipe recipe;
  const _FilterRecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/recipes/${recipe.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 108,
              height: 108,
              child: RecipeImage(
                imageUrl: recipe.imageUrl,
                fit: BoxFit.cover,
                iconSize: 32,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (recipe.tags.isNotEmpty)
                      Text(
                        recipe.tags.first.toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          fontSize: 10,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      recipe.name,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.onBackground,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.kitchen_outlined,
                          size: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.ingredientIds.length} Ingredients',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
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

class _CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CustomSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: value ? AppColors.secondary : AppColors.surfaceContainerHighest,
        ),
        padding: const EdgeInsets.all(4),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
