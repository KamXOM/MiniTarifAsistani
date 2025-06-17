class ShoppingItem {
  final String id;
  final String name;
  final String quantity;
  bool completed;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.quantity,
    this.completed = false,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      completed: json['completed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'completed': completed,
    };
  }

  ShoppingItem copyWith({
    String? id,
    String? name,
    String? quantity,
    bool? completed,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      completed: completed ?? this.completed,
    );
  }
}