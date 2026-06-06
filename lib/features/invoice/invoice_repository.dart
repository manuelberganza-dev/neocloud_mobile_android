import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import 'models/invoice_models.dart';

class InvoiceRepository {
  const InvoiceRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<InvoiceLookupOption>> searchClients(String search) {
    return _apiClient.getData<List<InvoiceLookupOption>>(
      ApiEndpoints.lookupsClientes,
      queryParameters: {'search': search.trim()},
      fromJson: _lookupListFromJson,
    );
  }

  Future<List<InvoiceLookupOption>> searchProducts(String search) {
    return _apiClient.getData<List<InvoiceLookupOption>>(
      ApiEndpoints.lookupsProductos,
      queryParameters: {'search': search.trim()},
      fromJson: _lookupListFromJson,
    );
  }

  Future<DteEmissionResult> emitFactura(InvoiceState draft) {
    return _apiClient.postData<DteEmissionResult>(
      ApiEndpoints.dteEmitirFactura,
      data: draft.toFacturaRequest(),
      fromJson: DteEmissionResult.fromJson,
    );
  }

  Future<List<int>> downloadPdf(int documentId) {
    return _apiClient.getBytes(ApiEndpoints.dteDocumentoPdf(documentId));
  }

  static List<InvoiceLookupOption> _lookupListFromJson(Object? json) {
    final list = json as List<dynamic>? ?? const [];
    return list.map(InvoiceLookupOption.fromJson).toList();
  }
}
