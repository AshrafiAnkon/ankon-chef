import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../providers/meal_plan_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/ingredient_provider.dart';
import '../widgets/recipe_image.dart';
import '../../providers/auth_provider.dart';
import '../../models/meal_plan_model.dart';
import '../../models/recipe_model.dart';
import '../widgets/settings_bottom_sheet.dart';

class MealPlanScreen extends ConsumerStatefulWidget {
  const MealPlanScreen({super.key});

  @override
  ConsumerState<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends ConsumerState<MealPlanScreen> {
  late DateTime _selectedDate;
  late DateTime _weekStart;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _weekStart = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );
    _scrollController = ScrollController();
  }


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _showFullMonthPicker() async {
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
        _selectedDate = date;
        _weekStart = date.subtract(Duration(days: date.weekday - 1));
      });
    }
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

  // ─── APP BAR ───────────────────────────────────────────────────────
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
                  Icons.search,
                  color: AppColors.onSurfaceVariant,
                ),
                onPressed: () => _showSelectRecipesDialog(),
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

  // ─── BODY ──────────────────────────────────────────────────────────
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
          _buildMealPlannerHeader(),
          const SizedBox(height: 24),
          _buildWeeklyCalendar(),
          const SizedBox(height: 28),
          _buildPlannedMealsSection(),
          const SizedBox(height: 28),
          _buildTodaysIngredientsSection(),
          const SizedBox(height: 20),
          _buildEstimatedPrepTime(),
        ],
      ),
    );
  }

  // ─── MEAL PLANNER HEADER ──────────────────────────────────────────
  Widget _buildMealPlannerHeader() {
    final monthYear = DateFormat('MMMM yyyy').format(_selectedDate);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meal Planner',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.onBackground,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                monthYear,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _showFullMonthPicker,
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'View Full Month',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── WEEKLY CALENDAR ──────────────────────────────────────────────
  Widget _buildWeeklyCalendar() {
    final days = List.generate(7, (i) => _weekStart.add(Duration(days: i)));

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = day.year == _selectedDate.year &&
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
                color: isSelected ? AppColors.primary : AppColors.surfaceContainerLowest,
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

  // ─── PLANNED MEALS SECTION ────────────────────────────────────────
  Widget _buildPlannedMealsSection() {
    final normalizedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final mealPlanAsync = ref.watch(mealPlanForDateProvider(normalizedDate));

    return mealPlanAsync.when(
      data: (mealPlan) {

        if (mealPlan == null || mealPlan.recipeIds.isEmpty) {
          return _buildPlannedMealsEmpty();
        }
        return _buildPlannedMealsList(mealPlan);
      },
      loading: () => _buildPlannedMealsSkeleton(),
      error: (e, s) => _buildPlannedMealsEmpty(),
    );
  }

  Widget _buildPlannedMealsEmpty() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Planned Meals',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.onBackground,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '0 Recipes',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.outlineVariant.withAlpha(80),
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.event_note,
                size: 48,
                color: AppColors.onSurfaceVariant.withAlpha(100),
              ),
              const SizedBox(height: 12),
              Text(
                'No meals planned for this day',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap + to start planning',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildAddMealButton(),
      ],
    );
  }

  Widget _buildPlannedMealsSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Planned Meals', style: AppTextStyles.h3),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 16),
        const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildPlannedMealsList(MealPlan mealPlan) {
    final recipesAsync = ref.watch(userRecipesProvider);
    final mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

    return recipesAsync.when(
      data: (allRecipes) {
        final plannedRecipes =
            allRecipes.where((r) => mealPlan.recipeIds.contains(r.id)).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Planned Meals',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.onBackground,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${plannedRecipes.length} Recipe${plannedRecipes.length != 1 ? "s" : ""}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...plannedRecipes.asMap().entries.map((entry) {
              final index = entry.key;
              final recipe = entry.value;
              final mealType =
                  index < mealTypes.length ? mealTypes[index] : 'Meal';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MealCard(
                  recipe: recipe,
                  mealType: mealType,
                  onRemove: () => _removeRecipeFromPlan(mealPlan, recipe.id),
                ),
              );
            }),
            _buildAddMealButton(),
          ],
        );
      },
      loading: () => _buildPlannedMealsSkeleton(),
      error: (e, s) => Text('Error: $e'),
    );
  }

  Widget _buildAddMealButton() {
    return GestureDetector(
      onTap: () => _showSelectRecipesDialog(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.outlineVariant.withAlpha(120),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.add_circle_outline,
              size: 28,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 6),
            Text(
              'Plan another meal for today',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── TODAY'S INGREDIENTS SECTION ──────────────────────────────────
  Widget _buildTodaysIngredientsSection() {
    final mealPlanAsync = ref.watch(mealPlanForDateProvider(_selectedDate));

    return mealPlanAsync.when(
      data: (mealPlan) {
        if (mealPlan == null || mealPlan.recipeIds.isEmpty) {
          return const SizedBox.shrink();
        }
        return _buildIngredientsContent(mealPlan);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildIngredientsContent(MealPlan mealPlan) {
    final currentIngredientsAsync = ref.watch(currentIngredientIdsProvider);

    return currentIngredientsAsync.when(
      data: (currentIngredientIds) {
        return FutureBuilder<List<GroceryItem>>(
          future: _generateGroceryList(mealPlan, currentIngredientIds),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }

            final groceryItems = snapshot.data ?? [];
            if (groceryItems.isEmpty) return const SizedBox.shrink();

            // Group ingredients by a simulated category
            final freshProduce = <GroceryItem>[];
            final proteins = <GroceryItem>[];
            final pantryStaples = <GroceryItem>[];

            for (final item in groceryItems) {
              final name = item.ingredientName.toLowerCase();
              if (_isProtein(name)) {
                proteins.add(item);
              } else if (_isFreshProduce(name)) {
                freshProduce.add(item);
              } else {
                pantryStaples.add(item);
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Today's Ingredients",
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.onBackground,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (freshProduce.isNotEmpty)
                  _IngredientCategoryRow(
                    icon: Icons.eco,
                    iconColor: const Color(0xFF2E7D32),
                    iconBgColor: const Color(0xFFE8F5E9),
                    title: 'Fresh Produce',
                    items: freshProduce
                        .map((i) => i.ingredientName)
                        .join(', '),
                  ),
                if (proteins.isNotEmpty)
                  _IngredientCategoryRow(
                    icon: Icons.egg_alt,
                    iconColor: AppColors.primary,
                    iconBgColor: AppColors.primary.withAlpha(20),
                    title: 'Proteins',
                    items: proteins
                        .map((i) => i.ingredientName)
                        .join(', '),
                  ),
                if (pantryStaples.isNotEmpty)
                  _IngredientCategoryRow(
                    icon: Icons.kitchen,
                    iconColor: const Color(0xFF795548),
                    iconBgColor: const Color(0xFFEFEBE9),
                    title: 'Pantry Staples',
                    items: pantryStaples
                        .map((i) => i.ingredientName)
                        .join(', '),
                  ),
              ],
            );
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  bool _isProtein(String name) {
    final proteinKeywords = [
      'chicken', 'beef', 'pork', 'fish', 'salmon', 'tuna', 'shrimp',
      'turkey', 'lamb', 'tofu', 'egg', 'meat', 'steak', 'fillet',
      'breast', 'thigh', 'wing', 'prawn', 'crab', 'lobster',
    ];
    return proteinKeywords.any((k) => name.contains(k));
  }

  bool _isFreshProduce(String name) {
    final produceKeywords = [
      'tomato', 'lettuce', 'spinach', 'kale', 'avocado', 'onion',
      'garlic', 'pepper', 'carrot', 'broccoli', 'cauliflower', 'cucumber',
      'lemon', 'lime', 'orange', 'apple', 'banana', 'berry', 'grape',
      'mango', 'pineapple', 'potato', 'sweet potato', 'mushroom',
      'celery', 'asparagus', 'zucchini', 'corn', 'peas', 'bean',
      'cilantro', 'parsley', 'basil', 'mint', 'ginger', 'cabbage',
    ];
    return produceKeywords.any((k) => name.contains(k));
  }

  // ─── ESTIMATED PREP TIME ──────────────────────────────────────────
  Widget _buildEstimatedPrepTime() {
    final mealPlanAsync = ref.watch(mealPlanForDateProvider(_selectedDate));

    return mealPlanAsync.when(
      data: (mealPlan) {
        if (mealPlan == null || mealPlan.recipeIds.isEmpty) {
          return const SizedBox.shrink();
        }
        final estimatedMinutes = mealPlan.recipeIds.length * 20;
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(
                'Estimated Prep Time',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '$estimatedMinutes Minutes Total',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.onBackground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  // ─── FAB ───────────────────────────────────────────────────────────
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

  // ─── BOTTOM NAV ───────────────────────────────────────────────────
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

  // ─── HELPERS ──────────────────────────────────────────────────────
  Future<List<GroceryItem>> _generateGroceryList(
    MealPlan mealPlan,
    List<String> currentIngredientIds,
  ) async {
    final service = ref.read(mealPlanServiceProvider);
    return await service.generateGroceryList(
      recipeIds: mealPlan.recipeIds,
      currentIngredientIds: currentIngredientIds,
    );
  }

  void _removeRecipeFromPlan(MealPlan mealPlan, String recipeId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final updatedIds =
        mealPlan.recipeIds.where((id) => id != recipeId).toList();
    final service = ref.read(mealPlanServiceProvider);

    if (updatedIds.isEmpty) {
      await service.deleteMealPlan(mealPlan.id);
    } else {
      await service.createOrUpdateMealPlan(
        userId: user.uid,
        planDate: mealPlan.planDate,
        recipeIds: updatedIds,
        existingMealPlanId: mealPlan.id,
      );
    }
  }

  void _showSelectRecipesDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SelectRecipesBottomSheet(
        selectedDate: _selectedDate,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// MEAL CARD WIDGET
// ═══════════════════════════════════════════════════════════════════════
class _MealCard extends StatelessWidget {
  final Recipe recipe;
  final String mealType;
  final VoidCallback onRemove;

  const _MealCard({
    required this.recipe,
    required this.mealType,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Food Image
          RecipeImage(
            imageUrl: recipe.imageUrl,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            iconSize: 28,
          ),
          const SizedBox(width: 14),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealType.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  recipe.name,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.onBackground,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.ingredientIds.length * 5}m',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.local_fire_department,
                      size: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.ingredientIds.length * 50} kcal',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Remove button
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// INGREDIENT CATEGORY ROW
// ═══════════════════════════════════════════════════════════════════════
class _IngredientCategoryRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String items;

  const _IngredientCategoryRow({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.surfaceContainerHigh,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.onBackground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  items,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// NAV BAR ITEM
// ═══════════════════════════════════════════════════════════════════════
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
                color:
                    isActive ? AppColors.primary : AppColors.onSurfaceVariant,
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

// ═══════════════════════════════════════════════════════════════════════
// SELECT RECIPES BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════
class _SelectRecipesBottomSheet extends ConsumerStatefulWidget {
  final DateTime selectedDate;

  const _SelectRecipesBottomSheet({required this.selectedDate});

  @override
  ConsumerState<_SelectRecipesBottomSheet> createState() =>
      _SelectRecipesBottomSheetState();
}

class _SelectRecipesBottomSheetState
    extends ConsumerState<_SelectRecipesBottomSheet> {
  final Set<String> _selectedRecipeIds = {};
  bool _isSaving = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(userRecipesProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Handle bar
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Recipes',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.onBackground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE, MMMM d').format(
                          widget.selectedDate,
                        ),
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
          const SizedBox(height: 20),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search your recipes...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.outline),
                prefixIcon: const Icon(Icons.search, color: AppColors.outline),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: const Icon(Icons.close, color: AppColors.outline, size: 18))
                    : null,
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: AppColors.surfaceContainerHigh)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Recipe list
          Expanded(
            child: recipesAsync.when(
              data: (recipes) {
                final filteredRecipes = recipes.where((r) => 
                  r.name.toLowerCase().contains(_searchQuery.toLowerCase())
                ).toList();

                if (filteredRecipes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isEmpty ? Icons.restaurant_menu : Icons.search_off,
                          size: 56,
                          color: AppColors.onSurfaceVariant.withAlpha(80),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty ? 'No recipes yet' : 'No recipes found',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty 
                            ? 'Create a recipe first to plan meals'
                            : 'Try searching for something else',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: filteredRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = filteredRecipes[index];
                    final isSelected =
                        _selectedRecipeIds.contains(recipe.id);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedRecipeIds.remove(recipe.id);
                          } else {
                            _selectedRecipeIds.add(recipe.id);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withAlpha(12)
                              : AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surfaceContainerHigh,
                            width: isSelected ? 1.5 : 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            RecipeImage(
                              imageUrl: recipe.imageUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              iconSize: 22,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe.name,
                                    style:
                                        AppTextStyles.labelLarge.copyWith(
                                      color: AppColors.onBackground,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${recipe.ingredientIds.length} ingredients',
                                    style:
                                        AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.outlineVariant,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),

          // Bottom action
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_selectedRecipeIds.isEmpty || _isSaving)
                      ? null
                      : () async {
                          setState(() => _isSaving = true);
                          try {
                            final user = ref.read(currentUserProvider);
                            if (user == null) {
                              setState(() => _isSaving = false);
                              return;
                            }

                            final service = ref.read(mealPlanServiceProvider);

                            // Using the provider instead of direct service call to avoid potentially broken Firestore query (e.g. missing index)
                            // and leverage already-watched data
                            final existingPlan = ref
                                .read(
                                  mealPlanForDateProvider(widget.selectedDate),
                                )
                                .value;

                            final allRecipeIds = <String>{
                              ...?existingPlan?.recipeIds,
                              ..._selectedRecipeIds,
                            }.toList();

                            await service.createOrUpdateMealPlan(
                              userId: user.uid,
                              planDate: widget.selectedDate,
                              recipeIds: allRecipeIds,
                              existingMealPlanId: existingPlan?.id,
                            );

                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error adding recipes: $e'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isSaving = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    disabledBackgroundColor:
                        AppColors.primary.withAlpha(100),
                    disabledForegroundColor:
                        AppColors.onPrimary.withAlpha(100),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _selectedRecipeIds.isEmpty
                              ? 'Select recipes to plan'
                              : 'Add ${_selectedRecipeIds.length} Recipe${_selectedRecipeIds.length != 1 ? "s" : ""} to Plan',
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
