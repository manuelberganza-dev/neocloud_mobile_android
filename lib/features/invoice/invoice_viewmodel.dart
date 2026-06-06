import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import 'invoice_repository.dart';
import 'models/invoice_models.dart';

final invoiceRepositoryProvider = Provider.autoDispose<InvoiceRepository>((
  ref,
) {
  return InvoiceRepository(ref.watch(apiClientProvider));
});

final invoiceViewModelProvider =
    NotifierProvider.autoDispose<InvoiceViewModel, InvoiceState>(
      InvoiceViewModel.new,
    );

class InvoiceViewModel extends Notifier<InvoiceState> {
  @override
  InvoiceState build() {
    return InvoiceState.initial();
  }

  void selectType(String code) {
    state = state.copyWith(
      types: [
        for (final type in state.types)
          type.copyWith(selected: type.code == code),
      ],
      emission: null,
      errorMessage: null,
      pdfPath: null,
    );
  }

  Future<void> searchClients(String search) async {
    final query = search.trim();
    if (query.length < 2) {
      state = state.copyWith(
        clientResults: const [],
        isSearchingClients: false,
        errorMessage: null,
      );
      return;
    }

    state = state.copyWith(isSearchingClients: true, errorMessage: null);
    try {
      final results = await ref
          .read(invoiceRepositoryProvider)
          .searchClients(query);
      state = state.copyWith(clientResults: results, isSearchingClients: false);
    } catch (error) {
      state = state.copyWith(
        isSearchingClients: false,
        errorMessage: _friendlyError(error),
      );
    }
  }

  void selectClient(InvoiceLookupOption client) {
    state = state.copyWith(
      selectedClient: client,
      clientResults: const [],
      emission: null,
      errorMessage: null,
      pdfPath: null,
    );
  }

  void clearClient() {
    state = state.copyWith(
      selectedClient: null,
      emission: null,
      errorMessage: null,
      pdfPath: null,
    );
  }

  Future<void> searchProducts(String search) async {
    final query = search.trim();
    if (query.length < 2) {
      state = state.copyWith(
        productResults: const [],
        isSearchingProducts: false,
        errorMessage: null,
      );
      return;
    }

    state = state.copyWith(isSearchingProducts: true, errorMessage: null);
    try {
      final results = await ref
          .read(invoiceRepositoryProvider)
          .searchProducts(query);
      state = state.copyWith(
        productResults: results,
        isSearchingProducts: false,
      );
    } catch (error) {
      state = state.copyWith(
        isSearchingProducts: false,
        errorMessage: _friendlyError(error),
      );
    }
  }

  void addProduct(InvoiceLookupOption product) {
    final existingIndex = state.lines.indexWhere(
      (line) => line.productId == product.id,
    );

    final lines = [...state.lines];
    if (existingIndex >= 0) {
      final line = lines[existingIndex];
      lines[existingIndex] = line.copyWith(quantity: line.quantity + 1);
    } else {
      lines.add(InvoiceLine.fromProduct(product));
    }

    state = state.copyWith(
      lines: lines,
      productResults: const [],
      emission: null,
      errorMessage: null,
      pdfPath: null,
    );
  }

  void increaseQuantity(int index) {
    _updateLineQuantity(index, 1);
  }

  void decreaseQuantity(int index) {
    _updateLineQuantity(index, -1);
  }

  void removeLine(int index) {
    if (index < 0 || index >= state.lines.length) {
      return;
    }

    final lines = [...state.lines]..removeAt(index);
    state = state.copyWith(
      lines: lines,
      emission: null,
      errorMessage: null,
      pdfPath: null,
    );
  }

  Future<void> emitFactura() async {
    if (state.selectedClient == null) {
      state = state.copyWith(
        errorMessage: 'Selecciona un cliente antes de emitir.',
      );
      return;
    }

    if (state.lines.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Agrega al menos un producto a la factura.',
      );
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      emission: null,
      errorMessage: null,
      pdfPath: null,
    );

    try {
      final result = await ref
          .read(invoiceRepositoryProvider)
          .emitFactura(state);
      state = state.copyWith(isSubmitting: false, emission: result);
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<void> downloadPdf() async {
    final emission = state.emission;
    if (emission == null) {
      state = state.copyWith(errorMessage: 'Emite el DTE antes de descargar.');
      return;
    }

    state = state.copyWith(isPdfBusy: true, errorMessage: null);
    try {
      final path = await _downloadPdfToTemporaryFile(emission);
      state = state.copyWith(isPdfBusy: false, pdfPath: path);
    } catch (error) {
      state = state.copyWith(
        isPdfBusy: false,
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<void> sharePdf({required String channel}) async {
    final emission = state.emission;
    if (emission == null) {
      state = state.copyWith(errorMessage: 'Emite el DTE antes de compartir.');
      return;
    }

    state = state.copyWith(isPdfBusy: true, errorMessage: null);
    try {
      final path = state.pdfPath ?? await _downloadPdfToTemporaryFile(emission);
      final fileName = _pdfFileName(emission);
      await SharePlus.instance.share(
        ShareParams(
          title: 'Compartir DTE',
          subject: 'DTE ${emission.numeroControl}',
          text:
              'DTE ${emission.numeroControl} - ${formatMoney(emission.totalPagar)}',
          files: [XFile(path, mimeType: 'application/pdf', name: fileName)],
          fileNameOverrides: [fileName],
        ),
      );
      state = state.copyWith(isPdfBusy: false, pdfPath: path);
    } catch (error) {
      state = state.copyWith(
        isPdfBusy: false,
        errorMessage:
            'No se pudo compartir por $channel. ${_friendlyError(error)}',
      );
    }
  }

  void _updateLineQuantity(int index, double delta) {
    if (index < 0 || index >= state.lines.length) {
      return;
    }

    final line = state.lines[index];
    final nextQuantity = line.quantity + delta;
    if (nextQuantity <= 0) {
      removeLine(index);
      return;
    }

    final lines = [...state.lines];
    lines[index] = line.copyWith(quantity: nextQuantity);
    state = state.copyWith(
      lines: lines,
      emission: null,
      errorMessage: null,
      pdfPath: null,
    );
  }

  Future<String> _downloadPdfToTemporaryFile(DteEmissionResult emission) async {
    final bytes = await ref
        .read(invoiceRepositoryProvider)
        .downloadPdf(emission.id);
    if (bytes.isEmpty) {
      throw const ApiException(message: 'El PDF descargado esta vacio.');
    }

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${_pdfFileName(emission)}');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  String _pdfFileName(DteEmissionResult emission) {
    final safeNumber = emission.numeroControl.replaceAll(
      RegExp(r'[^A-Za-z0-9_-]+'),
      '_',
    );
    return '$safeNumber.pdf';
  }

  String _friendlyError(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'No se pudo completar la operacion. Revisa la conexion e intenta de nuevo.';
  }
}
