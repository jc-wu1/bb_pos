part of 'dashboard_cubit.dart';

const Object _stateFieldNotSet = Object();

enum DashboardStatus { initial, loading, ready, failure }

class DashboardState extends Equatable {
  const DashboardState({
    required this.status,
    required this.snapshot,
    required this.errorMessage,
    required this.errorSerial,
  });

  factory DashboardState.initial() {
    return const DashboardState(
      status: DashboardStatus.initial,
      snapshot: null,
      errorMessage: null,
      errorSerial: 0,
    );
  }

  final DashboardStatus status;
  final DashboardSnapshot? snapshot;
  final String? errorMessage;
  final int errorSerial;

  bool get isInitialLoading {
    return status == DashboardStatus.loading && snapshot == null;
  }

  DashboardState copyWith({
    DashboardStatus? status,
    Object? snapshot = _stateFieldNotSet,
    Object? errorMessage = _stateFieldNotSet,
    bool clearErrorMessage = false,
    int? errorSerial,
  }) {
    final resolvedErrorMessage = clearErrorMessage
        ? null
        : identical(errorMessage, _stateFieldNotSet)
        ? this.errorMessage
        : errorMessage as String?;

    return DashboardState(
      status: status ?? this.status,
      snapshot: identical(snapshot, _stateFieldNotSet)
          ? this.snapshot
          : snapshot as DashboardSnapshot?,
      errorMessage: resolvedErrorMessage,
      errorSerial: errorSerial ?? this.errorSerial,
    );
  }

  @override
  List<Object?> get props {
    return [status, snapshot, errorMessage, errorSerial];
  }
}
