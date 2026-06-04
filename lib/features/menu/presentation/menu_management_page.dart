import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/dependencies/injector.dart';
import '../../../shared/widgets/app_field_decoration.dart';
import '../domain/entities/menu_category_entity.dart';
import '../domain/entities/menu_item_entity.dart';
import '../domain/entities/menu_item_input.dart';
import 'cubit/menu_management_cubit.dart';

const Color _availableColor = Color(0xff0f9f6e);
const Color _soldOutColor = Color(0xffdc4a2d);

final NumberFormat _currencyFormatter = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

class MenuManagementPage extends StatelessWidget {
  const MenuManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MenuManagementCubit>()..load(),
      child: const _MenuManagementView(),
    );
  }
}

class _MenuManagementView extends StatefulWidget {
  const _MenuManagementView();

  @override
  State<_MenuManagementView> createState() => _MenuManagementViewState();
}

class _MenuManagementViewState extends State<_MenuManagementView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openMenuForm({MenuItemEntity? item}) async {
    final cubit = context.read<MenuManagementCubit>();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (context) {
        return BlocProvider.value(
          value: cubit,
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.85,
            child: _MenuFormSheet(item: item),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<MenuManagementCubit, MenuManagementState>(
      listenWhen: (previous, current) {
        return previous.errorSerial != current.errorSerial &&
            current.errorMessage != null;
      },
      listener: (context, state) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      builder: (context, state) {
        return SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 600;
              final horizontalPadding = isCompact ? 14.0 : 20.0;

              return Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      16,
                      horizontalPadding,
                      22,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HeaderBar(
                          showAddButton: !isCompact,
                          onAddMenu: () => _openMenuForm(),
                        ),
                        const SizedBox(height: 14),
                        _SearchField(
                          controller: _searchController,
                          hasQuery: state.searchQuery.isNotEmpty,
                          onChanged: context
                              .read<MenuManagementCubit>()
                              .searchChanged,
                          onClear: () {
                            _searchController.clear();
                            context.read<MenuManagementCubit>().clearSearch();
                          },
                        ),
                        const SizedBox(height: 10),
                        _CategoryFilter(
                          categories: state.categories,
                          selectedCategory: state.selectedCategory,
                          onChanged: context
                              .read<MenuManagementCubit>()
                              .selectCategory,
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          child: _MenuContent(
                            state: state,
                            onRetry: context.read<MenuManagementCubit>().retry,
                            onAddMenu: () => _openMenuForm(),
                            onEdit: (item) => _openMenuForm(item: item),
                            onToggleAvailability: context
                                .read<MenuManagementCubit>()
                                .toggleAvailability,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${state.visibleItems.length} menu ditampilkan',
                          textAlign: TextAlign.end,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCompact)
                    Positioned(
                      right: 16,
                      bottom: 14,
                      child: FloatingActionButton(
                        onPressed: () => _openMenuForm(),
                        tooltip: 'Tambah Menu',
                        child: const Icon(Icons.add),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _MenuContent extends StatelessWidget {
  const _MenuContent({
    required this.state,
    required this.onRetry,
    required this.onAddMenu,
    required this.onEdit,
    required this.onToggleAvailability,
  });

  final MenuManagementState state;
  final VoidCallback onRetry;
  final VoidCallback onAddMenu;
  final ValueChanged<MenuItemEntity> onEdit;
  final ValueChanged<MenuItemEntity> onToggleAvailability;

  @override
  Widget build(BuildContext context) {
    if (state.isInitialLoading) {
      return const _LoadingMenuState();
    }

    if (state.status == MenuManagementStatus.failure && state.items.isEmpty) {
      return _ErrorMenuState(onRetry: onRetry);
    }

    if (state.visibleItems.isEmpty) {
      return _EmptyMenuState(
        message: state.searchQuery.trim().isEmpty
            ? 'Belum ada menu di kategori ini'
            : 'Menu tidak ditemukan',
        onAddMenu: onAddMenu,
      );
    }

    return _MenuGrid(
      items: state.visibleItems,
      onEdit: onEdit,
      onToggleAvailability: onToggleAvailability,
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hasQuery,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool hasQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: appFieldDecoration(
        context,
        label: 'Cari Menu',
        hint: 'Cari nama, kategori, atau deskripsi',
        prefixIcon: Icons.search,
        suffixIcon: hasQuery
            ? IconButton(
                tooltip: 'Hapus pencarian',
                onPressed: onClear,
                icon: const Icon(Icons.close),
              )
            : null,
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({required this.showAddButton, required this.onAddMenu});

  final bool showAddButton;
  final VoidCallback onAddMenu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 520;
        final title = Text(
          'Manajemen Menu',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        );
        final button = ElevatedButton.icon(
          onPressed: onAddMenu,
          icon: const Icon(Icons.add),
          label: const Text('Tambah Menu'),
        );

        if (!showAddButton || isCompact) {
          return title;
        }

        return Row(
          children: [
            Expanded(child: title),
            const SizedBox(width: 12),
            button,
          ],
        );
      },
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
  });

  final List<MenuCategoryEntity> categories;
  final MenuCategoryEntity? selectedCategory;
  final ValueChanged<MenuCategoryEntity?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filterCategories = <MenuCategoryEntity?>[null, ...categories];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final category in filterCategories) ...[
            FilterChip(
              selected: _isSameCategory(selectedCategory, category),
              showCheckmark: false,
              selectedColor: colorScheme.primaryContainer,
              backgroundColor: colorScheme.surface,
              side: BorderSide(
                color: _isSameCategory(selectedCategory, category)
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
              ),
              label: Text(category?.name ?? 'Semua'),
              labelStyle: TextStyle(
                color: _isSameCategory(selectedCategory, category)
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: _isSameCategory(selectedCategory, category)
                    ? FontWeight.w800
                    : FontWeight.w600,
              ),
              onSelected: (_) => onChanged(category),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _MenuGrid extends StatelessWidget {
  const _MenuGrid({
    required this.items,
    required this.onEdit,
    required this.onToggleAvailability,
  });

  final List<MenuItemEntity> items;
  final ValueChanged<MenuItemEntity> onEdit;
  final ValueChanged<MenuItemEntity> onToggleAvailability;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = constraints.maxWidth < 520 ? 10.0 : 12.0;
        final crossAxisCount = constraints.maxWidth < 320
            ? 1
            : constraints.maxWidth < 520
            ? 2
            : ((constraints.maxWidth + spacing) / (220 + spacing))
                  .floor()
                  .clamp(3, 8)
                  .toInt();
        final childAspectRatio = constraints.maxWidth < 520 ? 0.72 : 0.76;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];

            return _MenuItemCard(
              item: item,
              onEdit: () => onEdit(item),
              onToggleAvailability: () => onToggleAvailability(item),
            );
          },
        );
      },
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({
    required this.item,
    required this.onEdit,
    required this.onToggleAvailability,
  });

  final MenuItemEntity item;
  final VoidCallback onEdit;
  final VoidCallback onToggleAvailability;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Opacity(
      opacity: item.isAvailable ? 1 : 0.6,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _MenuImage(
                    imagePath: item.imagePath,
                    isAvailable: item.isAvailable,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(9, 7, 9, 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatCurrency(item.price),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _CardIconButton(
                            tooltip: 'Edit menu',
                            icon: Icons.edit_outlined,
                            onPressed: onEdit,
                          ),
                          const Spacer(),
                          _CardIconButton(
                            tooltip: item.isAvailable
                                ? 'Tandai habis'
                                : 'Tandai tersedia',
                            icon: item.isAvailable
                                ? Icons.check_circle_outline
                                : Icons.cancel_outlined,
                            onPressed: onToggleAvailability,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: _StatusBadge(isAvailable: item.isAvailable),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardIconButton extends StatelessWidget {
  const _CardIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        fixedSize: const Size.square(32),
        minimumSize: const Size.square(32),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(icon, size: 18),
    );
  }
}

class _MenuImage extends StatelessWidget {
  const _MenuImage({required this.imagePath, required this.isAvailable});

  final String? imagePath;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final path = imagePath;
    final image = path == null || path.isEmpty
        ? _MenuImageFallback(colorScheme: colorScheme)
        : Image.file(
            File(path),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _MenuImageFallback(colorScheme: colorScheme);
            },
          );

    if (isAvailable) return image;

    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
      child: image,
    );
  }
}

class _MenuImageFallback extends StatelessWidget {
  const _MenuImageFallback({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.restaurant,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.58),
        size: 34,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isAvailable});

  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isAvailable ? _availableColor : _soldOutColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          isAvailable ? 'Tersedia' : 'Habis',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _LoadingMenuState extends StatelessWidget {
  const _LoadingMenuState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorMenuState extends StatelessWidget {
  const _ErrorMenuState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 58, color: colorScheme.error),
          const SizedBox(height: 10),
          Text(
            'Data menu gagal dimuat.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.tonalIcon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

class _EmptyMenuState extends StatelessWidget {
  const _EmptyMenuState({required this.message, required this.onAddMenu});

  final String message;
  final VoidCallback onAddMenu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 68,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onAddMenu,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Menu Pertama'),
          ),
        ],
      ),
    );
  }
}

class _MenuFormSheet extends StatefulWidget {
  const _MenuFormSheet({required this.item});

  final MenuItemEntity? item;

  @override
  State<_MenuFormSheet> createState() => _MenuFormSheetState();
}

class _MenuFormSheetState extends State<_MenuFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();

  MenuCategoryEntity? _category;
  String? _pickedImagePath;
  bool _imageRemoved = false;

  @override
  void initState() {
    super.initState();

    final item = widget.item;
    _nameController.text = item?.name ?? '';
    _priceController.text = item == null ? '' : item.price.toString();
    _descriptionController.text = item?.description ?? '';
    _category = item?.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 86,
      maxWidth: 1400,
    );

    if (pickedImage == null || !mounted) return;

    setState(() {
      _pickedImagePath = pickedImage.path;
      _imageRemoved = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final saved = await context.read<MenuManagementCubit>().saveMenuItem(
      MenuItemInput(
        id: widget.item?.id,
        categoryId: _category!.id,
        name: _nameController.text.trim(),
        price: int.parse(_priceController.text),
        description: _descriptionController.text.trim(),
        imagePath: widget.item?.imagePath,
        pickedImagePath: _pickedImagePath,
        removeImage: _imageRemoved,
      ),
    );

    if (!mounted || !saved) return;
    Navigator.of(context).pop();
  }

  Future<void> _deleteMenu() async {
    final item = widget.item;
    if (item == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return AlertDialog(
          title: const Text('Hapus Menu?'),
          content: Text('Menu "${item.name}" akan dihapus dari daftar.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus Menu'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    final deleted = await context.read<MenuManagementCubit>().deleteMenuItem(
      item,
    );
    if (!mounted || !deleted) return;
    Navigator.of(context).pop();
  }

  List<MenuCategoryEntity> _categoriesForDropdown(
    List<MenuCategoryEntity> categories,
  ) {
    final selectedCategory = _category;
    if (selectedCategory == null) return categories;

    for (final category in categories) {
      if (category.id == selectedCategory.id) return categories;
    }

    return [selectedCategory, ...categories];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categories = _categoriesForDropdown(
      context.select((MenuManagementCubit cubit) => cubit.state.categories),
    );
    final activeAction = context.select(
      (MenuManagementCubit cubit) => cubit.state.activeAction,
    );
    final isSaving = activeAction == MenuManagementAction.saving;
    final isDeleting = activeAction == MenuManagementAction.deleting;
    final isBusy = activeAction != MenuManagementAction.none;
    final previewPath =
        _pickedImagePath ?? (_imageRemoved ? null : widget.item?.imagePath);
    final isEditing = widget.item != null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Material(
          color: colorScheme.surface,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 10, 8),
                child: Column(
                  children: [
                    Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              isEditing
                                  ? Icons.edit_outlined
                                  : Icons.add_business_outlined,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isEditing ? 'Edit Menu' : 'Tambah Menu',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Tutup',
                          onPressed: isBusy
                              ? null
                              : () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _FormSection(
                          title: 'Foto Menu',
                          child: _PhotoPickerPreview(
                            imagePath: previewPath,
                            onPickImage: isBusy ? null : _pickImage,
                            onRemoveImage: isBusy
                                ? null
                                : () {
                                    setState(() {
                                      _pickedImagePath = null;
                                      _imageRemoved = true;
                                    });
                                  },
                          ),
                        ),
                        const SizedBox(height: 12),
                        _FormSection(
                          title: 'Detail Menu',
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nameController,
                                enabled: !isBusy,
                                textInputAction: TextInputAction.next,
                                decoration: appFieldDecoration(
                                  context,
                                  label: 'Nama Menu',
                                  prefixIcon: Icons.restaurant_menu_outlined,
                                ),
                                validator: context
                                    .read<MenuManagementCubit>()
                                    .validateName,
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<MenuCategoryEntity>(
                                initialValue: _category,
                                decoration: appFieldDecoration(
                                  context,
                                  label: 'Kategori',
                                  prefixIcon: Icons.category_outlined,
                                ),
                                items: categories
                                    .map(
                                      (category) => DropdownMenuItem(
                                        value: category,
                                        child: Text(category.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: isBusy
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _category = value;
                                        });
                                      },
                                validator: context
                                    .read<MenuManagementCubit>()
                                    .validateCategory,
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _priceController,
                                enabled: !isBusy,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: appFieldDecoration(
                                  context,
                                  label: 'Harga',
                                  prefixIcon: Icons.payments_outlined,
                                ).copyWith(prefixText: 'Rp '),
                                validator: context
                                    .read<MenuManagementCubit>()
                                    .validatePrice,
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _descriptionController,
                                enabled: !isBusy,
                                minLines: 3,
                                maxLines: 5,
                                decoration: appFieldDecoration(
                                  context,
                                  label: 'Deskripsi',
                                  prefixIcon: Icons.notes_outlined,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isEditing) ...[
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.error,
                              side: BorderSide(color: colorScheme.error),
                              minimumSize: const Size.fromHeight(42),
                            ),
                            onPressed: isBusy ? null : _deleteMenu,
                            icon: isDeleting
                                ? const SizedBox.square(
                                    dimension: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.delete_outline),
                            label: const Text('Hapus Menu'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  border: Border(
                    top: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: isBusy
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Batal'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isBusy ? null : _save,
                            icon: isSaving
                                ? const SizedBox.square(
                                    dimension: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined),
                            label: const Text('Simpan'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _PhotoPickerPreview extends StatelessWidget {
  const _PhotoPickerPreview({
    required this.imagePath,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  final String? imagePath;
  final VoidCallback? onPickImage;
  final VoidCallback? onRemoveImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final path = imagePath;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 160,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: path == null || path.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                color: colorScheme.primary,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Belum ada foto',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        : Image.file(
                            File(path),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.restaurant,
                                  color: colorScheme.onSurfaceVariant,
                                  size: 36,
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
              if (path != null && path.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton.filled(
                    tooltip: 'Hapus foto',
                    onPressed: onRemoveImage,
                    icon: const Icon(Icons.close),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        FilledButton.tonalIcon(
          onPressed: onPickImage,
          icon: const Icon(Icons.image_outlined),
          label: const Text('Pilih Foto'),
        ),
      ],
    );
  }
}

bool _isSameCategory(MenuCategoryEntity? first, MenuCategoryEntity? second) {
  return first?.id == second?.id;
}

String _formatCurrency(int value) {
  return _currencyFormatter.format(value);
}
