import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import 'models/dte_config_models.dart';

class DteConfigRepository {
  const DteConfigRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<DteConfig> getConfig() {
    return _apiClient.getData<DteConfig>(
      ApiEndpoints.dteConfiguracion,
      fromJson: DteConfig.fromJson,
    );
  }

  Future<DteConfig> saveConfig(DteConfigForm form) {
    return _apiClient.putData<DteConfig>(
      ApiEndpoints.dteConfiguracion,
      data: form.toJson(),
      fromJson: DteConfig.fromJson,
    );
  }

  Future<DteConfig> uploadCertificate(CertificateUpload upload) {
    return _apiClient.postData<DteConfig>(
      ApiEndpoints.dteConfiguracionCertificado,
      data: upload.toJson(),
      fromJson: DteConfig.fromJson,
    );
  }

  Future<DteConnectionTestResult> testConnection() {
    return _apiClient.postData<DteConnectionTestResult>(
      ApiEndpoints.dteConfiguracionProbarConexion,
      fromJson: DteConnectionTestResult.fromJson,
    );
  }
}
