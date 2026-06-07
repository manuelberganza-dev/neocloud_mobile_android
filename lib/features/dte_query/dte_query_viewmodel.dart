import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import 'dte_query_repository.dart';
import 'models/dte_query_models.dart';

final dteQueryRepositoryProvider = Provider.autoDispose<DteQueryRepository>((
  ref,
) {
  return DteQueryRepository(ref.watch(apiClientProvider));
});

final dteQueryViewModelProvider =
    NotifierProvider.autoDispose<DteQueryViewModel, DteQueryState>(
      DteQueryViewModel.new,
    );

class DteQueryViewModel extends Notifier<DteQueryState> {
  @override
  DteQueryState build() {
    return DteQueryState.initial();
  }

  Future<void> loadFirstPage() async {
    final filters = state.filters.firstPage();
    state = state.copyWith(
      filters: filters,
      isLoading: true,
      errorMessage: null,
      traceId: null,
      lastDownloadedFile: null,
    );
    await _load(filters, append: false);
  }

  Future<void> refresh() {
    return loadFirstPage();
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) {
      return;
    }

    final filters = state.filters.copyWith(page: state.filters.page + 1);
    state = state.copyWith(filters: filters, isLoadingMore: true);
    await _load(filters, append: true);
  }

  Future<void> applyFilters({
    String? search,
    String? estadoCodigo,
    String? tipoDteCodigo,
    DateTime? desde,
    DateTime? hasta,
  }) async {
    final filters = state.filters
        .copyWith(
          search: search,
          estadoCodigo: estadoCodigo,
          tipoDteCodigo: tipoDteCodigo,
          desde: desde,
          hasta: hasta,
        )
        .firstPage();

    state = state.copyWith(filters: filters, isLoading: true);
    await _load(filters, append: false);
  }

  Future<void> setStatus(String? status) async {
    await applyFilters(
      search: state.filters.search,
      estadoCodigo: status,
      tipoDteCodigo: state.filters.tipoDteCodigo,
      desde: state.filters.desde,
      hasta: state.filters.hasta,
    );
  }

  Future<void> setType(String? type) async {
    await applyFilters(
      search: state.filters.search,
      estadoCodigo: state.filters.estadoCodigo,
      tipoDteCodigo: type,
      desde: state.filters.desde,
      hasta: state.filters.hasta,
    );
  }

  Future<void> setDateRange(DateTime? desde, DateTime? hasta) async {
    await applyFilters(
      search: state.filters.search,
      estadoCodigo: state.filters.estadoCodigo,
      tipoDteCodigo: state.filters.tipoDteCodigo,
      desde: desde,
      hasta: hasta,
    );
  }

  Future<void> clearFilters() async {
    state = state.copyWith(filters: const DteFilters(), isLoading: true);
    await _load(const DteFilters(), append: false);
  }

  Future<void> loadDetail(int id) async {
    state = state.copyWith(
      selectedDetail: null,
      isDetailLoading: true,
      errorMessage: null,
      traceId: null,
      lastDownloadedFile: null,
    );

    try {
      final detail = await ref.read(dteQueryRepositoryProvider).getDetail(id);
      state = state.copyWith(selectedDetail: detail, isDetailLoading: false);
    } catch (error) {
      final apiError = error is ApiException ? error : null;
      state = state.copyWith(
        isDetailLoading: false,
        errorMessage: _friendlyError(error),
        traceId: apiError?.traceId,
      );
    }
  }

  Future<DteDownloadedFile?> downloadPdf() {
    return _downloadSelectedFile(kind: _DteFileKind.pdf);
  }

  Future<DteDownloadedFile?> downloadJson() {
    return _downloadSelectedFile(kind: _DteFileKind.json);
  }

  Future<DteReenvioResult?> resendEmail(String email) async {
    final detail = state.selectedDetail;
    final cleanEmail = email.trim();
    if (detail == null || cleanEmail.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Indica un correo valido para reenviar el DTE.',
      );
      return null;
    }

    state = state.copyWith(
      isSendingEmail: true,
      errorMessage: null,
      traceId: null,
    );

    try {
      final result = await ref
          .read(dteQueryRepositoryProvider)
          .resendEmail(id: detail.id, email: cleanEmail);
      state = state.copyWith(isSendingEmail: false);
      return result;
    } catch (error) {
      final apiError = error is ApiException ? error : null;
      state = state.copyWith(
        isSendingEmail: false,
        errorMessage: _friendlyError(error),
        traceId: apiError?.traceId,
      );
      return null;
    }
  }

  Future<void> _load(DteFilters filters, {required bool append}) async {
    try {
      final page = await ref
          .read(dteQueryRepositoryProvider)
          .listDocuments(filters);
      state = state.withPage(page, append: append);
    } catch (error) {
      final apiError = error is ApiException ? error : null;
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: _friendlyError(error),
        traceId: apiError?.traceId,
      );
    }
  }

  Future<DteDownloadedFile?> _downloadSelectedFile({
    required _DteFileKind kind,
  }) async {
    final detail = state.selectedDetail;
    if (detail == null) {
      state = state.copyWith(errorMessage: 'Selecciona un DTE primero.');
      return null;
    }

    state = state.copyWith(
      isFileBusy: true,
      errorMessage: null,
      traceId: null,
      lastDownloadedFile: null,
    );

    try {
      final repository = ref.read(dteQueryRepositoryProvider);
      final bytes = kind == _DteFileKind.pdf
          ? await repository.downloadPdf(detail.id)
          : await repository.downloadJson(detail.id);

      if (bytes.isEmpty) {
        throw const ApiException(message: 'El archivo descargado esta vacio.');
      }

      final fileName = _fileName(detail, kind);
      final directory = await _downloadDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);

      final downloaded = DteDownloadedFile(path: file.path, fileName: fileName);
      state = state.copyWith(isFileBusy: false, lastDownloadedFile: downloaded);
      return downloaded;
    } catch (error) {
      final apiError = error is ApiException ? error : null;
      state = state.copyWith(
        isFileBusy: false,
        errorMessage: _friendlyError(error),
        traceId: apiError?.traceId,
      );
      return null;
    }
  }

  Future<Directory> _downloadDirectory() async {
    return await getExternalStorageDirectory() ?? await getTemporaryDirectory();
  }

  String _fileName(DteDetail detail, _DteFileKind kind) {
    final safeNumber = detail.numeroControl.replaceAll(
      RegExp(r'[^A-Za-z0-9_-]+'),
      '_',
    );
    return '$safeNumber.${kind.extension}';
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

enum _DteFileKind {
  pdf('pdf'),
  json('json');

  const _DteFileKind(this.extension);

  final String extension;
}
