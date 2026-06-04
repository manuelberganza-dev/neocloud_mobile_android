class ClientMetric {
  const ClientMetric({
    required this.title,
    required this.value,
    required this.tone,
  });

  final String title;
  final String value;
  final String tone;
}

class ClientContactAction {
  const ClientContactAction({required this.label, required this.icon});

  final String label;
  final String icon;
}

class ClientDetailState {
  const ClientDetailState({
    required this.name,
    required this.nit,
    required this.tag,
    required this.metrics,
    required this.actions,
  });

  final String name;
  final String nit;
  final String tag;
  final List<ClientMetric> metrics;
  final List<ClientContactAction> actions;
}
