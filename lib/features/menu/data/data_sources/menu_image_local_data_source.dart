import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class MenuImageLocalDataSource {
  Future<String> copyPickedImage(String pickedImagePath) async {
    final imageDirectory = await _imageDirectory();
    final extension = p.extension(pickedImagePath).isEmpty
        ? '.jpg'
        : p.extension(pickedImagePath);
    final fileName = 'menu_${DateTime.now().microsecondsSinceEpoch}$extension';
    final savedImage = await File(
      pickedImagePath,
    ).copy(p.join(imageDirectory.path, fileName));

    return savedImage.path;
  }

  Future<void> deleteManagedImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return;

    final imageDirectory = await _imageDirectory(create: false);
    final normalizedDirectory = p.normalize(imageDirectory.path);
    final normalizedPath = p.normalize(imagePath);
    if (!p.isWithin(normalizedDirectory, normalizedPath)) return;

    try {
      await File(normalizedPath).delete();
    } on FileSystemException {
      return;
    }
  }

  Future<Directory> _imageDirectory({bool create = true}) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final imageDirectory = Directory(
      p.join(documentsDirectory.path, 'menu_images'),
    );

    if (create) {
      await imageDirectory.create(recursive: true);
    }

    return imageDirectory;
  }
}
