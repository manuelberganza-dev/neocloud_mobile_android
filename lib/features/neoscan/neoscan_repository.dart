import 'models/neoscan_models.dart';

class NeoScanRepository {
  const NeoScanRepository();

  NeoScanState loadScanPreview() {
    return const NeoScanState(
      fields: [
        ExtractedField(label: 'Emisor', value: 'Comercial XYZ, S.A.'),
        ExtractedField(label: 'NIT/NRC', value: '0614-123456-001-0'),
        ExtractedField(label: 'Fecha', value: '20/05/2026'),
        ExtractedField(label: 'Monto', value: r'$245.00'),
        ExtractedField(
          label: 'Numero de control',
          value: 'DTE-03-M001P001-000000123',
        ),
        ExtractedField(
          label: 'Sello de recepcion',
          value: '2026A8CDEF1234567890',
        ),
      ],
      actions: [
        ScanAction(label: 'Guardar imagen/PDF', icon: 'cloud', tone: 'blue'),
        ScanAction(
          label: 'Clasificar compra/gasto',
          icon: 'catalog',
          tone: 'purple',
        ),
        ScanAction(
          label: 'Asociar a proveedor',
          icon: 'client',
          tone: 'purple',
        ),
        ScanAction(label: 'Validar QR DTE', icon: 'qr', tone: 'purple'),
        ScanAction(
          label: 'Crear proveedor desde factura',
          icon: 'client',
          tone: 'purple',
        ),
        ScanAction(
          label: 'Subir respaldo al panel web',
          icon: 'cloud',
          tone: 'blue',
        ),
      ],
    );
  }
}
