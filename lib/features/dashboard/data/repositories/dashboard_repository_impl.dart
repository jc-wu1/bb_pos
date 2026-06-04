import '../../domain/entities/dashboard_snapshot.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../data_sources/dashboard_local_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl({required DashboardLocalDataSource dataSource})
    : _dataSource = dataSource;

  final DashboardLocalDataSource _dataSource;

  @override
  Stream<DashboardSnapshot> watchDashboard() {
    return _dataSource.watchDashboard();
  }
}
