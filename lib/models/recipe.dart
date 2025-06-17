class Recipe {
  final String id;
  final String title;
  final String image;

  final String? category;
  final String? area;
  final String? youtubeLink;
  final List<Ingredient> ingredients;
  final String? instructions;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    this.category,
    this.area,
    this.youtubeLink,
    required this.ingredients,
    this.instructions,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<Ingredient> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredientName = json['strIngredient$i'];
      final ingredientMeasure = json['strMeasure$i'];

      if (ingredientName != null && ingredientName.isNotEmpty) {
        ingredients.add(Ingredient(
          name: ingredientName,
          quantity: ingredientMeasure ?? '',
          unit: '',
        ));
      }
    }

    return Recipe(
      id: json['idMeal'], //idMeal olarak geliyor
      title: json['strMeal'], //strMeal olarak geliyor
      image: json['strMealThumb'], //strMealThumb olarak geliyor
      category: json['strCategory'], //strCategory  "      "
      area: json['strArea'], //strArea "  "
      youtubeLink: json['strYoutube'], // TheMealDB'den strYoutube
      ingredients: ingredients,
      instructions: json['strInstructions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'category': category,
      'area': area,
      'youtubeLink': youtubeLink,
      'ingredients': ingredients.map((x) => x.toJson()).toList(),
      'instructions': instructions,
    };
  }
}

class Ingredient {
  final String name;
  final String quantity;
  final String unit;

  Ingredient({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] ?? '',
      quantity: json['quantity']?.toString() ?? '',
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }
}