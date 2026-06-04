import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'invoice_repository.dart';
import 'models/invoice_models.dart';

part 'invoice_viewmodel.g.dart';

@riverpod
InvoiceRepository invoiceRepository(Ref ref) {
  return const InvoiceRepository();
}

@riverpod
InvoiceState invoiceViewModel(Ref ref) {
  return ref.watch(invoiceRepositoryProvider).loadInvoiceDraft();
}
