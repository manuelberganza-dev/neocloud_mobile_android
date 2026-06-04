class DteDocument {
  const DteDocument({
    required this.number,
    required this.date,
    required this.party,
    required this.amount,
    required this.status,
    required this.tone,
  });

  final String number;
  final String date;
  final String party;
  final String amount;
  final String status;
  final String tone;
}

class ToolAction {
  const ToolAction({
    required this.label,
    required this.icon,
    required this.tone,
  });

  final String label;
  final String icon;
  final String tone;
}

class DteQueryState {
  const DteQueryState({required this.documents, required this.tools});

  final List<DteDocument> documents;
  final List<ToolAction> tools;
}
