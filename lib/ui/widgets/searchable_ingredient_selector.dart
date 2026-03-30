import 'package:flutter/material.dart';
import '../../models/ingredient_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SearchableIngredientSelector extends StatefulWidget {
  final List<Ingredient> allIngredients;
  final String? selectedIngredientId;
  final ValueChanged<Ingredient> onSelected;

  const SearchableIngredientSelector({
    super.key,
    required this.allIngredients,
    this.selectedIngredientId,
    required this.onSelected,
  });

  @override
  State<SearchableIngredientSelector> createState() =>
      _SearchableIngredientSelectorState();
}

class _SearchableIngredientSelectorState
    extends State<SearchableIngredientSelector> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _categories {
    final categories = widget.allIngredients
        .map((e) => e.category)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  List<Ingredient> get _filteredIngredients {
    final query = _searchQuery.toLowerCase().trim();
    final queryWords = query.split(' ').where((w) => w.isNotEmpty).toList();

    return widget.allIngredients.where((ingredient) {
      final matchesCategory =
          _selectedCategory == null || ingredient.category == _selectedCategory;
      if (!matchesCategory) return false;

      if (queryWords.isEmpty) return true;

      final name = ingredient.name.toLowerCase();
      return queryWords.every((word) => name.contains(word));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Category Filter
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('All', null),
                ..._categories.map(
                  (category) => _buildCategoryChip(category, category),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Search Box
        TextField(
          controller: _searchController,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Search ingredients...',
            prefixIcon: const Icon(
              Icons.search,
              size: 20,
              color: AppColors.textTertiary,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: AppColors.surface,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),

        const SizedBox(height: 12),

        // Ingredient List
        Container(
          height:
              250, // Fixed height instead of constraints to be more stable on Web
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _filteredIngredients.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No ingredients found',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ListView.builder(
                    key: const PageStorageKey('ingredient_list'),
                    shrinkWrap: true,
                    itemCount: _filteredIngredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = _filteredIngredients[index];
                      final isSelected =
                          ingredient.id == widget.selectedIngredientId;

                      return Column(
                        key: ValueKey(ingredient.id),
                        children: [
                          ListTile(
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            title: Text(
                              ingredient.name,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              ingredient.category,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: AppColors.primary,
                                    size: 18,
                                  )
                                : null,
                            selected: isSelected,
                            selectedTileColor: AppColors.primary.withValues(
                              alpha: 0.05,
                            ),
                            onTap: () => widget.onSelected(ingredient),
                          ),
                          if (index < _filteredIngredients.length - 1)
                            const Divider(height: 1, indent: 16, endIndent: 16),
                        ],
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        checkmarkColor: AppColors.primary,
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: AppColors.surface,
        showCheckmark: false,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 0.5,
          ),
        ),
      ),
    );
  }
}
