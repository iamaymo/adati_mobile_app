import 'package:flutter/material.dart';
import 'prodct.dart';

class Cart {
  Cart._();
  static final Cart instance = Cart._();

  // Notifies listeners when items change
  final ValueNotifier<List<Product>> items = ValueNotifier<List<Product>>([]);

  void add(Product p) {
    items.value = [...items.value, p];
  }

  void removeAt(int index) {
    final list = List<Product>.from(items.value)..removeAt(index);
    items.value = list;
  }

  void clear() => items.value = [];

  double totalPrice() {
    double parsePrice(String s) {
      final cleaned = s.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }

    return items.value.fold(0.0, (sum, p) => sum + parsePrice(p.price));
  }
}
