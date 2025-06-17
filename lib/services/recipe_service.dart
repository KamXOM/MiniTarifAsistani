import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:recipe_app/models/recipe.dart';

class RecipeService {
  // TheMealDB API base URL
  final String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // ID'ye göre tek bir tarif getirme
  Future<Recipe?> fetchRecipeById(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/lookup.php?i=$id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          return Recipe.fromJson(data['meals'][0]);
        } else {
          return null; // Tarif bulunamadı demek
        }
      } else {
        throw Exception('Failed to load recipe: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching recipe by ID: $e');
      throw Exception('Failed to load recipe. Please check your network connection.');
    }
  }

  // Kategoriye göre tarifleri getir (kategoribazlı)
  Future<List<Recipe>> fetchRecipesByCategory(String categoryName) async {
    List<Recipe> recipes = [];
    try {
      final response = await http.get(Uri.parse('$_baseUrl/filter.php?c=$categoryName'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          for (var mealJson in data['meals']) {
            // Sadece liste için  Recipe objesi
            recipes.add(Recipe(
              id: mealJson['idMeal'],
              title: mealJson['strMeal'],
              image: mealJson['strMealThumb'],
              ingredients: [],
              instructions: null,
            ));
          }
        }
      } else {
        throw Exception('Failed to load recipes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching recipes by category: $e');
      throw Exception('Failed to load recipes. Please check your network connection.');
    }
    return recipes;
  }

  // Arama sorgusu
  Future<List<Recipe>> searchRecipes(String query) async {
    List<Recipe> recipes = [];
    try {
      final response = await http.get(Uri.parse('$_baseUrl/search.php?s=$query'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          recipes = List<Recipe>.from(data['meals'].map((json) => Recipe(
            id: json['idMeal'],
            title: json['strMeal'],
            image: json['strMealThumb'],
            ingredients: [],
            instructions: null,
          )));
        }
      } else {
        throw Exception('Failed to search recipes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching recipes: $e');
      throw Exception('Failed to search recipes. Please check your network connection.');
    }
    return recipes;
  }

  Future<List<Recipe>> getFavoriteRecipes(List<String> ids) async {
    List<Recipe> favoriteRecipes = [];
    for (String id in ids) {
      try {
        final recipe = await fetchRecipeById(id);
        if (recipe != null) {
          favoriteRecipes.add(recipe);
        }
      } catch (e) {
        print('Error fetching favorite recipe with ID $id: $e');
      }
    }
    return favoriteRecipes;
  }

}