import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:unicons/unicons.dart';

import '../../../core/injector.dart';
import '../../categories/data/model/category.dart';
import '../../categories/domain/usecases/categories_usecase.dart';
import '../data/model/menu_model.dart';
import '../domain/usecases/menus_usecase.dart';
import 'bloc/menus_bloc.dart';

class MenusScreen extends StatelessWidget {
  const MenusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MenusBloc(usecase: sl<MenusUsecase>())..add(const MenusFetched()),
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
            child: Row(
              spacing: 8,
              children: [
                Text("Menu Management", style: textTheme.titleLarge),
                Expanded(
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
              ],
            ),
          ),
          const SliverGap(8),
          SliverToBoxAdapter(
            child: Row(
              spacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () {},
                  label: const Text("Buat menu baru"),
                  icon: const Icon(UniconsLine.plus),
                ),
              ],
            ),
          ),
          const SliverGap(8),
          SliverToBoxAdapter(
            child: Row(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {},
                  label: const Text("Filter"),
                  icon: const Icon(UniconsLine.filter),
                ),
              ],
            ),
          ),
          const SliverGap(8),
          BlocBuilder<MenusBloc, MenusState>(
            builder: (context, state) {
              if (state is MenusLoadInProgress) {
                return SliverGrid.builder(
                  itemCount: 2,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2 / 1,
                  ),
                  itemBuilder: (context, index) => const Card.outlined(),
                );
              }
              if (state is MenusLoadComplete) {
                if (state.menus.isNotEmpty) {
                  return SliverGrid.builder(
                    itemCount: state.menus.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 250,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 2 / 1,
                        ),
                    itemBuilder: (context, index) {
                      return Card.outlined(
                        color: colorSheme.primaryContainer,
                        clipBehavior: Clip.hardEdge,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                UniconsSolid.table,
                                color: colorSheme.onPrimaryContainer,
                              ),
                              const Spacer(),
                              Text(
                                state.menus[index].name,
                                style: textTheme.headlineSmall!.copyWith(
                                  color: colorSheme.onPrimaryContainer,
                                ),
                              ),
                              Text(
                                "${state.menus.length} Items",
                                style: textTheme.labelSmall!.copyWith(
                                  color: colorSheme.onPrimaryContainer,
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Menu kosong, Yuk tambahkan menunya"),
                      ElevatedButton(
                        onPressed: () {
                          final MenuItem menu = const MenuItem(
                            categoryId: 1,
                            name: 'Americano',
                            description: 'Hot black coffee',
                            price: 2.50,
                            category: "Beverages",
                          );

                          context.read<MenusBloc>().add(
                            MenuInserted(menuItem: menu),
                          );
                        },
                        child: const Text("Tambah Menu"),
                      ),
                    ],
                  ),
                );
              }
              return SliverGrid.builder(
                itemCount: 2,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 250,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2 / 1,
                ),
                itemBuilder: (context, index) => const Card.outlined(),
              );
            },
          ),
        ],
      ),
    );
  }
}
