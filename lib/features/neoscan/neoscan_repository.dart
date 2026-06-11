import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import 'models/neoscan_models.dart';

class NeoScanRepository {
  const NeoScanRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<PagedResult<ScanDocument>> list(ScanFilters filters) {
    return _apiClient.getData<PagedResult<ScanDocument>>(
      ApiEndpoints.scanAiDocumentos,
      queryParameters: filters.toQuery(),
      fromJson: (json) => PagedResult.fromJson(json, ScanDocument.fromJson),
    );
  }

  Future<ScanDocument> get(int id) {
    return _apiClient.getData<ScanDocument>(
      ApiEndpoints.scanAiDocumento(id),
      fromJson: ScanDocument.fromJson,
    );
  }

  Future<ScanDocument> upload(ScanUploadRequest request) {
    return _apiClient.postData<ScanDocument>(
      ApiEndpoints.scanAiDocumentos,
      data: request.toJson(),
      fromJson: ScanDocument.fromJson,
    );
  }

  Future<ScanDocument> correctFields(int id, ScanFields fields) {
    return _apiClient.putData<ScanDocument>(
      ApiEndpoints.scanAiCampos(id),
      data: fields.toCorrectionJson(),
      fromJson: ScanDocument.fromJson,
    );
  }

  Future<ScanDocument> registerExpense(int id, ScanFields fields) {
    return _apiClient.postData<ScanDocument>(
      ApiEndpoints.scanAiRegistrarGasto(id),
      data: fields.toGastoJson(),
      fromJson: ScanDocument.fromJson,
    );
  }

  Future<ScanDocument> registerPurchase(int id, ScanFields fields) {
    return _apiClient.postData<ScanDocument>(
      ApiEndpoints.scanAiRegistrarCompra(id),
      data: fields.toCompraJson(),
      fromJson: ScanDocument.fromJson,
    );
  }

  Future<ScanDocument> registerReceivedDte(int id, ScanFields fields) {
    return _apiClient.postData<ScanDocument>(
      ApiEndpoints.scanAiRegistrarDteRecibido(id),
      data: fields.toDteRecibidoJson(),
      fromJson: ScanDocument.fromJson,
    );
  }

  Future<void> reject(int id, String reason) {
    return _apiClient.postVoid(
      ApiEndpoints.scanAiRechazar(id),
      data: {'motivo': reason},
    );
  }
}
