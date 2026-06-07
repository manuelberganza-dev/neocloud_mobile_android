import '../../../core/network/api_response.dart';

const _unset = Object();

class MasterDataFilters {
  const MasterDataFilters({this.search, this.page = 1, this.pageSize = 10});

  final String? search;
  final int page;
  final int pageSize;

  MasterDataFilters copyWith({
    Object? search = _unset,
    int? page,
    int? pageSize,
  }) {
    return MasterDataFilters(
      search: search == _unset ? this.search : _cleanText(search as String?),
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  MasterDataFilters firstPage() => copyWith(page: 1);

  Map<String, dynamic> toQuery() {
    return {
      'page': page,
      'pageSize': pageSize,
      if (_cleanText(search) != null) 'search': search!.trim(),
    };
  }
}

class Customer {
  const Customer({
    required this.id,
    required this.tipoDocumentoCodigo,
    required this.numeroDocumento,
    required this.nombre,
    required this.tipoContribuyenteCodigo,
    required this.esContribuyente,
    required this.estadoCodigo,
    this.nrc,
    this.nombreComercial,
    this.codigoActividad,
    this.actividadEconomica,
    this.departamentoCodigo,
    this.municipioCodigo,
    this.direccion,
    this.correo,
    this.telefono,
    this.etiqueta,
  });

  final int id;
  final String tipoDocumentoCodigo;
  final String numeroDocumento;
  final String? nrc;
  final String nombre;
  final String? nombreComercial;
  final String tipoContribuyenteCodigo;
  final bool esContribuyente;
  final String? codigoActividad;
  final String? actividadEconomica;
  final String? departamentoCodigo;
  final String? municipioCodigo;
  final String? direccion;
  final String? correo;
  final String? telefono;
  final String estadoCodigo;
  final String? etiqueta;

  String get subtitle {
    final pieces = [numeroDocumento, correo, telefono]
        .where((value) => _cleanText(value) != null)
        .map((value) => value!)
        .toList();
    return pieces.isEmpty ? estadoCodigo : pieces.join(' - ');
  }

  factory Customer.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return Customer(
      id: (map['id'] as num?)?.toInt() ?? 0,
      tipoDocumentoCodigo: map['tipoDocumentoCodigo']?.toString() ?? 'DUI',
      numeroDocumento: map['numeroDocumento']?.toString() ?? '',
      nrc: _cleanText(map['nrc']?.toString()),
      nombre: map['nombre']?.toString() ?? 'Cliente',
      nombreComercial: _cleanText(map['nombreComercial']?.toString()),
      tipoContribuyenteCodigo:
          map['tipoContribuyenteCodigo']?.toString() ?? 'CONSUMIDOR_FINAL',
      esContribuyente: map['esContribuyente'] == true,
      codigoActividad: _cleanText(map['codigoActividad']?.toString()),
      actividadEconomica: _cleanText(map['actividadEconomica']?.toString()),
      departamentoCodigo: _cleanText(map['departamentoCodigo']?.toString()),
      municipioCodigo: _cleanText(map['municipioCodigo']?.toString()),
      direccion: _cleanText(map['direccion']?.toString()),
      correo: _cleanText(map['correo']?.toString()),
      telefono: _cleanText(map['telefono']?.toString()),
      estadoCodigo: map['estadoCodigo']?.toString() ?? 'ACTIVO',
      etiqueta: _cleanText(map['etiqueta']?.toString()),
    );
  }
}

class CustomerForm {
  const CustomerForm({
    required this.numeroDocumento,
    required this.nombre,
    this.id,
    this.tipoDocumentoCodigo = 'DUI',
    this.nrc,
    this.nombreComercial,
    this.tipoContribuyenteCodigo = 'CONSUMIDOR_FINAL',
    this.codigoActividad,
    this.actividadEconomica,
    this.departamentoCodigo,
    this.municipioCodigo,
    this.direccion,
    this.correo,
    this.telefono,
    this.estadoCodigo = 'ACTIVO',
  });

  final int? id;
  final String tipoDocumentoCodigo;
  final String numeroDocumento;
  final String? nrc;
  final String nombre;
  final String? nombreComercial;
  final String tipoContribuyenteCodigo;
  final String? codigoActividad;
  final String? actividadEconomica;
  final String? departamentoCodigo;
  final String? municipioCodigo;
  final String? direccion;
  final String? correo;
  final String? telefono;
  final String estadoCodigo;

  factory CustomerForm.fromCustomer(Customer customer) {
    return CustomerForm(
      id: customer.id,
      tipoDocumentoCodigo: customer.tipoDocumentoCodigo,
      numeroDocumento: customer.numeroDocumento,
      nrc: customer.nrc,
      nombre: customer.nombre,
      nombreComercial: customer.nombreComercial,
      tipoContribuyenteCodigo: customer.tipoContribuyenteCodigo,
      codigoActividad: customer.codigoActividad,
      actividadEconomica: customer.actividadEconomica,
      departamentoCodigo: customer.departamentoCodigo,
      municipioCodigo: customer.municipioCodigo,
      direccion: customer.direccion,
      correo: customer.correo,
      telefono: customer.telefono,
      estadoCodigo: customer.estadoCodigo,
    );
  }

  Map<String, Object?> toCreateJson() {
    return {
      'tipoDocumentoCodigo': tipoDocumentoCodigo,
      'numeroDocumento': numeroDocumento.trim(),
      'nrc': _cleanText(nrc),
      'nombre': nombre.trim(),
      'nombreComercial': _cleanText(nombreComercial),
      'tipoContribuyenteCodigo': tipoContribuyenteCodigo,
      'codigoActividad': _cleanText(codigoActividad),
      'actividadEconomica': _cleanText(actividadEconomica),
      'departamentoCodigo': _cleanText(departamentoCodigo),
      'municipioCodigo': _cleanText(municipioCodigo),
      'direccion': _cleanText(direccion),
      'correo': _cleanText(correo),
      'telefono': _cleanText(telefono),
    };
  }

  Map<String, Object?> toUpdateJson() {
    return {...toCreateJson(), 'estadoCodigo': estadoCodigo};
  }
}

class NitVerification {
  const NitVerification({
    required this.formatoValido,
    required this.tipoDocumento,
    required this.documentoNormalizado,
    required this.encontradoLocal,
    required this.fuente,
    required this.mensaje,
    this.nombre,
    this.nrc,
    this.tipoContribuyente,
  });

  final bool formatoValido;
  final String tipoDocumento;
  final String documentoNormalizado;
  final bool encontradoLocal;
  final String fuente;
  final String mensaje;
  final String? nombre;
  final String? nrc;
  final String? tipoContribuyente;

  factory NitVerification.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return NitVerification(
      formatoValido: map['formatoValido'] == true,
      tipoDocumento: map['tipoDocumento']?.toString() ?? 'DESCONOCIDO',
      documentoNormalizado: map['documentoNormalizado']?.toString() ?? '',
      encontradoLocal: map['encontradoLocal'] == true,
      nombre: _cleanText(map['nombre']?.toString()),
      nrc: _cleanText(map['nrc']?.toString()),
      tipoContribuyente: _cleanText(map['tipoContribuyente']?.toString()),
      fuente: map['fuente']?.toString() ?? 'FORMATO',
      mensaje: map['mensaje']?.toString() ?? '',
    );
  }
}

class Product {
  const Product({
    required this.id,
    required this.codigoInterno,
    required this.nombre,
    required this.tipoItem,
    required this.esServicio,
    required this.unidadMedidaCodigo,
    required this.precioUnitario,
    required this.aplicaIva,
    required this.estadoCodigo,
    this.codigoBarra,
    this.descripcion,
    this.costoUnitario,
    this.tributoCodigo,
  });

  final int id;
  final String codigoInterno;
  final String? codigoBarra;
  final String nombre;
  final String? descripcion;
  final String tipoItem;
  final bool esServicio;
  final String unidadMedidaCodigo;
  final double precioUnitario;
  final double? costoUnitario;
  final bool aplicaIva;
  final String? tributoCodigo;
  final String estadoCodigo;

  String get priceLabel => formatMoney(precioUnitario);

  String get subtitle {
    final barcode = _cleanText(codigoBarra);
    return barcode == null ? codigoInterno : '$codigoInterno - $barcode';
  }

  factory Product.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return Product(
      id: (map['id'] as num?)?.toInt() ?? 0,
      codigoInterno: map['codigoInterno']?.toString() ?? '',
      codigoBarra: _cleanText(map['codigoBarra']?.toString()),
      nombre: map['nombre']?.toString() ?? 'Producto',
      descripcion: _cleanText(map['descripcion']?.toString()),
      tipoItem: map['tipoItem']?.toString() ?? 'BIEN',
      esServicio: map['esServicio'] == true,
      unidadMedidaCodigo: map['unidadMedidaCodigo']?.toString() ?? '59',
      precioUnitario: (map['precioUnitario'] as num?)?.toDouble() ?? 0,
      costoUnitario: (map['costoUnitario'] as num?)?.toDouble(),
      aplicaIva: map['aplicaIva'] != false,
      tributoCodigo: _cleanText(map['tributoCodigo']?.toString()),
      estadoCodigo: map['estadoCodigo']?.toString() ?? 'ACTIVO',
    );
  }
}

class ProductForm {
  const ProductForm({
    required this.codigoInterno,
    required this.nombre,
    required this.precioUnitario,
    this.id,
    this.codigoBarra,
    this.descripcion,
    this.tipoItem = 'BIEN',
    this.unidadMedidaCodigo = '59',
    this.costoUnitario,
    this.aplicaIva = true,
    this.tributoCodigo,
    this.estadoCodigo = 'ACTIVO',
  });

  final int? id;
  final String codigoInterno;
  final String? codigoBarra;
  final String nombre;
  final String? descripcion;
  final String tipoItem;
  final String unidadMedidaCodigo;
  final double precioUnitario;
  final double? costoUnitario;
  final bool aplicaIva;
  final String? tributoCodigo;
  final String estadoCodigo;

  factory ProductForm.fromProduct(Product product) {
    return ProductForm(
      id: product.id,
      codigoInterno: product.codigoInterno,
      codigoBarra: product.codigoBarra,
      nombre: product.nombre,
      descripcion: product.descripcion,
      tipoItem: product.tipoItem,
      unidadMedidaCodigo: product.unidadMedidaCodigo,
      precioUnitario: product.precioUnitario,
      costoUnitario: product.costoUnitario,
      aplicaIva: product.aplicaIva,
      tributoCodigo: product.tributoCodigo,
      estadoCodigo: product.estadoCodigo,
    );
  }

  Map<String, Object?> toCreateJson() {
    return {
      'codigoInterno': codigoInterno.trim(),
      'codigoBarra': _cleanText(codigoBarra),
      'nombre': nombre.trim(),
      'descripcion': _cleanText(descripcion),
      'tipoItem': tipoItem,
      'unidadMedidaCodigo': unidadMedidaCodigo,
      'precioUnitario': precioUnitario,
      'costoUnitario': costoUnitario,
      'aplicaIva': aplicaIva,
      'tributoCodigo': _cleanText(tributoCodigo),
    };
  }

  Map<String, Object?> toUpdateJson() {
    return {...toCreateJson(), 'estadoCodigo': estadoCodigo};
  }
}

class MasterDataState {
  const MasterDataState({
    required this.customers,
    required this.products,
    required this.customerFilters,
    required this.productFilters,
    required this.customerTotalPages,
    required this.productTotalPages,
    required this.isLoadingCustomers,
    required this.isLoadingProducts,
    required this.isSaving,
    this.errorMessage,
    this.traceId,
  });

  factory MasterDataState.initial() {
    return const MasterDataState(
      customers: [],
      products: [],
      customerFilters: MasterDataFilters(),
      productFilters: MasterDataFilters(),
      customerTotalPages: 0,
      productTotalPages: 0,
      isLoadingCustomers: false,
      isLoadingProducts: false,
      isSaving: false,
    );
  }

  final List<Customer> customers;
  final List<Product> products;
  final MasterDataFilters customerFilters;
  final MasterDataFilters productFilters;
  final int customerTotalPages;
  final int productTotalPages;
  final bool isLoadingCustomers;
  final bool isLoadingProducts;
  final bool isSaving;
  final String? errorMessage;
  final String? traceId;

  bool get hasMoreCustomers => customerFilters.page < customerTotalPages;

  bool get hasMoreProducts => productFilters.page < productTotalPages;

  MasterDataState copyWith({
    List<Customer>? customers,
    List<Product>? products,
    MasterDataFilters? customerFilters,
    MasterDataFilters? productFilters,
    int? customerTotalPages,
    int? productTotalPages,
    bool? isLoadingCustomers,
    bool? isLoadingProducts,
    bool? isSaving,
    Object? errorMessage = _unset,
    Object? traceId = _unset,
  }) {
    return MasterDataState(
      customers: customers ?? this.customers,
      products: products ?? this.products,
      customerFilters: customerFilters ?? this.customerFilters,
      productFilters: productFilters ?? this.productFilters,
      customerTotalPages: customerTotalPages ?? this.customerTotalPages,
      productTotalPages: productTotalPages ?? this.productTotalPages,
      isLoadingCustomers: isLoadingCustomers ?? this.isLoadingCustomers,
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      traceId: traceId == _unset ? this.traceId : traceId as String?,
    );
  }

  MasterDataState withCustomerPage(
    PagedResult<Customer> page, {
    required bool append,
  }) {
    return copyWith(
      customers: append ? [...customers, ...page.items] : page.items,
      customerFilters: customerFilters.copyWith(
        page: page.page,
        pageSize: page.pageSize,
      ),
      customerTotalPages: page.totalPages,
      isLoadingCustomers: false,
      errorMessage: null,
      traceId: null,
    );
  }

  MasterDataState withProductPage(
    PagedResult<Product> page, {
    required bool append,
  }) {
    return copyWith(
      products: append ? [...products, ...page.items] : page.items,
      productFilters: productFilters.copyWith(
        page: page.page,
        pageSize: page.pageSize,
      ),
      productTotalPages: page.totalPages,
      isLoadingProducts: false,
      errorMessage: null,
      traceId: null,
    );
  }
}

String formatMoney(double value) => '\$${value.toStringAsFixed(2)}';

String? _cleanText(String? value) {
  final clean = value?.trim();
  if (clean == null || clean.isEmpty) {
    return null;
  }
  return clean;
}
