import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../providers/ingredient_provider.dart';
import '../../providers/pantry_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/ingredient_model.dart';
import '../widgets/settings_bottom_sheet.dart';

class IngredientsScreen extends ConsumerStatefulWidget {
  const IngredientsScreen({super.key});

  @override
  ConsumerState<IngredientsScreen> createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends ConsumerState<IngredientsScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allIngredientsAsync = ref.watch(allIngredientsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(),
      body: user == null
          ? const Center(child: Text('Please log in'))
          : allIngredientsAsync.when(
              data: (ings) => _buildBody(ings),
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
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
                Text('Ankon-Chef', style: AppTextStyles.h3.copyWith(color: AppColors.primary, fontWeight: FontWeight.w900)),
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
    );
  }

  Widget _buildBody(List<Ingredient> allIngredients) {
    // Filter by search
    final filtered = _searchQuery.isEmpty
        ? allIngredients
        : allIngredients.where((i) => i.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    // Group by category
    final Map<String, List<Ingredient>> categorized = {};
    for (final ing in filtered) {
      categorized.putIfAbsent(ing.category, () => []).add(ing);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 100,
        bottom: 120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ingredients', style: AppTextStyles.h1.copyWith(color: AppColors.onBackground, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('Source the finest seasonal produce and pantry staples for your next culinary masterpiece.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Search bar ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search ingredients...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.outline),
                prefixIcon: const Icon(Icons.search, color: AppColors.outline),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () { _searchController.clear(); setState(() => _searchQuery = ''); },
                        child: const Icon(Icons.close, color: AppColors.outline, size: 18))
                    : null,
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: AppColors.surfaceContainerHigh)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Summer Harvest promo banner ─────────────────────────
          if (_searchQuery.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildPromoBanner(),
            ),

          if (_searchQuery.isEmpty) const SizedBox(height: 28),

          // ── Category sections ───────────────────────────────────
          if (filtered.isEmpty)
            _buildEmptyState()
          else
            ...categorized.entries.map((entry) {
              return _CategorySection(
                category: entry.key,
                ingredients: entry.value,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF2E7D32).withAlpha(60), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Decorative circles
          Positioned(right: -20, top: -20,
            child: Container(width: 120, height: 120, decoration: BoxDecoration(color: Colors.white.withAlpha(15), shape: BoxShape.circle))),
          Positioned(right: 40, bottom: -30,
            child: Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.white.withAlpha(10), shape: BoxShape.circle))),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withAlpha(40), borderRadius: BorderRadius.circular(12)),
                  child: Text('SUMMER HARVEST', style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 1.2)),
                ),
                const SizedBox(height: 8),
                Text('Peak season produce\ndelivered fresh from\nlocal artisanal farms.',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, height: 1.4)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.local_shipping, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text('Fast Farm-to-Table Delivery', style: AppTextStyles.labelSmall.copyWith(color: Colors.white.withAlpha(220), fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(color: AppColors.primary.withAlpha(15), shape: BoxShape.circle),
            child: const Icon(Icons.kitchen, size: 44, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text('No ingredients found', style: AppTextStyles.h3.copyWith(color: AppColors.onBackground)),
          const SizedBox(height: 8),
          Text('Try a different search term', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(230),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 24, offset: const Offset(0, -4))],
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
                  _NavItem(icon: Icons.home, label: 'Home', isActive: false, onTap: () => context.go('/home')),
                  _NavItem(icon: Icons.restaurant_menu, label: 'Recipes', isActive: false, onTap: () => context.go('/recipes')),
                  _NavItem(icon: Icons.inventory_2, label: 'Pantry', isActive: false, onTap: () => context.go('/pantry')),
                  _NavItem(icon: Icons.calendar_month, label: 'Planner', isActive: false, onTap: () => context.go('/meal-plan')),
                  _NavItem(icon: Icons.kitchen, label: 'Ingredients', isActive: true, onTap: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// CATEGORY SECTION
// ═══════════════════════════════════════════════════════════
class _CategorySection extends ConsumerWidget {
  final String category;
  final List<Ingredient> ingredients;

  const _CategorySection({required this.category, required this.ingredients});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
          child: Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(color: AppColors.primary.withAlpha(20), shape: BoxShape.circle),
                child: Icon(_categoryIcon(category), color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 10),
              Text(category, style: AppTextStyles.h3.copyWith(color: AppColors.onBackground)),
            ],
          ),
        ),
        ...ingredients.map((ing) => _IngredientCard(ingredient: ing)),
        const SizedBox(height: 24),
      ],
    );
  }

  IconData _categoryIcon(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('vegetable') || c.contains('produce')) return Icons.eco;
    if (c.contains('protein') || c.contains('meat') || c.contains('fish')) return Icons.egg_alt;
    if (c.contains('dairy')) return Icons.water_drop;
    if (c.contains('grain') || c.contains('bread')) return Icons.grain;
    if (c.contains('spice') || c.contains('herb')) return Icons.spa;
    if (c.contains('fruit')) return Icons.apple;
    return Icons.kitchen;
  }
}

// ═══════════════════════════════════════════════════════════
// INGREDIENT CARD
// ═══════════════════════════════════════════════════════════
class _IngredientCard extends ConsumerStatefulWidget {
  final Ingredient ingredient;
  const _IngredientCard({required this.ingredient});

  @override
  ConsumerState<_IngredientCard> createState() => _IngredientCardState();
}

class _IngredientCardState extends ConsumerState<_IngredientCard> {
  bool _adding = false;
  final _amountController = TextEditingController();
  final _unitController = TextEditingController(text: 'pcs');

  @override
  void dispose() {
    _amountController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: _categoryColor(widget.ingredient.category).withAlpha(30),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Placeholder icon (no real image in model)
                Center(
                  child: Icon(
                    _categoryIcon(widget.ingredient.category),
                    size: 56,
                    color: _categoryColor(widget.ingredient.category).withAlpha(120),
                  ),
                ),
                // Gradient overlay at bottom
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    height: 50,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [AppColors.surfaceContainerLowest, Colors.transparent],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(widget.ingredient.name,
                          style: AppTextStyles.labelLarge.copyWith(color: AppColors.onBackground, fontWeight: FontWeight.w700)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _categoryColor(widget.ingredient.category).withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(widget.ingredient.category,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: _categoryColor(widget.ingredient.category),
                            fontWeight: FontWeight.w700, fontSize: 10)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outlineVariant.withAlpha(60)),
                        ),
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: 'Amount',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            isDense: true,
                          ),
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outlineVariant.withAlpha(60)),
                        ),
                        child: TextField(
                          controller: _unitController,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: 'Unit',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            isDense: true,
                          ),
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: ElevatedButton(
                        onPressed: (_adding || _amountController.text.trim().isEmpty || _unitController.text.trim().isEmpty) ? null : _quickAddToPantry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.secondary.withAlpha(100),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: _adding
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text('+ Pantry', style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Future<void> _quickAddToPantry() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _adding = true);

    final svc = ref.read(pantryServiceProvider);
    await svc.addPantryItem(
      userId: user.uid,
      ingredientId: widget.ingredient.id,
      amount: amount,
      unit: _unitController.text.trim(),
      expiryDate: null,
    );

    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _adding = false;
        _amountController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.ingredient.name} added to pantry!'),
          backgroundColor: AppColors.secondary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Color _categoryColor(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('vegetable') || c.contains('produce')) return const Color(0xFF2E7D32);
    if (c.contains('protein') || c.contains('meat') || c.contains('fish')) return AppColors.primary;
    if (c.contains('dairy')) return const Color(0xFF1565C0);
    if (c.contains('grain') || c.contains('bread')) return const Color(0xFF795548);
    if (c.contains('spice') || c.contains('herb')) return const Color(0xFF6A1B9A);
    if (c.contains('fruit')) return const Color(0xFFE65100);
    return AppColors.secondary;
  }

  IconData _categoryIcon(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('vegetable') || c.contains('produce')) return Icons.eco;
    if (c.contains('protein') || c.contains('meat') || c.contains('fish')) return Icons.egg_alt;
    if (c.contains('dairy')) return Icons.water_drop;
    if (c.contains('grain') || c.contains('bread')) return Icons.grain;
    if (c.contains('spice') || c.contains('herb')) return Icons.spa;
    if (c.contains('fruit')) return Icons.apple;
    return Icons.kitchen;
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(color: isActive ? AppColors.onPrimary : Colors.transparent, borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? AppColors.primary : AppColors.onSurfaceVariant),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.labelSmall.copyWith(
              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
