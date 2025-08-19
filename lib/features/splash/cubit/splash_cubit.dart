import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/injector.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  Future<void> initializeApp() async {
    emit(const SplashLoading());
    await Future.delayed(const Duration(seconds: 3), () async {
      await initDbService();
    });
    emit(const SplashFinished());
  }
}
