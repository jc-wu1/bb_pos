import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:unicons/unicons.dart';

import '../../core/injector.dart';
import '../categories/display/bloc/categories_bloc.dart';
import '../categories/domain/usecases/categories_usecase.dart';
import '../menus/display/bloc/menus_bloc.dart';
import '../menus/display/menus_screen.dart';
import '../menus/domain/usecases/menus_usecase.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

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
      child: const OrdersScreenView(),
    );
  }
}

class OrdersScreenView extends StatefulWidget {
  const OrdersScreenView({super.key});

  @override
  State<OrdersScreenView> createState() => _OrdersScreenViewState();
}

class _OrdersScreenViewState extends State<OrdersScreenView> {
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorSheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        spacing: 16,
        children: [
          Expanded(
            flex: 2,
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
                SliverToBoxAdapter(
                  child: Text("Menu", style: textTheme.titleLarge),
                ),
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
                                  key: const PageStorageKey<String>(
                                    'myListViewKey',
                                  ),
                                  scrollDirection: Axis.horizontal,
                                  separatorBuilder: (context, index) =>
                                      const Gap(8),
                                  itemCount: state.categories.length,
                                  itemBuilder: (_, int index) {
                                    return Center(
                                      child: ActionChip(
                                        avatar: CircleAvatar(
                                          backgroundColor:
                                              colorSheme.primaryContainer,
                                          foregroundColor:
                                              colorSheme.onPrimaryContainer,
                                          child: HugeIcon(
                                            icon: HugeIcons
                                                .strokeRoundedMenuRestaurant,
                                            color:
                                                colorSheme.onPrimaryContainer,
                                            size: 18,
                                          ),
                                        ),
                                        onPressed: () {
                                          context.read<MenusBloc>().add(
                                            MenusFetched(
                                              categoryName:
                                                  state.categories[index].name,
                                            ),
                                          );
                                        },
                                        label: Text(
                                          state.categories[index].name,
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
                          itemCount: state.menus.length,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 200,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 4 / 6,
                              ),
                          itemBuilder: (context, index) {
                            return Card.outlined(
                              clipBehavior: Clip.hardEdge,
                              child: InkWell(
                                onTap: () {},
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildMenuImage(
                                          state.menus[index].imageUrl,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                            left: 8.0,
                                            right: 8.0,
                                          ),
                                          child: Text(
                                            state.menus[index].name,
                                            style: textTheme.titleSmall!
                                                .copyWith(
                                                  color: colorSheme
                                                      .onPrimaryContainer,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8.0,
                                        right: 8.0,
                                        bottom: 8.0,
                                      ),
                                      child: Text(
                                        NumberFormatting.toIdr(
                                          state.menus[index].price,
                                        ),
                                        style: textTheme.bodySmall!.copyWith(
                                          color: colorSheme.onPrimaryContainer,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
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
                              onPressed: () async {},
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
                              context.read<MenusBloc>().add(
                                const MenusFetched(),
                              );
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
          ),
          const Expanded(flex: 1, child: Text("Heellloo this is Row")),
        ],
      ),
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
