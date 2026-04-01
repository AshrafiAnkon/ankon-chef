import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import '../widgets/settings_bottom_sheet.dart';
import '../widgets/recipe_image.dart';

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
                  icon: const Icon(Icons.settings, color: AppColors.onSurfaceVariant),
                  onPressed: () => showSettingsBottomSheet(context, ref),
                ),
              ],
            ),
          ),
        ),
      ),
      body: userAsync.when(
        data: (user) => _HomeContent(userName: user?.displayName ?? 'Alex'),
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
            )
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
                    _NavBarItem(icon: Icons.home, label: 'Home', isActive: true, onTap: () {}),
                    _NavBarItem(icon: Icons.restaurant_menu, label: 'Recipes', isActive: false, onTap: () => context.go('/recipes')),
                    _NavBarItem(icon: Icons.inventory_2, label: 'Pantry', isActive: false, onTap: () => context.go('/pantry')),
                    _NavBarItem(icon: Icons.calendar_month, label: 'Planner', isActive: false, onTap: () => context.go('/meal-plan')),
                    _NavBarItem(icon: Icons.kitchen, label: 'Ingredients', isActive: false, onTap: () => context.go('/ingredients')),
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
                color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
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
  final String userName;

  const _HomeContent({required this.userName});

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
              style: AppTextStyles.display2.copyWith(color: AppColors.onBackground, height: 1.2),
              children: [
                TextSpan(text: 'Hi, ${widget.userName}!\n'),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department, color: AppColors.onSecondary, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Pantry 85% full',
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.onSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Cooking Streak: 5 Days',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.onSurfaceVariant),
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
                borderSide: const BorderSide(color: AppColors.surfaceContainerHigh),
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
                if (index == 0) return _buildBentoItem(context, 'All Recipes', Icons.restaurant_menu, AppColors.surfaceContainerLowest, AppColors.primary, AppColors.onPrimary, () => context.push('/recipes'));
                if (index == 1) return _buildBentoItem(context, 'Add New', Icons.add_circle, AppColors.primaryContainer, AppColors.onPrimaryContainer, AppColors.onPrimaryContainer, () => context.push('/recipes/create'));
                if (index == 2) return _buildBentoItem(context, 'Manage Pantry', Icons.inventory_2, AppColors.surfaceContainerLowest, AppColors.secondary, AppColors.onSecondary, () => context.push('/pantry'));
                if (index == 3) return _buildBentoItem(context, 'Meal Planner', Icons.calendar_month, AppColors.surfaceContainerLowest, AppColors.tertiary, AppColors.onTertiary, () => context.push('/meal-plan'));
                return _buildBentoItem(context, 'Browse Ingredients', Icons.kitchen, AppColors.surfaceContainerLowest, AppColors.primaryDim, AppColors.onPrimary, () => context.push('/ingredients'));
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
                    Text(isSearching ? 'Search Results' : 'Make it Now', style: AppTextStyles.h3),
                    const SizedBox(height: 4),
                    Text(
                      isSearching ? 'Recipes matching "$_searchQuery"' : 'Based on items in your pantry', 
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)
                    ),
                  ],
                ),
              ),
              if (!isSearching)
                GestureDetector(
                  onTap: () => context.push('/recipes'),
                  child: Text(
                    'View All',
                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
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
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        
        return Column(
          children: recipes.map((recipe) => Padding(
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
              onCookNow: () => context.push('/recipes/${recipe.id}'),
              isFavorite: recipe.isFavorite,
              onBookmark: () {
                ref.read(recipeServiceProvider).toggleFavorite(recipe.id, !recipe.isFavorite);
              },
            ),
          )).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildMakeItNowResults(WidgetRef ref) {
    final makeItNowAsync = ref.watch(recipesWithCurrentIngredientsProvider);
    
    return makeItNowAsync.when(
      data: (recipes) {
        if (recipes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  const Icon(Icons.kitchen, size: 48, color: AppColors.outline),
                  const SizedBox(height: 16),
                  Text(
                    'Add more ingredients to your pantry to see recommendations here.',
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/pantry'),
                    child: const Text('Update Pantry'),
                  ),
                ],
              ),
            ),
          );
        }
        
        // Show up to 3 recommendations
        final displayRecipes = recipes.take(3).toList();
        
        return Column(
          children: displayRecipes.map((recipe) => Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: _RecipeCard(
              title: recipe.name,
              description: recipe.instructions.length > 80 ? '${recipe.instructions.substring(0, 80)}...' : recipe.instructions,
              imageUrl: recipe.imageUrl,
              tag: 'Ready to Cook',
              tagColor: AppColors.secondary,
              tagTextColor: AppColors.onSecondary,
              time: '${(recipe.prepTime ?? 0) + (recipe.cookTime ?? 0)}m',
              onCookNow: () => context.push('/recipes/${recipe.id}'),
              isFavorite: recipe.isFavorite,
              onBookmark: () {
                ref.read(recipeServiceProvider).toggleFavorite(recipe.id, !recipe.isFavorite);
              },
            ),
          )).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildBentoItem(BuildContext context, String title, IconData icon, Color bgColor, Color iconColor, Color iconOnColor, VoidCallback onTap) {
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
                color: bgColor == AppColors.primaryContainer ? AppColors.onPrimaryContainer : AppColors.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final String tag;
  final Color tagColor;
  final Color tagTextColor;
  final String time;
  final VoidCallback onCookNow;
  final VoidCallback onBookmark;
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
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                RecipeImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: tagColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      tag.toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: tagTextColor,
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        color: Colors.white.withAlpha(200),
                        child: Row(
                          children: [
                            const Icon(Icons.timer, size: 16, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              time,
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
                Text(title, style: AppTextStyles.h3),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onCookNow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Cook Now',
                          style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
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
                          isFavorite ? Icons.bookmark : Icons.bookmark_border, 
                          color: AppColors.primary
                        ),
                        onPressed: onBookmark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
