part of 'splash_cubit.dart';

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object> get props => [];
}

final class SplashInitial extends SplashState {}

final class SplashLoading extends SplashState {
  const SplashLoading();
}

final class SplashFinished extends SplashState {
  const SplashFinished();
}

final class SplashError extends SplashState {
  final String message;
  const SplashError(this.message);
}
