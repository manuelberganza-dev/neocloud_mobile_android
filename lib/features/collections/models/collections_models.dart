class CollectionInvoice {
  const CollectionInvoice({
    required this.client,
    required this.number,
    required this.dueDate,
    required this.amount,
  });

  final String client;
  final String number;
  final String dueDate;
  final String amount;
}

class AlertItem {
  const AlertItem({
    required this.title,
    required this.subtitle,
    required this.age,
    required this.tone,
  });

  final String title;
  final String subtitle;
  final String age;
  final String tone;
}

class CollectionsState {
  const CollectionsState({required this.invoices, required this.alerts});

  final List<CollectionInvoice> invoices;
  final List<AlertItem> alerts;
}
