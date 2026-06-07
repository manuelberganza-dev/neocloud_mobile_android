import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import 'dte_config_repository.dart';
import 'models/dte_config_models.dart';

final dteConfigRepositoryProvider = Provider.autoDispose<DteConfigRepository>((
  ref,
) {
  return DteConfigRepository(ref.watch(apiClientProvider));
});

final dteConfigViewModelProvider =
    NotifierProvider.autoDispose<DteConfigViewModel, DteConfigState>(
      DteConfigViewModel.new,
    );

class DteConfigViewModel extends Notifier<DteConfigState> {
  @override
  DteConfigState build() {
    return DteConfigState.initial();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null, traceId: null);
    try {
      final config = await ref.read(dteConfigRepositoryProvider).getConfig();
      state = state.copyWith(isLoading: false, config: config);
    } catch (error) {
      _setError(error, isLoading: false);
    }
  }

  Future<bool> save(DteConfigForm form) async {
    state = state.copyWith(isSaving: true, errorMessage: null, traceId: null);
    try {
      final config = await ref
          .read(dteConfigRepositoryProvider)
          .saveConfig(form);
      state = state.copyWith(isSaving: false, config: config);
      return true;
    } catch (error) {
      _setError(error, isSaving: false);
      return false;
    }
  }

  Future<bool> uploadCertificate(CertificateUpload upload) async {
    state = state.copyWith(
      isUploadingCertificate: true,
      errorMessage: null,
      traceId: null,
    );
    try {
      final config = await ref
          .read(dteConfigRepositoryProvider)
          .uploadCertificate(upload);
      state = state.copyWith(isUploadingCertificate: false, config: config);
      return true;
    } catch (error) {
      _setError(error, isUploadingCertificate: false);
      return false;
    }
  }

  Future<DteConnectionTestResult?> testConnection() async {
    state = state.copyWith(
      isTestingConnection: true,
      errorMessage: null,
      traceId: null,
    );
    try {
      final result = await ref
          .read(dteConfigRepositoryProvider)
          .testConnection();
      final config = await ref.read(dteConfigRepositoryProvider).getConfig();
      state = state.copyWith(
        isTestingConnection: false,
        lastTest: result,
        config: config,
      );
      return result;
    } catch (error) {
      _setError(error, isTestingConnection: false);
      return null;
    }
  }

  void _setError(
    Object error, {
    bool? isLoading,
    bool? isSaving,
    bool? isUploadingCertificate,
    bool? isTestingConnection,
  }) {
    final apiError = error is ApiException ? error : null;
    state = state.copyWith(
      isLoading: isLoading,
      isSaving: isSaving,
      isUploadingCertificate: isUploadingCertificate,
      isTestingConnection: isTestingConnection,
      errorMessage: _friendlyError(error),
      traceId: apiError?.traceId,
    );
  }

  String _friendlyError(Object error) {
    if (error is ApiException) {
      if (error.errors.isEmpty) {
        return error.message;
      }
      return '${error.message} ${error.errors.join(', ')}';
    }
    return 'No se pudo completar la operacion. Revisa la conexion e intenta de nuevo.';
  }
}
