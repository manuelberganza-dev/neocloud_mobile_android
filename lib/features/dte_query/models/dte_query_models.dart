import 'dart:convert';

import '../../../core/network/api_response.dart';

const _unset = Object();

class DteFilters {
  const DteFilters({
    this.search,
    this.estadoCodigo,
    this.tipoDteCodigo,
    this.desde,
    this.hasta,
    this.page = 1,
    this.pageSize = 10,
  });

  final String? search;
  final String? estadoCodigo;
  final String? tipoDteCodigo;
  final DateTime? desde;
  final DateTime? hasta;
  final int page;
  final int pageSize;

  DteFilters copyWith({
    Object? search = _unset,
    Object? estadoCodigo = _unset,
    Object? tipoDteCodigo = _unset,
    Object? desde = _unset,
    Object? hasta = _unset,
    int? page,
    int? pageSize,
  }) {
    return DteFilters(
      search: search == _unset ? this.search : _cleanText(search as String?),
      estadoCodigo: estadoCodigo == _unset
          ? this.estadoCodigo
          : _cleanText(estadoCodigo as String?),
      tipoDteCodigo: tipoDteCodigo == _unset
          ? this.tipoDteCodigo
          : _cleanText(tipoDteCodigo as String?),
      desde: desde == _unset ? this.desde : desde as DateTime?,
      hasta: hasta == _unset ? this.hasta : hasta as DateTime?,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  DteFilters firstPage() => copyWith(page: 1);

  Map<String, dynamic> toQueryParameters() {
    return {
      'page': page,
      'pageSize': pageSize,
      if (_cleanText(search) != null) 'search': search!.trim(),
      if (_cleanText(estadoCodigo) != null) 'estadoCodigo': estadoCodigo,
      if (_cleanText(tipoDteCodigo) != null) 'tipoDteCodigo': tipoDteCodigo,
      if (desde != null) 'desde': _dateOnly(desde!),
      if (hasta != null) 'hasta': _dateOnly(hasta!),
    };
  }
}

class DteListItem {
  const DteListItem({
    required this.id,
    required this.tipoDteCodigo,
    required this.numeroControl,
    required this.codigoGeneracion,
    required this.fechaEmision,
    required this.montoTotalOperacion,
    required this.totalPagar,
    required this.estadoCodigo,
    required this.ambienteCodigo,
    required this.createdAt,
    this.receptorNombre,
    this.receptorNumeroDocumento,
  });

  final int id;
  final String tipoDteCodigo;
  final String numeroControl;
  final String codigoGeneracion;
  final DateTime? fechaEmision;
  final String? receptorNombre;
  final String? receptorNumeroDocumento;
  final double montoTotalOperacion;
  final double totalPagar;
  final String estadoCodigo;
  final String ambienteCodigo;
  final DateTime? createdAt;

  String get typeLabel => dteTypeLabel(tipoDteCodigo);

  String get dateLabel => fechaEmision == null ? '-' : _dateOnly(fechaEmision!);

  String get amountLabel => formatMoney(totalPagar);

  String get statusLabel => estadoCodigo.toUpperCase();

  String get tone => dteStatusTone(estadoCodigo);

  factory DteListItem.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return DteListItem(
      id: (map['id'] as num?)?.toInt() ?? 0,
      tipoDteCodigo: map['tipoDteCodigo']?.toString() ?? '',
      numeroControl: map['numeroControl']?.toString() ?? '-',
      codigoGeneracion: map['codigoGeneracion']?.toString() ?? '-',
      fechaEmision: DateTime.tryParse(map['fechaEmision']?.toString() ?? ''),
      receptorNombre: _cleanText(map['receptorNombre']?.toString()),
      receptorNumeroDocumento: _cleanText(
        map['receptorNumeroDocumento']?.toString(),
      ),
      montoTotalOperacion:
          (map['montoTotalOperacion'] as num?)?.toDouble() ?? 0,
      totalPagar: (map['totalPagar'] as num?)?.toDouble() ?? 0,
      estadoCodigo: map['estadoCodigo']?.toString() ?? 'DESCONOCIDO',
      ambienteCodigo: map['ambienteCodigo']?.toString() ?? '-',
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? ''),
    );
  }
}

class DteDetail extends DteListItem {
  const DteDetail({
    required super.id,
    required super.tipoDteCodigo,
    required super.numeroControl,
    required super.codigoGeneracion,
    required super.fechaEmision,
    required super.montoTotalOperacion,
    required super.totalPagar,
    required super.estadoCodigo,
    required super.ambienteCodigo,
    required super.createdAt,
    required this.selloRecibido,
    required this.detalles,
    this.receptorCorreo,
    this.receptorTelefono,
    this.jsonDte,
    this.respuestaHacienda,
    super.receptorNombre,
    super.receptorNumeroDocumento,
  });

  final String? selloRecibido;
  final String? receptorCorreo;
  final String? receptorTelefono;
  final List<DteLineItem> detalles;
  final String? jsonDte;
  final String? respuestaHacienda;

  String? get rejectionMessage {
    final raw = _cleanText(respuestaHacienda);
    if (raw == null) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        final fields = [
          decoded['descripcionMsg'],
          decoded['descripcion'],
          decoded['mensaje'],
          decoded['observaciones'],
          decoded['detalle'],
        ];
        final text = fields
            .where((value) => value != null)
            .map((value) => value is List ? value.join(', ') : value.toString())
            .map(_cleanText)
            .whereType<String>()
            .join(' - ');
        return _cleanText(text);
      }
    } catch (_) {
      return raw;
    }

    return raw;
  }

  factory DteDetail.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return DteDetail(
      id: (map['id'] as num?)?.toInt() ?? 0,
      tipoDteCodigo: map['tipoDteCodigo']?.toString() ?? '',
      numeroControl: map['numeroControl']?.toString() ?? '-',
      codigoGeneracion: map['codigoGeneracion']?.toString() ?? '-',
      fechaEmision: DateTime.tryParse(map['fechaEmision']?.toString() ?? ''),
      receptorNombre: _cleanText(map['receptorNombre']?.toString()),
      receptorNumeroDocumento: _cleanText(
        map['receptorNumeroDocumento']?.toString(),
      ),
      receptorCorreo: _cleanText(map['receptorCorreo']?.toString()),
      receptorTelefono: _cleanText(map['receptorTelefono']?.toString()),
      montoTotalOperacion:
          (map['montoTotalOperacion'] as num?)?.toDouble() ?? 0,
      totalPagar: (map['totalPagar'] as num?)?.toDouble() ?? 0,
      estadoCodigo: map['estadoCodigo']?.toString() ?? 'DESCONOCIDO',
      ambienteCodigo: map['ambienteCodigo']?.toString() ?? '-',
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? ''),
      selloRecibido: _cleanText(map['selloRecibido']?.toString()),
      detalles: (map['detalles'] as List<dynamic>? ?? const [])
          .map(DteLineItem.fromJson)
          .toList(),
      jsonDte: _cleanText(map['jsonDte']?.toString()),
      respuestaHacienda: _cleanText(map['respuestaHacienda']?.toString()),
    );
  }
}

class DteLineItem {
  const DteLineItem({
    required this.numeroLinea,
    required this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
    required this.ventaGravada,
  });

  final int numeroLinea;
  final String descripcion;
  final double cantidad;
  final double precioUnitario;
  final double ventaGravada;

  String get detail =>
      '${_formatQuantity(cantidad)} x ${formatMoney(precioUnitario)}';

  String get totalLabel => formatMoney(ventaGravada);

  factory DteLineItem.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return DteLineItem(
      numeroLinea: (map['numeroLinea'] as num?)?.toInt() ?? 0,
      descripcion: map['descripcion']?.toString() ?? 'Producto',
      cantidad: (map['cantidad'] as num?)?.toDouble() ?? 0,
      precioUnitario: (map['precioUnitario'] as num?)?.toDouble() ?? 0,
      ventaGravada: (map['ventaGravada'] as num?)?.toDouble() ?? 0,
    );
  }
}

class DteDownloadedFile {
  const DteDownloadedFile({required this.path, required this.fileName});

  final String path;
  final String fileName;
}

class DteQueryState {
  const DteQueryState({
    required this.documents,
    required this.filters,
    required this.total,
    required this.totalPages,
    required this.isLoading,
    required this.isLoadingMore,
    required this.isDetailLoading,
    required this.isFileBusy,
    required this.isSendingEmail,
    required this.isSharingPdf,
    this.selectedDetail,
    this.errorMessage,
    this.traceId,
    this.lastDownloadedFile,
  });

  factory DteQueryState.initial() {
    return const DteQueryState(
      documents: [],
      filters: DteFilters(),
      total: 0,
      totalPages: 0,
      isLoading: false,
      isLoadingMore: false,
      isDetailLoading: false,
      isFileBusy: false,
      isSendingEmail: false,
      isSharingPdf: false,
    );
  }

  final List<DteListItem> documents;
  final DteFilters filters;
  final int total;
  final int totalPages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isDetailLoading;
  final bool isFileBusy;
  final bool isSendingEmail;
  final bool isSharingPdf;
  final DteDetail? selectedDetail;
  final String? errorMessage;
  final String? traceId;
  final DteDownloadedFile? lastDownloadedFile;

  bool get hasMore => filters.page < totalPages;

  bool get isEmpty => !isLoading && documents.isEmpty && errorMessage == null;

  DteQueryState copyWith({
    List<DteListItem>? documents,
    DteFilters? filters,
    int? total,
    int? totalPages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isDetailLoading,
    bool? isFileBusy,
    bool? isSendingEmail,
    bool? isSharingPdf,
    Object? selectedDetail = _unset,
    Object? errorMessage = _unset,
    Object? traceId = _unset,
    Object? lastDownloadedFile = _unset,
  }) {
    return DteQueryState(
      documents: documents ?? this.documents,
      filters: filters ?? this.filters,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      isFileBusy: isFileBusy ?? this.isFileBusy,
      isSendingEmail: isSendingEmail ?? this.isSendingEmail,
      isSharingPdf: isSharingPdf ?? this.isSharingPdf,
      selectedDetail: selectedDetail == _unset
          ? this.selectedDetail
          : selectedDetail as DteDetail?,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      traceId: traceId == _unset ? this.traceId : traceId as String?,
      lastDownloadedFile: lastDownloadedFile == _unset
          ? this.lastDownloadedFile
          : lastDownloadedFile as DteDownloadedFile?,
    );
  }

  DteQueryState withPage(
    PagedResult<DteListItem> page, {
    required bool append,
  }) {
    return copyWith(
      documents: append ? [...documents, ...page.items] : page.items,
      filters: filters.copyWith(page: page.page, pageSize: page.pageSize),
      total: page.total,
      totalPages: page.totalPages,
      isLoading: false,
      isLoadingMore: false,
      errorMessage: null,
      traceId: null,
    );
  }
}

String dteTypeLabel(String code) {
  return switch (code) {
    '01' => 'Factura',
    '03' => 'Credito fiscal',
    '05' => 'Nota credito',
    '06' => 'Nota debito',
    '11' => 'Exportacion',
    '14' => 'Sujeto excluido',
    _ => code.isEmpty ? 'DTE' : code,
  };
}

String dteStatusTone(String status) {
  return switch (status.toUpperCase()) {
    'PROCESADO' => 'green',
    'RECHAZADO' => 'danger',
    'CONTINGENCIA' => 'orange',
    'INVALIDADO' => 'ink',
    'ERROR' => 'danger',
    'BORRADOR' => 'yellow',
    'FIRMADO' => 'blue',
    'ENVIADO' => 'blue',
    _ => 'yellow',
  };
}

String formatMoney(double value) {
  return '\$${value.toStringAsFixed(2)}';
}

String _dateOnly(DateTime date) {
  final local = date.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

String _formatQuantity(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(2);
}

String? _cleanText(String? value) {
  final clean = value?.trim();
  if (clean == null || clean.isEmpty) {
    return null;
  }
  return clean;
}
