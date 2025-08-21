import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:unicons/unicons.dart';

import '../../../categories/data/model/category.dart';

class AddNewCategoryDialog extends StatefulWidget {
  const AddNewCategoryDialog({super.key});

  @override
  State<AddNewCategoryDialog> createState() => _AddNewCategoryDialogState();
}

class _AddNewCategoryDialogState extends State<AddNewCategoryDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              spacing: 4,
              children: [
                const Icon(UniconsSolid.window_grid),
                Text("Tambah Kategori", style: textTheme.titleSmall),
              ],
            ),
            const Gap(16),
            Text("Nama *", style: textTheme.labelMedium),
            const Gap(8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hint: const Text("Nama kategori (cth: Makanan)"),
              ),
              validator: (value) {
                if (value == "") {
                  return "Nama tidak boleh kosong!";
                } else if (value == null) {
                  return "Nama tidak boleh kosong!";
                }
                return null;
              },
              keyboardType: TextInputType.name,
            ),
            const Gap(8),
            Text("Deskripsi", style: textTheme.labelMedium),
            const Gap(8),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hint: const Text("Deskripsi kategori (opsional)"),
              ),
              maxLines: 5,
              keyboardType: TextInputType.multiline,
            ),
            const Gap(8),
            Row(
              spacing: 8,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Batal"),
                ),
                TextButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      final CategoryItem category = CategoryItem(
                        name: _nameController.text,
                      );
                      Navigator.of(context).pop(category);
                    }
                  },
                  child: const Text("Tambah Menu"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
