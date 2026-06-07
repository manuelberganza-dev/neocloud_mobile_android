import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import 'models/client_models.dart';

class ClientsRepository {
  const ClientsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<PagedResult<Customer>> listCustomers(MasterDataFilters filters) {
    return _apiClient.getData<PagedResult<Customer>>(
      ApiEndpoints.clientes,
      queryParameters: filters.toQuery(),
      fromJson: (json) => PagedResult.fromJson(json, Customer.fromJson),
    );
  }

  Future<Customer> createCustomer(CustomerForm form) {
    return _apiClient.postData<Customer>(
      ApiEndpoints.clientes,
      data: form.toCreateJson(),
      fromJson: Customer.fromJson,
    );
  }

  Future<Customer> updateCustomer(CustomerForm form) {
    return _apiClient.putData<Customer>(
      ApiEndpoints.cliente(form.id ?? 0),
      data: form.toUpdateJson(),
      fromJson: Customer.fromJson,
    );
  }

  Future<void> deactivateCustomer(int id) {
    return _apiClient.patchVoid(ApiEndpoints.clienteInactivar(id));
  }

  Future<NitVerification> verifyDocument(String document) {
    return _apiClient.getData<NitVerification>(
      ApiEndpoints.lookupsVerificarNit,
      queryParameters: {'documento': document.trim()},
      fromJson: NitVerification.fromJson,
    );
  }

  Future<PagedResult<Product>> listProducts(MasterDataFilters filters) {
    return _apiClient.getData<PagedResult<Product>>(
      ApiEndpoints.productos,
      queryParameters: filters.toQuery(),
      fromJson: (json) => PagedResult.fromJson(json, Product.fromJson),
    );
  }

  Future<Product> createProduct(ProductForm form) {
    return _apiClient.postData<Product>(
      ApiEndpoints.productos,
      data: form.toCreateJson(),
      fromJson: Product.fromJson,
    );
  }

  Future<Product> updateProduct(ProductForm form) {
    return _apiClient.putData<Product>(
      ApiEndpoints.producto(form.id ?? 0),
      data: form.toUpdateJson(),
      fromJson: Product.fromJson,
    );
  }

  Future<void> deactivateProduct(int id) {
    return _apiClient.patchVoid(ApiEndpoints.productoInactivar(id));
  }
}
