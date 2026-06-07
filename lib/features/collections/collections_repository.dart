import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import 'models/collections_models.dart';

class CollectionsRepository {
  const CollectionsRepository(this._api);

  final ApiClient _api;

  Future<CobranzaResumen> getResumen() {
    return _api.getData<CobranzaResumen>(
      ApiEndpoints.cobrosResumen,
      fromJson: CobranzaResumen.fromJson,
    );
  }

  Future<PagedResult<CobroPendiente>> getPendientes(CobrosQuery query) {
    return _api.getData<PagedResult<CobroPendiente>>(
      ApiEndpoints.cobrosPendientes,
      queryParameters: query.toQuery(),
      fromJson: (json) => PagedResult.fromJson(json, CobroPendiente.fromJson),
    );
  }

  Future<SaldoCliente> getSaldoCliente(int clienteId) {
    return _api.getData<SaldoCliente>(
      ApiEndpoints.cobrosCliente(clienteId),
      fromJson: SaldoCliente.fromJson,
    );
  }

  Future<PagoCliente> registrarPago(int dteId, RegistrarPagoForm form) {
    return _api.postData<PagoCliente>(
      ApiEndpoints.cobrosDtePagos(dteId),
      data: form.toJson(),
      fromJson: PagoCliente.fromJson,
    );
  }

  Future<CobroQr> generarQr(GenerarQrCobroRequest request) {
    return _api.postData<CobroQr>(
      ApiEndpoints.cobrosQr,
      data: request.toJson(),
      fromJson: CobroQr.fromJson,
    );
  }
}
