import 'dart:io';

import 'package:flutter/material.dart';

class ImageController extends ChangeNotifier {
  bool isLoading = false;
  File? _imagePath;
  File? get imagePath => _imagePath;

  void setLoading() {
    isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    isLoading = false;
    notifyListeners();
  }

  void setImage(File? image) {
    _imagePath = image;
    notifyListeners();
  }

  void deleteImage() {
    _imagePath = null;
    notifyListeners();
  }
}
