import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_scaffold.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../invoice/models/invoice_models.dart';
import '../models/pos_models.dart';
import '../pos_viewmodel.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final _productSearch = TextEditingController();
  final _customerName = TextEditingController();
  final _salesSearch = TextEditingController();
  final _cash = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(posViewModelProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _productSearch.dispose();
    _customerName.dispose();
    _salesSearch.dispose();
    _cash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(posViewModelProvider);
    final notifier = ref.read(posViewModelProvider.notifier);
    final isTablet = MediaQuery.sizeOf(context).width >= 820;

    return NeoScaffold(
      title: 'Venta POS',
      subtitle: 'Factura tradicional sin DTE',
      trailing: IconButton(
        tooltip: 'Actualizar',
        onPressed: state.isLoading ? null : notifier.refresh,
        icon: const Icon(Icons.refresh_rounded, color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryRow(summary: state.summary),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 12),
            _MessageCard(
              message: state.errorMessage!,
              traceId: state.traceId,
              isError: true,
            ),
          ],
          if (state.successMessage != null) ...[
            const SizedBox(height: 12),
            _MessageCard(message: state.successMessage!, isError: false),
          ],
          const SizedBox(height: 12),
          if (isTablet)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: _QuickSalePanel(
                    state: state,
                    productSearch: _productSearch,
                    customerName: _customerName,
                    cash: _cash,
                    onSearchProduct: notifier.searchProducts,
                    onAddProduct: notifier.addProduct,
                    onScan: _scanProduct,
                    onQuantity: notifier.updateQuantity,
                    onRemove: notifier.removeLine,
                    onCustomerChanged: notifier.setCustomerName,
                    onPaymentChanged: notifier.setPayment,
                    onSubmit: _createSale,
                    onClear: notifier.clearDraft,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: _HistoryPanel(
                    state: state,
                    salesSearch: _salesSearch,
                    onSearch: notifier.searchSales,
                    onSelect: notifier.selectSale,
                    onLoadMore: notifier.loadMore,
                    onDownloadTicket: _downloadTicket,
                    onShareTicket: _shareTicket,
                    onSendEmail: _sendTicket,
                    onPromote: _promoteSale,
                    onCancel: _cancelSale,
                  ),
                ),
              ],
            )
          else ...[
            _QuickSalePanel(
              state: state,
              productSearch: _productSearch,
              customerName: _customerName,
              cash: _cash,
              onSearchProduct: notifier.searchProducts,
              onAddProduct: notifier.addProduct,
              onScan: _scanProduct,
              onQuantity: notifier.updateQuantity,
              onRemove: notifier.removeLine,
              onCustomerChanged: notifier.setCustomerName,
              onPaymentChanged: notifier.setPayment,
              onSubmit: _createSale,
              onClear: notifier.clearDraft,
            ),
            const SizedBox(height: 12),
            _HistoryPanel(
              state: state,
              salesSearch: _salesSearch,
              onSearch: notifier.searchSales,
              onSelect: notifier.selectSale,
              onLoadMore: notifier.loadMore,
              onDownloadTicket: _downloadTicket,
              onShareTicket: _shareTicket,
              onSendEmail: _sendTicket,
              onPromote: _promoteSale,
              onCancel: _cancelSale,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _scanProduct() async {
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _BarcodeScannerSheet(),
    );
    if (code == null || !mounted) {
      return;
    }
    await ref.read(posViewModelProvider.notifier).addScannedProduct(code);
  }

  Future<void> _createSale() async {
    final sale = await ref.read(posViewModelProvider.notifier).createSale();
    if (mounted && sale != null) {
      _showSnack(context, 'Venta ${sale.title} creada.');
    }
  }

  Future<void> _downloadTicket(PosSale sale) async {
    final path = await ref
        .read(posViewModelProvider.notifier)
        .downloadTicket(sale);
    if (mounted && path != null) {
      _showSnack(context, 'Ticket descargado: $path');
    }
  }

  Future<void> _shareTicket(PosSale sale) async {
    await ref.read(posViewModelProvider.notifier).shareTicket(sale);
  }

  Future<void> _sendTicket(PosSale sale) async {
    final email = await showDialog<String>(
      context: context,
      builder: (context) => const _EmailDialog(),
    );
    if (email == null || !mounted) {
      return;
    }
    final ok = await ref
        .read(posViewModelProvider.notifier)
        .sendTicket(sale, email);
    if (mounted && ok) {
      _showSnack(context, 'Ticket enviado.');
    }
  }

  Future<void> _promoteSale(PosSale sale) async {
    final type = await showDialog<String>(
      context: context,
      builder: (context) => const _DteTypeDialog(),
    );
    if (type == null || !mounted) {
      return;
    }
    final result = await ref
        .read(posViewModelProvider.notifier)
        .promoteSale(sale, tipoDteCodigo: type);
    if (mounted && result != null) {
      _showSnack(context, result.displayMessage);
    }
  }

  Future<void> _cancelSale(PosSale sale) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Anular venta'),
        content: Text('Quieres anular ${sale.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Anular'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) {
      return;
    }
    final ok = await ref.read(posViewModelProvider.notifier).cancelSale(sale);
    if (mounted && ok) {
      _showSnack(context, 'Venta anulada.');
    }
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.summary});

  final PosSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            label: 'Ventas',
            value: summary.ventas.toString(),
            color: AppColors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryTile(
            label: 'Total dia',
            value: posMoney(summary.total),
            color: AppColors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryTile(
            label: 'Ticket prom.',
            value: posMoney(summary.ticketPromedio),
            color: AppColors.purple,
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickSalePanel extends StatelessWidget {
  const _QuickSalePanel({
    required this.state,
    required this.productSearch,
    required this.customerName,
    required this.cash,
    required this.onSearchProduct,
    required this.onAddProduct,
    required this.onScan,
    required this.onQuantity,
    required this.onRemove,
    required this.onCustomerChanged,
    required this.onPaymentChanged,
    required this.onSubmit,
    required this.onClear,
  });

  final PosState state;
  final TextEditingController productSearch;
  final TextEditingController customerName;
  final TextEditingController cash;
  final ValueChanged<String> onSearchProduct;
  final ValueChanged<InvoiceLookupOption> onAddProduct;
  final VoidCallback onScan;
  final void Function(int index, double quantity) onQuantity;
  final ValueChanged<int> onRemove;
  final ValueChanged<String> onCustomerChanged;
  final void Function(String payment, {double? cash}) onPaymentChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final draft = state.draft;
    final cashValue = double.tryParse(cash.text.replaceAll(',', '.'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Venta rapida'),
        NeoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: productSearch,
                textInputAction: TextInputAction.search,
                onSubmitted: onSearchProduct,
                decoration: InputDecoration(
                  labelText: 'Producto o codigo',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Escanear codigo',
                        onPressed: onScan,
                        icon: const Icon(Icons.qr_code_scanner_rounded),
                      ),
                      IconButton(
                        tooltip: 'Buscar',
                        onPressed: () => onSearchProduct(productSearch.text),
                        icon: const Icon(Icons.arrow_forward_rounded),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.isSearchingProducts) ...[
                const SizedBox(height: 8),
                const LinearProgressIndicator(),
              ],
              if (state.productResults.isNotEmpty) ...[
                const SizedBox(height: 8),
                for (final product in state.productResults.take(5))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      product.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(product.subtitle),
                    trailing: Text(posMoney(product.priceFromMeta)),
                    onTap: () {
                      productSearch.clear();
                      onAddProduct(product);
                    },
                  ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: customerName,
                onChanged: onCustomerChanged,
                decoration: const InputDecoration(
                  labelText: 'Cliente',
                  hintText: 'Consumidor final',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: draft.formaPagoCodigo,
                      decoration: const InputDecoration(
                        labelText: 'Forma de pago',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'EFECTIVO',
                          child: Text('Efectivo'),
                        ),
                        DropdownMenuItem(
                          value: 'TARJETA',
                          child: Text('Tarjeta'),
                        ),
                        DropdownMenuItem(
                          value: 'TRANSFERENCIA',
                          child: Text('Transferencia'),
                        ),
                      ],
                      onChanged: (value) {
                        onPaymentChanged(value ?? 'EFECTIVO', cash: cashValue);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: cash,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => onPaymentChanged(
                        draft.formaPagoCodigo,
                        cash: double.tryParse(value.replaceAll(',', '.')),
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Efectivo recibido',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _CartCard(
          draft: draft,
          isSubmitting: state.isSubmitting,
          onQuantity: onQuantity,
          onRemove: onRemove,
          onSubmit: onSubmit,
          onClear: onClear,
        ),
      ],
    );
  }
}

class _CartCard extends StatelessWidget {
  const _CartCard({
    required this.draft,
    required this.isSubmitting,
    required this.onQuantity,
    required this.onRemove,
    required this.onSubmit,
    required this.onClear,
  });

  final PosSaleDraft draft;
  final bool isSubmitting;
  final void Function(int index, double quantity) onQuantity;
  final ValueChanged<int> onRemove;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Carrito',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Limpiar',
                onPressed: draft.lineas.isEmpty ? null : onClear,
                icon: const Icon(Icons.delete_sweep_rounded),
              ),
            ],
          ),
          if (draft.lineas.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Agrega productos para crear una venta.',
                style: TextStyle(color: AppColors.muted),
              ),
            )
          else
            for (var index = 0; index < draft.lineas.length; index++) ...[
              _CartLine(
                line: draft.lineas[index],
                onAdd: () =>
                    onQuantity(index, draft.lineas[index].cantidad + 1),
                onSubtract: () =>
                    onQuantity(index, draft.lineas[index].cantidad - 1),
                onRemove: () => onRemove(index),
              ),
              if (index != draft.lineas.length - 1) const Divider(height: 14),
            ],
          const Divider(height: 20),
          _TotalRow(label: 'Subtotal', value: posMoney(draft.subtotal)),
          _TotalRow(label: 'Descuento', value: posMoney(draft.descuento)),
          _TotalRow(label: 'Total', value: posMoney(draft.total), strong: true),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: draft.canSubmit && !isSubmitting ? onSubmit : null,
              icon: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.point_of_sale_rounded),
              label: const Text('Crear venta'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartLine extends StatelessWidget {
  const _CartLine({
    required this.line,
    required this.onAdd,
    required this.onSubtract,
    required this.onRemove,
  });

  final PosSaleLine line;
  final VoidCallback onAdd;
  final VoidCallback onSubtract;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.descripcion,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${line.cantidad.toStringAsFixed(0)} x ${posMoney(line.precioUnitario)}',
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Restar',
          onPressed: onSubtract,
          icon: const Icon(Icons.remove_circle_outline_rounded),
        ),
        IconButton(
          tooltip: 'Sumar',
          onPressed: onAdd,
          icon: const Icon(Icons.add_circle_outline_rounded),
        ),
        Text(
          posMoney(line.total),
          style: const TextStyle(
            color: AppColors.blue,
            fontWeight: FontWeight.w900,
          ),
        ),
        IconButton(
          tooltip: 'Quitar',
          onPressed: onRemove,
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }
}

class _HistoryPanel extends StatelessWidget {
  const _HistoryPanel({
    required this.state,
    required this.salesSearch,
    required this.onSearch,
    required this.onSelect,
    required this.onLoadMore,
    required this.onDownloadTicket,
    required this.onShareTicket,
    required this.onSendEmail,
    required this.onPromote,
    required this.onCancel,
  });

  final PosState state;
  final TextEditingController salesSearch;
  final ValueChanged<String> onSearch;
  final ValueChanged<PosSale> onSelect;
  final VoidCallback onLoadMore;
  final ValueChanged<PosSale> onDownloadTicket;
  final ValueChanged<PosSale> onShareTicket;
  final ValueChanged<PosSale> onSendEmail;
  final ValueChanged<PosSale> onPromote;
  final ValueChanged<PosSale> onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Ventas recientes'),
        TextField(
          controller: salesSearch,
          textInputAction: TextInputAction.search,
          onSubmitted: onSearch,
          decoration: InputDecoration(
            hintText: 'Buscar venta o cliente',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: IconButton(
              tooltip: 'Buscar',
              onPressed: () => onSearch(salesSearch.text),
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (state.isLoading && state.sales.isEmpty)
          const NeoCard(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else if (state.sales.isEmpty)
          const NeoCard(
            child: Text(
              'Aun no hay ventas POS.',
              style: TextStyle(color: AppColors.muted),
            ),
          )
        else
          for (final sale in state.sales) ...[
            _SaleTile(
              sale: sale,
              selected: state.selectedSale?.id == sale.id,
              onTap: () => onSelect(sale),
            ),
            const SizedBox(height: 8),
          ],
        if (state.hasMore)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: state.isLoadingMore ? null : onLoadMore,
              child: state.isLoadingMore
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Cargar mas'),
            ),
          ),
        const SizedBox(height: 12),
        _TicketPanel(
          sale: state.selectedSale,
          isBusy:
              state.isTicketBusy ||
              state.isSendingEmail ||
              state.isPromoting ||
              state.isSubmitting,
          onDownload: onDownloadTicket,
          onShare: onShareTicket,
          onEmail: onSendEmail,
          onPromote: onPromote,
          onCancel: onCancel,
        ),
      ],
    );
  }
}

class _SaleTile extends StatelessWidget {
  const _SaleTile({
    required this.sale,
    required this.selected,
    required this.onTap,
  });

  final PosSale sale;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? AppColors.purple : Colors.transparent,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.blue.withValues(alpha: 0.1),
          child: const Icon(Icons.receipt_rounded, color: AppColors.blue),
        ),
        title: Text(
          sale.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text('${sale.customerLabel} ${sale.dateLabel}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              posMoney(sale.total),
              style: const TextStyle(
                color: AppColors.blue,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            StatusChip(
              label: sale.estadoCodigo,
              tone: posStatusTone(sale.estadoCodigo),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketPanel extends StatelessWidget {
  const _TicketPanel({
    required this.sale,
    required this.isBusy,
    required this.onDownload,
    required this.onShare,
    required this.onEmail,
    required this.onPromote,
    required this.onCancel,
  });

  final PosSale? sale;
  final bool isBusy;
  final ValueChanged<PosSale> onDownload;
  final ValueChanged<PosSale> onShare;
  final ValueChanged<PosSale> onEmail;
  final ValueChanged<PosSale> onPromote;
  final ValueChanged<PosSale> onCancel;

  @override
  Widget build(BuildContext context) {
    final sale = this.sale;
    if (sale == null) {
      return const NeoCard(
        child: Text(
          'Selecciona una venta para ver ticket y acciones.',
          style: TextStyle(color: AppColors.muted),
        ),
      );
    }

    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  sale.title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                posMoney(sale.total),
                style: const TextStyle(
                  color: AppColors.blue,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final line in sale.lineas.take(4))
            _TotalRow(
              label:
                  '${line.cantidad.toStringAsFixed(0)} x ${line.descripcion}',
              value: posMoney(line.total),
            ),
          if (sale.lineas.length > 4)
            Text(
              '+${sale.lineas.length - 4} lineas mas',
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          const Divider(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: isBusy ? null : () => onDownload(sale),
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: const Text('Ticket'),
              ),
              OutlinedButton.icon(
                onPressed: isBusy ? null : () => onShare(sale),
                icon: const Icon(Icons.chat_rounded),
                label: const Text('WhatsApp'),
              ),
              OutlinedButton.icon(
                onPressed: isBusy ? null : () => onEmail(sale),
                icon: const Icon(Icons.mail_rounded),
                label: const Text('Correo'),
              ),
              FilledButton.icon(
                onPressed: isBusy || sale.isPromoted || sale.isAnulada
                    ? null
                    : () => onPromote(sale),
                icon: const Icon(Icons.verified_rounded),
                label: const Text('Convertir a DTE'),
              ),
              IconButton.outlined(
                tooltip: 'Anular',
                onPressed: isBusy || sale.isAnulada
                    ? null
                    : () => onCancel(sale),
                icon: const Icon(Icons.block_rounded),
              ),
            ],
          ),
          if (isBusy) ...[
            const SizedBox(height: 10),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: strong ? AppColors.navy : AppColors.muted,
                fontWeight: strong ? FontWeight.w900 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: strong ? AppColors.blue : AppColors.ink,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.message,
    required this.isError,
    this.traceId,
  });

  final String message;
  final bool isError;
  final String? traceId;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.warning_rounded : Icons.check_circle_rounded,
            color: isError ? AppColors.danger : AppColors.green,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: const TextStyle(color: AppColors.ink)),
                if (traceId != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'traceId: $traceId',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmailDialog extends StatefulWidget {
  const _EmailDialog();

  @override
  State<_EmailDialog> createState() => _EmailDialogState();
}

class _EmailDialogState extends State<_EmailDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enviar ticket'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(labelText: 'Correo'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('Enviar'),
        ),
      ],
    );
  }
}

class _DteTypeDialog extends StatefulWidget {
  const _DteTypeDialog();

  @override
  State<_DteTypeDialog> createState() => _DteTypeDialogState();
}

class _DteTypeDialogState extends State<_DteTypeDialog> {
  String _type = '01';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Convertir a DTE'),
      content: DropdownButtonFormField<String>(
        initialValue: _type,
        decoration: const InputDecoration(labelText: 'Tipo DTE'),
        items: const [
          DropdownMenuItem(
            value: '01',
            child: Text('Factura consumidor final'),
          ),
          DropdownMenuItem(value: '03', child: Text('Credito fiscal')),
        ],
        onChanged: (value) => setState(() => _type = value ?? '01'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_type),
          child: const Text('Convertir'),
        ),
      ],
    );
  }
}

class _BarcodeScannerSheet extends StatefulWidget {
  const _BarcodeScannerSheet();

  @override
  State<_BarcodeScannerSheet> createState() => _BarcodeScannerSheetState();
}

class _BarcodeScannerSheetState extends State<_BarcodeScannerSheet> {
  late final MobileScannerController _controller;
  bool _captured = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      formats: const [
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
        BarcodeFormat.code128,
        BarcodeFormat.code39,
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.72,
      child: Column(
        children: [
          const SizedBox(height: 14),
          const _SheetHandle(),
          const Text(
            'Escanear producto',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: MobileScanner(
                controller: _controller,
                onDetect: (capture) {
                  if (_captured) {
                    return;
                  }
                  for (final barcode in capture.barcodes) {
                    final value = barcode.rawValue;
                    if (value == null || value.isEmpty) {
                      continue;
                    }
                    _captured = true;
                    Navigator.of(context).pop(value);
                    return;
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
              label: const Text('Cancelar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 4,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.line,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
