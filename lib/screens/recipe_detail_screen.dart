import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/providers/favorites_provider.dart';
import 'package:recipe_app/providers/recipe_provider.dart';
import 'package:recipe_app/providers/shopping_list_provider.dart';
import 'package:share_plus/share_plus.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String id;

  const RecipeDetailScreen({
    super.key,
    required this.id,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Recipe? _recipe;
  bool _isFavorite = false;
  bool _loading = true;
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollOffset = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _loadRecipe();
    _checkFavoriteStatus();
    _scrollController.addListener(_updateScrollOffset);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollOffset);
    _scrollController.dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  void _updateScrollOffset() {
    _scrollOffset.value = _scrollController.offset;
  }

  Future<void> _loadRecipe() async {
    setState(() {
      _loading = true;
    });

    final recipe = await context.read<RecipeProvider>().fetchRecipeById(widget.id);

    if (mounted) {
      setState(() {
        _recipe = recipe;

        _loading = false;
      });
    }
  }

  Future<void> _checkFavoriteStatus() async {
    final isFavorite = await context.read<FavoritesProvider>().isFavorite(widget.id);

    if (mounted) {
      setState(() {
        _isFavorite = isFavorite;
      });
    }
  }

  void _toggleFavorite() {
    if (_recipe != null) {
      context.read<FavoritesProvider>().toggleFavorite(_recipe!);
      setState(() {
        _isFavorite = !_isFavorite;
      });
    }
  }

  void _shareRecipe() {
    if (_recipe != null) {
      Share.share(

        'Check out this recipe for ${_recipe!.title}! Find more details at ${_recipe!.youtubeLink ?? 'TheMealDB.com'}',
        subject: _recipe!.title,
      );
    }
  }

  void _addIngredientsToShoppingList() {
    if (_recipe == null) return;

    final shoppingListProvider = context.read<ShoppingListProvider>();

    for (var ingredient in _recipe!.ingredients) {

      final quantityText = '${ingredient.quantity} ${ingredient.unit}'.trim();


      if (ingredient.name.isNotEmpty) {
        shoppingListProvider.addItem(ingredient.name, quantityText);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ingredients added to shopping list'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_recipe == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Recipe Not Found'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Recipe not found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'The recipe you\'re looking for doesn\'t exist.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Ana İçerik
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Recipe image with parallax effect
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: CachedNetworkImage(
                    imageUrl: _recipe!.image,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.share,
                        color: Colors.white,
                      ),
                      onPressed: _shareRecipe,
                    ),
                  ),
                ],
              ),

              // Tarif içeriği
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _recipe!.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          if (_recipe!.category != null && _recipe!.category!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.category, size: 20, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Kategori: ${_recipe!.category}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          if (_recipe!.area != null && _recipe!.area!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on, size: 20, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Bölge: ${_recipe!.area}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),

                        ],
                      ),
                    ),


                    // Malzemeler
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Ingredients',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.add_shopping_cart),
                                label: const Text('Add All'),
                                onPressed: _addIngredientsToShoppingList,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Sadece adı olan malzemeleri listeleme
                          ..._recipe!.ingredients.where((i) => i.name.isNotEmpty).map(
                                (ingredient) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${ingredient.quantity} ${ingredient.unit}'.trim(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(ingredient.name),
                                  ),
                                ],
                              ),
                            ),
                          ).toList(),
                        ],
                      ),
                    ),

                    // Yapılış talimatları
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Instructions',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_recipe!.instructions != null && _recipe!.instructions!.isNotEmpty)
                            ..._recipe!.instructions!
                                .split('\r\n')
                                .where((line) => line.trim().isNotEmpty)
                                .map((line) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                line.trim(),
                                style: const TextStyle(
                                  height: 1.5,
                                ),
                              ),
                            ))
                                .toList(),
                          // Add bottom padding
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}