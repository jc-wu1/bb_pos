import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardScreenView();
  }
}

class DashboardScreenView extends StatefulWidget {
  const DashboardScreenView({super.key});

  @override
  State<DashboardScreenView> createState() => _DashboardScreenViewState();
}

class _DashboardScreenViewState extends State<DashboardScreenView> {
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorSheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text("Dashboard", style: textTheme.titleLarge),
            pinned: true,
          ),
          SliverList.builder(
            itemCount: 100,
            itemBuilder: (context, index) => Card(
              margin: EdgeInsets.zero,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: const Text("ASdshajkdhsa"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
