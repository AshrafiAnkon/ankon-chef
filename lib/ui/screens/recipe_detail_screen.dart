import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/ingredient_provider.dart';
import '../widgets/main_drawer.dart';
import '../widgets/recipe_image.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeAsync = ref.watch(recipeByIdProvider(recipeId));
    final allIngredientsAsync = ref.watch(allIngredientsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: const MainDrawer(),
      body: recipeAsync.when(
        data: (recipe) {
          if (recipe == null) {
            return const Center(child: Text('Recipe not found'));
          }

          return CustomScrollView(
            slivers: [
              // Editorial App Bar with Image
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                backgroundColor: AppColors.surface,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.canPop() ? context.pop() : context.go('/recipes'),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withAlpha(80),
                    foregroundColor: Colors.white,
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                    RecipeImage(
                      imageUrl: recipe.imageUrl,
                      fit: BoxFit.cover,
                      iconSize: 80,
                    ),
                      // Gradient overlay for better text readability
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                            stops: [0.6, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    recipe.name,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 16, right: 16),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => context.pushNamed('edit-recipe', pathParameters: {'id': recipe.id}),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withAlpha(80),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Stats Row
                      _buildQuickStats(recipe),

                      const SizedBox(height: 32),

                      // Tags
                      if (recipe.tags.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: recipe.tags.map((tag) {
                            return Chip(
                              label: Text(tag),
                              backgroundColor: AppColors.surfaceContainerHigh,
                              side: BorderSide.none,
                              labelStyle: AppTextStyles.labelSmall,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Ingredients Section
                      Text('Ingredients', style: AppTextStyles.h2),
                      const SizedBox(height: 16),
                      allIngredientsAsync.when(
                        data: (allIngredients) {
                          final ingredientMap = {for (var ing in allIngredients) ing.id: ing};
                          return Column(
                            children: recipe.ingredientIds.map((id) {
                              final ingredient = ingredientMap[id];
                              final quantity = recipe.ingredientQuantities?[id] ?? '';
                              return _buildIngredientItem(ingredient?.name ?? 'Unknown', quantity);
                            }).toList(),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, s) => const Text('Error loading ingredients'),
                      ),

                      const SizedBox(height: 40),

                      // Instructions Section
                      Text('Instructions', style: AppTextStyles.h2),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: AppColors.outlineVariant.withAlpha(30)),
                        ),
                        child: Text(
                          recipe.instructions,
                          style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Youtube Player
                      if (recipe.youtubeUrl != null && recipe.youtubeUrl!.isNotEmpty) ...[
                        Text('Video Tutorial', style: AppTextStyles.h2),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: RecipeYoutubePlayer(youtubeUrl: recipe.youtubeUrl!),
                        ),
                        const SizedBox(height: 48),
                      ],

                      // Footer Metadata
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Created: ${_formatDate(recipe.createdAt)}',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                          IconButton(
                            icon: Icon(
                              recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: AppColors.primary,
                            ),
                            onPressed: () async {
                              await ref.read(recipeServiceProvider).toggleFavorite(recipe.id, !recipe.isFavorite);
                              ref.invalidate(recipeByIdProvider(recipe.id));
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildQuickStats(dynamic recipe) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.timer_outlined, '${recipe.prepTime ?? 0}m', 'Prep'),
          _buildStatDivider(),
          _buildStatItem(Icons.local_fire_department_outlined, '${recipe.cookTime ?? 0}m', 'Cook'),
          _buildStatDivider(),
          _buildStatItem(Icons.bolt_outlined, '${recipe.calories ?? 0} kcal', 'Est. Calories'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(value, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 30,
      width: 1,
      color: AppColors.outlineVariant.withAlpha(60),
    );
  }

  Widget _buildIngredientItem(String name, String quantity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withAlpha(20)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.secondary, size: 20),
          const SizedBox(width: 16),
          if (quantity.isNotEmpty)
            Text(
              '$quantity ',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
            ),
          Expanded(
            child: Text(name, style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class RecipeYoutubePlayer extends StatefulWidget {
  final String youtubeUrl;

  const RecipeYoutubePlayer({super.key, required this.youtubeUrl});

  @override
  State<RecipeYoutubePlayer> createState() => _RecipeYoutubePlayerState();
}

class _RecipeYoutubePlayerState extends State<RecipeYoutubePlayer> {
  late YoutubePlayerController _controller;
  bool _isInitError = false;

  @override
  void initState() {
    super.initState();
    
    String? videoId;
    try {
      final uri = Uri.parse(widget.youtubeUrl);
      if (uri.host.contains('youtu.be')) {
        videoId = uri.pathSegments.first;
      } else if (uri.host.contains('youtube.com')) {
        videoId = uri.queryParameters['v'];
      }
    } catch (_) {
      videoId = null;
    }

    if (videoId != null && videoId.isNotEmpty) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          mute: false,
          enableCaption: false,
        ),
      );
    } else {
      _isInitError = true;
    }
  }

  @override
  void dispose() {
    if (!_isInitError) {
      _controller.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitError) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: Border.all(color: AppColors.outlineVariant.withAlpha(30)),
        ),
        child: const Center(child: Text('Invalid YouTube URL')),
      );
    }

    return YoutubePlayer(
      controller: _controller,
      aspectRatio: 16 / 9,
    );
  }
}
