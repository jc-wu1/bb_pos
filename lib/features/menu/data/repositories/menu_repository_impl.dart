import '../../domain/entities/menu_category_entity.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/entities/menu_item_input.dart';
import '../../domain/repositories/menu_repository.dart';
import '../data_sources/menu_image_local_data_source.dart';
import '../data_sources/menu_local_data_source.dart';

class MenuRepositoryImpl implements MenuRepository {
  const MenuRepositoryImpl({
    required MenuLocalDataSource localDataSource,
    required MenuImageLocalDataSource imageDataSource,
  }) : _localDataSource = localDataSource,
       _imageDataSource = imageDataSource;

  final MenuLocalDataSource _localDataSource;
  final MenuImageLocalDataSource _imageDataSource;

  @override
  Stream<List<MenuCategoryEntity>> watchCategories() {
    return _localDataSource.watchCategories();
  }

  @override
  Stream<List<MenuItemEntity>> watchMenuItems() {
    return _localDataSource.watchMenuItems();
  }

  @override
  Future<void> saveMenuItem(MenuItemInput input) async {
    final pickedImagePath = input.pickedImagePath;
    final resolvedImagePath = pickedImagePath == null
        ? input.removeImage
              ? null
              : input.imagePath
        : await _imageDataSource.copyPickedImage(pickedImagePath);

    try {
      await _localDataSource.saveMenuItem(input, imagePath: resolvedImagePath);
    } catch (_) {
      if (pickedImagePath != null) {
        await _imageDataSource.deleteManagedImage(resolvedImagePath);
      }
      rethrow;
    }

    if (pickedImagePath != null || input.removeImage) {
      await _imageDataSource.deleteManagedImage(input.imagePath);
    }
  }

  @override
  Future<void> deleteMenuItem(MenuItemEntity item) async {
    await _localDataSource.deleteMenuItem(item.id);
    await _imageDataSource.deleteManagedImage(item.imagePath);
  }

  @override
  Future<void> toggleMenuItemAvailability(MenuItemEntity item) {
    return _localDataSource.updateAvailability(
      id: item.id,
      isAvailable: !item.isAvailable,
    );
  }
}
