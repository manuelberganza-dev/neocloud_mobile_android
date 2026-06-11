import '../../../core/network/api_response.dart';

const _unset = Object();

class ScanDocument {
  const ScanDocument({
    required this.id,
    required this.estadoCodigo,
    required this.origen,
    required this.tieneArchivo,
    required this.confianza,
    required this.createdAt,
    this.tipoClasificacion,
    this.archivoNombre,
    this.archivoContentType,
    this.emisorNombre,
    this.emisorNit,
    this.emisorNrc,
    this.fecha,
    this.tipoDocumento,
    this.numeroControl,
    this.selloRecibido,
    this.subtotal,
    this.iva,
    this.total,
    this.notas,
    this.profitGastoId,
    this.profitCompraId,
    this.dteRecibidoId,
  });

  final int id;
  final String estadoCodigo;
  final String? tipoClasificacion;
  final String origen;
  final String? archivoNombre;
  final String? archivoContentType;
  final bool tieneArchivo;
  final String? emisorNombre;
  final String? emisorNit;
  final String? emisorNrc;
  final DateTime? fecha;
  final String? tipoDocumento;
  final String? numeroControl;
  final String? selloRecibido;
  final double? subtotal;
  final double? iva;
  final double? total;
  final double confianza;
  final String? notas;
  final int? profitGastoId;
  final int? profitCompraId;
  final int? dteRecibidoId;
  final DateTime? createdAt;

  bool get needsReview => estadoCodigo.toUpperCase() == 'REQUIERE_REVISION';
  bool get isConfirmed => estadoCodigo.toUpperCase() == 'CONFIRMADO';
  bool get isRejected => estadoCodigo.toUpperCase() == 'RECHAZADO';

  String get title {
    return _clean(emisorNombre) ?? archivoNombre ?? 'Documento #$id';
  }

  String get subtitle {
    final parts = [
      if (_clean(numeroControl) != null) numeroControl,
      if (_clean(tipoDocumento) != null) tipoDocumento,
      if (fechaLabel.isNotEmpty) fechaLabel,
    ];
    return parts.isEmpty ? estadoCodigo : parts.join(' - ');
  }

  String get fechaText => _dateText(fecha);
  String get fechaLabel => _shortDate(fecha);
  String get totalText => _money(total);
  String get confidenceLabel => '${(confianza * 100).round()}%';

  ScanFields toFields() {
    return ScanFields(
      emisorNombre: emisorNombre ?? '',
      emisorNit: emisorNit ?? '',
      emisorNrc: emisorNrc ?? '',
      fecha: fechaText,
      tipoDocumento: tipoDocumento ?? '',
      numeroControl: numeroControl ?? '',
      selloRecibido: selloRecibido ?? '',
      subtotal: _decimalText(subtotal),
      iva: _decimalText(iva),
      total: _decimalText(total),
      notas: notas ?? '',
    );
  }

  factory ScanDocument.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return ScanDocument(
      id: _int(map, 'id', 'Id'),
      estadoCodigo:
          _text(map, 'estadoCodigo', 'EstadoCodigo') ?? 'REQUIERE_REVISION',
      tipoClasificacion: _text(map, 'tipoClasificacion', 'TipoClasificacion'),
      origen: _text(map, 'origen', 'Origen') ?? 'MOBILE',
      archivoNombre: _text(map, 'archivoNombre', 'ArchivoNombre'),
      archivoContentType: _text(
        map,
        'archivoContentType',
        'ArchivoContentType',
      ),
      tieneArchivo: _bool(map, 'tieneArchivo', 'TieneArchivo'),
      emisorNombre: _text(map, 'emisorNombre', 'EmisorNombre'),
      emisorNit: _text(map, 'emisorNit', 'EmisorNit'),
      emisorNrc: _text(map, 'emisorNrc', 'EmisorNrc'),
      fecha: _date(map, 'fecha', 'Fecha'),
      tipoDocumento: _text(map, 'tipoDocumento', 'TipoDocumento'),
      numeroControl: _text(map, 'numeroControl', 'NumeroControl'),
      selloRecibido: _text(map, 'selloRecibido', 'SelloRecibido'),
      subtotal: _double(map, 'subtotal', 'Subtotal'),
      iva: _double(map, 'iva', 'Iva'),
      total: _double(map, 'total', 'Total'),
      confianza: _double(map, 'confianza', 'Confianza') ?? 0,
      notas: _text(map, 'notas', 'Notas'),
      profitGastoId: _nullableInt(map, 'profitGastoId', 'ProfitGastoId'),
      profitCompraId: _nullableInt(map, 'profitCompraId', 'ProfitCompraId'),
      dteRecibidoId: _nullableInt(map, 'dteRecibidoId', 'DteRecibidoId'),
      createdAt: _date(map, 'createdAt', 'CreatedAt'),
    );
  }
}

class ScanFields {
  const ScanFields({
    required this.emisorNombre,
    required this.emisorNit,
    required this.emisorNrc,
    required this.fecha,
    required this.tipoDocumento,
    required this.numeroControl,
    required this.selloRecibido,
    required this.subtotal,
    required this.iva,
    required this.total,
    required this.notas,
  });

  final String emisorNombre;
  final String emisorNit;
  final String emisorNrc;
  final String fecha;
  final String tipoDocumento;
  final String numeroControl;
  final String selloRecibido;
  final String subtotal;
  final String iva;
  final String total;
  final String notas;

  Map<String, dynamic> toCorrectionJson() {
    return {
      'emisorNombre': _nullableText(emisorNombre),
      'emisorNit': _nullableText(emisorNit),
      'emisorNrc': _nullableText(emisorNrc),
      'fecha': _nullableText(fecha),
      'tipoDocumento': _nullableText(tipoDocumento),
      'numeroControl': _nullableText(numeroControl),
      'selloRecibido': _nullableText(selloRecibido),
      'subtotal': _parseDecimal(subtotal),
      'iva': _parseDecimal(iva),
      'total': _parseDecimal(total),
      'notas': _nullableText(notas),
    };
  }

  Map<String, dynamic> toGastoJson() {
    return {
      'fecha': _nullableText(fecha),
      'categoria': 'OTROS',
      'descripcion': _nullableText(notas) ?? 'Gasto capturado desde NeoScan',
      'proveedor': _nullableText(emisorNombre),
      'monto': _parseDecimal(subtotal) ?? _parseDecimal(total) ?? 0,
      'ivaMonto': _parseDecimal(iva) ?? 0,
      'ivaDeducible': true,
    };
  }

  Map<String, dynamic> toCompraJson() {
    return {
      'fecha': _nullableText(fecha),
      'proveedor': _nullableText(emisorNombre) ?? 'Proveedor',
      'numeroDocumento': _nullableText(numeroControl),
      'descripcion': _nullableText(notas) ?? 'Compra capturada desde NeoScan',
      'subtotal': _parseDecimal(subtotal) ?? 0,
      'ivaMonto': _parseDecimal(iva) ?? 0,
    };
  }

  Map<String, dynamic> toDteRecibidoJson() {
    return {
      'emisorNombre': _nullableText(emisorNombre) ?? 'Proveedor',
      'emisorNit': _nullableText(emisorNit),
      'emisorNrc': _nullableText(emisorNrc),
      'fecha': _nullableText(fecha),
      'tipoDteCodigo': _nullableText(tipoDocumento),
      'numeroControl': _nullableText(numeroControl),
      'selloRecibido': _nullableText(selloRecibido),
      'subtotal': _parseDecimal(subtotal) ?? 0,
      'iva': _parseDecimal(iva) ?? 0,
      'total': _parseDecimal(total) ?? 0,
    };
  }
}

class ScanUploadRequest {
  const ScanUploadRequest({
    required this.nombre,
    required this.contentType,
    required this.contenidoBase64,
  });

  final String nombre;
  final String contentType;
  final String contenidoBase64;

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'contentType': contentType,
      'contenidoBase64': contenidoBase64,
      'origen': 'MOBILE',
    };
  }
}

class ScanFilters {
  const ScanFilters({
    this.page = 1,
    this.pageSize = 20,
    this.search,
    this.estadoCodigo,
    this.tipoClasificacion,
  });

  final int page;
  final int pageSize;
  final String? search;
  final String? estadoCodigo;
  final String? tipoClasificacion;

  ScanFilters firstPage() => copyWith(page: 1);

  ScanFilters copyWith({
    int? page,
    int? pageSize,
    Object? search = _unset,
    Object? estadoCodigo = _unset,
    Object? tipoClasificacion = _unset,
  }) {
    return ScanFilters(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      search: search == _unset ? this.search : _nullableText(search as String?),
      estadoCodigo: estadoCodigo == _unset
          ? this.estadoCodigo
          : _nullableText(estadoCodigo as String?),
      tipoClasificacion: tipoClasificacion == _unset
          ? this.tipoClasificacion
          : _nullableText(tipoClasificacion as String?),
    );
  }

  Map<String, dynamic> toQuery() {
    return {
      'page': page,
      'pageSize': pageSize,
      if (_nullableText(search) != null) 'search': search,
      if (_nullableText(estadoCodigo) != null) 'estadoCodigo': estadoCodigo,
      if (_nullableText(tipoClasificacion) != null)
        'tipoClasificacion': tipoClasificacion,
    };
  }
}

class NeoScanState {
  const NeoScanState({
    required this.documents,
    required this.filters,
    required this.total,
    required this.totalPages,
    required this.isLoading,
    required this.isLoadingMore,
    required this.isUploading,
    required this.isSaving,
    this.selected,
    this.errorMessage,
    this.traceId,
  });

  final List<ScanDocument> documents;
  final ScanDocument? selected;
  final ScanFilters filters;
  final int total;
  final int totalPages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isUploading;
  final bool isSaving;
  final String? errorMessage;
  final String? traceId;

  bool get hasMore => filters.page < totalPages;

  factory NeoScanState.initial() {
    return const NeoScanState(
      documents: [],
      filters: ScanFilters(),
      total: 0,
      totalPages: 0,
      isLoading: false,
      isLoadingMore: false,
      isUploading: false,
      isSaving: false,
    );
  }

  NeoScanState copyWith({
    List<ScanDocument>? documents,
    Object? selected = _unset,
    ScanFilters? filters,
    int? total,
    int? totalPages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isUploading,
    bool? isSaving,
    Object? errorMessage = _unset,
    Object? traceId = _unset,
  }) {
    return NeoScanState(
      documents: documents ?? this.documents,
      selected: selected == _unset ? this.selected : selected as ScanDocument?,
      filters: filters ?? this.filters,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isUploading: isUploading ?? this.isUploading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      traceId: traceId == _unset ? this.traceId : traceId as String?,
    );
  }

  NeoScanState withPage(PagedResult<ScanDocument> page, bool append) {
    final nextItems = append ? [...documents, ...page.items] : page.items;
    return copyWith(
      documents: nextItems,
      selected: selected ?? nextItems.firstOrNull,
      total: page.total,
      totalPages: page.totalPages,
      filters: filters.copyWith(page: page.page, pageSize: page.pageSize),
      isLoading: false,
      isLoadingMore: false,
      errorMessage: null,
      traceId: null,
    );
  }
}

String scanStatusTone(String status) {
  return switch (status.toUpperCase()) {
    'CONFIRMADO' => 'green',
    'RECHAZADO' || 'ERROR' => 'danger',
    'REQUIERE_REVISION' => 'orange',
    'PROCESANDO' => 'blue',
    _ => 'purple',
  };
}

String _money(double? value) {
  if (value == null) {
    return r'$0.00';
  }
  return '\$${value.toStringAsFixed(2)}';
}

String _decimalText(double? value) {
  return value == null ? '' : value.toStringAsFixed(2);
}

String _dateText(DateTime? value) {
  if (value == null) {
    return '';
  }
  final local = value.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

String _shortDate(DateTime? value) {
  if (value == null) {
    return '';
  }
  final local = value.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '$day/$month/${local.year}';
}

String? _nullableText(String? value) {
  final clean = value?.trim();
  return clean == null || clean.isEmpty ? null : clean;
}

String? _clean(String? value) => _nullableText(value);

num? _parseDecimal(String value) {
  final clean = value.trim().replaceAll(',', '');
  if (clean.isEmpty) {
    return null;
  }
  return num.tryParse(clean);
}

int _int(Map<String, dynamic> map, String camel, String pascal) {
  return (map[camel] as num?)?.toInt() ?? (map[pascal] as num?)?.toInt() ?? 0;
}

int? _nullableInt(Map<String, dynamic> map, String camel, String pascal) {
  return (map[camel] as num?)?.toInt() ?? (map[pascal] as num?)?.toInt();
}

double? _double(Map<String, dynamic> map, String camel, String pascal) {
  return (map[camel] as num?)?.toDouble() ?? (map[pascal] as num?)?.toDouble();
}

bool _bool(Map<String, dynamic> map, String camel, String pascal) {
  return map[camel] == true || map[pascal] == true;
}

String? _text(Map<String, dynamic> map, String camel, String pascal) {
  return _nullableText((map[camel] ?? map[pascal])?.toString());
}

DateTime? _date(Map<String, dynamic> map, String camel, String pascal) {
  final value = _text(map, camel, pascal);
  return value == null ? null : DateTime.tryParse(value);
}
