import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:unicons/unicons.dart';

import '../../../core/injector.dart';
import '../../categories/display/bloc/categories_bloc.dart';
import '../../categories/domain/usecases/categories_usecase.dart';
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
                FilledButton.tonalIcon(
                  onPressed: () {},
                  label: const Text("Tambah Menu"),
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
          BlocBuilder<CategoriesBloc, CategoriesState>(
            builder: (context, state) {
              if (state is CategoriesLoadInProgress) {
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
              if (state is CategoriesLoadComplete) {
                if (state.categories.isNotEmpty) {
                  return SliverGrid.builder(
                    itemCount: state.categories.length,
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
                                state.categories[index].name,
                                style: textTheme.headlineSmall!.copyWith(
                                  color: colorSheme.onPrimaryContainer,
                                ),
                              ),
                              Text(
                                "${state.categories.length} Items",
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
                return const SliverGap(1);
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
                  itemBuilder: (context, index) => const Card.filled(),
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
                      return Card.filled(
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
                          final result = await showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return const Dialog(
                                constraints: BoxConstraints(
                                  maxWidth: 560,
                                  minHeight: 280,
                                ),
                                child: AddNewMenuDialog(),
                              );
                            },
                          );
                          print("dialog result $result");
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
}
