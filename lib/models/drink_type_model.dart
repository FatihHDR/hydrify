import 'package:flutter/material.dart';

class DrinkTypeModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final double multiplier; // Water content multiplier (e.g., 1.0 for water, 0.8 for juice)
  final bool isDefault;
  final DateTime? createdAt;

  DrinkTypeModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.multiplier = 1.0,
    this.isDefault = false,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint,
      'color': color.value,
      'multiplier': multiplier,
      'isDefault': isDefault ? 1 : 0,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  factory DrinkTypeModel.fromMap(Map<String, dynamic> map) {
    return DrinkTypeModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: IconData(map['icon'] ?? Icons.local_drink.codePoint, fontFamily: 'MaterialIcons'),
      color: Color(map['color'] ?? Colors.blue.value),
      multiplier: (map['multiplier'] ?? 1.0).toDouble(),
      isDefault: (map['isDefault'] ?? 0) == 1,
      createdAt: map['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : null,
    );
  }
  
  // JSON serialization for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint,
      'color': color.value,
      'multiplier': multiplier,
      'isDefault': isDefault,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory DrinkTypeModel.fromJson(Map<String, dynamic> json) {
    return DrinkTypeModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: IconData(json['icon'] ?? Icons.local_drink.codePoint, fontFamily: 'MaterialIcons'),
      color: Color(json['color'] ?? Colors.blue.value),
      multiplier: (json['multiplier'] ?? 1.0).toDouble(),
      isDefault: json['isDefault'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  DrinkTypeModel copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    double? multiplier,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return DrinkTypeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      multiplier: multiplier ?? this.multiplier,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'DrinkTypeModel(id: $id, name: $name, icon: $icon, color: $color, multiplier: $multiplier)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DrinkTypeModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Default drink types
  static List<DrinkTypeModel> getDefaultDrinkTypes() {
    return [
      DrinkTypeModel(
        id: 'water',
        name: 'Water',
        icon: Icons.water_drop,
        color: const Color(0xFF2196F3),
        multiplier: 1.0,
        isDefault: true,
      ),
      DrinkTypeModel(
        id: 'coffee',
        name: 'Coffee',
        icon: Icons.coffee,
        color: const Color(0xFF795548),
        multiplier: 0.8,
        isDefault: true,
      ),
      DrinkTypeModel(
        id: 'tea',
        name: 'Tea',
        icon: Icons.emoji_food_beverage,
        color: const Color(0xFF4CAF50),
        multiplier: 0.9,
        isDefault: true,
      ),
      DrinkTypeModel(
        id: 'juice',
        name: 'Juice',
        icon: Icons.local_drink,
        color: const Color(0xFFFF9800),
        multiplier: 0.8,
        isDefault: true,
      ),
      DrinkTypeModel(
        id: 'soda',
        name: 'Soda',
        icon: Icons.local_bar,
        color: const Color(0xFFE91E63),
        multiplier: 0.6,
        isDefault: true,
      ),
      DrinkTypeModel(
        id: 'milk',
        name: 'Milk',
        icon: Icons.liquor,
        color: const Color(0xFFFFF8E1),
        multiplier: 0.9,
        isDefault: true,
      ),
    ];
  }
}
