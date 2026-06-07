import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import 'collections_repository.dart';
import 'models/collections_models.dart';

final collectionsRepositoryProvider =
    Provider.autoDispose<CollectionsRepository>((ref) {
      return CollectionsRepository(ref.watch(apiClientProvider));
    });

final collectionsViewModelProvider =
    NotifierProvider.autoDispose<CollectionsViewModel, CollectionsState>(
      CollectionsViewModel.new,
    );

class CollectionsViewModel extends Notifier<CollectionsState> {
  @override
  CollectionsState build() {
    return CollectionsState.initial();
  }

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      query: state.query.firstPage(),
      clearError: true,
      clearSuccess: true,
    );

    try {
      final repository = ref.read(collectionsRepositoryProvider);
      final summary = await repository.getResumen();
      final page = await repository.getPendientes(state.query.firstPage());
      state = state
          .copyWith(summary: summary, isLoading: false)
          .withPage(page, false);
    } catch (error) {
      _setError(error, isLoading: false);
    }
  }

  Future<void> refresh() {
    return load();
  }

  Future<void> setSoloVencidas(bool value) async {
    final query = state.query.copyWith(soloVencidas: value).firstPage();
    state = state.copyWith(query: query, isLoading: true, clearError: true);
    await _loadPendientes(query, append: false);
  }

  Future<void> search(String value) async {
    final clean = value.trim();
    final query = state.query
        .copyWith(
          search: clean.isEmpty ? null : clean,
          clearSearch: clean.isEmpty,
        )
        .firstPage();
    state = state.copyWith(query: query, isLoading: true, clearError: true);
    await _loadPendientes(query, append: false);
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isBusy) {
      return;
    }
    final query = state.query.copyWith(page: state.query.page + 1);
    state = state.copyWith(query: query, isLoadingMore: true);
    await _loadPendientes(query, append: true);
  }

  Future<SaldoCliente?> loadSaldoCliente(int? clienteId) async {
    if (clienteId == null) {
      state = state.copyWith(
        errorMessage: 'Este documento no tiene cliente asociado.',
        traceId: null,
      );
      return null;
    }

    state = state.copyWith(
      isLoadingSaldo: true,
      clearError: true,
      clearSuccess: true,
      clearSaldo: true,
    );

    try {
      final saldo = await ref
          .read(collectionsRepositoryProvider)
          .getSaldoCliente(clienteId);
      state = state.copyWith(isLoadingSaldo: false, selectedSaldo: saldo);
      return saldo;
    } catch (error) {
      _setError(error, isLoadingSaldo: false);
      return null;
    }
  }

  Future<PagoCliente?> registrarPago(
    CobroPendiente item,
    RegistrarPagoForm form,
  ) async {
    state = state.copyWith(
      isSavingPayment: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final pago = await ref
          .read(collectionsRepositoryProvider)
          .registrarPago(item.dteDocumentoId, form);
      state = state.copyWith(
        isSavingPayment: false,
        lastPayment: pago,
        successMessage: 'Pago registrado correctamente.',
      );
      await load();
      return pago;
    } catch (error) {
      _setError(error, isSavingPayment: false);
      return null;
    }
  }

  Future<CobroQr?> generarQr(CobroPendiente item) async {
    state = state.copyWith(
      isGeneratingQr: true,
      clearError: true,
      clearSuccess: true,
      clearQr: true,
    );

    try {
      final qr = await ref
          .read(collectionsRepositoryProvider)
          .generarQr(
            GenerarQrCobroRequest(dteDocumentoId: item.dteDocumentoId),
          );
      state = state.copyWith(isGeneratingQr: false, lastQr: qr);
      return qr;
    } catch (error) {
      _setError(error, isGeneratingQr: false);
      return null;
    }
  }

  Future<void> compartirQr(CobroQr qr) async {
    state = state.copyWith(isSharingQr: true, clearError: true);
    try {
      final bytes = base64Decode(qr.qrPngBase64);
      final dir = await getTemporaryDirectory();
      final cleanRef = qr.referencia.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
      final file = File('${dir.path}/cobro_$cleanRef.png');
      await file.writeAsBytes(bytes, flush: true);

      await SharePlus.instance.share(
        ShareParams(
          title: 'Compartir cobro',
          subject: 'Cobro ${qr.referencia}',
          text:
              'Cobro ${qr.referencia} por ${formatMoney(qr.monto)}\n${qr.payload}',
          files: [
            XFile(
              file.path,
              mimeType: 'image/png',
              name: 'cobro_$cleanRef.png',
            ),
          ],
          fileNameOverrides: ['cobro_$cleanRef.png'],
        ),
      );
      state = state.copyWith(isSharingQr: false);
    } catch (error) {
      _setError(error, isSharingQr: false);
    }
  }

  Future<void> compartirTexto(CobroQr qr) async {
    state = state.copyWith(isSharingQr: true, clearError: true);
    try {
      await SharePlus.instance.share(
        ShareParams(
          title: 'Compartir enlace de cobro',
          subject: 'Cobro ${qr.referencia}',
          text:
              'Cobro ${qr.referencia} por ${formatMoney(qr.monto)}\n${qr.payload}',
        ),
      );
      state = state.copyWith(isSharingQr: false);
    } catch (error) {
      _setError(error, isSharingQr: false);
    }
  }

  Future<void> _loadPendientes(
    CobrosQuery query, {
    required bool append,
  }) async {
    try {
      final page = await ref
          .read(collectionsRepositoryProvider)
          .getPendientes(query);
      state = state.withPage(page, append);
    } catch (error) {
      _setError(error, isLoading: false, isLoadingMore: false);
    }
  }

  void _setError(
    Object error, {
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSavingPayment,
    bool? isLoadingSaldo,
    bool? isGeneratingQr,
    bool? isSharingQr,
  }) {
    state = state.copyWith(
      isLoading: isLoading,
      isLoadingMore: isLoadingMore,
      isSavingPayment: isSavingPayment,
      isLoadingSaldo: isLoadingSaldo,
      isGeneratingQr: isGeneratingQr,
      isSharingQr: isSharingQr,
      errorMessage: _friendlyError(error),
      traceId: error is ApiException ? error.traceId : null,
    );
  }

  String _friendlyError(Object error) {
    if (error is ApiException) {
      if (error.isForbidden) {
        return 'Tu usuario no tiene permisos de cobros.';
      }
      return error.errors.isEmpty
          ? error.message
          : '${error.message} ${error.errors.join(', ')}';
    }
    return 'No se pudo completar la operacion de cobros.';
  }
}
