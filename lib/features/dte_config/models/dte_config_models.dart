class DteConfig {
  const DteConfig({
    required this.empresaId,
    required this.ambienteCodigo,
    required this.tienePasswordMh,
    required this.tieneCertificado,
    required this.certificadoTienePassword,
    required this.esCompleto,
    this.usuarioMh,
    this.tipoEstablecimientoCodigo,
    this.codigoEstablecimientoMh,
    this.codigoPuntoVentaMh,
    this.certificadoNombre,
    this.certificadoHuella,
    this.certificadoEmitido,
    this.certificadoVence,
    this.ultimaPruebaAt,
    this.ultimaPruebaResultado,
    this.ultimaPruebaDetalle,
  });

  final int empresaId;
  final String ambienteCodigo;
  final String? usuarioMh;
  final bool tienePasswordMh;
  final String? tipoEstablecimientoCodigo;
  final String? codigoEstablecimientoMh;
  final String? codigoPuntoVentaMh;
  final bool tieneCertificado;
  final String? certificadoNombre;
  final String? certificadoHuella;
  final DateTime? certificadoEmitido;
  final DateTime? certificadoVence;
  final bool certificadoTienePassword;
  final DateTime? ultimaPruebaAt;
  final String? ultimaPruebaResultado;
  final String? ultimaPruebaDetalle;
  final bool esCompleto;

  bool get hasMhCredentials {
    return _hasText(usuarioMh) && tienePasswordMh;
  }

  bool get hasEstablishment {
    return _hasText(tipoEstablecimientoCodigo) &&
        _hasText(codigoEstablecimientoMh);
  }

  bool get hasPointOfSale => _hasText(codigoPuntoVentaMh);

  bool get hasCertificate => tieneCertificado;

  List<DteChecklistItem> get checklist {
    return [
      DteChecklistItem(
        title: 'Credenciales MH',
        description: hasMhCredentials
            ? 'Usuario y password configurados.'
            : 'Falta usuario o password MH.',
        isDone: hasMhCredentials,
      ),
      DteChecklistItem(
        title: 'Establecimiento',
        description: hasEstablishment
            ? '${tipoEstablecimientoCodigo ?? '-'} ${codigoEstablecimientoMh ?? ''}'
            : 'Falta tipo o codigo de establecimiento.',
        isDone: hasEstablishment,
      ),
      DteChecklistItem(
        title: 'Punto de venta',
        description: hasPointOfSale
            ? codigoPuntoVentaMh!
            : 'Falta codigo de punto de venta.',
        isDone: hasPointOfSale,
      ),
      DteChecklistItem(
        title: 'Certificado',
        description: hasCertificate
            ? certificadoNombre ?? 'Certificado cargado.'
            : 'No hay certificado cargado.',
        isDone: hasCertificate,
      ),
    ];
  }

  factory DteConfig.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return DteConfig(
      empresaId: (map['empresaId'] as num?)?.toInt() ?? 0,
      ambienteCodigo: map['ambienteCodigo']?.toString() ?? 'PRUEBAS',
      usuarioMh: _cleanText(map['usuarioMh']?.toString()),
      tienePasswordMh: map['tienePasswordMh'] == true,
      tipoEstablecimientoCodigo: _cleanText(
        map['tipoEstablecimientoCodigo']?.toString(),
      ),
      codigoEstablecimientoMh: _cleanText(
        map['codigoEstablecimientoMh']?.toString(),
      ),
      codigoPuntoVentaMh: _cleanText(map['codigoPuntoVentaMh']?.toString()),
      tieneCertificado: map['tieneCertificado'] == true,
      certificadoNombre: _cleanText(map['certificadoNombre']?.toString()),
      certificadoHuella: _cleanText(map['certificadoHuella']?.toString()),
      certificadoEmitido: DateTime.tryParse(
        map['certificadoEmitido']?.toString() ?? '',
      ),
      certificadoVence: DateTime.tryParse(
        map['certificadoVence']?.toString() ?? '',
      ),
      certificadoTienePassword: map['certificadoTienePassword'] == true,
      ultimaPruebaAt: DateTime.tryParse(
        map['ultimaPruebaAt']?.toString() ?? '',
      ),
      ultimaPruebaResultado: _cleanText(
        map['ultimaPruebaResultado']?.toString(),
      ),
      ultimaPruebaDetalle: _cleanText(map['ultimaPruebaDetalle']?.toString()),
      esCompleto: map['esCompleto'] == true,
    );
  }
}

class DteConfigForm {
  const DteConfigForm({
    required this.ambienteCodigo,
    this.usuarioMh,
    this.passwordMh,
    this.tipoEstablecimientoCodigo,
    this.codigoEstablecimientoMh,
    this.codigoPuntoVentaMh,
  });

  final String ambienteCodigo;
  final String? usuarioMh;
  final String? passwordMh;
  final String? tipoEstablecimientoCodigo;
  final String? codigoEstablecimientoMh;
  final String? codigoPuntoVentaMh;

  Map<String, Object?> toJson() {
    return {
      'ambienteCodigo': ambienteCodigo,
      'usuarioMh': _cleanText(usuarioMh),
      'passwordMh': _cleanText(passwordMh),
      'tipoEstablecimientoCodigo': _cleanText(tipoEstablecimientoCodigo),
      'codigoEstablecimientoMh': _cleanText(codigoEstablecimientoMh),
      'codigoPuntoVentaMh': _cleanText(codigoPuntoVentaMh),
    };
  }
}

class CertificateUpload {
  const CertificateUpload({
    required this.nombre,
    required this.contenidoBase64,
    this.password,
  });

  final String nombre;
  final String contenidoBase64;
  final String? password;

  Map<String, Object?> toJson() {
    return {
      'nombre': nombre,
      'contenidoBase64': contenidoBase64,
      'password': _cleanText(password),
    };
  }
}

class DteConnectionTestResult {
  const DteConnectionTestResult({
    required this.exitoso,
    required this.probadoAt,
    this.mensaje,
    this.codigoHttp,
    this.detalle,
  });

  final bool exitoso;
  final String? mensaje;
  final int? codigoHttp;
  final String? detalle;
  final DateTime probadoAt;

  String get displayMessage {
    return _cleanText(mensaje) ??
        _cleanText(detalle) ??
        (exitoso ? 'Conexion exitosa.' : 'No se pudo conectar.');
  }

  factory DteConnectionTestResult.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return DteConnectionTestResult(
      exitoso: map['exitoso'] == true,
      mensaje: _cleanText(map['mensaje']?.toString()),
      codigoHttp: (map['codigoHttp'] as num?)?.toInt(),
      detalle: _cleanText(map['detalle']?.toString()),
      probadoAt:
          DateTime.tryParse(map['probadoAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class DteChecklistItem {
  const DteChecklistItem({
    required this.title,
    required this.description,
    required this.isDone,
  });

  final String title;
  final String description;
  final bool isDone;
}

class DteConfigState {
  const DteConfigState({
    required this.isLoading,
    required this.isSaving,
    required this.isUploadingCertificate,
    required this.isTestingConnection,
    this.config,
    this.lastTest,
    this.errorMessage,
    this.traceId,
  });

  factory DteConfigState.initial() {
    return const DteConfigState(
      isLoading: false,
      isSaving: false,
      isUploadingCertificate: false,
      isTestingConnection: false,
    );
  }

  final DteConfig? config;
  final DteConnectionTestResult? lastTest;
  final bool isLoading;
  final bool isSaving;
  final bool isUploadingCertificate;
  final bool isTestingConnection;
  final String? errorMessage;
  final String? traceId;

  DteConfigState copyWith({
    DteConfig? config,
    DteConnectionTestResult? lastTest,
    bool? isLoading,
    bool? isSaving,
    bool? isUploadingCertificate,
    bool? isTestingConnection,
    Object? errorMessage = _unset,
    Object? traceId = _unset,
  }) {
    return DteConfigState(
      config: config ?? this.config,
      lastTest: lastTest ?? this.lastTest,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isUploadingCertificate:
          isUploadingCertificate ?? this.isUploadingCertificate,
      isTestingConnection: isTestingConnection ?? this.isTestingConnection,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      traceId: traceId == _unset ? this.traceId : traceId as String?,
    );
  }
}

const _unset = Object();

bool _hasText(String? value) => _cleanText(value) != null;

String? _cleanText(String? value) {
  final clean = value?.trim();
  if (clean == null || clean.isEmpty) {
    return null;
  }
  return clean;
}
