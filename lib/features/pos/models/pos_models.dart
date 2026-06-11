import '../../../core/network/api_response.dart';
import '../../invoice/models/invoice_models.dart';

const _unset = Object();

class PosSummary {
  const PosSummary({
    required this.ventas,
    required this.total,
    required this.anuladas,
    required this.ticketPromedio,
  });

  final int ventas;
  final double total;
  final int anuladas;
  final double ticketPromedio;

  factory PosSummary.empty() {
    return const PosSummary(
      ventas: 0,
      total: 0,
      anuladas: 0,
      ticketPromedio: 0,
    );
  }

  factory PosSummary.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    final total = _doubleAny(map, const [
      'total',
      'totalVentas',
      'montoTotal',
      'Total',
      'TotalVentas',
      'MontoTotal',
    ]);
    final ventas = _intAny(map, const [
      'ventas',
      'ventasHoy',
      'cantidad',
      'documentos',
      'Ventas',
      'VentasHoy',
      'Cantidad',
      'Documentos',
    ]);
    return PosSummary(
      ventas: ventas,
      total: total,
      anuladas: _intAny(map, const ['anuladas', 'ventasAnuladas', 'Anuladas']),
      ticketPromedio: _doubleAny(map, const [
        'ticketPromedio',
        'promedio',
        'TicketPromedio',
        'Promedio',
      ], fallback: ventas == 0 ? 0 : total / ventas),
    );
  }
}

class PosSale {
  const PosSale({
    required this.id,
    required this.numero,
    required this.estadoCodigo,
    required this.formaPagoCodigo,
    required this.subtotal,
    required this.descuento,
    required this.iva,
    required this.total,
    required this.lineas,
    this.fecha,
    this.clienteId,
    this.clienteNombre,
    this.efectivoRecibido,
    this.cambio,
    this.dteDocumentoId,
  });

  final int id;
  final String numero;
  final DateTime? fecha;
  final int? clienteId;
  final String? clienteNombre;
  final String estadoCodigo;
  final String formaPagoCodigo;
  final double subtotal;
  final double descuento;
  final double iva;
  final double total;
  final double? efectivoRecibido;
  final double? cambio;
  final int? dteDocumentoId;
  final List<PosSaleLine> lineas;

  bool get isAnulada => estadoCodigo.toUpperCase() == 'ANULADA';
  bool get isPromoted => dteDocumentoId != null && dteDocumentoId! > 0;
  String get title => numero.trim().isEmpty ? 'Venta #$id' : numero;
  String get customerLabel => _blankToNull(clienteNombre) ?? 'Consumidor final';
  String get dateLabel => _shortDate(fecha);

  factory PosSale.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return PosSale(
      id: _int(map, 'id', 'Id'),
      numero:
          _textAny(map, const ['numero', 'codigo', 'correlativo', 'Numero']) ??
          'POS-${_int(map, 'id', 'Id')}',
      fecha: _dateAny(map, const ['fecha', 'createdAt', 'Fecha', 'CreatedAt']),
      clienteId: _nullableInt(map, 'clienteId', 'ClienteId'),
      clienteNombre: _textAny(map, const [
        'clienteNombre',
        'nombreCliente',
        'ClienteNombre',
        'NombreCliente',
      ]),
      estadoCodigo:
          _textAny(map, const ['estadoCodigo', 'estado', 'EstadoCodigo']) ??
          'ACTIVA',
      formaPagoCodigo:
          _textAny(map, const ['formaPagoCodigo', 'FormaPagoCodigo']) ??
          'EFECTIVO',
      subtotal: _doubleAny(map, const ['subtotal', 'subTotal', 'Subtotal']),
      descuento: _doubleAny(map, const ['descuento', 'Descuento']),
      iva: _doubleAny(map, const ['iva', 'Iva']),
      total: _doubleAny(map, const ['total', 'Total']),
      efectivoRecibido: _nullableDoubleAny(map, const [
        'efectivoRecibido',
        'EfectivoRecibido',
      ]),
      cambio: _nullableDoubleAny(map, const ['cambio', 'Cambio']),
      dteDocumentoId: _nullableInt(map, 'dteDocumentoId', 'DteDocumentoId'),
      lineas: _listAny(map, const [
        'lineas',
        'detalle',
        'items',
        'Lineas',
      ]).map(PosSaleLine.fromJson).toList(),
    );
  }
}

class PosSaleLine {
  const PosSaleLine({
    required this.productoId,
    required this.codigo,
    required this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
    required this.descuento,
    required this.aplicaIva,
  });

  final int? productoId;
  final String codigo;
  final String descripcion;
  final double cantidad;
  final double precioUnitario;
  final double descuento;
  final bool aplicaIva;

  double get subtotal => cantidad * precioUnitario;
  double get total => (subtotal - descuento).clamp(0, double.infinity);

  Map<String, dynamic> toJson() {
    return {
      'productoId': productoId,
      'codigo': _blankToNull(codigo),
      'descripcion': _blankToNull(descripcion),
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      'descuento': descuento,
      'aplicaIva': aplicaIva,
    };
  }

  PosSaleLine copyWith({double? cantidad}) {
    return PosSaleLine(
      productoId: productoId,
      codigo: codigo,
      descripcion: descripcion,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario,
      descuento: descuento,
      aplicaIva: aplicaIva,
    );
  }

  factory PosSaleLine.fromProduct(InvoiceLookupOption product) {
    return PosSaleLine(
      productoId: product.id == 0 ? null : product.id,
      codigo: product.parent ?? product.id.toString(),
      descripcion: product.label,
      cantidad: 1,
      precioUnitario: product.priceFromMeta,
      descuento: 0,
      aplicaIva: true,
    );
  }

  factory PosSaleLine.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return PosSaleLine(
      productoId: _nullableInt(map, 'productoId', 'ProductoId'),
      codigo: _textAny(map, const ['codigo', 'Codigo']) ?? '',
      descripcion:
          _textAny(map, const ['descripcion', 'nombre', 'Descripcion']) ??
          'Producto',
      cantidad: _doubleAny(map, const ['cantidad', 'Cantidad']),
      precioUnitario: _doubleAny(map, const [
        'precioUnitario',
        'precio',
        'PrecioUnitario',
      ]),
      descuento: _doubleAny(map, const ['descuento', 'Descuento']),
      aplicaIva: _boolAny(map, const [
        'aplicaIva',
        'AplicaIva',
      ], fallback: true),
    );
  }
}

class PosSaleDraft {
  const PosSaleDraft({
    required this.lineas,
    this.clienteId,
    this.clienteNombre,
    this.formaPagoCodigo = 'EFECTIVO',
    this.efectivoRecibido,
    this.nota,
  });

  final int? clienteId;
  final String? clienteNombre;
  final String formaPagoCodigo;
  final double? efectivoRecibido;
  final String? nota;
  final List<PosSaleLine> lineas;

  double get subtotal {
    return lineas.fold(0, (sum, line) => sum + line.subtotal);
  }

  double get descuento {
    return lineas.fold(0, (sum, line) => sum + line.descuento);
  }

  double get total {
    return lineas.fold(0, (sum, line) => sum + line.total);
  }

  bool get canSubmit => lineas.isNotEmpty;

  PosSaleDraft copyWith({
    Object? clienteId = _unset,
    Object? clienteNombre = _unset,
    String? formaPagoCodigo,
    Object? efectivoRecibido = _unset,
    Object? nota = _unset,
    List<PosSaleLine>? lineas,
  }) {
    return PosSaleDraft(
      clienteId: clienteId == _unset ? this.clienteId : clienteId as int?,
      clienteNombre: clienteNombre == _unset
          ? this.clienteNombre
          : clienteNombre as String?,
      formaPagoCodigo: formaPagoCodigo ?? this.formaPagoCodigo,
      efectivoRecibido: efectivoRecibido == _unset
          ? this.efectivoRecibido
          : efectivoRecibido as double?,
      nota: nota == _unset ? this.nota : nota as String?,
      lineas: lineas ?? this.lineas,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clienteId': clienteId,
      'clienteNombre': _blankToNull(clienteNombre) ?? 'Consumidor final',
      'formaPagoCodigo': formaPagoCodigo,
      'efectivoRecibido': efectivoRecibido,
      'nota': _blankToNull(nota),
      'lineas': lineas.map((line) => line.toJson()).toList(),
    };
  }
}

class PosQuery {
  const PosQuery({this.page = 1, this.pageSize = 10, this.search});

  final int page;
  final int pageSize;
  final String? search;

  PosQuery firstPage() => copyWith(page: 1);

  PosQuery copyWith({int? page, int? pageSize, Object? search = _unset}) {
    return PosQuery(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      search: search == _unset ? this.search : _blankToNull(search as String?),
    );
  }

  Map<String, dynamic> toQuery() {
    return {
      'page': page,
      'pageSize': pageSize,
      if (_blankToNull(search) != null) 'search': search,
    };
  }
}

class PosPromotionResult {
  const PosPromotionResult({
    required this.dteDocumentoId,
    required this.estadoCodigo,
    this.numeroControl,
    this.selloRecibido,
  });

  final int dteDocumentoId;
  final String estadoCodigo;
  final String? numeroControl;
  final String? selloRecibido;

  String get displayMessage {
    final number = numeroControl == null ? '' : ' $numeroControl';
    return 'DTE $estadoCodigo$number';
  }

  factory PosPromotionResult.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return PosPromotionResult(
      dteDocumentoId: _intAny(map, const [
        'dteDocumentoId',
        'documentoId',
        'id',
        'DteDocumentoId',
      ]),
      estadoCodigo:
          _textAny(map, const ['estadoCodigo', 'estado', 'EstadoCodigo']) ??
          'PROCESADO',
      numeroControl: _textAny(map, const ['numeroControl', 'NumeroControl']),
      selloRecibido: _textAny(map, const ['selloRecibido', 'SelloRecibido']),
    );
  }
}

class PosCashSession {
  const PosCashSession({
    required this.id,
    required this.numero,
    required this.estadoCodigo,
    required this.montoInicial,
    required this.ventas,
    required this.totalVentas,
    required this.totalEfectivo,
    required this.totalTarjeta,
    required this.totalOtros,
    required this.efectivoEsperado,
    this.sucursalId,
    this.puntoVentaId,
    this.abiertaAt,
    this.abiertaPor,
    this.cerradaAt,
    this.montoEsperado,
    this.montoContado,
    this.diferencia,
    this.cerradaPor,
    this.nota,
  });

  final int id;
  final String numero;
  final String estadoCodigo;
  final int? sucursalId;
  final int? puntoVentaId;
  final DateTime? abiertaAt;
  final double montoInicial;
  final String? abiertaPor;
  final DateTime? cerradaAt;
  final double? montoEsperado;
  final double? montoContado;
  final double? diferencia;
  final String? cerradaPor;
  final String? nota;
  final int ventas;
  final double totalVentas;
  final double totalEfectivo;
  final double totalTarjeta;
  final double totalOtros;
  final double efectivoEsperado;

  bool get isOpen => estadoCodigo.toUpperCase() == 'ABIERTA';
  String get title => numero.trim().isEmpty ? 'Caja #$id' : numero;
  String get openedLabel => _shortDateTime(abiertaAt);
  String get closedLabel => _shortDateTime(cerradaAt);
  String get differenceTone {
    final value = diferencia ?? 0;
    if (value.abs() < 0.01) {
      return 'green';
    }
    return value < 0 ? 'danger' : 'orange';
  }

  factory PosCashSession.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return PosCashSession(
      id: _int(map, 'id', 'Id'),
      numero: _textAny(map, const ['numero', 'Numero']) ?? 'CAJA',
      estadoCodigo:
          _textAny(map, const ['estadoCodigo', 'estado', 'EstadoCodigo']) ??
          'ABIERTA',
      sucursalId: _nullableInt(map, 'sucursalId', 'SucursalId'),
      puntoVentaId: _nullableInt(map, 'puntoVentaId', 'PuntoVentaId'),
      abiertaAt: _dateAny(map, const ['abiertaAt', 'AbiertaAt']),
      montoInicial: _doubleAny(map, const ['montoInicial', 'MontoInicial']),
      abiertaPor: _textAny(map, const ['abiertaPor', 'AbiertaPor']),
      cerradaAt: _dateAny(map, const ['cerradaAt', 'CerradaAt']),
      montoEsperado: _nullableDoubleAny(map, const [
        'montoEsperado',
        'MontoEsperado',
      ]),
      montoContado: _nullableDoubleAny(map, const [
        'montoContado',
        'MontoContado',
      ]),
      diferencia: _nullableDoubleAny(map, const ['diferencia', 'Diferencia']),
      cerradaPor: _textAny(map, const ['cerradaPor', 'CerradaPor']),
      nota: _textAny(map, const ['nota', 'Nota']),
      ventas: _intAny(map, const ['ventas', 'Ventas']),
      totalVentas: _doubleAny(map, const ['totalVentas', 'TotalVentas']),
      totalEfectivo: _doubleAny(map, const ['totalEfectivo', 'TotalEfectivo']),
      totalTarjeta: _doubleAny(map, const ['totalTarjeta', 'TotalTarjeta']),
      totalOtros: _doubleAny(map, const ['totalOtros', 'TotalOtros']),
      efectivoEsperado: _doubleAny(map, const [
        'efectivoEsperado',
        'EfectivoEsperado',
      ]),
    );
  }
}

class PosOpenCashRequest {
  const PosOpenCashRequest({
    required this.montoInicial,
    this.sucursalId,
    this.puntoVentaId,
    this.nota,
  });

  final double montoInicial;
  final int? sucursalId;
  final int? puntoVentaId;
  final String? nota;

  Map<String, dynamic> toJson() {
    return {
      'montoInicial': montoInicial,
      'sucursalId': sucursalId,
      'puntoVentaId': puntoVentaId,
      'nota': _blankToNull(nota),
    };
  }
}

class PosCloseCashRequest {
  const PosCloseCashRequest({required this.montoContado, this.nota});

  final double montoContado;
  final String? nota;

  Map<String, dynamic> toJson() {
    return {'montoContado': montoContado, 'nota': _blankToNull(nota)};
  }
}

class PosState {
  const PosState({
    required this.summary,
    required this.sales,
    required this.cashHistory,
    required this.query,
    required this.draft,
    required this.productResults,
    required this.total,
    required this.totalPages,
    required this.cashTotal,
    required this.cashTotalPages,
    required this.isLoading,
    required this.isLoadingMore,
    required this.isLoadingCash,
    required this.isOpeningCash,
    required this.isClosingCash,
    required this.isSearchingProducts,
    required this.isSubmitting,
    required this.isTicketBusy,
    required this.isSendingEmail,
    required this.isPromoting,
    this.selectedSale,
    this.currentCash,
    this.selectedCash,
    this.lastPromotion,
    this.ticketPath,
    this.errorMessage,
    this.traceId,
    this.successMessage,
  });

  final PosSummary summary;
  final List<PosSale> sales;
  final List<PosCashSession> cashHistory;
  final PosQuery query;
  final PosSaleDraft draft;
  final List<InvoiceLookupOption> productResults;
  final PosSale? selectedSale;
  final PosCashSession? currentCash;
  final PosCashSession? selectedCash;
  final PosPromotionResult? lastPromotion;
  final String? ticketPath;
  final int total;
  final int totalPages;
  final int cashTotal;
  final int cashTotalPages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isLoadingCash;
  final bool isOpeningCash;
  final bool isClosingCash;
  final bool isSearchingProducts;
  final bool isSubmitting;
  final bool isTicketBusy;
  final bool isSendingEmail;
  final bool isPromoting;
  final String? errorMessage;
  final String? traceId;
  final String? successMessage;

  bool get hasMore => query.page < totalPages;
  bool get isBusy =>
      isLoading ||
      isLoadingCash ||
      isOpeningCash ||
      isClosingCash ||
      isSubmitting ||
      isTicketBusy ||
      isSendingEmail ||
      isPromoting;

  factory PosState.initial() {
    return PosState(
      summary: PosSummary.empty(),
      sales: const [],
      cashHistory: const [],
      query: const PosQuery(),
      draft: const PosSaleDraft(lineas: []),
      productResults: const [],
      total: 0,
      totalPages: 0,
      cashTotal: 0,
      cashTotalPages: 0,
      isLoading: false,
      isLoadingMore: false,
      isLoadingCash: false,
      isOpeningCash: false,
      isClosingCash: false,
      isSearchingProducts: false,
      isSubmitting: false,
      isTicketBusy: false,
      isSendingEmail: false,
      isPromoting: false,
    );
  }

  PosState copyWith({
    PosSummary? summary,
    List<PosSale>? sales,
    List<PosCashSession>? cashHistory,
    PosQuery? query,
    PosSaleDraft? draft,
    List<InvoiceLookupOption>? productResults,
    Object? selectedSale = _unset,
    Object? currentCash = _unset,
    Object? selectedCash = _unset,
    Object? lastPromotion = _unset,
    Object? ticketPath = _unset,
    int? total,
    int? totalPages,
    int? cashTotal,
    int? cashTotalPages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isLoadingCash,
    bool? isOpeningCash,
    bool? isClosingCash,
    bool? isSearchingProducts,
    bool? isSubmitting,
    bool? isTicketBusy,
    bool? isSendingEmail,
    bool? isPromoting,
    Object? errorMessage = _unset,
    Object? traceId = _unset,
    Object? successMessage = _unset,
  }) {
    return PosState(
      summary: summary ?? this.summary,
      sales: sales ?? this.sales,
      cashHistory: cashHistory ?? this.cashHistory,
      query: query ?? this.query,
      draft: draft ?? this.draft,
      productResults: productResults ?? this.productResults,
      selectedSale: selectedSale == _unset
          ? this.selectedSale
          : selectedSale as PosSale?,
      currentCash: currentCash == _unset
          ? this.currentCash
          : currentCash as PosCashSession?,
      selectedCash: selectedCash == _unset
          ? this.selectedCash
          : selectedCash as PosCashSession?,
      lastPromotion: lastPromotion == _unset
          ? this.lastPromotion
          : lastPromotion as PosPromotionResult?,
      ticketPath: ticketPath == _unset
          ? this.ticketPath
          : ticketPath as String?,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
      cashTotal: cashTotal ?? this.cashTotal,
      cashTotalPages: cashTotalPages ?? this.cashTotalPages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLoadingCash: isLoadingCash ?? this.isLoadingCash,
      isOpeningCash: isOpeningCash ?? this.isOpeningCash,
      isClosingCash: isClosingCash ?? this.isClosingCash,
      isSearchingProducts: isSearchingProducts ?? this.isSearchingProducts,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isTicketBusy: isTicketBusy ?? this.isTicketBusy,
      isSendingEmail: isSendingEmail ?? this.isSendingEmail,
      isPromoting: isPromoting ?? this.isPromoting,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      traceId: traceId == _unset ? this.traceId : traceId as String?,
      successMessage: successMessage == _unset
          ? this.successMessage
          : successMessage as String?,
    );
  }

  PosState withPage(PagedResult<PosSale> page, bool append) {
    final items = append ? [...sales, ...page.items] : page.items;
    return copyWith(
      sales: items,
      selectedSale: selectedSale ?? items.firstOrNull,
      total: page.total,
      totalPages: page.totalPages,
      query: query.copyWith(page: page.page, pageSize: page.pageSize),
      isLoading: false,
      isLoadingMore: false,
      errorMessage: null,
      traceId: null,
    );
  }

  PosState withCashPage(PagedResult<PosCashSession> page) {
    return copyWith(
      cashHistory: page.items,
      selectedCash: selectedCash ?? page.items.firstOrNull,
      cashTotal: page.total,
      cashTotalPages: page.totalPages,
      isLoadingCash: false,
    );
  }
}

String posStatusTone(String status) {
  return switch (status.toUpperCase()) {
    'ANULADA' || 'RECHAZADA' => 'danger',
    'PROMOVIDA' || 'DTE' || 'PROCESADO' => 'green',
    _ => 'blue',
  };
}

String posMoney(double value) => '\$${value.toStringAsFixed(2)}';

String _shortDate(DateTime? value) {
  if (value == null) {
    return '';
  }
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  return '$day/$month/${local.year}';
}

String _shortDateTime(DateTime? value) {
  if (value == null) {
    return '';
  }
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month/${local.year} $hour:$minute';
}

String? _blankToNull(String? value) {
  final clean = value?.trim();
  return clean == null || clean.isEmpty ? null : clean;
}

int _int(Map<String, dynamic> map, String camel, String pascal) {
  return (map[camel] as num?)?.toInt() ?? (map[pascal] as num?)?.toInt() ?? 0;
}

int? _nullableInt(Map<String, dynamic> map, String camel, String pascal) {
  return (map[camel] as num?)?.toInt() ?? (map[pascal] as num?)?.toInt();
}

int _intAny(Map<String, dynamic> map, List<String> keys, {int fallback = 0}) {
  for (final key in keys) {
    final value = map[key];
    if (value is num) {
      return value.toInt();
    }
  }
  return fallback;
}

double _doubleAny(
  Map<String, dynamic> map,
  List<String> keys, {
  double fallback = 0,
}) {
  for (final key in keys) {
    final value = map[key];
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final parsed = double.tryParse(value.replaceAll(',', '.'));
      if (parsed != null) {
        return parsed;
      }
    }
  }
  return fallback;
}

double? _nullableDoubleAny(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final parsed = double.tryParse(value.replaceAll(',', '.'));
      if (parsed != null) {
        return parsed;
      }
    }
  }
  return null;
}

String? _textAny(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = _blankToNull(map[key]?.toString());
    if (value != null) {
      return value;
    }
  }
  return null;
}

bool _boolAny(
  Map<String, dynamic> map,
  List<String> keys, {
  bool fallback = false,
}) {
  for (final key in keys) {
    final value = map[key];
    if (value is bool) {
      return value;
    }
  }
  return fallback;
}

DateTime? _dateAny(Map<String, dynamic> map, List<String> keys) {
  final value = _textAny(map, keys);
  return value == null ? null : DateTime.tryParse(value);
}

List<dynamic> _listAny(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is List<dynamic>) {
      return value;
    }
  }
  return const [];
}
