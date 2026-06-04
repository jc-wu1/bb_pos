import '../entities/dashboard_snapshot.dart';
import '../repositories/dashboard_repository.dart';

class WatchDashboard {
  const WatchDashboard(this._repository);

  final DashboardRepository _repository;

  Stream<DashboardSnapshot> call() {
    return _repository.watchDashboard();
  }
}
