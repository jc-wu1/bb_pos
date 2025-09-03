import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'cubit/splash_cubit.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is SplashError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          context.go("/");
        } else if (state is SplashFinished) {
          context.go("/dashboard");
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(backgroundColor: colorScheme.surface, elevation: 0),
        body: Center(
          child: BlocBuilder<SplashCubit, SplashState>(
            builder: (context, state) {
              if (state is SplashLoading) {
                return const CircularProgressIndicator.adaptive();
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
