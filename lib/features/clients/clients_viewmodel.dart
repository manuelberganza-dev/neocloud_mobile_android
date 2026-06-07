import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import 'clients_repository.dart';
import 'models/client_models.dart';

final clientsRepositoryProvider = Provider.autoDispose<ClientsRepository>((
  ref,
) {
  return ClientsRepository(ref.watch(apiClientProvider));
});

final clientsViewModelProvider =
    NotifierProvider.autoDispose<ClientsViewModel, MasterDataState>(
      ClientsViewModel.new,
    );

class ClientsViewModel extends Notifier<MasterDataState> {
  @override
  MasterDataState build() {
    return MasterDataState.initial();
  }

  Future<void> loadCustomers({String? search, bool append = false}) async {
    final filters = append
        ? state.customerFilters.copyWith(page: state.customerFilters.page + 1)
        : state.customerFilters.copyWith(search: search, page: 1);

    state = state.copyWith(
      customerFilters: filters,
      isLoadingCustomers: true,
      errorMessage: null,
      traceId: null,
    );

    try {
      final page = await ref
          .read(clientsRepositoryProvider)
          .listCustomers(filters);
      state = state.withCustomerPage(page, append: append);
    } catch (error) {
      _setError(error, isLoadingCustomers: false);
    }
  }

  Future<void> loadProducts({String? search, bool append = false}) async {
    final filters = append
        ? state.productFilters.copyWith(page: state.productFilters.page + 1)
        : state.productFilters.copyWith(search: search, page: 1);

    state = state.copyWith(
      productFilters: filters,
      isLoadingProducts: true,
      errorMessage: null,
      traceId: null,
    );

    try {
      final page = await ref
          .read(clientsRepositoryProvider)
          .listProducts(filters);
      state = state.withProductPage(page, append: append);
    } catch (error) {
      _setError(error, isLoadingProducts: false);
    }
  }

  Future<Customer?> saveCustomer(CustomerForm form) async {
    state = state.copyWith(isSaving: true, errorMessage: null, traceId: null);
    try {
      final result = form.id == null
          ? await ref.read(clientsRepositoryProvider).createCustomer(form)
          : await ref.read(clientsRepositoryProvider).updateCustomer(form);
      state = state.copyWith(isSaving: false);
      await loadCustomers(search: state.customerFilters.search);
      return result;
    } catch (error) {
      _setError(error, isSaving: false);
      return null;
    }
  }

  Future<Product?> saveProduct(ProductForm form) async {
    state = state.copyWith(isSaving: true, errorMessage: null, traceId: null);
    try {
      final result = form.id == null
          ? await ref.read(clientsRepositoryProvider).createProduct(form)
          : await ref.read(clientsRepositoryProvider).updateProduct(form);
      state = state.copyWith(isSaving: false);
      await loadProducts(search: state.productFilters.search);
      return result;
    } catch (error) {
      _setError(error, isSaving: false);
      return null;
    }
  }

  Future<void> deactivateCustomer(int id) async {
    state = state.copyWith(isSaving: true, errorMessage: null, traceId: null);
    try {
      await ref.read(clientsRepositoryProvider).deactivateCustomer(id);
      state = state.copyWith(isSaving: false);
      await loadCustomers(search: state.customerFilters.search);
    } catch (error) {
      _setError(error, isSaving: false);
    }
  }

  Future<void> deactivateProduct(int id) async {
    state = state.copyWith(isSaving: true, errorMessage: null, traceId: null);
    try {
      await ref.read(clientsRepositoryProvider).deactivateProduct(id);
      state = state.copyWith(isSaving: false);
      await loadProducts(search: state.productFilters.search);
    } catch (error) {
      _setError(error, isSaving: false);
    }
  }

  Future<NitVerification?> verifyDocument(String document) async {
    try {
      return await ref.read(clientsRepositoryProvider).verifyDocument(document);
    } catch (error) {
      _setError(error);
      return null;
    }
  }

  void _setError(
    Object error, {
    bool? isLoadingCustomers,
    bool? isLoadingProducts,
    bool? isSaving,
  }) {
    final apiError = error is ApiException ? error : null;
    state = state.copyWith(
      isLoadingCustomers: isLoadingCustomers,
      isLoadingProducts: isLoadingProducts,
      isSaving: isSaving,
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
