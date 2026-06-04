class ExtractedField {
  const ExtractedField({required this.label, required this.value});

  final String label;
  final String value;
}

class ScanAction {
  const ScanAction({
    required this.label,
    required this.icon,
    required this.tone,
  });

  final String label;
  final String icon;
  final String tone;
}

class NeoScanState {
  const NeoScanState({required this.fields, required this.actions});

  final List<ExtractedField> fields;
  final List<ScanAction> actions;
}
