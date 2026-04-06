import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import '../widgets/settings_bottom_sheet.dart';
import 'meal_plan_screen.dart';
import '../widgets/recipe_image.dart';

import '../../models/user_model.dart';
import '../../providers/meal_plan_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: AppColors.surface.withAlpha(200),
              elevation: 0,
              toolbarHeight: 80,
              titleSpacing: 24,
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
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('User not found.'));
          return _HomeContent(user: user);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      bottomNavigationBar: Container(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavBarItem(
                      icon: Icons.home,
                      label: 'Home',
                      isActive: true,
                      onTap: () {},
                    ),
                    _NavBarItem(
                      icon: Icons.restaurant_menu,
                      label: 'Recipes',
                      isActive: false,
                      onTap: () => context.go('/recipes'),
                    ),
                    _NavBarItem(
                      icon: Icons.inventory_2,
                      label: 'Pantry',
                      isActive: false,
                      onTap: () => context.go('/pantry'),
                    ),
                    _NavBarItem(
                      icon: Icons.calendar_month,
                      label: 'Planner',
                      isActive: false,
                      onTap: () => context.go('/meal-plan'),
                    ),
                    _NavBarItem(
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
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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

class _HomeContent extends ConsumerStatefulWidget {
  final UserModel user;

  const _HomeContent({required this.user});

  @override
  ConsumerState<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<_HomeContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // In Flutter, constraints might force bento items to collapse if not handled responsive
    int crossAxisCount = MediaQuery.of(context).size.width > 600 ? 5 : 2;

    final isSearching = _searchQuery.isNotEmpty;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 100,
        left: 24,
        right: 24,
        bottom: 120, // space for nav bar
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          RichText(
            text: TextSpan(
              style: AppTextStyles.display2.copyWith(
                color: AppColors.onBackground,
                height: 1.2,
              ),
              children: [
                TextSpan(text: 'Hi, ${widget.user.displayName}!\n'),
                const TextSpan(
                  text: "What's for dinner?",
                  style: TextStyle(color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Chips
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Cooking Streak: ${widget.user.cookingStreak} Days',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Search
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search your saved recipes or browse...',
              prefixIcon: const Icon(Icons.search, color: AppColors.outline),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.outline),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: const BorderSide(
                  color: AppColors.surfaceContainerHigh,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
            ),
          ),

          const SizedBox(height: 32),

          // Bento Grid (only show when not searching)
          if (!isSearching) ...[
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildBentoItem(
                    context,
                    'All Recipes',
                    Icons.restaurant_menu,
                    AppColors.surfaceContainerLowest,
                    AppColors.primary,
                    AppColors.onPrimary,
                    () => context.push('/recipes'),
                  );
                }
                if (index == 1) {
                  return _buildBentoItem(
                    context,
                    'Add New',
                    Icons.add_circle,
                    AppColors.primaryContainer,
                    AppColors.onPrimaryContainer,
                    AppColors.onPrimaryContainer,
                    () => context.push('/recipes/create'),
                  );
                }
                if (index == 2) {
                  return _buildBentoItem(
                    context,
                    'Manage Pantry',
                    Icons.inventory_2,
                    AppColors.surfaceContainerLowest,
                    AppColors.secondary,
                    AppColors.onSecondary,
                    () => context.push('/pantry'),
                  );
                }
                if (index == 3) {
                  return _buildBentoItem(
                    context,
                    'Meal Planner',
                    Icons.calendar_month,
                    AppColors.surfaceContainerLowest,
                    AppColors.tertiary,
                    AppColors.onTertiary,
                    () => context.push('/meal-plan'),
                  );
                }
                return _buildBentoItem(
                  context,
                  'Browse Ingredients',
                  Icons.kitchen,
                  AppColors.surfaceContainerLowest,
                  AppColors.primaryDim,
                  AppColors.onPrimary,
                  () => context.push('/ingredients'),
                );
              },
            ),
            const SizedBox(height: 48),
          ],

          // Suggestions/Search header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSearching ? 'Search Results' : 'Today\'s Meal Plan',
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSearching
                          ? 'Recipes matching "$_searchQuery"'
                          : 'Your planned meals for today',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isSearching)
                GestureDetector(
                  onTap: () => context.push('/meal-plan'),
                  child: Text(
                    'View Planner',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Recipes List
          if (isSearching)
            _buildSearchResults(ref)
          else
            _buildMakeItNowResults(ref),
        ],
      ),
    );
  }

  Widget _buildSearchResults(WidgetRef ref) {
    final searchAsync = ref.watch(searchRecipesProvider(_searchQuery));

    return searchAsync.when(
      data: (recipes) {
        if (recipes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'No recipes found matching "$_searchQuery"',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Column(
          children: recipes
              .map(
                (recipe) => Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: _RecipeCard(
                    title: recipe.name,
                    description: recipe.instructions.length > 100
                        ? '${recipe.instructions.substring(0, 100)}...'
                        : recipe.instructions,
                    imageUrl: recipe.imageUrl,
                    tag: recipe.tags.isNotEmpty ? recipe.tags.first : 'Recipe',
                    tagColor: AppColors.primaryContainer,
                    tagTextColor: AppColors.onPrimaryContainer,
                    time: '${(recipe.prepTime ?? 0) + (recipe.cookTime ?? 0)}m',
                    onCookNow: () {}, // Handled internally
                    onTapCard: () => context.push('/recipes/${recipe.id}'),
                    isFavorite: recipe.isFavorite,
                    onBookmark: () {
                      ref
                          .read(recipeServiceProvider)
                          .toggleFavorite(recipe.id, !recipe.isFavorite);
                    },
                  ),
                ),
              )
              .toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildMakeItNowResults(WidgetRef ref) {
    final now = DateTime.now();
    final normalizedDate = DateTime(now.year, now.month, now.day);
    final mealPlanAsync = ref.watch(mealPlanForDateProvider(normalizedDate));
    final recipesAsync = ref.watch(userRecipesProvider);

    return mealPlanAsync.when(
      data: (mealPlan) {
        if (mealPlan == null || mealPlan.plannedMeals.isEmpty) {
          return recipesAsync.when(
            data: (allRecipes) {
              if (allRecipes.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const Icon(Icons.calendar_today, size: 48, color: AppColors.outline),
                        const SizedBox(height: 16),
                        Text(
                          'No meals planned for today.',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add some recipes to get started',
                          style: TextStyle(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Nondeterministic suggestion: pick a random recipe
              final random = DateTime.now().millisecond % allRecipes.length;
              final suggestedRecipe = allRecipes[random];

              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      const Icon(Icons.lightbulb_outline, size: 48, color: AppColors.primary),
                      const SizedBox(height: 16),
                      Text(
                        'Suggestion for today',
                        style: AppTextStyles.h3.copyWith(color: AppColors.onBackground),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        suggestedRecipe.name,
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onBackground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Open add-to-planner sheet with pre-selected recipe and appropriate time slot
                          final now = TimeOfDay.now();
                          String initialPeriod = 'Dinner';
                          if (now.hour < 11) {
                            initialPeriod = 'Breakfast';
                          } else if (now.hour < 15) {
                            initialPeriod = 'Lunch';
                          } else if (now.hour < 17) {
                            initialPeriod = 'Afternoon Snacks';
                          }

                          showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => Padding(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: SelectRecipesBottomSheet(
                                selectedDate: DateTime.now(),
                                initialMealPeriod: initialPeriod,
                                initialSuggestedRecipe: suggestedRecipe,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Add this to today\'s plan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => const Center(child: Text('Could not load suggestions')),
          );
        }

        return recipesAsync.when(
          data: (allRecipes) {
            final recipeMap = {for (final r in allRecipes) r.id: r};
            final todayMeals = mealPlan.plannedMeals.where((m) => recipeMap.containsKey(m.recipeId)).toList();

            if (todayMeals.isEmpty) {
              return const Center(child: Text('Planned recipes not found.'));
            }

            return Column(
              children: todayMeals.map((plannedMeal) {
                final recipe = recipeMap[plannedMeal.recipeId]!;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: _RecipeCard(
                    title: recipe.name,
                    description: '${plannedMeal.mealPeriod} · ${plannedMeal.servingTime}',
                    imageUrl: recipe.imageUrl,
                    tag: plannedMeal.mealPeriod,
                    tagColor: AppColors.secondary,
                    tagTextColor: AppColors.onSecondary,
                    time: '${(recipe.prepTime ?? 0) + (recipe.cookTime ?? 0)}m',
                    onCookNow: () {
                      // Handled by _RecipeCard state internally now, or passed as callback
                      // But wait, the prompt says "on tap of other parts of the card should take me to recipe details page"
                    },
                    onTapCard: () => context.push('/recipes/${recipe.id}'),
                    isFavorite: recipe.isFavorite,
                    onBookmark: () {
                      ref.read(recipeServiceProvider).toggleFavorite(recipe.id, !recipe.isFavorite);
                    },
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildBentoItem(
    BuildContext context,
    String title,
    IconData icon,
    Color bgColor,
    Color iconColor,
    Color iconOnColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            Text(
              title,
              style: AppTextStyles.h4.copyWith(
                fontSize: 16,
                color: bgColor == AppColors.primaryContainer
                    ? AppColors.onPrimaryContainer
                    : AppColors.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeCard extends StatefulWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final String tag;
  final Color tagColor;
  final Color tagTextColor;
  final String time;
  final VoidCallback onCookNow;
  final VoidCallback onBookmark;
  final VoidCallback? onTapCard;
  final bool isFavorite;

  const _RecipeCard({
    required this.title,
    required this.description,
    this.imageUrl,
    required this.tag,
    required this.tagColor,
    required this.tagTextColor,
    required this.time,
    required this.onCookNow,
    required this.onBookmark,
    this.onTapCard,
    this.isFavorite = false,
  });

  @override
  State<_RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<_RecipeCard> {
  bool _isCooking = false;
  bool _isCooked = false;
  DateTime? _cookingStartTime;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTapCard,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  RecipeImage(imageUrl: widget.imageUrl, fit: BoxFit.cover),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: widget.tagColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        widget.tag.toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: widget.tagTextColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          color: Colors.white.withAlpha(200),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.timer,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.time,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.onBackground,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isCooked
                              ? null
                              : () {
                                  if (!_isCooking) {
                                    setState(() {
                                      _isCooking = true;
                                      _cookingStartTime = DateTime.now();
                                    });
                                    debugPrint('Started cooking at $_cookingStartTime');
                                  } else {
                                    final end = DateTime.now();
                                    final duration = end.difference(_cookingStartTime!);
                                    debugPrint('Finished cooking at $end. Interval: ${duration.inMinutes} minutes');
                                    setState(() {
                                      _isCooking = false;
                                      _isCooked = true;
                                    });
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isCooked ? AppColors.surfaceContainerHigh : AppColors.primary,
                            foregroundColor: _isCooked ? AppColors.onSurfaceVariant : AppColors.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _isCooked
                                ? 'Cooked'
                                : (_isCooking ? 'Finish cooking' : 'Cook Now'),
                            style: AppTextStyles.labelLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            widget.isFavorite ? Icons.bookmark : Icons.bookmark_border,
                            color: AppColors.primary,
                          ),
                          onPressed: widget.onBookmark,
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
