import 'package:flutter/material.dart';

import '../../../categories/data/model/category.dart';

class CategorySelector extends ChangeNotifier {
  CategoryItem? _category;
  CategoryItem? get selectedCategory => _category;

  void select(CategoryItem category) {
    _category = category;
    notifyListeners();
  }
}
