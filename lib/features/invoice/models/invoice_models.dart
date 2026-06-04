class DteTypeOption {
  const DteTypeOption({
    required this.code,
    required this.label,
    required this.selected,
  });

  final String code;
  final String label;
  final bool selected;
}

class InvoiceLine {
  const InvoiceLine({
    required this.name,
    required this.detail,
    required this.amount,
  });

  final String name;
  final String detail;
  final String amount;
}

class InvoiceAction {
  const InvoiceAction({
    required this.label,
    required this.icon,
    required this.tone,
  });

  final String label;
  final String icon;
  final String tone;
}

class InvoiceState {
  const InvoiceState({
    required this.types,
    required this.products,
    required this.steps,
    required this.shareActions,
    required this.total,
  });

  final List<DteTypeOption> types;
  final List<InvoiceLine> products;
  final List<InvoiceAction> steps;
  final List<InvoiceAction> shareActions;
  final String total;
}
