class DteDeliveryDocument {
  const DteDeliveryDocument({
    required this.id,
    required this.numeroControl,
    required this.totalPagar,
    this.receptorCorreo,
  });

  final int id;
  final String numeroControl;
  final double totalPagar;
  final String? receptorCorreo;
}

class DteDeliveryFile {
  const DteDeliveryFile({
    required this.path,
    required this.fileName,
    required this.kind,
  });

  final String path;
  final String fileName;
  final DteDeliveryFileKind kind;
}

enum DteDeliveryFileKind {
  pdf('pdf', 'application/pdf'),
  json('json', 'application/json');

  const DteDeliveryFileKind(this.extension, this.mimeType);

  final String extension;
  final String mimeType;
}

class DteEmailDeliveryResult {
  const DteEmailDeliveryResult({
    required this.enviado,
    this.destinatario,
    this.mensaje,
    this.detalle,
  });

  final bool enviado;
  final String? destinatario;
  final String? mensaje;
  final String? detalle;

  String get displayMessage {
    return _cleanText(mensaje) ??
        _cleanText(detalle) ??
        (enviado ? 'Correo enviado.' : 'No se pudo enviar el correo.');
  }

  factory DteEmailDeliveryResult.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return DteEmailDeliveryResult(
      enviado: map['enviado'] == true,
      destinatario: _cleanText(map['destinatario']?.toString()),
      mensaje: _cleanText(map['mensaje']?.toString()),
      detalle: _cleanText(map['detalle']?.toString()),
    );
  }
}

String formatDteMoney(double value) {
  return '\$${value.toStringAsFixed(2)}';
}

String? _cleanText(String? value) {
  final clean = value?.trim();
  if (clean == null || clean.isEmpty) {
    return null;
  }
  return clean;
}
