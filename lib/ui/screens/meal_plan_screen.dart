import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/meal_plan_model.dart';
import '../../models/recipe_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ingredient_provider.dart';
import '../../providers/meal_plan_provider.dart';
import '../../providers/recipe_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/recipe_image.dart';

const _kMealPeriods = <String>[
  'Breakfast',
  'Lunch',
  'Afternoon Snacks',
  'Dinner',
];

String _normalizeMealPeriod(String raw) {
  final p = raw.trim().toLowerCase();
  if (p.contains('breakfast')) return 'Breakfast';
  if (p.contains('lunch')) return 'Lunch';
  if (p.contains('afternoon') || p == 'snack' || p.contains('snacks')) {
    return 'Afternoon Snacks';
  }
  if (p.contains('dinner')) return 'Dinner';
  return 'Dinner';
}

TimeOfDay _defaultTimeForPeriod(String period) {
  switch (period) {
    case 'Breakfast':
      return const TimeOfDay(hour: 8, minute: 0);
    case 'Lunch':
      return const TimeOfDay(hour: 12, minute: 30);
    case 'Afternoon Snacks':
      return const TimeOfDay(hour: 15, minute: 0);
    case 'Dinner':
    default:
      return const TimeOfDay(hour: 19, minute: 0);
  }
}

String _formatTimeOfDay(TimeOfDay t) {
  final h = t.hour.toString().padLeft(2, '0');
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

int _countMissingIngredients(Recipe recipe, Set<String> pantryIds) {
  return recipe.ingredientIds.where((id) => !pantryIds.contains(id)).length;
}

bool _isFullyStocked(Recipe recipe, Set<String> pantryIds) {
  if (recipe.ingredientIds.isEmpty) return true;
  return recipe.ingredientIds.every((id) => pantryIds.contains(id));
}

class MealPlanScreen extends ConsumerStatefulWidget {
  const MealPlanScreen({super.key});

  @override
  ConsumerState<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends ConsumerState<MealPlanScreen> {
  late DateTime _selectedDate;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day);
    });
  }

  Future<void> _showFullMonthPicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        _selectedDate = DateTime(date.year, date.month, date.day);
      });
    }
  }

  void _showSelectRecipesDialog({String? initialMealPeriod}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _SelectRecipesBottomSheet(
          selectedDate: _selectedDate,
          initialMealPeriod: initialMealPeriod,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFAB(),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildFAB() {
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
        onPressed: () => _showSelectRecipesDialog(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
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
                  Icons.shopping_cart_outlined,
                  color: AppColors.onSurfaceVariant,
                ),
                onPressed: () => context.push('/shopping-list'),
              ),
              IconButton(
                padding: const EdgeInsets.only(right: 24),
                icon: const Icon(
                  Icons.calendar_month,
                  color: AppColors.onSurfaceVariant,
                ),
                onPressed: _showFullMonthPicker,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 100,
        left: 24,
        right: 24,
        bottom: 120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlannerHeader(),
          const SizedBox(height: 24),
          _buildFiveDayStrip(),
          const SizedBox(height: 28),
          _buildMealSections(),
          const SizedBox(height: 28),
          _buildInventoryBento(),
        ],
      ),
    );
  }

  Widget _buildPlannerHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Planner',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.onBackground,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE, MMM d').format(_selectedDate),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: AppColors.primary,
          elevation: 4,
          shadowColor: AppColors.primary.withAlpha(100),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => context.push('/shopping-list'),
            child: const SizedBox(
              width: 56,
              height: 56,
              child: Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.onPrimary,
                size: 26,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFiveDayStrip() {
    final days = List.generate(
      5,
      (i) => _selectedDate.add(Duration(days: i - 2)),
    );

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected =
              day.year == _selectedDate.year &&
              day.month == _selectedDate.month &&
              day.day == _selectedDate.day;
          final dayLabel = DateFormat('E').format(day).toUpperCase();

          return GestureDetector(
            onTap: () => _selectDate(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: 60,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? null
                    : Border.all(color: AppColors.surfaceContainerHigh),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(60),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayLabel.substring(0, 3),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isSelected
                          ? AppColors.onPrimary.withAlpha(200)
                          : AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: AppTextStyles.h4.copyWith(
                      color: isSelected
                          ? AppColors.onPrimary
                          : AppColors.onBackground,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealSections() {
    final normalizedDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final mealPlanAsync = ref.watch(mealPlanForDateProvider(normalizedDate));
    final recipesAsync = ref.watch(userRecipesProvider);
    final pantryAsync = ref.watch(currentIngredientIdsProvider);

    return mealPlanAsync.when(
      data: (mealPlan) {
        return recipesAsync.when(
          data: (allRecipes) {
            return pantryAsync.when(
              data: (pantryIds) {
                final recipeMap = {for (final r in allRecipes) r.id: r};
                final pantrySet = pantryIds.toSet();

                final grouped = <String, List<PlannedMeal>>{};
                for (final p in _kMealPeriods) {
                  grouped[p] = [];
                }
                if (mealPlan != null) {
                  for (final m in mealPlan.plannedMeals) {
                    final key = _normalizeMealPeriod(m.mealPeriod);
                    grouped.putIfAbsent(key, () => []).add(m);
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final period in _kMealPeriods) ...[
                      _MealPeriodBlock(
                        title: period,
                        meals: grouped[period] ?? const [],
                        recipeMap: recipeMap,
                        pantryIds: pantrySet,
                        mealPlan: mealPlan,
                        ref: ref,
                        onAddRecipe: () =>
                            _showSelectRecipesDialog(initialMealPeriod: period),
                        onRemoveMeal: mealPlan == null
                            ? null
                            : (planned) =>
                                  _removeMealFromPlan(mealPlan, planned),
                        onStartCooking: (recipe) =>
                            context.push('/recipes/${recipe.id}'),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (e, s) => const SizedBox.shrink(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          error: (e, _) => Text('Error: $e'),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  Future<void> _removeMealFromPlan(MealPlan mealPlan, PlannedMeal meal) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final updated = mealPlan.plannedMeals.where((m) => m != meal).toList();
    final service = ref.read(mealPlanServiceProvider);

    if (updated.isEmpty) {
      await service.deleteMealPlan(mealPlan.id);
    } else {
      await service.createOrUpdateMealPlan(
        userId: user.uid,
        planDate: mealPlan.planDate,
        plannedMeals: updated,
        existingMealPlanId: mealPlan.id,
      );
    }
  }

  Widget _buildInventoryBento() {
    final normalizedDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final mealPlanAsync = ref.watch(mealPlanForDateProvider(normalizedDate));
    final pantryAsync = ref.watch(currentIngredientIdsProvider);

    return mealPlanAsync.when(
      data: (mealPlan) {
        return pantryAsync.when(
          data: (pantryIds) {
            if (mealPlan == null || mealPlan.plannedMeals.isEmpty) {
              return _inventoryCardStatic(mealPlan);
            }
            return FutureBuilder<List<GroceryItem>>(
              future: ref
                  .read(mealPlanServiceProvider)
                  .generateGroceryList(
                    recipeIds: mealPlan.recipeIds,
                    currentIngredientIds: pantryIds,
                    shoppingListExclusions: mealPlan.shoppingListExclusions,
                    shoppingListOverrides: mealPlan.shoppingListOverrides,
                  ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }
                final items = snapshot.data!;
                if (items.isEmpty) {
                  return _inventoryCardStatic(mealPlan);
                }
                final total = items.length;
                final toBuy = items.where((g) => !g.isAvailable).length;
                final ready = total - toBuy;
                final pct = total == 0 ? 84 : ((ready / total) * 100).round();

                return _inventoryCard(
                  mealPlan: mealPlan,
                  readyPercent: pct,
                  itemsToBuy: toBuy,
                );
              },
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          error: (e, s) => _inventoryCardStatic(mealPlan),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (e, s) => _inventoryCardStatic(null),
    );
  }

  Widget _inventoryCardStatic(MealPlan? mealPlan) {
    return _inventoryCard(
      mealPlan: mealPlan,
      readyPercent: 0,
      itemsToBuy: 0,
      isLoading: true,
    );
  }

  Widget _inventoryCard({
    required MealPlan? mealPlan,
    required int readyPercent,
    required int itemsToBuy,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pantry Status',
            style: AppTextStyles.h3.copyWith(color: AppColors.onBackground),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _bentoTile(
                  label: 'Ready',
                  value: '$readyPercent%',
                  accent: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _bentoTile(
                  label: 'To Buy',
                  value: '$itemsToBuy Items',
                  accent: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (mealPlan == null) return;

                      final service = ref.read(mealPlanServiceProvider);
                      await service.updateShoppingListExclusions(
                        mealPlan.id,
                        [],
                      );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'All missing items added to shopping list',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.add_shopping_cart, size: 20),
              label: Text(
                'Add Missing Items to Shopping List',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bentoTile({
    required String label,
    required String value,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withAlpha(28),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
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
                  _NavBarItem(
                    icon: Icons.home,
                    label: 'Home',
                    isActive: false,
                    onTap: () => context.go('/home'),
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
                    isActive: true,
                    onTap: () {},
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
    );
  }
}

class _MealPeriodBlock extends StatelessWidget {
  const _MealPeriodBlock({
    required this.title,
    required this.meals,
    required this.recipeMap,
    required this.pantryIds,
    required this.mealPlan,
    required this.ref,
    required this.onAddRecipe,
    required this.onRemoveMeal,
    required this.onStartCooking,
  });

  final String title;
  final List<PlannedMeal> meals;
  final Map<String, Recipe> recipeMap;
  final Set<String> pantryIds;
  final MealPlan? mealPlan;
  final WidgetRef ref;
  final VoidCallback onAddRecipe;
  final void Function(PlannedMeal)? onRemoveMeal;
  final void Function(Recipe recipe) onStartCooking;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.h3.copyWith(
            color: AppColors.onBackground,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        if (meals.isEmpty)
          _EmptyMealSlot(onAddRecipe: onAddRecipe)
        else
          ...meals.map((planned) {
            final recipe = recipeMap[planned.recipeId];
            if (recipe == null) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _UnknownRecipeCard(
                  planned: planned,
                  onRemove: onRemoveMeal == null
                      ? null
                      : () => onRemoveMeal!(planned),
                ),
              );
            }
            final missing = _countMissingIngredients(recipe, pantryIds);
            final stocked = _isFullyStocked(recipe, pantryIds);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PlannedMealCard(
                mealPlan: mealPlan!,
                recipe: recipe,
                planned: planned,
                missingCount: missing,
                inStock: stocked,
                onRemove: onRemoveMeal == null
                    ? null
                    : () => onRemoveMeal!(planned),
                onStartCooking: () => onStartCooking(recipe),
                onAddMissing: () async {
                  final currentPlan = mealPlan;
                  if (currentPlan == null) return;
                  final service = ref.read(mealPlanServiceProvider);
                  final currentExclusions = List<String>.from(
                    currentPlan.shoppingListExclusions,
                  );

                  // Remove this recipe's ingredients from deletions if they were excluded
                  for (final ingredientId in recipe.ingredientIds) {
                    currentExclusions.remove(ingredientId);
                  }

                  await service.updateShoppingListExclusions(
                    currentPlan.id,
                    currentExclusions,
                  );
                },
              ),
            );
          }),
      ],
    );
  }
}

class _EmptyMealSlot extends StatelessWidget {
  const _EmptyMealSlot({required this.onAddRecipe});

  final VoidCallback onAddRecipe;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(
        color: AppColors.outlineVariant,
        strokeWidth: 1.5,
        radius: 20,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: onAddRecipe,
                  icon: const Icon(Icons.add, color: AppColors.primary),
                  label: Text(
                    'Add Recipe',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
  });

  final Color color;
  final double strokeWidth;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(r);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        const dash = 6.0;
        const gap = 4.0;
        final next = distance + dash;
        canvas.drawPath(
          metric.extractPath(
            distance,
            next > metric.length ? metric.length : next,
          ),
          paint,
        );
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius;
  }
}

class _PlannedMealCard extends StatefulWidget {
  const _PlannedMealCard({
    required this.mealPlan,
    required this.recipe,
    required this.planned,
    required this.missingCount,
    required this.inStock,
    required this.onRemove,
    required this.onStartCooking,
    required this.onAddMissing,
  });

  final MealPlan mealPlan;
  final Recipe recipe;
  final PlannedMeal planned;
  final int missingCount;
  final bool inStock;
  final VoidCallback? onRemove;
  final VoidCallback onStartCooking; // Navigates to recipe details
  final VoidCallback onAddMissing;

  @override
  State<_PlannedMealCard> createState() => _PlannedMealCardState();
}

class _PlannedMealCardState extends State<_PlannedMealCard> {
  bool _isCooking = false;
  bool _isCooked = false;
  DateTime? _cookingStartTime;

  @override
  Widget build(BuildContext context) {
    final greenBg = AppColors.secondary.withAlpha(36);
    final greenBorder = AppColors.secondary.withAlpha(120);
    final redBg = AppColors.error.withAlpha(28);
    final redBorder = AppColors.error.withAlpha(100);

    final bg = _isCooked ? AppColors.surfaceContainerHigh : (widget.inStock ? greenBg : redBg);
    final borderColor = _isCooked ? AppColors.outlineVariant : (widget.inStock ? greenBorder : redBorder);
    final statusLabel = _isCooked ? 'Cooked' : (widget.inStock ? 'In Stock' : '${widget.missingCount} Missing');
    final statusColor = _isCooked ? AppColors.onSurfaceVariant : (widget.inStock ? AppColors.secondary : AppColors.error);

    return GestureDetector(
      onTap: widget.onStartCooking, // Entire card tap navigates to details
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RecipeImage(
                  imageUrl: widget.recipe.imageUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  iconSize: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(40),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusLabel,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (widget.onRemove != null)
                            GestureDetector(
                              onTap: widget.onRemove,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: AppColors.surfaceContainerHigh,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.recipe.name,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.onBackground,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.planned.servingTime} · ${widget.planned.servings} servings',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (widget.inStock)
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
                        backgroundColor: _isCooked ? AppColors.surfaceContainerHigh : AppColors.secondary,
                        foregroundColor: _isCooked ? AppColors.onSurfaceVariant : AppColors.onSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        _isCooked ? 'Cooked' : (_isCooking ? 'Finish cooking' : 'Start Cooking'),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        widget.onAddMissing();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added missing ingredients for ${widget.recipe.name} to shopping list',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.add_shopping_cart, size: 18),
                      label: const Text(
                        'Add Missing to List',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UnknownRecipeCard extends StatelessWidget {
  const _UnknownRecipeCard({required this.planned, required this.onRemove});

  final PlannedMeal planned;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: Row(
        children: [
          const Icon(Icons.no_meals, color: AppColors.outline),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Recipe not found (${planned.recipeId})',
              style: AppTextStyles.bodySmall,
            ),
          ),
          if (onRemove != null)
            IconButton(icon: const Icon(Icons.close), onPressed: onRemove),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

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

class _SelectRecipesBottomSheet extends ConsumerStatefulWidget {
  const _SelectRecipesBottomSheet({
    required this.selectedDate,
    this.initialMealPeriod,
  });

  final DateTime selectedDate;
  final String? initialMealPeriod;

  @override
  ConsumerState<_SelectRecipesBottomSheet> createState() =>
      _SelectRecipesBottomSheetState();
}

class _SelectRecipesBottomSheetState
    extends ConsumerState<_SelectRecipesBottomSheet> {
  late String _selectedMealPeriod;
  late TimeOfDay _servingTime;
  int _servings = 2;
  bool _pantryOnly = false;
  bool _isSaving = false;
  String _searchQuery = '';
  final List<PlannedMeal> _pendingMeals = [];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _mealNotesController = TextEditingController();

  String? _reminderDraft;
  final List<String> _prepReminders = [];

  @override
  void initState() {
    super.initState();
    _selectedMealPeriod = widget.initialMealPeriod ?? 'Dinner';
    if (!_kMealPeriods.contains(_selectedMealPeriod)) {
      _selectedMealPeriod = 'Dinner';
    }
    _servingTime = _defaultTimeForPeriod(_selectedMealPeriod);
    _reminderDraft = '15 mins before';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mealNotesController.dispose();
    super.dispose();
  }

  PlannedMeal _buildPlannedMealFromRecipe(Recipe recipe) {
    return PlannedMeal(
      recipeId: recipe.id,
      mealPeriod: _selectedMealPeriod,
      servingTime: _formatTimeOfDay(_servingTime),
      servings: _servings,
      mealNotes: _mealNotesController.text,
      prepReminders: List<String>.from(_prepReminders),
    );
  }

  void _onMealPeriodChanged(String period) {
    setState(() {
      _selectedMealPeriod = period;
      _servingTime = _defaultTimeForPeriod(period);
    });
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _servingTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (t != null) {
      setState(() => _servingTime = t);
    }
  }

  void _addReminder() {
    final v = _reminderDraft;
    if (v == null || v.isEmpty) return;
    setState(() {
      if (!_prepReminders.contains(v)) {
        _prepReminders.add(v);
      }
    });
  }

  Future<void> _confirm() async {
    if (_pendingMeals.isEmpty || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        setState(() => _isSaving = false);
        return;
      }

      final existingPlan = await ref.read(
        mealPlanForDateProvider(widget.selectedDate).future,
      );
      final existing = existingPlan?.plannedMeals ?? const <PlannedMeal>[];

      final merged = <PlannedMeal>[...existing, ..._pendingMeals];

      final service = ref.read(mealPlanServiceProvider);
      await service.createOrUpdateMealPlan(
        userId: user.uid,
        planDate: widget.selectedDate,
        plannedMeals: merged,
        existingMealPlanId: existingPlan?.id,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving plan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(userRecipesProvider);
    final pantryAsync = ref.watch(currentIngredientIdsProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add to Meal Planner',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.onBackground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Scheduling for ${DateFormat('EEEE, MMM d').format(widget.selectedDate)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meal Period',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _kMealPeriods.map((p) {
                      final selected = _selectedMealPeriod == p;
                      return ChoiceChip(
                        label: Text(
                          p,
                          style: TextStyle(
                            fontSize: p == 'Afternoon Snacks' ? 11 : 13,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? AppColors.onPrimary
                                : AppColors.onBackground,
                          ),
                        ),
                        selected: selected,
                        onSelected: (_) => _onMealPeriodChanged(p),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surfaceContainerLowest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: selected
                                ? AppColors.primary
                                : AppColors.surfaceContainerHigh,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Serving Time',
                              style: AppTextStyles.labelLarge.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: _pickTime,
                              icon: const Icon(Icons.schedule, size: 18),
                              label: Text(_formatTimeOfDay(_servingTime)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.onBackground,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Servings',
                            style: AppTextStyles.labelLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              IconButton.filled(
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      AppColors.surfaceContainerHigh,
                                  foregroundColor: AppColors.onBackground,
                                ),
                                onPressed: _servings > 1
                                    ? () => setState(() => _servings--)
                                    : null,
                                icon: const Icon(Icons.remove, size: 18),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  '$_servings',
                                  style: AppTextStyles.h4.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              IconButton.filled(
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.onPrimary,
                                ),
                                onPressed: () => setState(() => _servings++),
                                icon: const Icon(Icons.add, size: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Recipes to Add',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search recipes...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.outline,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.outline,
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceContainerLowest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Pantry Only',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: _pantryOnly,
                        activeTrackColor: AppColors.primary.withAlpha(160),
                        activeThumbColor: AppColors.onPrimary,
                        onChanged: (v) => setState(() => _pantryOnly = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_pendingMeals.isNotEmpty) ...[
                    Text(
                      'Selected',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ReorderableListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      buildDefaultDragHandles: false,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex--;
                          final item = _pendingMeals.removeAt(oldIndex);
                          _pendingMeals.insert(newIndex, item);
                        });
                      },
                      children: [
                        for (var i = 0; i < _pendingMeals.length; i++)
                          _PendingMealRow(
                            key: ValueKey(
                              '${_pendingMeals[i].recipeId}_${i}_${_pendingMeals[i].mealPeriod}',
                            ),
                            planned: _pendingMeals[i],
                            index: i,
                            recipesAsync: recipesAsync,
                            onDelete: () {
                              setState(() => _pendingMeals.removeAt(i));
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  recipesAsync.when(
                    data: (recipes) {
                      return pantryAsync.when(
                        data: (pantryIds) {
                          final pantrySet = pantryIds.toSet();
                          var filtered = recipes
                              .where(
                                (r) => r.name.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ),
                              )
                              .toList();
                          if (_pantryOnly) {
                            filtered = filtered
                                .where((r) => _isFullyStocked(r, pantrySet))
                                .toList();
                          }

                          if (filtered.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  _searchQuery.isEmpty
                                      ? 'No recipes'
                                      : 'No matching recipes',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final recipe = filtered[index];
                              return Material(
                                color: AppColors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    setState(() {
                                      _pendingMeals.add(
                                        _buildPlannedMealFromRecipe(recipe),
                                      );
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        RecipeImage(
                                          imageUrl: recipe.imageUrl,
                                          width: 44,
                                          height: 44,
                                          fit: BoxFit.cover,
                                          iconSize: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                recipe.name,
                                                style: AppTextStyles.labelLarge
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '${recipe.ingredientIds.length} ingredients',
                                                style: AppTextStyles.bodySmall
                                                    .copyWith(
                                                      color: AppColors
                                                          .onSurfaceVariant,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.add_circle_outline,
                                          color: AppColors.primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        error: (e, s) => const SizedBox.shrink(),
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    error: (e, _) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Meal Notes',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _mealNotesController,
                    maxLines: 3,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Notes for this meal block...',
                      filled: true,
                      fillColor: AppColors.surfaceContainerLowest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Prep Reminders',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _reminderDraft,
                              items: const [
                                DropdownMenuItem(
                                  value: '15 mins before',
                                  child: Text('15 mins before'),
                                ),
                                DropdownMenuItem(
                                  value: '30 mins before',
                                  child: Text('30 mins before'),
                                ),
                              ],
                              onChanged: (v) =>
                                  setState(() => _reminderDraft = v),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _addReminder,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  if (_prepReminders.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _prepReminders.map((r) {
                        return Chip(
                          label: Text(r),
                          onDeleted: () {
                            setState(() => _prepReminders.remove(r));
                          },
                          deleteIconColor: AppColors.onSurfaceVariant,
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_pendingMeals.isEmpty || _isSaving)
                      ? null
                      : _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    disabledBackgroundColor: AppColors.primary.withAlpha(100),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : Text(
                          'Confirm Selection',
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onPrimary,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingMealRow extends ConsumerWidget {
  const _PendingMealRow({
    super.key,
    required this.planned,
    required this.index,
    required this.recipesAsync,
    required this.onDelete,
  });

  final PlannedMeal planned;
  final int index;
  final AsyncValue<List<Recipe>> recipesAsync;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return recipesAsync.when(
      data: (recipes) {
        final matches = recipes.where((r) => r.id == planned.recipeId);
        final recipe = matches.isEmpty ? null : matches.first;
        final name = recipe?.name ?? planned.recipeId;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.surfaceContainerHigh),
          ),
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.only(right: 4, top: 8, bottom: 8, left: 4),
                  child: Icon(Icons.drag_handle, color: AppColors.outline),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${planned.mealPeriod} · ${planned.servingTime}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: onDelete,
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}
