import 'dart:io';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unicons/unicons.dart';

import '../../../../app_scaffold_with_navbar.dart';
import '../../../../core/injector.dart';
import '../../../../main.dart';
import '../../../categories/data/model/category.dart';
import '../../../categories/display/bloc/categories_bloc.dart';
import '../../../categories/domain/usecases/categories_usecase.dart';
import '../../../supabase/domain/usecases/supabase_usecase.dart';
import '../../data/model/menu_model.dart';
import '../controller/category_selector.dart';
import '../controller/image_controller.dart';
import 'add_new_category_dialog.dart';

class AddNewMenuDialog extends StatelessWidget {
  const AddNewMenuDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CategoriesBloc(usecase: sl<CategoriesUsecase>())
            ..add(const CategoriesFetched()),
      child: const AddNewMenuDialogView(),
    );
  }
}

class AddNewMenuDialogView extends StatefulWidget {
  const AddNewMenuDialogView({super.key});

  @override
  State<AddNewMenuDialogView> createState() => _AddNewMenuDialogViewState();
}

class _AddNewMenuDialogViewState extends State<AddNewMenuDialogView> {
  late FocusNode _descriptionNode;
  late FocusNode _nameNode;
  late FocusNode _hargaNode;

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  late ImageController _imageController;
  late CategorySelector _categorySelector;

  final formatter = CurrencyTextInputFormatter.currency(
    locale: "id_ID",
    symbol: "Rp",
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _descriptionNode = FocusNode();
    _nameNode = FocusNode();
    _hargaNode = FocusNode();

    _nameController = TextEditingController();
    _descriptionController = TextEditingController();

    _imageController = ImageController();
    _categorySelector = CategorySelector();
  }

  @override
  void dispose() {
    _descriptionNode.dispose();
    _nameNode.dispose();
    _hargaNode.dispose();

    _nameController.dispose();
    _descriptionController.dispose();

    _imageController.dispose();
    _categorySelector.dispose();
    super.dispose();
  }

  Future<void> _onDeleteImagePressed() async {
    _imageController.setLoading();
    final rawPath = _imageController.imagePath;
    final splitPath = rawPath!.split("/");
    splitPath.removeAt(0);
    final path = splitPath.join("/");
    await sl<SupabaseUsecase>().deleteUploadedImage(path);
    _imageController.stopLoading();
    _imageController.deleteImage();
  }

  Future<void> _onUploadImagePressed() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    _imageController.setLoading();
    final File imageFile = File(image.path);
    final result = await sl<SupabaseUsecase>().uploadImage(imageFile);
    _imageController.stopLoading();
    _imageController.setImage(result);
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppBar(),
      body: BlocListener<CategoriesBloc, CategoriesState>(
        listener: (context, state) {},
        child: GestureDetector(
          onTap: () {
            _descriptionNode.unfocus();
            _nameNode.unfocus();
            _hargaNode.unfocus();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card.filled(
                margin: EdgeInsets.zero,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    spacing: 8,
                    children: [
                      Image.asset(
                        "assets/images/Food Menu Streamline Milano.png",
                        height: 100,
                        width: 100,
                        color: colorScheme.onSurface,
                      ),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Tambah Menu",
                              style: textTheme.headlineSmall!.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              "Tambahkan menu ke sistem POS Anda.",
                              style: textTheme.bodyMedium!.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(8),
              const Divider(),
              const Gap(8),
              ListenableBuilder(
                listenable: _imageController,
                builder: (context, child) {
                  if (_imageController.isLoading) {
                    return const Row(
                      children: [
                        Card.outlined(
                          margin: EdgeInsets.zero,
                          clipBehavior: Clip.hardEdge,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (_imageController.imagePath != null) {
                    final imagePath = _imageController.imagePath;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Card(
                          margin: EdgeInsets.zero,
                          clipBehavior: Clip.hardEdge,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: 150,
                                width: 150,
                                child: Image.network(
                                  "$baseImgUrl$imagePath",
                                  fit: BoxFit.cover,
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  await _onDeleteImagePressed();
                                },
                                icon: const Icon(UniconsLine.trash),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return Card.outlined(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      onTap: () async {
                        _onUploadImagePressed();
                      },
                      child: Padding(
                        padding: const EdgeInsetsGeometry.all(16),
                        child: Column(
                          spacing: 8,
                          children: [
                            const Icon(UniconsLine.image_upload),
                            Text("Pilih gambar", style: textTheme.titleMedium),
                            Text(
                              "Gambar yang didukung .PNG, .JPG (Tidak lebih dari 2MB)",
                              style: textTheme.labelSmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const Gap(16),
              Row(
                spacing: 4,
                children: [
                  const Icon(UniconsLine.book),
                  Text("Nama *", style: textTheme.labelMedium),
                ],
              ),
              const Gap(8),
              TextField(
                controller: _nameController,
                focusNode: _nameNode,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hint: const Text("Nama menu (cth: Mie Ayam)"),
                ),
                keyboardType: TextInputType.name,
              ),
              const Gap(8),
              Row(
                spacing: 4,
                children: [
                  const Icon(UniconsLine.money_bill),
                  Text("Harga *", style: textTheme.labelMedium),
                ],
              ),
              const Gap(8),
              TextField(
                focusNode: _hargaNode,
                inputFormatters: [formatter],
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hint: const Text("Harga (dalam rupiah)"),
                ),
                keyboardType: TextInputType.number,
              ),
              const Gap(8),
              Row(
                spacing: 4,
                children: [
                  const Icon(UniconsLine.bookmark),
                  Text("Kategori *", style: textTheme.labelMedium),
                ],
              ),
              const Divider(),
              CategoriesSelector(categorySelector: _categorySelector),
              const Gap(8),
              Row(
                spacing: 4,
                children: [
                  const Icon(UniconsLine.notebooks),
                  Text("Deskripsi", style: textTheme.labelMedium),
                ],
              ),
              const Gap(8),
              TextField(
                controller: _descriptionController,
                focusNode: _descriptionNode,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hint: const Text("Tulis deskripsi menu (optional)"),
                ),
                keyboardType: TextInputType.multiline,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          spacing: 8,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop({"refresh_category": true});
              },
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                final selectedCategory = _categorySelector.selectedCategory;
                final imageUrl = _imageController.imagePath;

                if (selectedCategory == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Kategori belum dipilih. Silahkan pilih menu Kategori",
                      ),
                    ),
                  );
                  return;
                }

                final MenuItem payload = MenuItem(
                  name: _nameController.text,
                  price: formatter.getDouble(),
                  categoryId: selectedCategory.id,
                  category: selectedCategory.name,
                  imageUrl: imageUrl,
                  description: _descriptionController.text,
                );

                Navigator.of(context).pop(payload);
              },
              child: const Text("Tambah Menu"),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoriesSelector extends StatelessWidget {
  const CategoriesSelector({super.key, required this.categorySelector});

  static Future<void> onAddNewCategoryPressed(BuildContext context) async {
    final dialogResult = await showDialog<CategoryItem>(
      context: context,
      builder: (context) {
        return const Dialog(
          constraints: BoxConstraints(maxWidth: 560, minHeight: 280),
          child: AddNewCategoryDialog(),
        );
      },
    );
    if (dialogResult == null) return;
    if (!context.mounted) return;
    context.read<CategoriesBloc>().add(
      CategoryInserted(categoryItem: dialogResult),
    );
  }

  final CategorySelector categorySelector;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesLoadComplete) {
          if (state.categories.isEmpty) {
            return Row(
              spacing: 8,
              children: [
                Text(
                  "Belum ada kategori tersimpan",
                  style: textTheme.labelSmall!.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Flexible(
                  child: ActionChip(
                    label: const Text("Tambah Kategori Baru"),
                    avatar: const Icon(UniconsLine.plus_circle),
                    onPressed: () async {
                      await CategoriesSelector.onAddNewCategoryPressed(context);
                    },
                  ),
                ),
              ],
            );
          }
          return ListenableBuilder(
            listenable: categorySelector,
            builder: (context, child) {
              return Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ...state.categories.map((category) {
                    return ChoiceChip(
                      label: Text(category.name),
                      selected: categorySelector.selectedCategory == category,
                      onSelected: (value) {
                        categorySelector.select(category);
                      },
                    );
                  }),
                  ActionChip(
                    label: const Text("Tambah Kategori Baru"),
                    avatar: const Icon(UniconsLine.plus_circle),
                    onPressed: () async {
                      await CategoriesSelector.onAddNewCategoryPressed(context);
                    },
                  ),
                ],
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
