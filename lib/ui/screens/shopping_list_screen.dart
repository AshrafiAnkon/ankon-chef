import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/meal_plan_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ingredient_provider.dart';
import '../../providers/meal_plan_provider.dart';
import '../../providers/pantry_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F3), // Soft Cream from HTML
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withAlpha(240),
            border: Border(
              bottom: BorderSide(
                color: AppColors.outlineVariant.withAlpha(100),
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.primary,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  const Icon(Icons.menu_book, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Shopping List',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: AppColors.onSurfaceVariant,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.more_vert,
                      color: AppColors.onSurfaceVariant,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _buildShoppingListBody(context, ref),
    );
  }

  Widget _buildShoppingListBody(BuildContext context, WidgetRef ref) {
    final pantryAsync = ref.watch(currentIngredientIdsProvider);
    final mealPlansAsync = ref.watch(mealPlansProvider);

    return mealPlansAsync.when(
      data: (mealPlans) {
        return pantryAsync.when(
          data: (pantryIds) {
            if (mealPlans.isEmpty) {
              return _buildEmptyShoppingList();
            }

            // Get the most recent or today's meal plan
            final now = DateTime.now();
            final todayNormalized = DateTime(now.year, now.month, now.day);
            MealPlan? mealPlan;
            try {
              mealPlan = mealPlans.firstWhere(
                (mp) =>
                    DateTime(
                      mp.planDate.year,
                      mp.planDate.month,
                      mp.planDate.day,
                    ) ==
                    todayNormalized,
              );
            } catch (_) {
              if (mealPlans.isNotEmpty) {
                mealPlan = mealPlans.first;
              }
            }

            final currentMealPlan = mealPlan;
            if (currentMealPlan == null) {
              return _buildEmptyShoppingList();
            }

            return FutureBuilder<List<GroceryItem>>(
              future: ref
                  .read(mealPlanServiceProvider)
                  .generateGroceryList(
                    recipeIds: currentMealPlan.recipeIds,
                    currentIngredientIds: pantryIds,
                    shoppingListExclusions: currentMealPlan.shoppingListExclusions,
                  ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                final items = snapshot.data!;
                final itemsToBuy = items.where((g) => !g.isAvailable).toList();

                if (itemsToBuy.isEmpty) {
                  return _buildEmptyShoppingList();
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 80,
                    left: 16,
                    right: 16,
                    bottom: 120,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'YOUR COLLECTION',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Ingredients to Buy',
                                    style: AppTextStyles.h2.copyWith(
                                      color: AppColors.onBackground,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _ItemsCountBadge(count: itemsToBuy.length),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: () => _addAllToPantry(context, ref, itemsToBuy),
                                  icon: const Icon(Icons.inventory, size: 18),
                                  label: const Text('Add All to Pantry'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    textStyle: AppTextStyles.labelMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...itemsToBuy.map((item) {
                        return _IngredientCard(
                          item: item,
                          onAddToPantry: (amount, unit) => _addToPantry(context, ref, item.ingredientId, amount, unit),
                          onDelete: () => _deleteFromShoppingList(context, ref, currentMealPlan, item.ingredientId),
                        );
                      }),
                      const SizedBox(height: 48),
                      const _QuoteCard(),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (e, s) => _buildEmptyShoppingList(),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (e, s) => _buildEmptyShoppingList(),
    );
  }

  Future<void> _deleteFromShoppingList(BuildContext context, WidgetRef ref, MealPlan mealPlan, String ingredientId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item?'),
        content: const Text('Are you sure you want to remove this item from your shopping list?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final newExclusions = [...mealPlan.shoppingListExclusions, ingredientId];
      await ref.read(mealPlanServiceProvider).updateShoppingListExclusions(mealPlan.id, newExclusions);
      // Riverpod will automatically refresh mealPlansProvider, which triggers a rebuild
    }
  }

  Future<void> _addToPantry(BuildContext context, WidgetRef ref, String ingredientId, double amount, String unit) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      await ref.read(pantryServiceProvider).addPantryItem(
            userId: user.uid,
            ingredientId: ingredientId,
            amount: amount,
            unit: unit,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to pantry')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _addAllToPantry(BuildContext context, WidgetRef ref, List<GroceryItem> items) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final service = ref.read(pantryServiceProvider);
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      for (final item in items) {
        await service.addPantryItem(
          userId: user.uid,
          ingredientId: item.ingredientId,
          amount: item.amount,
          unit: item.unit,
        );
      }
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All items added to pantry')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildEmptyShoppingList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: 100,
        left: 16,
        right: 16,
        bottom: 120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YOUR COLLECTION',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ingredients to Buy',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.onBackground,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const _ItemsCountBadge(count: 0),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Center(
            child: Text(
              'No items to buy',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemsCountBadge extends StatelessWidget {
  const _ItemsCountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryContainer),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '$count',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Items',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withAlpha(120),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryContainer),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.tips_and_updates,
            color: AppColors.primary,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '"A organized kitchen is the heart of a happy home. Don\'t forget to check your pantry for spices before you head out!"',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientCard extends StatefulWidget {
  const _IngredientCard({
    required this.item,
    required this.onAddToPantry,
    required this.onDelete,
  });

  final GroceryItem item;
  final void Function(double amount, String unit) onAddToPantry;
  final VoidCallback onDelete;

  @override
  State<_IngredientCard> createState() => _IngredientCardState();
}

class _IngredientCardState extends State<_IngredientCard> {
  late TextEditingController _amountController;
  late TextEditingController _unitController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.item.amount == widget.item.amount.toInt()
          ? widget.item.amount.toInt().toString()
          : widget.item.amount.toString(),
    );
    _unitController = TextEditingController(text: widget.item.unit);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withAlpha(100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withAlpha(100),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_grocery_store, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.ingredientName,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'From meal plan',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (!_isEditing) ...[
                GestureDetector(
                  onTap: () => setState(() => _isEditing = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.outlineVariant.withAlpha(100),
                      ),
                    ),
                    child: Text(
                      '${_amountController.text} ${_unitController.text}',
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onBackground,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_box_outlined, color: AppColors.primary),
                  onPressed: () {
                    final amount = double.tryParse(_amountController.text);
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid amount')),
                      );
                      return;
                    }
                    widget.onAddToPantry(amount, _unitController.text);
                  },
                  tooltip: 'Add to Pantry',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 24,
                ),
              ] else ...[
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    final amount = double.tryParse(_amountController.text);
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid amount')),
                      );
                      return;
                    }
                    setState(() => _isEditing = false);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 24,
                ),
              ],
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.outline),
                onPressed: widget.onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 24,
              ),
            ],
          ),
          if (_isEditing) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(width: 64),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _unitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
