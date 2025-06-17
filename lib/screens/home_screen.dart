import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/providers/recipe_provider.dart';
import 'package:recipe_app/widgets/recipe_card.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_app/models/recipe.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();


  @override
  void initState() {
    super.initState();


    // ilk tarifleri fetchleme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recipeProvider = context.read<RecipeProvider>();
      _searchController.text = recipeProvider.searchQuery;
      recipeProvider.fetchRecipes(refresh: true);
    });
  }

  @override
  void dispose() {

    _searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recipe App',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () => context.push('/favorites'),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => context.push('/shopping-list'),
          ),
        ],
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, recipeProvider, child) {
          final filteredRecipes = recipeProvider.filteredRecipes;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search recipes...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    suffixIcon: recipeProvider.searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        recipeProvider.setSearchQuery('');
                        recipeProvider.fetchRecipes(refresh: true); // Yeniden tüm tarifleri çek
                      },
                    )
                        : null,
                  ),
                  onChanged: (value) {
                    recipeProvider.setSearchQuery(value);
                  },
                  onSubmitted: (value) {

                  },
                ),
              ),
              Expanded(
                child: _buildRecipeList(recipeProvider, filteredRecipes),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecipeList(RecipeProvider recipeProvider, List<Recipe> filteredRecipes) {
    if (recipeProvider.isLoading && filteredRecipes.isEmpty) {
      // Yükleniyor ve henüz hiç tarif yoksa böyle
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (recipeProvider.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              recipeProvider.errorMessage,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                recipeProvider.fetchRecipes(refresh: true); // Tekrar Dene butonunda fetchRecipes'i çağır
              },
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (filteredRecipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No recipes found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              recipeProvider.searchQuery.isNotEmpty
                  ? 'Try different search terms'
                  : 'Check your internet connection or try again later.',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            if (recipeProvider.searchQuery.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  _searchController.clear();
                  recipeProvider.setSearchQuery('');
                  recipeProvider.fetchRecipes(refresh: true);
                },
                child: const Text('Tüm Tarifleri Göster'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => recipeProvider.fetchRecipes(refresh: true), // Refresh yapıldığında fetchRecipes'i çağırmak için
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: filteredRecipes.length,
          itemBuilder: (context, index) {

            final recipe = filteredRecipes[index];
            return RecipeCard(
              recipe: recipe,
              onTap: () => context.push('/recipe/${recipe.id}'),
            );
          },
        ),
      ),
    );
  }
}