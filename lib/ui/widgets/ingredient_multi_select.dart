import 'package:flutter/material.dart';
import '../../models/ingredient_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class IngredientMultiSelect extends StatefulWidget {
  final List<Ingredient> allIngredients;
  final List<String> selectedIngredientIds;
  final ValueChanged<List<String>> onSelectionChanged;
  final Future<String?> Function(String name) onAddIngredient;

  const IngredientMultiSelect({
    super.key,
    required this.allIngredients,
    required this.selectedIngredientIds,
    required this.onSelectionChanged,
    required this.onAddIngredient,
  });

  @override
  State<IngredientMultiSelect> createState() => _IngredientMultiSelectState();
}

class _IngredientMultiSelectState extends State<IngredientMultiSelect> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _searchQuery = '';
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) {
        if (_focusNode.hasFocus) {
          setState(() {
            _isMenuOpen = true;
          });
        } else {
          // Delay closing to allow tap event processing
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted && !_focusNode.hasFocus) {
              setState(() {
                _isMenuOpen = false;
              });
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<Ingredient> get _filteredIngredients {
    if (_searchQuery.isEmpty) {
      return widget.allIngredients;
    }
    final query = _searchQuery.toLowerCase();
    return widget.allIngredients.where((ingredient) {
      return ingredient.name.toLowerCase().contains(query);
    }).toList();
  }

  void _toggleSelection(String id) {
    final newSelection = List<String>.from(widget.selectedIngredientIds);
    if (newSelection.contains(id)) {
      newSelection.remove(id);
    } else {
      newSelection.add(id);
    }
    widget.onSelectionChanged(newSelection);
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    _focusNode.requestFocus();
  }

  Future<void> _addNewIngredient() async {
    final name = _searchQuery.trim();
    if (name.isEmpty) return;

    final shouldAdd = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Ingredient', style: AppTextStyles.h3),
        content: Text('Do you want to add "$name" to the master list?', style: AppTextStyles.bodyMedium),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: AppTextStyles.labelLarge.copyWith(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (shouldAdd == true) {
      final newId = await widget.onAddIngredient(name);
      if (newId != null) {
        _toggleSelection(newId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIngredients = widget.allIngredients
        .where((i) => widget.selectedIngredientIds.contains(i.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected Ingredients Chips
        if (selectedIngredients.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedIngredients.map((ingredient) {
                return Chip(
                  label: Text(ingredient.name),
                  onDeleted: () => _toggleSelection(ingredient.id),
                  backgroundColor: AppColors.secondary.withAlpha(20),
                  labelStyle: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.secondary,
                  ),
                  deleteIconColor: AppColors.secondary,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                );
              }).toList(),
            ),
          ),

        // Search Input
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search or add ingredients...',
              prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.onSurfaceVariant),
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant.withAlpha(150)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        // Dropdown Results
        if (_isMenuOpen || _searchQuery.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant.withAlpha(40)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount:
                    _filteredIngredients.isEmpty && _searchQuery.isNotEmpty
                    ? 1
                    : _filteredIngredients.length,
                itemBuilder: (context, index) {
                  if (_filteredIngredients.isEmpty && _searchQuery.isNotEmpty) {
                    return ListTile(
                      leading: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                      title: Text('Add "$_searchQuery"', style: AppTextStyles.labelLarge),
                      subtitle: Text('New ingredient discovered', style: AppTextStyles.bodySmall),
                      onTap: _addNewIngredient,
                    );
                  }

                  final ingredient = _filteredIngredients[index];
                  final isSelected = widget.selectedIngredientIds.contains(ingredient.id);
                  return ListTile(
                    dense: true,
                    title: Text(ingredient.name, style: AppTextStyles.bodyMedium),
                    subtitle: Text(ingredient.category, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppColors.secondary, size: 20)
                        : null,
                    onTap: () => _toggleSelection(ingredient.id),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}
