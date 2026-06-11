import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import 'models/neoscan_models.dart';
import 'neoscan_repository.dart';

final neoScanRepositoryProvider = Provider.autoDispose<NeoScanRepository>((
  ref,
) {
  return NeoScanRepository(ref.watch(apiClientProvider));
});

final neoScanViewModelProvider =
    NotifierProvider.autoDispose<NeoScanViewModel, NeoScanState>(
      NeoScanViewModel.new,
    );

class NeoScanViewModel extends Notifier<NeoScanState> {
  @override
  NeoScanState build() {
    return NeoScanState.initial();
  }

  Future<void> load() async {
    final filters = state.filters.firstPage();
    state = state.copyWith(
      filters: filters,
      isLoading: true,
      errorMessage: null,
      traceId: null,
    );
    try {
      final page = await ref.read(neoScanRepositoryProvider).list(filters);
      state = state.withPage(page, false);
    } catch (error) {
      _setError(error, isLoading: false);
    }
  }

  Future<void> refresh() => load();

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.isLoadingMore) {
      return;
    }
    final filters = state.filters.copyWith(page: state.filters.page + 1);
    state = state.copyWith(filters: filters, isLoadingMore: true);
    try {
      final page = await ref.read(neoScanRepositoryProvider).list(filters);
      state = state.withPage(page, true);
    } catch (error) {
      _setError(error, isLoadingMore: false);
    }
  }

  Future<void> setStatus(String? status) async {
    state = state.copyWith(
      filters: state.filters
          .copyWith(estadoCodigo: status, search: state.filters.search)
          .firstPage(),
      isLoading: true,
      errorMessage: null,
      traceId: null,
    );
    try {
      final page = await ref
          .read(neoScanRepositoryProvider)
          .list(state.filters);
      state = state.withPage(page, false);
    } catch (error) {
      _setError(error, isLoading: false);
    }
  }

  Future<void> search(String value) async {
    state = state.copyWith(
      filters: state.filters.copyWith(search: value).firstPage(),
      isLoading: true,
      errorMessage: null,
      traceId: null,
    );
    try {
      final page = await ref
          .read(neoScanRepositoryProvider)
          .list(state.filters);
      state = state.withPage(page, false);
    } catch (error) {
      _setError(error, isLoading: false);
    }
  }

  Future<void> select(ScanDocument document) async {
    state = state.copyWith(selected: document, errorMessage: null);
    try {
      final fresh = await ref.read(neoScanRepositoryProvider).get(document.id);
      _replaceDocument(fresh);
    } catch (error) {
      _setError(error);
    }
  }

  Future<ScanDocument?> upload(ScanUploadRequest request) async {
    state = state.copyWith(
      isUploading: true,
      errorMessage: null,
      traceId: null,
    );
    try {
      final document = await ref
          .read(neoScanRepositoryProvider)
          .upload(request);
      state = state.copyWith(
        documents: [document, ...state.documents],
        selected: document,
        total: state.total + 1,
        isUploading: false,
      );
      return document;
    } catch (error) {
      _setError(error, isUploading: false);
      return null;
    }
  }

  Future<bool> correct(ScanDocument document, ScanFields fields) async {
    return _mutate(
      () => ref
          .read(neoScanRepositoryProvider)
          .correctFields(document.id, fields),
    );
  }

  Future<bool> registerExpense(ScanDocument document, ScanFields fields) async {
    return _mutate(
      () => ref
          .read(neoScanRepositoryProvider)
          .registerExpense(document.id, fields),
    );
  }

  Future<bool> registerPurchase(
    ScanDocument document,
    ScanFields fields,
  ) async {
    return _mutate(
      () => ref
          .read(neoScanRepositoryProvider)
          .registerPurchase(document.id, fields),
    );
  }

  Future<bool> registerReceivedDte(
    ScanDocument document,
    ScanFields fields,
  ) async {
    return _mutate(
      () => ref
          .read(neoScanRepositoryProvider)
          .registerReceivedDte(document.id, fields),
    );
  }

  Future<bool> reject(ScanDocument document, String reason) async {
    state = state.copyWith(isSaving: true, errorMessage: null, traceId: null);
    try {
      await ref.read(neoScanRepositoryProvider).reject(document.id, reason);
      final updated = await ref
          .read(neoScanRepositoryProvider)
          .get(document.id);
      _replaceDocument(updated, isSaving: false);
      return true;
    } catch (error) {
      _setError(error, isSaving: false);
      return false;
    }
  }

  Future<bool> _mutate(Future<ScanDocument> Function() action) async {
    state = state.copyWith(isSaving: true, errorMessage: null, traceId: null);
    try {
      final updated = await action();
      _replaceDocument(updated, isSaving: false);
      return true;
    } catch (error) {
      _setError(error, isSaving: false);
      return false;
    }
  }

  void _replaceDocument(ScanDocument document, {bool? isSaving}) {
    final items = [
      for (final item in state.documents)
        if (item.id == document.id) document else item,
    ];
    final exists = state.documents.any((item) => item.id == document.id);
    state = state.copyWith(
      documents: exists ? items : [document, ...state.documents],
      selected: document,
      isSaving: isSaving,
      errorMessage: null,
      traceId: null,
    );
  }

  void _setError(
    Object error, {
    bool? isLoading,
    bool? isLoadingMore,
    bool? isUploading,
    bool? isSaving,
  }) {
    final apiError = error is ApiException ? error : null;
    state = state.copyWith(
      isLoading: isLoading,
      isLoadingMore: isLoadingMore,
      isUploading: isUploading,
      isSaving: isSaving,
      errorMessage: _friendlyError(error),
      traceId: apiError?.traceId,
    );
  }

  String _friendlyError(Object error) {
    if (error is ApiException) {
      return error.errors.isEmpty
          ? error.message
          : '${error.message} ${error.errors.join(', ')}';
    }
    return 'No se pudo completar la accion de NeoScan.';
  }
}
