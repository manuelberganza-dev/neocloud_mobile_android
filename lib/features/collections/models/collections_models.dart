import '../../../core/network/api_response.dart';

class CobranzaResumen {
  const CobranzaResumen({
    required this.totalPendiente,
    required this.totalVencido,
    required this.facturasPendientes,
    required this.facturasVencidas,
    required this.clientesConDeuda,
  });

  final double totalPendiente;
  final double totalVencido;
  final int facturasPendientes;
  final int facturasVencidas;
  final int clientesConDeuda;

  factory CobranzaResumen.empty() {
    return const CobranzaResumen(
      totalPendiente: 0,
      totalVencido: 0,
      facturasPendientes: 0,
      facturasVencidas: 0,
      clientesConDeuda: 0,
    );
  }

  factory CobranzaResumen.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return CobranzaResumen(
      totalPendiente: _double(map, 'totalPendiente', 'TotalPendiente'),
      totalVencido: _double(map, 'totalVencido', 'TotalVencido'),
      facturasPendientes: _int(map, 'facturasPendientes', 'FacturasPendientes'),
      facturasVencidas: _int(map, 'facturasVencidas', 'FacturasVencidas'),
      clientesConDeuda: _int(map, 'clientesConDeuda', 'ClientesConDeuda'),
    );
  }
}

class CobroPendiente {
  const CobroPendiente({
    required this.dteDocumentoId,
    required this.tipoDteCodigo,
    required this.numeroControl,
    required this.fechaEmision,
    required this.total,
    required this.pagado,
    required this.saldo,
    required this.estadoCobro,
    required this.diasVencido,
    this.vencimiento,
    this.clienteId,
    this.clienteNombre,
  });

  final int dteDocumentoId;
  final String tipoDteCodigo;
  final String numeroControl;
  final DateTime? fechaEmision;
  final DateTime? vencimiento;
  final int? clienteId;
  final String? clienteNombre;
  final double total;
  final double pagado;
  final double saldo;
  final String estadoCobro;
  final int diasVencido;

  bool get isVencido => estadoCobro.toUpperCase() == 'VENCIDO';

  factory CobroPendiente.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return CobroPendiente(
      dteDocumentoId: _int(map, 'dteDocumentoId', 'DteDocumentoId'),
      tipoDteCodigo: _text(map, 'tipoDteCodigo', 'TipoDteCodigo') ?? 'DTE',
      numeroControl: _text(map, 'numeroControl', 'NumeroControl') ?? 'SN',
      fechaEmision: _date(map, 'fechaEmision', 'FechaEmision'),
      vencimiento: _date(map, 'vencimiento', 'Vencimiento'),
      clienteId: _nullableInt(map, 'clienteId', 'ClienteId'),
      clienteNombre: _text(map, 'clienteNombre', 'ClienteNombre'),
      total: _double(map, 'total', 'Total'),
      pagado: _double(map, 'pagado', 'Pagado'),
      saldo: _double(map, 'saldo', 'Saldo'),
      estadoCobro: _text(map, 'estadoCobro', 'EstadoCobro') ?? 'PENDIENTE',
      diasVencido: _int(map, 'diasVencido', 'DiasVencido'),
    );
  }
}

class SaldoCliente {
  const SaldoCliente({
    required this.clienteNombre,
    required this.totalPendiente,
    required this.totalVencido,
    required this.facturas,
    this.clienteId,
  });

  final int? clienteId;
  final String clienteNombre;
  final double totalPendiente;
  final double totalVencido;
  final List<CobroPendiente> facturas;

  factory SaldoCliente.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return SaldoCliente(
      clienteId: _nullableInt(map, 'clienteId', 'ClienteId'),
      clienteNombre: _text(map, 'clienteNombre', 'ClienteNombre') ?? 'Cliente',
      totalPendiente: _double(map, 'totalPendiente', 'TotalPendiente'),
      totalVencido: _double(map, 'totalVencido', 'TotalVencido'),
      facturas: _list(
        map,
        'facturas',
        'Facturas',
      ).map(CobroPendiente.fromJson).toList(),
    );
  }
}

class PagoCliente {
  const PagoCliente({
    required this.id,
    required this.dteDocumentoId,
    required this.fecha,
    required this.monto,
    required this.formaPagoCodigo,
    required this.estadoCodigo,
    this.referencia,
    this.nota,
    this.comprobanteUrl,
  });

  final int id;
  final int dteDocumentoId;
  final DateTime? fecha;
  final double monto;
  final String formaPagoCodigo;
  final String? referencia;
  final String? nota;
  final String? comprobanteUrl;
  final String estadoCodigo;

  factory PagoCliente.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return PagoCliente(
      id: _int(map, 'id', 'Id'),
      dteDocumentoId: _int(map, 'dteDocumentoId', 'DteDocumentoId'),
      fecha: _date(map, 'fecha', 'Fecha'),
      monto: _double(map, 'monto', 'Monto'),
      formaPagoCodigo:
          _text(map, 'formaPagoCodigo', 'FormaPagoCodigo') ?? 'EFECTIVO',
      referencia: _text(map, 'referencia', 'Referencia'),
      nota: _text(map, 'nota', 'Nota'),
      comprobanteUrl: _text(map, 'comprobanteUrl', 'ComprobanteUrl'),
      estadoCodigo: _text(map, 'estadoCodigo', 'EstadoCodigo') ?? 'CONFIRMADO',
    );
  }
}

class RegistrarPagoForm {
  const RegistrarPagoForm({
    required this.monto,
    required this.formaPagoCodigo,
    required this.fecha,
    this.referencia,
    this.nota,
    this.pendienteRevision = false,
  });

  final double monto;
  final String formaPagoCodigo;
  final DateTime fecha;
  final String? referencia;
  final String? nota;
  final bool pendienteRevision;

  Map<String, dynamic> toJson() {
    return {
      'fecha': fecha.toIso8601String(),
      'monto': monto,
      'formaPagoCodigo': formaPagoCodigo,
      'referencia': _blankToNull(referencia),
      'nota': _blankToNull(nota),
      'pendienteRevision': pendienteRevision,
    };
  }
}

class GenerarQrCobroRequest {
  const GenerarQrCobroRequest({
    this.dteDocumentoId,
    this.cuentaCobroId,
    this.monto,
    this.referencia,
  });

  final int? dteDocumentoId;
  final int? cuentaCobroId;
  final double? monto;
  final String? referencia;

  Map<String, dynamic> toJson() {
    return {
      if (dteDocumentoId != null) 'dteDocumentoId': dteDocumentoId,
      if (cuentaCobroId != null) 'cuentaCobroId': cuentaCobroId,
      if (monto != null) 'monto': monto,
      if (_blankToNull(referencia) != null) 'referencia': referencia!.trim(),
    };
  }
}

class CobroQr {
  const CobroQr({
    required this.monto,
    required this.referencia,
    required this.cuentaNombre,
    required this.payload,
    required this.qrPngBase64,
  });

  final double monto;
  final String referencia;
  final String cuentaNombre;
  final String payload;
  final String qrPngBase64;

  factory CobroQr.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return CobroQr(
      monto: _double(map, 'monto', 'Monto'),
      referencia: _text(map, 'referencia', 'Referencia') ?? '',
      cuentaNombre: _text(map, 'cuentaNombre', 'CuentaNombre') ?? 'Cuenta',
      payload: _text(map, 'payload', 'Payload') ?? '',
      qrPngBase64: _text(map, 'qrPngBase64', 'QrPngBase64') ?? '',
    );
  }
}

class CobrosQuery {
  const CobrosQuery({
    this.page = 1,
    this.pageSize = 20,
    this.search,
    this.clienteId,
    this.soloVencidas = true,
  });

  final int page;
  final int pageSize;
  final String? search;
  final int? clienteId;
  final bool soloVencidas;

  CobrosQuery firstPage() {
    return copyWith(page: 1);
  }

  CobrosQuery copyWith({
    int? page,
    int? pageSize,
    String? search,
    int? clienteId,
    bool? soloVencidas,
    bool clearSearch = false,
  }) {
    return CobrosQuery(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      search: clearSearch ? null : search ?? this.search,
      clienteId: clienteId ?? this.clienteId,
      soloVencidas: soloVencidas ?? this.soloVencidas,
    );
  }

  Map<String, dynamic> toQuery() {
    return {
      'page': page,
      'pageSize': pageSize,
      'soloVencidas': soloVencidas,
      if (_blankToNull(search) != null) 'search': search!.trim(),
      if (clienteId != null) 'clienteId': clienteId,
    };
  }
}

class CollectionsState {
  const CollectionsState({
    required this.query,
    required this.items,
    required this.total,
    required this.totalPages,
    required this.isLoading,
    required this.isLoadingMore,
    required this.isSavingPayment,
    required this.isLoadingSaldo,
    required this.isGeneratingQr,
    required this.isSharingQr,
    required this.summary,
    this.selectedSaldo,
    this.lastPayment,
    this.lastQr,
    this.errorMessage,
    this.successMessage,
    this.traceId,
  });

  final CobrosQuery query;
  final List<CobroPendiente> items;
  final int total;
  final int totalPages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isSavingPayment;
  final bool isLoadingSaldo;
  final bool isGeneratingQr;
  final bool isSharingQr;
  final CobranzaResumen summary;
  final SaldoCliente? selectedSaldo;
  final PagoCliente? lastPayment;
  final CobroQr? lastQr;
  final String? errorMessage;
  final String? successMessage;
  final String? traceId;

  bool get hasMore => query.page < totalPages;
  bool get isBusy =>
      isLoading ||
      isLoadingMore ||
      isSavingPayment ||
      isLoadingSaldo ||
      isGeneratingQr ||
      isSharingQr;

  factory CollectionsState.initial() {
    return CollectionsState(
      query: const CobrosQuery(),
      items: const [],
      total: 0,
      totalPages: 0,
      isLoading: false,
      isLoadingMore: false,
      isSavingPayment: false,
      isLoadingSaldo: false,
      isGeneratingQr: false,
      isSharingQr: false,
      summary: CobranzaResumen.empty(),
    );
  }

  CollectionsState copyWith({
    CobrosQuery? query,
    List<CobroPendiente>? items,
    int? total,
    int? totalPages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSavingPayment,
    bool? isLoadingSaldo,
    bool? isGeneratingQr,
    bool? isSharingQr,
    CobranzaResumen? summary,
    SaldoCliente? selectedSaldo,
    PagoCliente? lastPayment,
    CobroQr? lastQr,
    String? errorMessage,
    String? successMessage,
    String? traceId,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearSaldo = false,
    bool clearQr = false,
  }) {
    return CollectionsState(
      query: query ?? this.query,
      items: items ?? this.items,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSavingPayment: isSavingPayment ?? this.isSavingPayment,
      isLoadingSaldo: isLoadingSaldo ?? this.isLoadingSaldo,
      isGeneratingQr: isGeneratingQr ?? this.isGeneratingQr,
      isSharingQr: isSharingQr ?? this.isSharingQr,
      summary: summary ?? this.summary,
      selectedSaldo: clearSaldo ? null : selectedSaldo ?? this.selectedSaldo,
      lastPayment: lastPayment ?? this.lastPayment,
      lastQr: clearQr ? null : lastQr ?? this.lastQr,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
      traceId: clearError ? null : traceId ?? this.traceId,
    );
  }

  CollectionsState withPage(PagedResult<CobroPendiente> page, bool append) {
    return copyWith(
      items: append ? [...items, ...page.items] : page.items,
      total: page.total,
      totalPages: page.totalPages,
      query: query.copyWith(page: page.page, pageSize: page.pageSize),
      isLoading: false,
      isLoadingMore: false,
    );
  }
}

String formatMoney(double value) {
  final fixed = value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final whole = parts.first;
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    final position = whole.length - i;
    buffer.write(whole[i]);
    if (position > 1 && position % 3 == 1) {
      buffer.write(',');
    }
  }
  return '\$$buffer.${parts.last}';
}

String formatDate(DateTime? value) {
  if (value == null) {
    return 'Sin fecha';
  }
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}

int _int(Map<String, dynamic> map, String camel, String pascal) {
  return (map[camel] as num?)?.toInt() ?? (map[pascal] as num?)?.toInt() ?? 0;
}

int? _nullableInt(Map<String, dynamic> map, String camel, String pascal) {
  return (map[camel] as num?)?.toInt() ?? (map[pascal] as num?)?.toInt();
}

double _double(Map<String, dynamic> map, String camel, String pascal) {
  return (map[camel] as num?)?.toDouble() ??
      (map[pascal] as num?)?.toDouble() ??
      0;
}

String? _text(Map<String, dynamic> map, String camel, String pascal) {
  final value = map[camel] ?? map[pascal];
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

DateTime? _date(Map<String, dynamic> map, String camel, String pascal) {
  return DateTime.tryParse(_text(map, camel, pascal) ?? '');
}

List<Object?> _list(Map<String, dynamic> map, String camel, String pascal) {
  return (map[camel] as List<dynamic>? ?? map[pascal] as List<dynamic>?) ??
      const [];
}

String? _blankToNull(String? value) {
  final clean = value?.trim();
  return clean == null || clean.isEmpty ? null : clean;
}
