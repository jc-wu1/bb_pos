import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const OrdersScreenView();
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
    return const Center(child: Text("Orders Screen"));
  }
}
