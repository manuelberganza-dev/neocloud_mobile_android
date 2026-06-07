import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../clients/models/client_models.dart';
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

  Future<Customer> createQuickCustomer(CustomerForm form) {
    return _apiClient.postData<Customer>(
      ApiEndpoints.clientes,
      data: form.toCreateJson(),
      fromJson: Customer.fromJson,
    );
  }

  Future<NitVerification> verifyDocument(String document) {
    return _apiClient.getData<NitVerification>(
      ApiEndpoints.lookupsVerificarNit,
      queryParameters: {'documento': document.trim()},
      fromJson: NitVerification.fromJson,
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
