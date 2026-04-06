import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/pantry_provider.dart';
import '../../providers/filter_recipe_provider.dart';
import '../widgets/settings_bottom_sheet.dart';
import '../widgets/recipe_image.dart';
import '../../models/recipe_model.dart';

class RecipesScreen extends ConsumerStatefulWidget {
  const RecipesScreen({super.key});

  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All Recipes';
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filters = ['All Recipes', 'Pantry Only', 'Main Course'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeFilters = ref.watch(activeFilterOptionsProvider);
    final recipesAsync = _searchQuery.isEmpty
        ? ref.watch(filteredRecipesProvider(activeFilters))
        : ref.watch(searchRecipesProvider(_searchQuery));

    final pantryItemsAsync = ref.watch(pantryItemsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 100,
          bottom: 120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header, Search Bar, and Filter Chips (Always present to maintain focus)
            _buildHeaderAndSearch(recipesAsync.value, pantryItemsAsync),

            // Results (Only this part shows loading/error)
            recipesAsync.when(
              data: (recipes) {
                final pantryIngredientIds = pantryItemsAsync.maybeWhen(
                  data: (items) => items
                      .map((item) => (item as dynamic).ingredientId as String)
                      .toSet(),
                  orElse: () => <String>{},
                );
                final filteredRecipes = _applyFilters(
                  recipes,
                  pantryIngredientIds,
                );
                if (filteredRecipes.isEmpty) return _buildEmptyState();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Dismissible(
                        key: ValueKey(filteredRecipes.first.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Recipe'),
                              content: Text('Are you sure you want to delete "${filteredRecipes.first.name}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) {
                          ref.read(recipeServiceProvider).deleteRecipe(filteredRecipes.first.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Recipe deleted')),
                                  );
                        },
                        child: _HeroRecipeCard(recipe: filteredRecipes.first),
                      ),
                      const SizedBox(height: 16),
                      ...filteredRecipes
                          .skip(1)
                          .map(
                            (r) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Dismissible(
                                key: ValueKey(r.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 24),
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  return await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Recipe'),
                                      content: Text('Are you sure you want to delete "${r.name}"?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        FilledButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          style: FilledButton.styleFrom(
                                            backgroundColor: AppColors.error,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onDismissed: (direction) {
                                  ref.read(recipeServiceProvider).deleteRecipe(r.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Recipe deleted')),
                                  );
                                },
                                child: _StandardRecipeCard(recipe: r),
                              ),
                            ),
                          ),
                    ],
                  ),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (e, s) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text('Error: $e', style: AppTextStyles.bodyMedium),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AppBar(
            backgroundColor: AppColors.surface.withAlpha(200),
            elevation: 0,
            toolbarHeight: 80,
            titleSpacing: 24,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Ankon-Chef',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.filter_list,
                  color: AppColors.onSurfaceVariant,
                ),
                onPressed: () => context.push('/filter-recipes'),
              ),
              IconButton(
                padding: const EdgeInsets.only(right: 24),
                icon: const Icon(
                  Icons.settings,
                  color: AppColors.onSurfaceVariant,
                ),
                onPressed: () => showSettingsBottomSheet(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Recipe> _applyFilters(
    List<Recipe> recipes,
    Set<String> pantryIngredientIds,
  ) {
    if (_selectedFilter == 'All Recipes') {
      return recipes;
    } else if (_selectedFilter == 'Pantry Only') {
      return recipes
          .where(
            (r) =>
                r.ingredientIds.every((id) => pantryIngredientIds.contains(id)),
          )
          .toList();
    } else if (_selectedFilter == 'Main Course') {
      return recipes
          .where(
            (r) =>
                r.tags.any((tag) => tag.toLowerCase().contains('main course')),
          )
          .toList();
    }
    return recipes;
  }

  Widget _buildHeaderAndSearch(
    List<Recipe>? allRecipes,
    AsyncValue<List<dynamic>> pantryItemsAsync,
  ) {
    final pantryIngredientIds = pantryItemsAsync.maybeWhen(
      data: (items) =>
          items.map((item) => (item as dynamic).ingredientId as String).toSet(),
      orElse: () => <String>{},
    );
    final filteredRecipesCount = allRecipes != null
        ? _applyFilters(allRecipes, pantryIngredientIds).length
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Recipes',
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.onBackground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (filteredRecipesCount != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$filteredRecipesCount Recipes Found',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.onSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search for recipes or ingredients...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.outline,
              ),
              prefixIcon: const Icon(Icons.search, color: AppColors.outline),
              suffixIcon: _searchQuery.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: const Icon(
                        Icons.close,
                        color: AppColors.outline,
                        size: 18,
                      ),
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.filter_list,
                        color: AppColors.outline,
                        size: 20,
                      ),
                      onPressed: () => context.push('/filter-recipes'),
                    ),
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(
                  color: AppColors.surfaceContainerHigh,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Filter chips
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final f = _filters[i];
              final sel = f == _selectedFilter;
              return GestureDetector(
                onTap: () => setState(() => _selectedFilter = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.primary
                        : AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel
                          ? AppColors.primary
                          : AppColors.surfaceContainerHigh,
                    ),
                  ),
                  child: Text(
                    f,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: sel
                          ? AppColors.onPrimary
                          : AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_menu,
              size: 44,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No recipes yet',
            style: AppTextStyles.h3.copyWith(color: AppColors.onBackground),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first recipe',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(80),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => context.push('/recipes/create'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(230),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home,
                    label: 'Home',
                    isActive: false,
                    onTap: () => context.go('/home'),
                  ),
                  _NavItem(
                    icon: Icons.restaurant_menu,
                    label: 'Recipes',
                    isActive: true,
                    onTap: () {},
                  ),
                  _NavItem(
                    icon: Icons.inventory_2,
                    label: 'Pantry',
                    isActive: false,
                    onTap: () => context.go('/pantry'),
                  ),
                  _NavItem(
                    icon: Icons.calendar_month,
                    label: 'Planner',
                    isActive: false,
                    onTap: () => context.go('/meal-plan'),
                  ),
                  _NavItem(
                    icon: Icons.kitchen,
                    label: 'Ingredients',
                    isActive: false,
                    onTap: () => context.go('/ingredients'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroRecipeCard extends StatelessWidget {
  final Recipe recipe;
  const _HeroRecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/recipes/${recipe.id}'),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppColors.surfaceDark,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (recipe.imageUrl != null)
              RecipeImage(
                imageUrl: recipe.imageUrl,
                fit: BoxFit.cover,
                iconSize: 56,
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withAlpha(180)],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (recipe.tags.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        recipe.tags.first.toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.onSecondary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    recipe.name,
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.kitchen,
                        size: 14,
                        color: Colors.white.withAlpha(200),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.ingredientIds.length} Ingredients',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withAlpha(200),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'View Recipe →',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StandardRecipeCard extends StatelessWidget {
  final Recipe recipe;
  const _StandardRecipeCard({required this.recipe});

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
              color: Colors.black.withAlpha(5),
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
                        const Spacer(),
                        Text(
                          'View Recipe →',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
          color: isActive ? AppColors.onPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isActive
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
