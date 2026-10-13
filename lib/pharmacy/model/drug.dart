import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Category keys are stored in English and translated with context.tr().
const drugCategories = <String, IconData>{
  'Pain & fever': Icons.thermostat_outlined,
  'Cough & cold': Icons.air,
  'Digestive': Icons.lunch_dining_outlined,
  'Vitamins & minerals': Icons.spa_outlined,
  'Allergy': Icons.local_florist_outlined,
  'Skin care': Icons.healing_outlined,
  'Eye, ear & nose': Icons.visibility_outlined,
  'Antibiotics': Icons.coronavirus_outlined,
  'Heart & blood pressure': Icons.favorite_outline,
  'Diabetes': Icons.bloodtype_outlined,
};

IconData drugIcon(String category) =>
    drugCategories[category] ?? Icons.medication_outlined;

String formatVnd(int amount) =>
    '${NumberFormat.decimalPattern('vi').format(amount)} ₫';

class Drug {
  const Drug({
    required this.id,
    required this.name,
    required this.ingredient,
    required this.category,
    required this.price,
    required this.stock,
    this.prescription = false,
    this.strength = '',
    this.form = '',
    this.pack = '',
    this.uses = '',
    this.dosage = '',
    this.contraindications = '',
    this.sideEffects = '',
  });

  static const lowStock = 10;
  static const maxPerOrder = 99;

  final String id;
  final String name;
  final String ingredient;
  final String category;
  final int price;
  final int stock;
  final bool prescription;
  final String strength;
  final String form;
  final String pack;
  final String uses;
  final String dosage;
  final String contraindications;
  final String sideEffects;

  bool get inStock => stock > 0;
  bool get isLow => stock <= lowStock;
  bool get canBuy => !prescription && inStock;
  int get maxQty => stock < maxPerOrder ? stock : maxPerOrder;

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    return q.isEmpty ||
        name.toLowerCase().contains(q) ||
        ingredient.toLowerCase().contains(q);
  }

  factory Drug.fromMap(Map data, String key) {
    String text(String field) => '${data[field] ?? ''}';
    return Drug(
      id: key,
      name: text('name'),
      ingredient: text('ingredient'),
      category: text('category'),
      price: (data['price'] as num?)?.toInt() ?? 0,
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      prescription: data['prescription'] == true,
      strength: text('strength'),
      form: text('form'),
      pack: text('pack'),
      uses: text('uses'),
      dosage: text('dosage'),
      contraindications: text('contraindications'),
      sideEffects: text('sideEffects'),
    );
  }

  Map<String, Object> toMap() => {
        'id': id,
        'name': name,
        'ingredient': ingredient,
        'category': category,
        'price': price,
        'stock': stock,
        'prescription': prescription,
        'strength': strength,
        'form': form,
        'pack': pack,
        'uses': uses,
        'dosage': dosage,
        'contraindications': contraindications,
        'sideEffects': sideEffects,
      };
}
