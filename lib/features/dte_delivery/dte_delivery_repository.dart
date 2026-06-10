import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import 'models/dte_delivery_models.dart';

final dteDeliveryRepositoryProvider =
    Provider.autoDispose<DteDeliveryRepository>((ref) {
      return DteDeliveryRepository(ref.watch(apiClientProvider));
    });

class DteDeliveryRepository {
  const DteDeliveryRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<int>> downloadPdf(int documentId) {
    return _apiClient.getBytes(ApiEndpoints.dteDocumentoPdf(documentId));
  }

  Future<List<int>> downloadJson(int documentId) {
    return _apiClient.getBytes(ApiEndpoints.dteDocumentoJson(documentId));
  }

  Future<DteEmailDeliveryResult> resendEmail({
    required int documentId,
    required String email,
  }) {
    return _apiClient.postData<DteEmailDeliveryResult>(
      ApiEndpoints.dteDocumentoReenviar(documentId),
      data: {'destinatario': email.trim()},
      fromJson: DteEmailDeliveryResult.fromJson,
    );
  }
}
