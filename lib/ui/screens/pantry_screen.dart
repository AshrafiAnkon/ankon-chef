import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../providers/pantry_provider.dart';
import '../../providers/ingredient_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/pantry_item_model.dart';
import '../../models/ingredient_model.dart';
import '../widgets/searchable_ingredient_selector.dart';
import '../widgets/settings_bottom_sheet.dart';

class PantryScreen extends ConsumerStatefulWidget {
  const PantryScreen({super.key});

  @override
  ConsumerState<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends ConsumerState<PantryScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pantryItemsAsync = ref.watch(pantryItemsProvider);
    final allIngredientsAsync = ref.watch(allIngredientsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(),
      body: allIngredientsAsync.when(
        data: (allIngredients) {
          final ingredientMap = {for (var i in allIngredients) i.id: i};
          return pantryItemsAsync.when(
            data: (items) => _buildBody(items, ingredientMap),
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            error: (e, s) => Center(child: Text('Error: $e')),
          );
        },
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

  Widget _buildBody(List<PantryItem> items, Map<String, Ingredient> ingredientMap) {
    final filtered = _searchQuery.isEmpty
        ? items
        : items.where((i) {
            final name = (ingredientMap[i.ingredientId]?.name ?? '').toLowerCase();
            return name.contains(_searchQuery.toLowerCase());
          }).toList();

    final expiringItems = items.where((i) => i.isExpiringSoon || i.isExpired).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 100,
        bottom: 120,
        left: 24,
        right: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────
          Text('My Pantry', style: AppTextStyles.h1.copyWith(color: AppColors.onBackground, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Inventory management for your kitchen staples.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 20),

          // ── Search ────────────────────────────────────────────
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search an ingredient...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.outline),
              prefixIcon: const Icon(Icons.search, color: AppColors.outline),
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: AppColors.surfaceContainerHigh)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
          const SizedBox(height: 16),

          // ── Add Item button ────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddPantryItemSheet(context),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text('Add Item', style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Items list ────────────────────────────────────────
          if (filtered.isEmpty)
            _buildEmptyState()
          else
            ...filtered.map((item) {
              final ingredient = ingredientMap[item.ingredientId];
              return _PantryItemTile(
                item: item,
                ingredientName: ingredient?.name ?? 'Unknown',
                category: ingredient?.category ?? '',
                onDelete: () async {
                  final svc = ref.read(pantryServiceProvider);
                  await svc.deletePantryItem(item.id);
                },
                onEdit: () => _showEditSheet(context, item),
              );
            }),

          // ── Running low alert ──────────────────────────────────
          if (expiringItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildRunningLowCard(expiringItems, ingredientMap),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(color: AppColors.primary.withAlpha(15), shape: BoxShape.circle),
            child: const Icon(Icons.inventory_2, size: 44, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text('No pantry items yet', style: AppTextStyles.h3.copyWith(color: AppColors.onBackground)),
          const SizedBox(height: 8),
          Text('Tap Add Item to start tracking', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildRunningLowCard(List<PantryItem> items, Map<String, Ingredient> map) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withAlpha(60)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.error.withAlpha(30), shape: BoxShape.circle),
            child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Running Low on ${items.length} item${items.length != 1 ? "s" : ""}',
                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.error, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  '${items.map((i) => map[i.ingredientId]?.name ?? '').where((n) => n.isNotEmpty).join(', ')} are expiring soon or have expired.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _showAddPantryItemSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.error.withAlpha(20), borderRadius: BorderRadius.circular(20)),
                    child: Text('Add to Pantry', style: AppTextStyles.labelMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPantryItemSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddPantryItemSheet(),
    );
  }

  void _showEditSheet(BuildContext context, PantryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditPantryItemSheet(item: item),
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
                  _NavItem(icon: Icons.inventory_2, label: 'Pantry', isActive: true, onTap: () {}),
                  _NavItem(icon: Icons.calendar_month, label: 'Planner', isActive: false, onTap: () => context.go('/meal-plan')),
                  _NavItem(icon: Icons.kitchen, label: 'Ingredients', isActive: false, onTap: () => context.go('/ingredients')),
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
// PANTRY ITEM TILE
// ═══════════════════════════════════════════════════════════
class _PantryItemTile extends StatelessWidget {
  final PantryItem item;
  final String ingredientName;
  final String category;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _PantryItemTile({
    required this.item,
    required this.ingredientName,
    required this.category,
    required this.onDelete,
    required this.onEdit,
  });

  Color get _statusColor {
    if (item.isExpired) return AppColors.error;
    if (item.isExpiringSoon) return AppColors.warning;
    return AppColors.secondary;
  }

  String get _statusLabel {
    if (item.isExpired) return 'EXPIRED';
    if (item.isExpiringSoon) return 'EXPIRING SOON';
    return 'FRESH';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon circle
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _statusColor.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(_categoryIcon(category), color: _statusColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(ingredientName,
                              style: AppTextStyles.labelLarge.copyWith(color: AppColors.onBackground, fontWeight: FontWeight.w700)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _statusColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(_statusLabel,
                              style: AppTextStyles.labelSmall.copyWith(color: _statusColor, fontWeight: FontWeight.w700, fontSize: 9, letterSpacing: 0.5)),
                        ),
                      ],
                    ),
                    if (category.isNotEmpty)
                      Text(category, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Edit
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  width: 32, height: 32,
                  decoration: const BoxDecoration(color: AppColors.surfaceContainerHigh, shape: BoxShape.circle),
                  child: const Icon(Icons.edit_outlined, size: 16, color: AppColors.onSurfaceVariant),
                ),
              ),
              const SizedBox(width: 8),
              // Delete
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: AppColors.error.withAlpha(20), shape: BoxShape.circle),
                  child: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Quantity label
          Text('QUANTITY', style: AppTextStyles.labelSmall.copyWith(color: AppColors.outline, fontSize: 9, letterSpacing: 1.0)),
          const SizedBox(height: 4),
          Row(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${item.amount % 1 == 0 ? item.amount.toInt() : item.amount}',
                      style: AppTextStyles.h3.copyWith(color: AppColors.onBackground, fontWeight: FontWeight.w800),
                    ),
                    TextSpan(
                      text: ' ${item.unit}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (item.expiryDate != null) ...[
                const Spacer(),
                Text('Exp: ${DateFormat('MMM d').format(item.expiryDate!)}',
                    style: AppTextStyles.bodySmall.copyWith(color: _statusColor)),
              ],
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _stockLevel,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  double get _stockLevel {
    // Show rough stock level based on expiry proximity
    if (item.isExpired) return 0.1;
    if (item.isExpiringSoon) return 0.3;
    return 0.7;
  }

  IconData _categoryIcon(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('produce') || c.contains('vegetable') || c.contains('fruit')) return Icons.eco;
    if (c.contains('protein') || c.contains('meat') || c.contains('fish')) return Icons.egg_alt;
    if (c.contains('dairy')) return Icons.water_drop;
    if (c.contains('grain') || c.contains('bread') || c.contains('flour')) return Icons.grain;
    if (c.contains('spice') || c.contains('herb')) return Icons.spa;
    return Icons.inventory_2;
  }
}

// ═══════════════════════════════════════════════════════════
// ADD PANTRY ITEM BOTTOM SHEET
// ═══════════════════════════════════════════════════════════
class _AddPantryItemSheet extends ConsumerStatefulWidget {
  const _AddPantryItemSheet();

  @override
  ConsumerState<_AddPantryItemSheet> createState() => _AddPantryItemSheetState();
}

class _AddPantryItemSheetState extends ConsumerState<_AddPantryItemSheet> {
  String? _selectedIngredientId;
  final _amountController = TextEditingController();
  final _unitController = TextEditingController(text: 'kg');
  DateTime? _expiryDate;

  @override
  void dispose() {
    _amountController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ingredientsAsync = ref.watch(allIngredientsProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(child: Text('Add Pantry Item', style: AppTextStyles.h3.copyWith(color: AppColors.onBackground))),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(width: 36, height: 36, decoration: const BoxDecoration(color: AppColors.surfaceContainerHigh, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 18, color: AppColors.onSurfaceVariant)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Ingredient', style: AppTextStyles.labelLarge.copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  ingredientsAsync.when(
                    data: (ings) => SearchableIngredientSelector(
                      allIngredients: ings,
                      selectedIngredientId: _selectedIngredientId,
                      onSelected: (i) => setState(() => _selectedIngredientId = i.id),
                    ),
                    loading: () => const CircularProgressIndicator(color: AppColors.primary),
                    error: (e, s) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Amount', style: AppTextStyles.labelLarge.copyWith(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'e.g., 2.5',
                                filled: true,
                                fillColor: AppColors.surfaceContainerLowest,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.surfaceContainerHigh)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Unit', style: AppTextStyles.labelLarge.copyWith(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _unitController,
                              decoration: InputDecoration(
                                hintText: 'kg',
                                filled: true,
                                fillColor: AppColors.surfaceContainerLowest,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.surfaceContainerHigh)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Expiry Date (Optional)', style: AppTextStyles.labelLarge.copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        builder: (ctx, child) => Theme(
                          data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary, onPrimary: AppColors.onPrimary)),
                          child: child!,
                        ),
                      );
                      if (d != null) setState(() => _expiryDate = d);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.surfaceContainerHigh),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            _expiryDate != null ? DateFormat('MMM d, y').format(_expiryDate!) : 'Set expiry date',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _expiryDate != null ? AppColors.onBackground : AppColors.outline),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_selectedIngredientId == null || _amountController.text.isEmpty) ? null : _addItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withAlpha(100),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    elevation: 0,
                  ),
                  child: Text('Add to Pantry', style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addItem() async {
    final user = ref.read(currentUserProvider);
    if (user == null || _selectedIngredientId == null) return;
    final svc = ref.read(pantryServiceProvider);
    await svc.addPantryItem(
      userId: user.uid,
      ingredientId: _selectedIngredientId!,
      amount: double.tryParse(_amountController.text) ?? 0,
      unit: _unitController.text,
      expiryDate: _expiryDate,
    );
    if (mounted) Navigator.pop(context);
  }
}

// ═══════════════════════════════════════════════════════════
// EDIT PANTRY ITEM BOTTOM SHEET
// ═══════════════════════════════════════════════════════════
class _EditPantryItemSheet extends ConsumerStatefulWidget {
  final PantryItem item;
  const _EditPantryItemSheet({required this.item});

  @override
  ConsumerState<_EditPantryItemSheet> createState() => _EditPantryItemSheetState();
}

class _EditPantryItemSheetState extends ConsumerState<_EditPantryItemSheet> {
  late TextEditingController _amountController;
  late TextEditingController _unitController;
  DateTime? _expiryDate;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.item.amount.toString());
    _unitController = TextEditingController(text: widget.item.unit);
    _expiryDate = widget.item.expiryDate;
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
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(child: Text('Edit Item', style: AppTextStyles.h3.copyWith(color: AppColors.onBackground))),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(width: 36, height: 36, decoration: const BoxDecoration(color: AppColors.surfaceContainerHigh, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 18, color: AppColors.onSurfaceVariant)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Amount', style: AppTextStyles.labelLarge.copyWith(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                filled: true, fillColor: AppColors.surfaceContainerLowest,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.surfaceContainerHigh)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Unit', style: AppTextStyles.labelLarge.copyWith(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _unitController,
                              decoration: InputDecoration(
                                filled: true, fillColor: AppColors.surfaceContainerLowest,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.surfaceContainerHigh)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        builder: (ctx, child) => Theme(
                          data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary, onPrimary: AppColors.onPrimary)),
                          child: child!,
                        ),
                      );
                      if (d != null) setState(() => _expiryDate = d);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.surfaceContainerHigh)),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Text(_expiryDate != null ? 'Expires: ${DateFormat('MMM d, y').format(_expiryDate!)}' : 'Set expiry date',
                              style: AppTextStyles.bodyMedium.copyWith(color: _expiryDate != null ? AppColors.onBackground : AppColors.outline)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)), elevation: 0,
                  ),
                  child: Text('Save Changes', style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveEdit() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;
    final svc = ref.read(pantryServiceProvider);
    await svc.updatePantryItem(pantryItemId: widget.item.id, amount: amount, unit: _unitController.text, expiryDate: _expiryDate);
    if (mounted) Navigator.pop(context);
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
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: isActive ? AppColors.primary : AppColors.onSurfaceVariant, fontWeight: isActive ? FontWeight.bold : FontWeight.w600, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
