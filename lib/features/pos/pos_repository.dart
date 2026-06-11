import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import '../invoice/models/invoice_models.dart';
import 'models/pos_models.dart';

class PosRepository {
  const PosRepository(this._api);

  final ApiClient _api;

  Future<PosSummary> getSummary() {
    return _api.getData<PosSummary>(
      ApiEndpoints.posResumen,
      fromJson: PosSummary.fromJson,
    );
  }

  Future<PagedResult<PosSale>> listSales(PosQuery query) {
    return _api.getData<PagedResult<PosSale>>(
      ApiEndpoints.posVentas,
      queryParameters: query.toQuery(),
      fromJson: (json) => PagedResult.fromJson(json, PosSale.fromJson),
    );
  }

  Future<PosSale> getSale(int id) {
    return _api.getData<PosSale>(
      ApiEndpoints.posVenta(id),
      fromJson: PosSale.fromJson,
    );
  }

  Future<PosSale> createSale(PosSaleDraft draft) {
    return _api.postData<PosSale>(
      ApiEndpoints.posVentas,
      data: draft.toJson(),
      fromJson: PosSale.fromJson,
    );
  }

  Future<void> cancelSale(int id) {
    return _api.postVoid(ApiEndpoints.posVentaAnular(id));
  }

  Future<List<int>> downloadTicket(int id) {
    return _api.getBytes(ApiEndpoints.posVentaTicket(id));
  }

  Future<void> sendTicket({required int id, required String email}) {
    return _api.postVoid(
      ApiEndpoints.posVentaEnviar(id),
      data: {'email': email.trim()},
    );
  }

  Future<PosPromotionResult> promoteSale({
    required int id,
    required String tipoDteCodigo,
    int? clienteId,
  }) {
    return _api.postData<PosPromotionResult>(
      ApiEndpoints.posVentaPromover(id),
      data: {'tipoDteCodigo': tipoDteCodigo, 'clienteId': clienteId},
      fromJson: PosPromotionResult.fromJson,
    );
  }

  Future<List<InvoiceLookupOption>> searchProducts(String search) {
    return _api.getData<List<InvoiceLookupOption>>(
      ApiEndpoints.lookupsProductos,
      queryParameters: {'search': search.trim()},
      fromJson: _lookupListFromJson,
    );
  }

  Future<PosCashSession?> getCashStatus() {
    return _api.getOptionalData<PosCashSession>(
      ApiEndpoints.posCajaEstado,
      fromJson: PosCashSession.fromJson,
    );
  }

  Future<PagedResult<PosCashSession>> listCashSessions() {
    return _api.getData<PagedResult<PosCashSession>>(
      ApiEndpoints.posCaja,
      queryParameters: const {'page': 1, 'pageSize': 10},
      fromJson: (json) => PagedResult.fromJson(json, PosCashSession.fromJson),
    );
  }

  Future<PosCashSession> getCashSession(int id) {
    return _api.getData<PosCashSession>(
      ApiEndpoints.posCajaDetalle(id),
      fromJson: PosCashSession.fromJson,
    );
  }

  Future<PosCashSession> openCash(PosOpenCashRequest request) {
    return _api.postData<PosCashSession>(
      ApiEndpoints.posCajaAbrir,
      data: request.toJson(),
      fromJson: PosCashSession.fromJson,
    );
  }

  Future<PosCashSession> closeCash(int id, PosCloseCashRequest request) {
    return _api.postData<PosCashSession>(
      ApiEndpoints.posCajaCerrar(id),
      data: request.toJson(),
      fromJson: PosCashSession.fromJson,
    );
  }

  static List<InvoiceLookupOption> _lookupListFromJson(Object? json) {
    final list = json as List<dynamic>? ?? const [];
    return list.map(InvoiceLookupOption.fromJson).toList();
  }
}
