import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:unicons/unicons.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../core/injector.dart';
import '../../categories/data/model/category.dart';
import '../../categories/display/bloc/categories_bloc.dart';
import '../../categories/domain/usecases/categories_usecase.dart';
import '../data/model/menu_model.dart';
import '../domain/usecases/menus_usecase.dart';
import 'bloc/menus_bloc.dart';
import 'widgets/add_new_menu_dialog.dart';

class MenusScreen extends StatelessWidget {
  const MenusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              MenusBloc(usecase: sl<MenusUsecase>())..add(const MenusFetched()),
        ),
        BlocProvider(
          create: (context) =>
              CategoriesBloc(usecase: sl<CategoriesUsecase>())
                ..add(const CategoriesFetched()),
        ),
      ],
      child: const MenusScreenView(),
    );
  }
}

class MenusScreenView extends StatefulWidget {
  const MenusScreenView({super.key});

  @override
  State<MenusScreenView> createState() => _MenusScreenViewState();
}

class _MenusScreenViewState extends State<MenusScreenView> {
  Future<void> _onAddNewMenuPressed(BuildContext context) async {
    final dialogResult = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const Dialog(
          constraints: BoxConstraints(maxWidth: 560, minHeight: 280),
          child: AddNewMenuDialog(),
        );
      },
    );
    if (dialogResult is Map<String, dynamic>) {
      bool refreshRequested = dialogResult["refresh_category"] == true;
      if (refreshRequested) {
        if (!context.mounted) return;
        context.read<MenusBloc>().add(const MenusFetched());
        context.read<CategoriesBloc>().add(const CategoriesFetched());
      }
    } else if (dialogResult is MenuItem) {
      if (!context.mounted) return;
      context.read<CategoriesBloc>().add(const CategoriesFetched());
      context.read<MenusBloc>().add(MenuInserted(menuItem: dialogResult));
    }
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorSheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: CustomScrollView(
        slivers: [
          const SliverGap(8),
          SliverToBoxAdapter(
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(UniconsLine.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                hint: const Text("Cari menu"),
              ),
            ),
          ),
          const SliverGap(16),
          SliverToBoxAdapter(child: Text("Menu", style: textTheme.titleLarge)),
          const SliverGap(16),
          BlocBuilder<CategoriesBloc, CategoriesState>(
            builder: (context, state) {
              if (state is CategoriesLoadInProgress) {
                return const SliverGap(1);
              }
              if (state is CategoriesLoadComplete) {
                if (state.categories.isNotEmpty) {
                  return SliverMainAxisGroup(
                    slivers: [
                      SliverToBoxAdapter(
                        child: SizedBox(
                          width: double.infinity,
                          height: 42,
                          child: ListView.separated(
                            key: const PageStorageKey<String>('myListViewKey'),
                            scrollDirection: Axis.horizontal,
                            separatorBuilder: (context, index) => const Gap(8),
                            itemCount: state.categories.length + 2,
                            itemBuilder: (_, int index) {
                              if (index == 0) {
                                return Center(
                                  child: ActionChip(
                                    avatar: CircleAvatar(
                                      backgroundColor:
                                          colorSheme.primaryContainer,
                                      foregroundColor:
                                          colorSheme.onPrimaryContainer,
                                      child: const Icon(
                                        UniconsLine.check,
                                        size: 18,
                                      ),
                                    ),
                                    onPressed: () {
                                      context.read<MenusBloc>().add(
                                        const MenusFetched(),
                                      );
                                    },
                                    label: const Text("Semua"),
                                  ),
                                );
                              } else if (index == state.categories.length + 1) {
                                return Center(
                                  child: ActionChip(
                                    avatar: CircleAvatar(
                                      backgroundColor:
                                          colorSheme.primaryContainer,
                                      foregroundColor:
                                          colorSheme.onPrimaryContainer,
                                      child: const Icon(
                                        UniconsLine.plus,
                                        size: 18,
                                      ),
                                    ),
                                    onPressed: () {
                                      CategoriesSelector.onAddNewCategoryPressed(
                                        context,
                                      );
                                    },
                                    label: const Text("Tambah kategori"),
                                  ),
                                );
                              }
                              return Center(
                                child: GestureDetector(
                                  onLongPress: () {
                                    _showCategoryOptionsBottomSheet(
                                      context,
                                      textTheme,
                                      colorSheme,
                                      state.categories[index - 1],
                                    );
                                  },
                                  child: ActionChip(
                                    avatar: CircleAvatar(
                                      backgroundColor:
                                          colorSheme.primaryContainer,
                                      foregroundColor:
                                          colorSheme.onPrimaryContainer,
                                      child: HugeIcon(
                                        icon: HugeIcons
                                            .strokeRoundedMenuRestaurant,
                                        color: colorSheme.onPrimaryContainer,
                                        size: 18,
                                      ),
                                    ),
                                    onPressed: () {
                                      context.read<MenusBloc>().add(
                                        MenusFetched(
                                          categoryName:
                                              state.categories[index - 1].name,
                                        ),
                                      );
                                    },
                                    label: Text(
                                      state.categories[index - 1].name,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SliverGap(16),
                      SliverGap(1, color: Colors.grey[300]),
                      const SliverGap(16),
                    ],
                  );
                }
                return const SliverGap(1);
              }
              return const SliverGap(1);
            },
          ),
          BlocBuilder<MenusBloc, MenusState>(
            builder: (context, state) {
              if (state is MenusLoadInProgress) {
                return const SliverGap(0);
              }
              if (state is MenusLoadComplete) {
                if (state.menus.isNotEmpty) {
                  return SliverGrid.builder(
                    key: const PageStorageKey<String>('listMenus'),
                    itemCount: state.menus.length + 1,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 150,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 4 / 7,
                        ),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Card.filled(
                          clipBehavior: Clip.hardEdge,
                          child: InkWell(
                            onTap: () {
                              _onAddNewMenuPressed(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child: Icon(
                                  UniconsLine.plus,
                                  color: colorSheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Card.outlined(
                          clipBehavior: Clip.hardEdge,
                          child: InkWell(
                            onTap: () {},
                            onLongPress: () {
                              _showOptionsBottomSheet(
                                context,
                                textTheme,
                                colorSheme,
                                state.menus[index - 1].id!,
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildMenuImage(
                                  state.menus[index - 1].imageUrl,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8.0,
                                    bottom: 8.0,
                                    left: 8.0,
                                    right: 8.0,
                                  ),
                                  child: Column(
                                    spacing: 2,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.menus[index - 1].name,
                                        style: textTheme.titleMedium!.copyWith(
                                          color: colorSheme.onPrimaryContainer,
                                        ),
                                      ),
                                      Text(
                                        NumberFormatting.toIdr(
                                          state.menus[index - 1].price,
                                        ),
                                        style: textTheme.bodySmall!.copyWith(
                                          color: colorSheme.onPrimaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  );
                }
                return SliverToBoxAdapter(
                  child: Column(
                    spacing: 16,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "assets/images/hot-air-balloon.png",
                        color: colorSheme.onSurface,
                      ),
                      Text(
                        "Menu kosong, yuk tambahkan menunya",
                        style: textTheme.titleMedium,
                      ),
                      FilledButton.tonalIcon(
                        icon: const Icon(UniconsLine.plus_circle),
                        onPressed: () async {
                          _onAddNewMenuPressed(context);
                        },
                        label: const Text("Tambah Menu"),
                      ),
                    ],
                  ),
                );
              }
              if (state is MenusInitial) {
                return const SliverGap(0);
              }
              return SliverToBoxAdapter(
                child: Column(
                  spacing: 16,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/images/FATAL Error 3 Streamline Barcelona.png",
                      scale: 3,
                    ),
                    Text(
                      "Aw snap, you got an error!",
                      style: textTheme.titleMedium,
                    ),
                    FilledButton.tonalIcon(
                      icon: const Icon(UniconsLine.refresh),
                      onPressed: () async {
                        context.read<MenusBloc>().add(const MenusFetched());
                      },
                      label: const Text("Retry"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showCategoryOptionsBottomSheet(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorSheme,
    CategoryItem categoryItem,
  ) {
    WoltModalSheet.show(
      useRootNavigator: true,
      context: context,
      pageListBuilder: (bottomSheetContext) => [
        SliverWoltModalSheetPage(
          hasTopBarLayer: true,
          navBarHeight: 72.0,
          isTopBarLayerAlwaysVisible: true,
          topBarTitle: Text("Pilihan", style: textTheme.titleMedium),
          mainContentSliversBuilder: (_) {
            return [
              SliverToBoxAdapter(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: ListTile(
                        title: const Text("Modifikasi"),
                        onTap: () {
                          CategoriesSelector.onModifyCategoryPressed(
                            context,
                            categoryId: categoryItem.id!,
                            categoryName: categoryItem.name,
                            categoryDesc: categoryItem.description,
                          );
                        },
                        leading: const Icon(UniconsLine.edit),
                      ),
                    ),
                    Flexible(
                      child: ListTile(
                        title: Text(
                          "Hapus",
                          style: textTheme.bodyLarge!.copyWith(
                            color: colorSheme.error,
                          ),
                        ),
                        onTap: () {
                          context.read<CategoriesBloc>().add(
                            CategoryDeleted(categoryId: categoryItem.id!),
                          );
                          Navigator.of(bottomSheetContext).pop();
                        },
                        leading: Icon(
                          UniconsLine.trash,
                          color: colorSheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
      ],
    );
  }

  void _showOptionsBottomSheet(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorSheme,
    int menuId,
  ) {
    WoltModalSheet.show(
      context: context,
      useRootNavigator: true,
      pageListBuilder: (bottomSheetContext) => [
        SliverWoltModalSheetPage(
          hasTopBarLayer: true,
          navBarHeight: 72.0,
          isTopBarLayerAlwaysVisible: true,
          topBarTitle: Text("Pilihan", style: textTheme.titleMedium),
          mainContentSliversBuilder: (_) {
            return [
              SliverToBoxAdapter(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: ListTile(
                        title: const Text("Modifikasi"),
                        onTap: () {},
                        leading: const Icon(UniconsLine.edit),
                      ),
                    ),
                    Flexible(
                      child: ListTile(
                        title: Text(
                          "Hapus",
                          style: textTheme.bodyLarge!.copyWith(
                            color: colorSheme.error,
                          ),
                        ),
                        onTap: () {
                          context.read<MenusBloc>().add(
                            MenuDeleted(menuId: menuId),
                          );
                          Navigator.of(bottomSheetContext).pop();
                        },
                        leading: Icon(
                          UniconsLine.trash,
                          color: colorSheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
      ],
    );
  }

  Widget _buildMenuImage(String? imagePath) {
    return SizedBox(
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        child: _getImage(imagePath),
      ),
    );
  }

  Widget _getImage(String? imagePath) {
    if (imagePath == null) {
      return AspectRatio(
        aspectRatio: 1,
        child: Image.asset(
          "assets/images/Home Cooked Meal.png",
          fit: BoxFit.fitWidth,
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: 1,
        child: Image.file(
          File(imagePath),
          fit: BoxFit.fitWidth,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              "assets/images/Home Cooked Meal.png",
              fit: BoxFit.fitWidth,
            );
          },
        ),
      );
    }
  }
}

class NumberFormatting {
  static String _baseCurrency({
    String? locale,
    String? name,
    String? symbol,
    num? number,
  }) {
    final baseFormat = NumberFormat.currency(
      locale: locale,
      name: name,
      symbol: symbol,
      decimalDigits: 0,
    );
    return baseFormat.format(number);
  }

  static String toIdr(num number) {
    return _baseCurrency(
      number: number,
      locale: 'id',
      name: 'IDR',
      symbol: 'Rp',
    );
  }
}
