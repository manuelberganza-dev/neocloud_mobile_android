const _unset = Object();

class DteTypeOption {
  const DteTypeOption({
    required this.code,
    required this.label,
    required this.selected,
  });

  final String code;
  final String label;
  final bool selected;

  DteTypeOption copyWith({bool? selected}) {
    return DteTypeOption(
      code: code,
      label: label,
      selected: selected ?? this.selected,
    );
  }
}

class InvoiceLookupOption {
  const InvoiceLookupOption({
    required this.id,
    required this.label,
    this.parent,
    this.meta,
  });

  final int id;
  final String label;
  final String? parent;
  final String? meta;

  String get subtitle {
    final pieces = [parent, meta]
        .where((value) => value != null && value.trim().isNotEmpty)
        .map((value) => value!)
        .toList();
    return pieces.isEmpty ? 'Registro activo' : pieces.join(' - ');
  }

  double get priceFromMeta {
    return double.tryParse(meta?.replaceAll(',', '.') ?? '') ?? 0;
  }

  factory InvoiceLookupOption.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return InvoiceLookupOption(
      id: int.tryParse(map['value']?.toString() ?? '') ?? 0,
      label: map['label']?.toString() ?? 'Sin nombre',
      parent: _cleanText(map['parent']?.toString()),
      meta: _cleanText(map['meta']?.toString()),
    );
  }
}

class InvoiceLine {
  const InvoiceLine({
    required this.productId,
    required this.code,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.discount = 0,
  });

  final int productId;
  final String code;
  final String description;
  final double quantity;
  final double unitPrice;
  final double discount;

  double get subtotal => quantity * unitPrice;

  double get total =>
      (subtotal - discount).clamp(0, double.infinity).toDouble();

  String get detail =>
      '${_formatQuantity(quantity)} x ${formatMoney(unitPrice)}';

  InvoiceLine copyWith({
    double? quantity,
    double? unitPrice,
    double? discount,
  }) {
    return InvoiceLine(
      productId: productId,
      code: code,
      description: description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discount: discount ?? this.discount,
    );
  }

  Map<String, Object?> toRequestJson() {
    return {
      'productoId': productId,
      'codigo': code,
      'descripcion': description,
      'unidadMedidaCodigo': '59',
      'tipoItem': 1,
      'cantidad': quantity,
      'precioUnitario': unitPrice,
      'montoDescuento': discount,
      'clasificacion': 'GRAVADA',
      'noGravado': false,
    };
  }

  factory InvoiceLine.fromProduct(InvoiceLookupOption product) {
    return InvoiceLine(
      productId: product.id,
      code: product.parent ?? product.id.toString(),
      description: product.label,
      quantity: 1,
      unitPrice: product.priceFromMeta,
    );
  }
}

class DteEmissionResult {
  const DteEmissionResult({
    required this.id,
    required this.estadoCodigo,
    required this.numeroControl,
    required this.totalPagar,
    this.selloRecibido,
    this.receptorNombre,
    this.receptorCorreo,
  });

  final int id;
  final String estadoCodigo;
  final String numeroControl;
  final double totalPagar;
  final String? selloRecibido;
  final String? receptorNombre;
  final String? receptorCorreo;

  String get tone {
    return switch (estadoCodigo.toUpperCase()) {
      'PROCESADO' => 'green',
      'RECHAZADO' => 'danger',
      'CONTINGENCIA' => 'orange',
      _ => 'blue',
    };
  }

  factory DteEmissionResult.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return DteEmissionResult(
      id: (map['id'] as num?)?.toInt() ?? 0,
      estadoCodigo: map['estadoCodigo']?.toString() ?? 'DESCONOCIDO',
      numeroControl: map['numeroControl']?.toString() ?? '-',
      totalPagar: (map['totalPagar'] as num?)?.toDouble() ?? 0,
      selloRecibido: _cleanText(map['selloRecibido']?.toString()),
      receptorNombre: _cleanText(map['receptorNombre']?.toString()),
      receptorCorreo: _cleanText(map['receptorCorreo']?.toString()),
    );
  }
}

class InvoiceState {
  const InvoiceState({
    required this.types,
    required this.clientResults,
    required this.productResults,
    required this.lines,
    required this.isSearchingClients,
    required this.isSearchingProducts,
    required this.isSubmitting,
    required this.isDownloadingPdf,
    required this.isSharingPdf,
    required this.isSendingEmail,
    this.selectedClient,
    this.emission,
    this.errorMessage,
    this.traceId,
    this.pdfPath,
  });

  factory InvoiceState.initial() {
    return const InvoiceState(
      types: [
        DteTypeOption(code: '01', label: 'Consumidor final', selected: true),
        DteTypeOption(code: '03', label: 'Credito fiscal', selected: false),
        DteTypeOption(code: '11', label: 'Exportacion', selected: false),
        DteTypeOption(code: '05', label: 'Nota de credito', selected: false),
        DteTypeOption(code: '06', label: 'Nota de debito', selected: false),
      ],
      clientResults: [],
      productResults: [],
      lines: [],
      isSearchingClients: false,
      isSearchingProducts: false,
      isSubmitting: false,
      isDownloadingPdf: false,
      isSharingPdf: false,
      isSendingEmail: false,
    );
  }

  final List<DteTypeOption> types;
  final List<InvoiceLookupOption> clientResults;
  final List<InvoiceLookupOption> productResults;
  final List<InvoiceLine> lines;
  final InvoiceLookupOption? selectedClient;
  final DteEmissionResult? emission;
  final bool isSearchingClients;
  final bool isSearchingProducts;
  final bool isSubmitting;
  final bool isDownloadingPdf;
  final bool isSharingPdf;
  final bool isSendingEmail;
  final String? errorMessage;
  final String? traceId;
  final String? pdfPath;

  bool get isPdfBusy => isDownloadingPdf || isSharingPdf || isSendingEmail;

  String get selectedTypeCode {
    return types.firstWhere((type) => type.selected).code;
  }

  int get itemCount => lines.length;

  double get subtotal {
    return lines.fold(0, (sum, line) => sum + line.subtotal);
  }

  double get discountTotal {
    return lines.fold(0, (sum, line) => sum + line.discount);
  }

  double get total {
    return lines.fold(0, (sum, line) => sum + line.total);
  }

  bool get canSubmit {
    return !isSubmitting && selectedClient != null && lines.isNotEmpty;
  }

  bool get canSharePdf {
    return !isPdfBusy && emission != null && emission!.id > 0;
  }

  InvoiceState copyWith({
    List<DteTypeOption>? types,
    List<InvoiceLookupOption>? clientResults,
    List<InvoiceLookupOption>? productResults,
    List<InvoiceLine>? lines,
    Object? selectedClient = _unset,
    Object? emission = _unset,
    bool? isSearchingClients,
    bool? isSearchingProducts,
    bool? isSubmitting,
    bool? isDownloadingPdf,
    bool? isSharingPdf,
    bool? isSendingEmail,
    Object? errorMessage = _unset,
    Object? traceId = _unset,
    Object? pdfPath = _unset,
  }) {
    return InvoiceState(
      types: types ?? this.types,
      clientResults: clientResults ?? this.clientResults,
      productResults: productResults ?? this.productResults,
      lines: lines ?? this.lines,
      selectedClient: selectedClient == _unset
          ? this.selectedClient
          : selectedClient as InvoiceLookupOption?,
      emission: emission == _unset
          ? this.emission
          : emission as DteEmissionResult?,
      isSearchingClients: isSearchingClients ?? this.isSearchingClients,
      isSearchingProducts: isSearchingProducts ?? this.isSearchingProducts,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isDownloadingPdf: isDownloadingPdf ?? this.isDownloadingPdf,
      isSharingPdf: isSharingPdf ?? this.isSharingPdf,
      isSendingEmail: isSendingEmail ?? this.isSendingEmail,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      traceId: traceId == _unset ? this.traceId : traceId as String?,
      pdfPath: pdfPath == _unset ? this.pdfPath : pdfPath as String?,
    );
  }

  Map<String, Object?> toFacturaRequest() {
    return {
      'tipoDteCodigo': '01',
      'clienteId': selectedClient?.id,
      'condicionOperacionCodigo': '1',
      'tipoMonedaCodigo': 'USD',
      'observaciones': 'Emitido desde NeoCloud Mobile.',
      'lineas': lines.map((line) => line.toRequestJson()).toList(),
    };
  }
}

String formatMoney(double value) {
  return '\$${value.toStringAsFixed(2)}';
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
