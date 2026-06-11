import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../invoice/models/invoice_models.dart';
import 'models/pos_models.dart';
import 'pos_repository.dart';

final posRepositoryProvider = Provider.autoDispose<PosRepository>((ref) {
  return PosRepository(ref.watch(apiClientProvider));
});

final posViewModelProvider =
    NotifierProvider.autoDispose<PosViewModel, PosState>(PosViewModel.new);

class PosViewModel extends Notifier<PosState> {
  @override
  PosState build() {
    return PosState.initial();
  }

  Future<void> load() async {
    final query = state.query.firstPage();
    state = state.copyWith(
      isLoading: true,
      query: query,
      errorMessage: null,
      successMessage: null,
      traceId: null,
    );
    try {
      final repository = ref.read(posRepositoryProvider);
      final summary = await repository.getSummary();
      final page = await repository.listSales(query);
      state = state
          .copyWith(summary: summary, isLoading: false)
          .withPage(page, false);
    } catch (error) {
      _setError(error, isLoading: false);
    }
  }

  Future<void> refresh() => load();

  Future<void> searchSales(String value) async {
    final query = state.query.copyWith(search: value).firstPage();
    state = state.copyWith(query: query, isLoading: true, errorMessage: null);
    try {
      final page = await ref.read(posRepositoryProvider).listSales(query);
      state = state.withPage(page, false);
    } catch (error) {
      _setError(error, isLoading: false);
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isBusy) {
      return;
    }
    final query = state.query.copyWith(page: state.query.page + 1);
    state = state.copyWith(query: query, isLoadingMore: true);
    try {
      final page = await ref.read(posRepositoryProvider).listSales(query);
      state = state.withPage(page, true);
    } catch (error) {
      _setError(error, isLoadingMore: false);
    }
  }

  Future<void> selectSale(PosSale sale) async {
    state = state.copyWith(selectedSale: sale, errorMessage: null);
    try {
      final fresh = await ref.read(posRepositoryProvider).getSale(sale.id);
      _replaceSale(fresh);
    } catch (error) {
      _setError(error);
    }
  }

  Future<void> searchProducts(String value) async {
    if (value.trim().isEmpty) {
      state = state.copyWith(productResults: const []);
      return;
    }
    state = state.copyWith(isSearchingProducts: true, errorMessage: null);
    try {
      final products = await ref
          .read(posRepositoryProvider)
          .searchProducts(value);
      state = state.copyWith(
        productResults: products,
        isSearchingProducts: false,
      );
    } catch (error) {
      _setError(error, isSearchingProducts: false);
    }
  }

  Future<void> addScannedProduct(String code) async {
    await searchProducts(code);
    final product = state.productResults.firstOrNull;
    if (product == null) {
      state = state.copyWith(
        errorMessage: 'No se encontro producto con codigo $code.',
        traceId: null,
      );
      return;
    }
    addProduct(product);
  }

  void addProduct(InvoiceLookupOption product) {
    final line = PosSaleLine.fromProduct(product);
    final existingIndex = state.draft.lineas.indexWhere(
      (item) =>
          item.productoId == line.productoId &&
          item.codigo.trim().toLowerCase() == line.codigo.trim().toLowerCase(),
    );
    final next = [...state.draft.lineas];
    if (existingIndex >= 0) {
      final current = next[existingIndex];
      next[existingIndex] = current.copyWith(cantidad: current.cantidad + 1);
    } else {
      next.add(line);
    }
    state = state.copyWith(
      draft: state.draft.copyWith(lineas: next),
      productResults: const [],
      errorMessage: null,
    );
  }

  void updateQuantity(int index, double quantity) {
    if (index < 0 || index >= state.draft.lineas.length) {
      return;
    }
    final next = [...state.draft.lineas];
    if (quantity <= 0) {
      next.removeAt(index);
    } else {
      next[index] = next[index].copyWith(cantidad: quantity);
    }
    state = state.copyWith(draft: state.draft.copyWith(lineas: next));
  }

  void removeLine(int index) {
    if (index < 0 || index >= state.draft.lineas.length) {
      return;
    }
    final next = [...state.draft.lineas]..removeAt(index);
    state = state.copyWith(draft: state.draft.copyWith(lineas: next));
  }

  void setCustomerName(String value) {
    state = state.copyWith(
      draft: state.draft.copyWith(clienteNombre: value.trim()),
    );
  }

  void setPayment(String payment, {double? cash}) {
    state = state.copyWith(
      draft: state.draft.copyWith(
        formaPagoCodigo: payment,
        efectivoRecibido: cash,
      ),
    );
  }

  void clearDraft() {
    state = state.copyWith(
      draft: const PosSaleDraft(lineas: []),
      productResults: const [],
      successMessage: null,
    );
  }

  Future<PosSale?> createSale() async {
    if (!state.draft.canSubmit) {
      state = state.copyWith(errorMessage: 'Agrega al menos un producto.');
      return null;
    }
    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      successMessage: null,
    );
    try {
      final sale = await ref
          .read(posRepositoryProvider)
          .createSale(state.draft);
      final summary = await ref.read(posRepositoryProvider).getSummary();
      state = state.copyWith(
        summary: summary,
        draft: const PosSaleDraft(lineas: []),
        selectedSale: sale,
        sales: [sale, ...state.sales],
        total: state.total + 1,
        isSubmitting: false,
        successMessage: 'Venta creada correctamente.',
      );
      return sale;
    } catch (error) {
      _setError(error, isSubmitting: false);
      return null;
    }
  }

  Future<bool> cancelSale(PosSale sale) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await ref.read(posRepositoryProvider).cancelSale(sale.id);
      final fresh = await ref.read(posRepositoryProvider).getSale(sale.id);
      _replaceSale(fresh, isSubmitting: false);
      return true;
    } catch (error) {
      _setError(error, isSubmitting: false);
      return false;
    }
  }

  Future<String?> downloadTicket(PosSale sale) async {
    state = state.copyWith(isTicketBusy: true, errorMessage: null);
    try {
      final bytes = await ref
          .read(posRepositoryProvider)
          .downloadTicket(sale.id);
      final path = await _writeTicket(sale, bytes);
      state = state.copyWith(isTicketBusy: false, ticketPath: path);
      return path;
    } catch (error) {
      _setError(error, isTicketBusy: false);
      return null;
    }
  }

  Future<void> shareTicket(PosSale sale) async {
    state = state.copyWith(isTicketBusy: true, errorMessage: null);
    try {
      final bytes = await ref
          .read(posRepositoryProvider)
          .downloadTicket(sale.id);
      final path = await _writeTicket(sale, bytes);
      await SharePlus.instance.share(
        ShareParams(
          title: 'Compartir ticket',
          subject: 'Ticket ${sale.title}',
          text: 'Ticket ${sale.title} por ${posMoney(sale.total)}',
          files: [
            XFile(
              path,
              mimeType: 'application/pdf',
              name: 'ticket_${sale.id}.pdf',
            ),
          ],
          fileNameOverrides: ['ticket_${sale.id}.pdf'],
        ),
      );
      state = state.copyWith(isTicketBusy: false, ticketPath: path);
    } catch (error) {
      _setError(error, isTicketBusy: false);
    }
  }

  Future<bool> sendTicket(PosSale sale, String email) async {
    state = state.copyWith(isSendingEmail: true, errorMessage: null);
    try {
      await ref
          .read(posRepositoryProvider)
          .sendTicket(id: sale.id, email: email);
      state = state.copyWith(
        isSendingEmail: false,
        successMessage: 'Ticket enviado por correo.',
      );
      return true;
    } catch (error) {
      _setError(error, isSendingEmail: false);
      return false;
    }
  }

  Future<PosPromotionResult?> promoteSale(
    PosSale sale, {
    required String tipoDteCodigo,
  }) async {
    state = state.copyWith(isPromoting: true, errorMessage: null);
    try {
      final result = await ref
          .read(posRepositoryProvider)
          .promoteSale(
            id: sale.id,
            tipoDteCodigo: tipoDteCodigo,
            clienteId: sale.clienteId,
          );
      final fresh = await ref.read(posRepositoryProvider).getSale(sale.id);
      state = state.copyWith(
        isPromoting: false,
        lastPromotion: result,
        successMessage: result.displayMessage,
      );
      _replaceSale(fresh, isPromoting: false);
      return result;
    } catch (error) {
      _setError(error, isPromoting: false);
      return null;
    }
  }

  Future<String> _writeTicket(PosSale sale, List<int> bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/ticket_${sale.id}.pdf');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  void _replaceSale(PosSale sale, {bool? isSubmitting, bool? isPromoting}) {
    final exists = state.sales.any((item) => item.id == sale.id);
    final items = [
      for (final item in state.sales)
        if (item.id == sale.id) sale else item,
    ];
    state = state.copyWith(
      sales: exists ? items : [sale, ...state.sales],
      selectedSale: sale,
      isSubmitting: isSubmitting,
      isPromoting: isPromoting,
      errorMessage: null,
      traceId: null,
    );
  }

  void _setError(
    Object error, {
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSearchingProducts,
    bool? isSubmitting,
    bool? isTicketBusy,
    bool? isSendingEmail,
    bool? isPromoting,
  }) {
    state = state.copyWith(
      isLoading: isLoading,
      isLoadingMore: isLoadingMore,
      isSearchingProducts: isSearchingProducts,
      isSubmitting: isSubmitting,
      isTicketBusy: isTicketBusy,
      isSendingEmail: isSendingEmail,
      isPromoting: isPromoting,
      errorMessage: _friendlyError(error),
      traceId: error is ApiException ? error.traceId : null,
      successMessage: null,
    );
  }

  String _friendlyError(Object error) {
    if (error is ApiException) {
      return error.errors.isEmpty
          ? error.message
          : '${error.message} ${error.errors.join(', ')}';
    }
    return 'No se pudo completar la operacion POS.';
  }
}
