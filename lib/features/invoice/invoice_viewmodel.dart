import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../clients/models/client_models.dart' hide formatMoney;
import '../dte_delivery/dte_delivery_service.dart';
import '../dte_delivery/models/dte_delivery_models.dart';
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
      traceId: null,
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
      traceId: null,
      pdfPath: null,
    );
  }

  void clearClient() {
    state = state.copyWith(
      selectedClient: null,
      emission: null,
      errorMessage: null,
      traceId: null,
      pdfPath: null,
    );
  }

  Future<Customer?> createQuickCustomer(CustomerForm form) async {
    state = state.copyWith(isSearchingClients: true, errorMessage: null);
    try {
      final customer = await ref
          .read(invoiceRepositoryProvider)
          .createQuickCustomer(form);
      state = state.copyWith(
        selectedClient: InvoiceLookupOption(
          id: customer.id,
          label: customer.nombre,
          parent: customer.tipoDocumentoCodigo,
          meta: customer.numeroDocumento,
        ),
        clientResults: const [],
        isSearchingClients: false,
        errorMessage: null,
        traceId: null,
      );
      return customer;
    } catch (error) {
      final apiError = error is ApiException ? error : null;
      state = state.copyWith(
        isSearchingClients: false,
        errorMessage: _friendlyError(error),
        traceId: apiError?.traceId,
      );
      return null;
    }
  }

  Future<NitVerification?> verifyDocument(String document) async {
    try {
      return await ref.read(invoiceRepositoryProvider).verifyDocument(document);
    } catch (error) {
      final apiError = error is ApiException ? error : null;
      state = state.copyWith(
        errorMessage: _friendlyError(error),
        traceId: apiError?.traceId,
      );
      return null;
    }
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
      traceId: null,
      pdfPath: null,
    );
  }

  Future<void> addScannedProduct(String barcode) async {
    final code = barcode.trim();
    if (code.isEmpty) {
      return;
    }

    state = state.copyWith(isSearchingProducts: true, errorMessage: null);
    try {
      final results = await ref
          .read(invoiceRepositoryProvider)
          .searchProducts(code);
      if (results.length == 1) {
        addProduct(results.first);
        state = state.copyWith(isSearchingProducts: false);
        return;
      }

      state = state.copyWith(
        productResults: results,
        isSearchingProducts: false,
        errorMessage: results.isEmpty
            ? 'No se encontro producto para el codigo $code.'
            : null,
        traceId: null,
      );
    } catch (error) {
      final apiError = error is ApiException ? error : null;
      state = state.copyWith(
        isSearchingProducts: false,
        errorMessage: _friendlyError(error),
        traceId: apiError?.traceId,
      );
    }
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
      traceId: null,
      pdfPath: null,
    );
  }

  Future<void> emitFactura() async {
    if (state.selectedClient == null) {
      state = state.copyWith(
        errorMessage: 'Selecciona un cliente antes de emitir.',
        traceId: null,
      );
      return;
    }

    if (state.lines.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Agrega al menos un producto a la factura.',
        traceId: null,
      );
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      emission: null,
      errorMessage: null,
      traceId: null,
      pdfPath: null,
    );

    try {
      final result = await ref
          .read(invoiceRepositoryProvider)
          .emitFactura(state);
      state = state.copyWith(isSubmitting: false, emission: result);
    } catch (error) {
      final apiError = error is ApiException ? error : null;
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _friendlyError(error),
        traceId: apiError?.traceId,
      );
    }
  }

  Future<DteDeliveryFile?> downloadPdf() async {
    final emission = state.emission;
    if (emission == null) {
      state = state.copyWith(
        errorMessage: 'Emite el DTE antes de descargar.',
        traceId: null,
      );
      return null;
    }

    state = state.copyWith(
      isDownloadingPdf: true,
      errorMessage: null,
      traceId: null,
    );
    try {
      final file = await ref
          .read(dteDeliveryServiceProvider)
          .downloadPdf(_deliveryDocument(emission));
      state = state.copyWith(isDownloadingPdf: false, pdfPath: file.path);
      return file;
    } catch (error) {
      final apiError = error is ApiException ? error : null;
      state = state.copyWith(
        isDownloadingPdf: false,
        errorMessage: _friendlyError(error),
        traceId: apiError?.traceId,
      );
      return null;
    }
  }

  Future<DteDeliveryFile?> sharePdf({required String channel}) async {
    final emission = state.emission;
    if (emission == null) {
      state = state.copyWith(
        errorMessage: 'Emite el DTE antes de compartir.',
        traceId: null,
      );
      return null;
    }

    state = state.copyWith(
      isSharingPdf: true,
      errorMessage: null,
      traceId: null,
    );
    try {
      final file = await ref
          .read(dteDeliveryServiceProvider)
          .sharePdf(_deliveryDocument(emission), channel: channel);
      state = state.copyWith(isSharingPdf: false, pdfPath: file.path);
      return file;
    } catch (error) {
      final apiError = error is ApiException ? error : null;
      state = state.copyWith(
        isSharingPdf: false,
        errorMessage:
            'No se pudo compartir por $channel. ${_friendlyError(error)}',
        traceId: apiError?.traceId,
      );
      return null;
    }
  }

  Future<DteEmailDeliveryResult?> resendEmail(String email) async {
    final emission = state.emission;
    if (emission == null) {
      state = state.copyWith(
        errorMessage: 'Emite el DTE antes de reenviar por correo.',
        traceId: null,
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
          .read(dteDeliveryServiceProvider)
          .resendEmail(document: _deliveryDocument(emission), email: email);
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
      traceId: null,
      pdfPath: null,
    );
  }

  DteDeliveryDocument _deliveryDocument(DteEmissionResult emission) {
    return DteDeliveryDocument(
      id: emission.id,
      numeroControl: emission.numeroControl,
      totalPagar: emission.totalPagar,
      receptorCorreo: emission.receptorCorreo,
    );
  }

  String _friendlyError(Object error) {
    if (error is ApiException) {
      return error.errors.isEmpty
          ? error.message
          : '${error.message} ${error.errors.join(', ')}';
    }
    return 'No se pudo completar la operacion. Revisa la conexion e intenta de nuevo.';
  }
}
