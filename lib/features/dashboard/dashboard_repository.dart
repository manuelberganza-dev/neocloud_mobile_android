import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import 'models/dashboard_models.dart';

class DashboardRepository {
  const DashboardRepository(this._api);

  final ApiClient _api;

  Future<DashboardEmpresa> getDashboard() {
    return _api.getData<DashboardEmpresa>(
      ApiEndpoints.dashboardEmpresa,
      fromJson: DashboardEmpresa.fromJson,
    );
  }
}
