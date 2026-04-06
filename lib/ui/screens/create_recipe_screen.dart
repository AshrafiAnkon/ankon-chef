import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/ingredient_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/ingredient_model.dart';
import '../../models/recipe_model.dart';
import '../widgets/ingredient_multi_select.dart';
import '../widgets/recipe_image.dart';
import '../../models/unit_constants.dart';

class CreateRecipeScreen extends ConsumerStatefulWidget {
  final String? editRecipeId;
  const CreateRecipeScreen({super.key, this.editRecipeId});

  @override
  ConsumerState<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends ConsumerState<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _tagController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _imageSearchController = TextEditingController();
  final _youtubeController = TextEditingController();

  final Map<String, TextEditingController> _quantityAmountControllers = {};
  final Map<String, String> _quantityUnits = {};
  final List<String> _selectedIngredientIds = [];
  final List<String> _tags = [];

  Uint8List? _imageBytes;
  String? _webImageUrl;
  bool _isLoading = false;
  bool _isEditing = false;

  // Web search state
  final ValueNotifier<bool> _isSearchingNotifier = ValueNotifier(false);
  final ValueNotifier<List<Map<String, dynamic>>> _searchResultsNotifier =
      ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    if (widget.editRecipeId != null) {
      _isEditing = true;
      // We'll load the recipe in didChangeDependencies or use a postFrameCallback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadRecipeForEditing();
      });
    }
  }

  void _loadRecipeForEditing() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final recipe = await ref
          .read(recipeServiceProvider)
          .getRecipeById(widget.editRecipeId!);
      if (recipe != null) {
        setState(() {
          _nameController.text = recipe.name;
          _instructionsController.text = recipe.instructions;
          _prepTimeController.text = recipe.prepTime?.toString() ?? '';
          _cookTimeController.text = recipe.cookTime?.toString() ?? '';
          _caloriesController.text = recipe.calories?.toString() ?? '';
          _webImageUrl = recipe.imageUrl;
          _youtubeController.text = recipe.youtubeUrl ?? '';
          _tags.clear();
          _tags.addAll(recipe.tags);
          _selectedIngredientIds.clear();
          _selectedIngredientIds.addAll(recipe.ingredientIds);

          if (recipe.ingredientQuantities != null) {
            recipe.ingredientQuantities!.forEach((id, qty) {
              _quantityAmountControllers[id] = TextEditingController(
                text: qty.amount.toString(),
              );
              _quantityUnits[id] = qty.unit;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading recipe: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    _tagController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _caloriesController.dispose();
    _imageSearchController.dispose();
    _youtubeController.dispose();
    _isSearchingNotifier.dispose();
    _searchResultsNotifier.dispose();
    for (var controller in _quantityAmountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _webImageUrl = null; // Clear web image if local picked
      });
    }
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields correctly.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedIngredientIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one ingredient')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        throw Exception('User is not logged in. Please log in and try again.');
      }

      final recipeService = ref.read(recipeServiceProvider);

      final Map<String, RecipeQuantity> ingredientQuantities = {};
      for (var id in _selectedIngredientIds) {
        ingredientQuantities[id] = RecipeQuantity(
          amount:
              double.tryParse(_quantityAmountControllers[id]?.text ?? '') ??
              0.0,
          unit: _quantityUnits[id] ?? 'pcs',
        );
      }

      if (_isEditing) {
        await recipeService.updateRecipe(
          recipeId: widget.editRecipeId!,
          name: _nameController.text,
          ingredientIds: _selectedIngredientIds,
          instructions: _instructionsController.text,
          tags: _tags,
          prepTime: int.tryParse(_prepTimeController.text),
          cookTime: int.tryParse(_cookTimeController.text),
          calories: int.tryParse(_caloriesController.text),
          ingredientQuantities: ingredientQuantities,
          imageBytes: _imageBytes,
          imageUrl: _webImageUrl,
          youtubeUrl: _youtubeController.text.trim().isEmpty
              ? null
              : _youtubeController.text.trim(),
        );
      } else {
        await recipeService
            .createRecipe(
              userId: user.uid,
              name: _nameController.text,
              ingredientIds: _selectedIngredientIds,
              instructions: _instructionsController.text,
              tags: _tags,
              prepTime: int.tryParse(_prepTimeController.text),
              cookTime: int.tryParse(_cookTimeController.text),
              calories: int.tryParse(_caloriesController.text),
              ingredientQuantities: ingredientQuantities,
              imageBytes: _imageBytes,
              imageUrl: _webImageUrl,
              youtubeUrl: _youtubeController.text.trim().isEmpty
                  ? null
                  : _youtubeController.text.trim(),
            )
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () => throw Exception(
                'The service is taking too long to respond. Please check your internet connection.',
              ),
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Recipe updated successfully!'
                  : 'Recipe created successfully!',
            ),
            backgroundColor: AppColors.secondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (_isEditing) {
          context.pop(); // Go back to details
        } else {
          context.pushReplacement('/recipes');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _sanitizeImageUrl(String url) {
    var sanitized = url.trim();
    if (sanitized.isNotEmpty && !sanitized.startsWith('http')) {
      sanitized = 'https://$sanitized';
    }
    return sanitized;
  }

  // Helper to parse string to RecipeQuantity
  RecipeQuantity _parseMeasure(String measure) {
    if (measure.isEmpty) return const RecipeQuantity(amount: 0, unit: 'pcs');

    measure = measure.trim();
    // Regex to split amount and unit even if there's no space (e.g. "150g" -> "150", "g")
    final match = RegExp(r'^([\d.,/]+)\s*([a-zA-Z\s]*)$').firstMatch(measure);

    if (match != null) {
      final amountStr = match.group(1);
      final unitStr = match.group(2)?.trim();

      double? parsedAmount;
      if (amountStr != null) {
        if (amountStr.contains('/')) {
          final parts = amountStr.split('/');
          if (parts.length == 2) {
            final num = double.tryParse(parts[0]);
            final den = double.tryParse(parts[1]);
            if (num != null && den != null && den != 0) {
              parsedAmount = num / den;
            }
          }
        } else {
          parsedAmount = double.tryParse(amountStr);
        }
      }

      if (parsedAmount != null) {
        return RecipeQuantity(
          amount: parsedAmount,
          unit: (unitStr != null && unitStr.isNotEmpty) ? unitStr : 'pcs',
        );
      }
    }

    final parts = measure.split(' ');
    if (parts.isEmpty) return const RecipeQuantity(amount: 0, unit: 'pcs');

    final parsedAmount = double.tryParse(parts.first);
    if (parsedAmount != null) {
      if (parts.length > 1) {
        return RecipeQuantity(
          amount: parsedAmount,
          unit: parts.sublist(1).join(' ').trim(),
        );
      }
      return RecipeQuantity(amount: parsedAmount, unit: 'pcs');
    }

    return RecipeQuantity(amount: 0, unit: measure);
  }

  Future<void> _importRecipe(
    Map<String, dynamic> meal, {
    bool imageOnly = false,
  }) async {
    if (imageOnly) {
      setState(() {
        _webImageUrl = _sanitizeImageUrl(meal['strMealThumb'] ?? '');
        _imageBytes = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final name = meal['strMeal'] ?? '';
      final instructions = meal['strInstructions'] ?? '';
      final thumb = meal['strMealThumb'] ?? '';
      final youtube = meal['strYoutube'] ?? '';

      _nameController.text = name;
      _instructionsController.text = instructions;
      _webImageUrl = _sanitizeImageUrl(thumb);
      _imageBytes = null;
      _youtubeController.text = youtube;

      _tags.clear();
      if (meal['strCategory'] != null &&
          meal['strCategory'].toString().isNotEmpty) {
        _tags.add(meal['strCategory']);
      }
      if (meal['strArea'] != null && meal['strArea'].toString().isNotEmpty) {
        if (!_tags.contains(meal['strArea'])) _tags.add(meal['strArea']);
      }
      if (meal['strTags'] != null) {
        final separated = meal['strTags'].toString().split(',');
        for (var t in separated) {
          final tagTrim = t.trim();
          if (tagTrim.isNotEmpty && !_tags.contains(tagTrim)) {
            _tags.add(tagTrim);
          }
        }
      }

      // Ingredients
      _selectedIngredientIds.clear();
      _quantityAmountControllers.clear();
      _quantityUnits.clear();

      final ingredientService = ref.read(ingredientServiceProvider);

      // Fetch all existing ingredients to do smart matching
      final allIngredients = await ingredientService.getAllIngredientsFuture();

      // Parse raw ingredients, deduplicate (case-insensitive) and combine measures
      final Map<String, String> normalizedToRawName = {};
      final Map<String, String> normalizedToMeasure = {};

      for (int i = 1; i <= 20; i++) {
        final ingredientName = meal['strIngredient$i'] as String?;
        final measure = meal['strMeasure$i'] as String?;

        if (ingredientName != null && ingredientName.trim().isNotEmpty) {
          final rawName = ingredientName.trim();
          final key = rawName.toLowerCase();

          if (!normalizedToRawName.containsKey(key)) {
            // Capitalize first letter for a cleaner look
            final formattedName = rawName.length > 1
                ? rawName[0].toUpperCase() + rawName.substring(1).toLowerCase()
                : rawName.toUpperCase();
            normalizedToRawName[key] = formattedName;
          }

          final existingMeasure = normalizedToMeasure[key] ?? '';
          final newMeasure = measure?.trim() ?? '';

          if (newMeasure.isNotEmpty) {
            if (existingMeasure.isNotEmpty &&
                !existingMeasure.contains(newMeasure)) {
              normalizedToMeasure[key] = '$existingMeasure + $newMeasure';
            } else if (existingMeasure.isEmpty) {
              normalizedToMeasure[key] = newMeasure;
            }
          }
        }
      }

      // Process ingredients sequentially to avoid rate limiting
      for (final key in normalizedToRawName.keys) {
        final nameToUse = normalizedToRawName[key]!;
        final finalMeasure = normalizedToMeasure[key] ?? '';

        try {
          // Smart match for predefined formats like "Butter (Makhan | মাখন)"
          String? matchedId;
          final searchLower = nameToUse.toLowerCase();

          for (final ing in allIngredients) {
            final ingNameLower = ing.name.toLowerCase();
            if (ingNameLower == searchLower ||
                ingNameLower.startsWith('$searchLower (') ||
                ingNameLower.startsWith('$searchLower ')) {
              matchedId = ing.id;
              break;
            }
          }

          // Get or create the ingredient
          final id =
              matchedId ??
              await ingredientService
                  .getOrCreateIngredient(nameToUse, 'Imported')
                  .timeout(const Duration(seconds: 10));

          if (mounted) {
            setState(() {
              final parsedQty = _parseMeasure(finalMeasure);

              if (!_selectedIngredientIds.contains(id)) {
                _selectedIngredientIds.add(id);
                _quantityAmountControllers[id] = TextEditingController(
                  text: parsedQty.amount > 0 ? parsedQty.amount.toString() : '',
                );
                _quantityUnits[id] = parsedQty.unit;
              } else {
                final currentAmountText =
                    _quantityAmountControllers[id]?.text ?? '';
                if (currentAmountText.isEmpty && parsedQty.amount > 0) {
                  _quantityAmountControllers[id]?.text = parsedQty.amount
                      .toString();
                } else if (parsedQty.amount > 0) {
                  final currentAmount = double.tryParse(currentAmountText) ?? 0;
                  _quantityAmountControllers[id]?.text =
                      (currentAmount + parsedQty.amount).toString();
                }

                final currentUnit = _quantityUnits[id] ?? '';
                if (currentUnit.isEmpty || currentUnit == 'pcs') {
                  _quantityUnits[id] = parsedQty.unit;
                } else if (parsedQty.unit.isNotEmpty &&
                    parsedQty.unit != 'pcs' &&
                    !currentUnit.contains(parsedQty.unit)) {
                  _quantityUnits[id] = '$currentUnit + ${parsedQty.unit}';
                }
              }
            });
          }
        } catch (e) {
          debugPrint('Error importing ingredient $nameToUse: $e');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _searchRecipes(String query) async {
    if (query.isEmpty) return;

    _isSearchingNotifier.value = true;
    _searchResultsNotifier.value = [];

    try {
      final url = Uri.parse(
        'https://www.themealdb.com/api/json/v1/1/search.php?s=${Uri.encodeComponent(query)}',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List?;

        final List<Map<String, dynamic>> results = [];
        if (meals != null) {
          for (var meal in meals) {
            results.add(Map<String, dynamic>.from(meal));
          }
        }

        // Fallback search if no results
        if (results.isEmpty && query.toLowerCase().split(' ').length > 1) {
          final firstWord = query.split(' ')[0];
          final urlFallback = Uri.parse(
            'https://www.themealdb.com/api/json/v1/1/search.php?s=${Uri.encodeComponent(firstWord)}',
          );
          final responseFallback = await http
              .get(urlFallback)
              .timeout(const Duration(seconds: 15));
          if (responseFallback.statusCode == 200) {
            final dataFallback = json.decode(responseFallback.body);
            final mealsFallback = dataFallback['meals'] as List?;
            if (mealsFallback != null) {
              for (var meal in mealsFallback) {
                results.add(Map<String, dynamic>.from(meal));
              }
            }
          }
        }

        // Ensure UI updates reliably
        _searchResultsNotifier.value = results;
      }
    } catch (e) {
      debugPrint('MealDB search error: $e');
    } finally {
      // Guaranteed to turn off spinning state no matter what
      _isSearchingNotifier.value = false;
    }
  }

  void _showRecipeSearchPopup({bool imageOnly = false}) {
    _imageSearchController.text = _nameController.text;

    // Clear state or initiate search initially
    if (_imageSearchController.text.isNotEmpty) {
      _searchRecipes(_imageSearchController.text);
    } else {
      _isSearchingNotifier.value = false;
      _searchResultsNotifier.value = [];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _isSearchingNotifier,
            _searchResultsNotifier,
          ]),
          builder: (context, _) {
            final isSearching = _isSearchingNotifier.value;
            final searchResults = _searchResultsNotifier.value;

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        imageOnly ? 'Find Recipe Image' : 'Find Recipes',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surfaceContainerHigh,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(
                        color: AppColors.outlineVariant.withAlpha(40),
                      ),
                    ),
                    child: TextField(
                      controller: _imageSearchController,
                      decoration: InputDecoration(
                        hintText: 'Search for recipes on MealDB...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.primary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        suffixIcon: isSearching
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: () {
                                  _searchRecipes(_imageSearchController.text);
                                },
                              ),
                      ),
                      onSubmitted: (value) {
                        _searchRecipes(value);
                      },
                    ),
                  ),

                  const SizedBox(height: 32),
                  Flexible(
                    child: isSearching
                        ? const Center(child: CircularProgressIndicator())
                        : searchResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.image_search,
                                  size: 48,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Type something above to search',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: searchResults.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final meal = searchResults[index];
                              return GestureDetector(
                                onTap: () {
                                  _importRecipe(meal, imageOnly: imageOnly);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: AppColors.outlineVariant.withAlpha(
                                        20,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(5),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: const BoxDecoration(
                                          color: AppColors.surfaceContainerLow,
                                        ),
                                        child: RecipeImage(
                                          imageUrl: meal['strMealThumb'] ?? '',
                                          fit: BoxFit.cover,
                                          iconSize: 32,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                (meal['strCategory'] ?? '')
                                                    .toString()
                                                    .toUpperCase(),
                                                style: AppTextStyles.labelSmall
                                                    .copyWith(
                                                      color:
                                                          AppColors.secondary,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      letterSpacing: 1.0,
                                                      fontSize: 10,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                meal['strMeal'] ??
                                                    'Unknown Recipe',
                                                style: AppTextStyles.labelLarge
                                                    .copyWith(
                                                      color: AppColors
                                                          .onBackground,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Text(
                                                    imageOnly
                                                        ? 'Select Image'
                                                        : 'Import Now',
                                                    style: AppTextStyles
                                                        .labelSmall
                                                        .copyWith(
                                                          color:
                                                              AppColors.primary,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Icon(
                                                    imageOnly
                                                        ? Icons
                                                              .add_a_photo_rounded
                                                        : Icons
                                                              .download_rounded,
                                                    size: 14,
                                                    color: AppColors.primary,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ingredientsAsync = ref.watch(allIngredientsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/recipes'),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: _showRecipeSearchPopup,
                tooltip: 'Search Recipes on MealDB',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _isEditing ? 'Edit Recipe' : 'Create Recipe',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section
                    GestureDetector(
                      onTap: _isLoading ? null : _pickImage,
                      child: Container(
                        height: 240,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: AppColors.outlineVariant.withAlpha(40),
                          ),
                        ),
                        child: _imageBytes != null || _webImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: Stack(
                                  children: [
                                    if (_imageBytes != null)
                                      Image.memory(
                                        _imageBytes!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      )
                                    else if (_webImageUrl != null)
                                      RecipeImage(
                                        imageUrl: _webImageUrl!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    Positioned(
                                      top: 16,
                                      right: 16,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withAlpha(100),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: const BoxDecoration(
                                      color: AppColors.surfaceContainerLowest,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 32,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Add Recipe Image',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildSmallImageAction(
                                        onPressed: _pickImage,
                                        icon: Icons.photo_library,
                                        label: 'Gallery',
                                      ),
                                      const SizedBox(width: 8),
                                      _buildSmallImageAction(
                                        onPressed: () => _showRecipeSearchPopup(
                                          imageOnly: true,
                                        ),
                                        icon: Icons.image_search,
                                        label: 'Search Image',
                                      ),
                                      const SizedBox(width: 8),
                                      _buildSmallImageAction(
                                        onPressed: () => _showRecipeSearchPopup(
                                          imageOnly: false,
                                        ),
                                        icon: Icons.language,
                                        label: 'Full Import',
                                        isPrimary: true,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Recipe Name
                    _buildInputField(
                      controller: _nameController,
                      label: 'Recipe Name',
                      hint: 'e.g., Artisanal Margherita Pizza',
                      icon: Icons.restaurant,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a recipe name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Time & Stats Section
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatInput(
                                  controller: _prepTimeController,
                                  label: 'Prep Time',
                                  hint: '15',
                                  unit: 'min',
                                  icon: Icons.timer_outlined,
                                  isMandatory: true,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _buildStatInput(
                                  controller: _cookTimeController,
                                  label: 'Cook Time',
                                  hint: '20',
                                  unit: 'min',
                                  icon: Icons.local_fire_department_outlined,
                                  isMandatory: true,
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            height: 48,
                            thickness: 1,
                            color: AppColors.onSurfaceVariant.withAlpha(20),
                            indent: 0,
                            endIndent: 0,
                          ),
                          _buildStatInput(
                            controller: _caloriesController,
                            label: 'Estimated Calories',
                            hint: '450',
                            unit: 'kcal',
                            icon: Icons.bolt_outlined,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Ingredients Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ingredients', style: AppTextStyles.h3),
                        if (_selectedIngredientIds.isNotEmpty)
                          Text(
                            '${_selectedIngredientIds.length} items',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_selectedIngredientIds.isNotEmpty) ...[
                      ingredientsAsync.when(
                        data: (ingredients) {
                          return Column(
                            children: _selectedIngredientIds.map((id) {
                              final ingredient = ingredients.firstWhere(
                                (i) => i.id == id,
                              );
                              return _buildIngredientQuantityRow(ingredient);
                            }).toList(),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (e, s) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    ingredientsAsync.when(
                      data: (ingredients) =>
                          _buildIngredientSelector(ingredients),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) =>
                          Text('Error loading ingredients: $error'),
                    ),

                    const SizedBox(height: 40),

                    if (_selectedIngredientIds.length > 2)
                      _buildNutritionCard(),

                    const SizedBox(height: 40),

                    // Instructions
                    Text('Instructions', style: AppTextStyles.h3),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.outlineVariant.withAlpha(40),
                        ),
                      ),
                      child: TextFormField(
                        controller: _instructionsController,
                        maxLines: 8,
                        decoration: const InputDecoration(
                          hintText:
                              'Describe the steps to culinary perfection...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(20),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter instructions';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Tags
                    Text('Tags & Categories', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _tagController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Italian, Vegan, Dinner',
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: AppColors.primary,
                          ),
                          onPressed: () {
                            if (_tagController.text.isNotEmpty) {
                              setState(() {
                                _tags.add(_tagController.text.trim());
                                _tagController.clear();
                              });
                            }
                          },
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.outlineVariant.withAlpha(80),
                          ),
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            _tags.add(value.trim());
                            _tagController.clear();
                          });
                        }
                      },
                    ),

                    if (_tags.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            backgroundColor: AppColors.surfaceContainerHigh,
                            labelStyle: AppTextStyles.labelMedium,
                            onDeleted: () {
                              setState(() {
                                _tags.remove(tag);
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // YouTube URL
                    _buildInputField(
                      controller: _youtubeController,
                      label: 'YouTube Tutorial (Optional)',
                      hint: 'https://youtube.com/watch?v=...',
                      icon: Icons.play_circle_outline,
                      keyboardType: TextInputType.url,
                    ),

                    const SizedBox(height: 64),

                    // Action Button
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primaryContainer,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(60),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveRecipe,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                _isEditing
                                    ? 'Update Creation'
                                    : 'Save To My Recipes',
                                style: AppTextStyles.h4.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String unit,
    required IconData icon,
    bool isMandatory = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                validator: isMandatory
                    ? (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value.trim()) == null) {
                          return 'Invalid';
                        }
                        return null;
                      }
                    : null,
                style: AppTextStyles.h3.copyWith(height: 1.1),
                decoration: InputDecoration(
                  hintText: hint,
                  border: InputBorder.none,
                  hintStyle: AppTextStyles.h3.copyWith(
                    color: AppColors.onSurfaceVariant.withAlpha(50),
                  ),
                  isDense: true,
                  errorStyle: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                unit,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIngredientQuantityRow(Ingredient ingredient) {
    if (!_quantityAmountControllers.containsKey(ingredient.id)) {
      _quantityAmountControllers[ingredient.id] = TextEditingController();
    }
    if (!_quantityUnits.containsKey(ingredient.id)) {
      _quantityUnits[ingredient.id] = 'pcs'; // default unit
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withAlpha(30)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.drag_indicator,
            color: AppColors.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: _quantityAmountControllers[ingredient.id],
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                hintText: 'e.g., 4',
                border: InputBorder.none,
                isDense: true,
              ),
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              initialValue:
                  UnitConstants.units.contains(_quantityUnits[ingredient.id])
                  ? _quantityUnits[ingredient.id]
                  : null,
              items: UnitConstants.units
                  .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _quantityUnits[ingredient.id] = val;
                  });
                }
              },
              decoration: const InputDecoration(
                hintText: 'Unit',
                border: InputBorder.none,
                isDense: true,
              ),
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              ingredient.name,
              style: AppTextStyles.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              size: 20,
              color: AppColors.onSurfaceVariant,
            ),
            onPressed: () {
              setState(() {
                _selectedIngredientIds.remove(ingredient.id);
                _quantityAmountControllers.remove(ingredient.id)?.dispose();
                _quantityUnits.remove(ingredient.id);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.outlineVariant.withAlpha(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estimated Nutrition', style: AppTextStyles.labelLarge),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNutritionStat('Protein', '24g', 0.6),
              _buildNutritionStat('Carbs', '42g', 0.4),
              _buildNutritionStat('Fats', '12g', 0.2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionStat(String label, String value, double percent) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: percent,
                backgroundColor: AppColors.surfaceContainerHigh,
                color: AppColors.primary,
                strokeWidth: 4,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outlineVariant.withAlpha(40)),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(
                icon,
                color: AppColors.primary.withAlpha(180),
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientSelector(List<Ingredient> ingredients) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withAlpha(40)),
      ),
      padding: const EdgeInsets.all(8),
      child: IngredientMultiSelect(
        allIngredients: ingredients,
        selectedIngredientIds: _selectedIngredientIds,
        onSelectionChanged: (ids) {
          setState(() {
            _selectedIngredientIds.clear();
            _selectedIngredientIds.addAll(ids);
          });
        },
        onAddIngredient: (name) async {
          final ingredientService = ref.read(ingredientServiceProvider);
          try {
            return await ingredientService.addIngredient(name, 'Custom');
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error adding ingredient: $e')),
              );
            }
            return null;
          }
        },
      ),
    );
  }

  Widget _buildSmallImageAction({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    bool isPrimary = false,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 90),
      child: isPrimary
          ? ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 16),
              label: Text(label, style: const TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 16),
              label: Text(label, style: const TextStyle(fontSize: 11)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: AppColors.primary.withAlpha(100)),
                foregroundColor: AppColors.primary,
              ),
            ),
    );
  }
}
