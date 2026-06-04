import '../entities/dashboard_snapshot.dart';

abstract interface class DashboardRepository {
  Stream<DashboardSnapshot> watchDashboard();
}
