import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/dashboard_snapshot.dart';
import '../../domain/usecase/watch_dashboard.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({required WatchDashboard watchDashboard})
    : _watchDashboard = watchDashboard,
      super(DashboardState.initial());

  final WatchDashboard _watchDashboard;

  StreamSubscription<DashboardSnapshot>? _dashboardSubscription;
  bool _isStarted = false;

  void load() {
    if (_isStarted) return;
    _isStarted = true;

    emit(state.copyWith(status: DashboardStatus.loading));

    _dashboardSubscription = _watchDashboard().listen(
      _onDashboardChanged,
      onError: (Object error, StackTrace stackTrace) {
        _emitStreamFailure();
      },
    );
  }

  Future<void> retry() async {
    await _dashboardSubscription?.cancel();
    _dashboardSubscription = null;
    _isStarted = false;
    load();
  }

  void _onDashboardChanged(DashboardSnapshot snapshot) {
    emit(
      state.copyWith(
        status: DashboardStatus.ready,
        snapshot: snapshot,
        clearErrorMessage: true,
      ),
    );
  }

  void _emitStreamFailure() {
    emit(
      state.copyWith(
        status: DashboardStatus.failure,
        errorMessage: 'Ringkasan belum bisa dimuat. Coba lagi sebentar lagi.',
        errorSerial: state.errorSerial + 1,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _dashboardSubscription?.cancel();
    return super.close();
  }
}
