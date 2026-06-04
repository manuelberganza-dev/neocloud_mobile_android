import 'models/invoice_models.dart';

class InvoiceRepository {
  const InvoiceRepository();

  InvoiceState loadInvoiceDraft() {
    return const InvoiceState(
      types: [
        DteTypeOption(code: 'CF', label: 'Consumidor final', selected: true),
        DteTypeOption(code: 'CR', label: 'Credito fiscal', selected: false),
        DteTypeOption(code: 'EX', label: 'Exportacion', selected: false),
        DteTypeOption(code: 'NC', label: 'Nota de credito', selected: false),
        DteTypeOption(code: 'ND', label: 'Nota de debito', selected: false),
      ],
      products: [
        InvoiceLine(
          name: 'Producto A',
          detail: r'1 x $100.00',
          amount: r'$100.00',
        ),
        InvoiceLine(
          name: 'Producto B',
          detail: r'2 x $50.00',
          amount: r'$100.00',
        ),
      ],
      steps: [
        InvoiceAction(
          label: 'Escanear codigo de barras',
          icon: 'scan',
          tone: 'ink',
        ),
        InvoiceAction(label: 'Vista previa del DTE', icon: 'pdf', tone: 'ink'),
        InvoiceAction(label: 'Consultar estado MH', icon: 'seal', tone: 'ink'),
      ],
      shareActions: [
        InvoiceAction(label: 'WhatsApp', icon: 'whatsapp', tone: 'green'),
        InvoiceAction(label: 'Correo', icon: 'mail', tone: 'blue'),
        InvoiceAction(label: 'Copiar enlace', icon: 'link', tone: 'ink'),
      ],
      total: r'$180.00',
    );
  }
}
