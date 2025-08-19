import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:unicons/unicons.dart';

class MenusScreen extends StatelessWidget {
  const MenusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MenusScreenView();
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
                  onPressed: () {},
                  label: const Text("Filter"),
                  icon: const Icon(UniconsLine.filter),
                ),
              ],
            ),
          ),
          const SliverGap(8),
          SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) => Card(child: Text("A$index")),
          ),
        ],
      ),
    );
  }
}
