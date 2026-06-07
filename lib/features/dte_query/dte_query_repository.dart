import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import 'models/dte_query_models.dart';

class DteQueryRepository {
  const DteQueryRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<PagedResult<DteListItem>> listDocuments(DteFilters filters) {
    return _apiClient.getData<PagedResult<DteListItem>>(
      ApiEndpoints.dteDocumentos,
      queryParameters: filters.toQueryParameters(),
      fromJson: (json) => PagedResult.fromJson(json, DteListItem.fromJson),
    );
  }

  Future<DteDetail> getDetail(int id) {
    return _apiClient.getData<DteDetail>(
      ApiEndpoints.dteDocumento(id),
      fromJson: DteDetail.fromJson,
    );
  }

  Future<List<int>> downloadPdf(int id) {
    return _apiClient.getBytes(ApiEndpoints.dteDocumentoPdf(id));
  }

  Future<List<int>> downloadJson(int id) {
    return _apiClient.getBytes(ApiEndpoints.dteDocumentoJson(id));
  }

  Future<DteReenvioResult> resendEmail({
    required int id,
    required String email,
  }) {
    return _apiClient.postData<DteReenvioResult>(
      ApiEndpoints.dteDocumentoReenviar(id),
      data: {'destinatario': email},
      fromJson: DteReenvioResult.fromJson,
    );
  }
}
