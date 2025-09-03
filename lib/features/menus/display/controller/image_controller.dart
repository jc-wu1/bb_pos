import 'package:flutter/material.dart';

class ImageController extends ChangeNotifier {
  bool isLoading = false;
  String? _imagePath;
  String? get imagePath => _imagePath;

  void setLoading() {
    isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    isLoading = false;
    notifyListeners();
  }

  void setImage(String image) {
    _imagePath = image;
    notifyListeners();
  }

  void deleteImage() {
    _imagePath = null;
    notifyListeners();
  }
}
