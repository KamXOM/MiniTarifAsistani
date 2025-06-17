import 'package:flutter/material.dart';
import 'package:recipe_app/models/shopping_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ShoppingListProvider extends ChangeNotifier {
  List<ShoppingItem> _items = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  List<ShoppingItem> get items => _items;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedItems = prefs.getString('shoppingList');
      
      if (savedItems != null) {
        final List<dynamic> decodedItems = jsonDecode(savedItems);
        _items = decodedItems.map((item) => ShoppingItem.fromJson(item)).toList();
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to load shopping list. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = jsonEncode(_items.map((item) => item.toJson()).toList());
      await prefs.setString('shoppingList', itemsJson);
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to save shopping list. Please try again.';
      notifyListeners();
    }
  }

  Future<void> addItem(String name, String quantity) async {
    if (name.isEmpty) {
      _hasError = true;
      _errorMessage = 'Item name cannot be empty.';
      notifyListeners();
      return;
    }

    final newItem = ShoppingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      quantity: quantity.isNotEmpty ? quantity : '1',
      completed: false,
    );

    _items.add(newItem);
    await _saveItems();
    notifyListeners();
  }

  Future<void> updateItem(ShoppingItem updatedItem) async {
    final index = _items.indexWhere((item) => item.id == updatedItem.id);
    
    if (index != -1) {
      _items[index] = updatedItem;
      await _saveItems();
      notifyListeners();
    }
  }

  Future<void> toggleItemCompletion(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    
    if (index != -1) {
      _items[index].completed = !_items[index].completed;
      await _saveItems();
      notifyListeners();
    }
  }

  Future<void> deleteItem(String id) async {
    _items.removeWhere((item) => item.id == id);
    await _saveItems();
    notifyListeners();
  }

  Future<void> clearCompletedItems() async {
    _items.removeWhere((item) => item.completed);
    await _saveItems();
    notifyListeners();
  }
}