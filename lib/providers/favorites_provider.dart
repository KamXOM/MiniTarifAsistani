import 'package:flutter/material.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/services/recipe_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  final RecipeService _recipeService = RecipeService();
  
  List<Recipe> _favorites = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  List<Recipe> get favorites => _favorites;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  Future<void> loadFavorites() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final favoriteIds = await _loadFavoriteIds();
      
      if (favoriteIds.isNotEmpty) {
        _favorites = await _recipeService.getFavoriteRecipes(favoriteIds);
      } else {
        _favorites = [];
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to load favorites. Please try again later.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<String>> _loadFavoriteIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedFavorites = prefs.getStringList('favoriteRecipes');
      return savedFavorites ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveFavoriteIds(List<String> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favoriteRecipes', ids);
    } catch (e) {
      // Handle error
    }
  }

  Future<bool> isFavorite(String id) async {
    final favoriteIds = await _loadFavoriteIds();
    return favoriteIds.contains(id);
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    try {
      final favoriteIds = await _loadFavoriteIds();
      
      if (favoriteIds.contains(recipe.id)) {
        favoriteIds.remove(recipe.id);
        _favorites.removeWhere((fav) => fav.id == recipe.id);
      } else {
        favoriteIds.add(recipe.id);
        _favorites.add(recipe);
      }
      
      await _saveFavoriteIds(favoriteIds);
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to update favorites. Please try again later.';
      notifyListeners();
    }
  }

  Future<void> removeFromFavorites(String recipeId) async {
    try {
      final favoriteIds = await _loadFavoriteIds();
      favoriteIds.remove(recipeId);
      await _saveFavoriteIds(favoriteIds);
      
      _favorites.removeWhere((recipe) => recipe.id == recipeId);
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to remove from favorites. Please try again later.';
      notifyListeners();
    }
  }
}