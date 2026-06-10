import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import 'models/notification_models.dart';

class NotificationsRepository {
  const NotificationsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<AlertSummary> getSummary() {
    return _apiClient.getData<AlertSummary>(
      ApiEndpoints.alertasResumen,
      fromJson: AlertSummary.fromJson,
    );
  }

  Future<PagedResult<AppAlert>> list(AlertFilters filters) {
    return _apiClient.getData<PagedResult<AppAlert>>(
      ApiEndpoints.alertas,
      queryParameters: filters.toQuery(),
      fromJson: (json) => PagedResult.fromJson(json, AppAlert.fromJson),
    );
  }

  Future<void> markRead(int id) {
    return _apiClient.postVoid(ApiEndpoints.alertaLeer(id));
  }

  Future<void> resolve(int id) {
    return _apiClient.postVoid(ApiEndpoints.alertaResolver(id));
  }

  Future<void> markAllRead() {
    return _apiClient.postVoid(ApiEndpoints.alertasLeerTodas);
  }

  Future<NotificationPreferences> getPreferences() {
    return _apiClient.getData<NotificationPreferences>(
      ApiEndpoints.alertasPreferencias,
      fromJson: NotificationPreferences.fromJson,
    );
  }

  Future<NotificationPreferences> savePreferences(
    NotificationPreferences preferences,
  ) {
    return _apiClient.putData<NotificationPreferences>(
      ApiEndpoints.alertasPreferencias,
      data: preferences.toJson(),
      fromJson: NotificationPreferences.fromJson,
    );
  }

  Future<void> registerDevice(String token) {
    return _apiClient.postVoid(
      ApiEndpoints.alertasDispositivos,
      data: {'token': token, 'plataforma': 'ANDROID'},
    );
  }
}
