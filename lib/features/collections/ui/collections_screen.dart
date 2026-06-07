import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/action_tile.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_scaffold.dart';
import '../../auth/auth_viewmodel.dart';
import '../collections_viewmodel.dart';
import '../models/collections_models.dart';

class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authViewModelProvider);
      final user = auth.hasValue ? auth.requireValue.user : null;
      if (user?.isSuperAdmin == true ||
          user?.hasPermission('Cobros.Ver') == true) {
        ref.read(collectionsViewModelProvider.notifier).load();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(collectionsViewModelProvider);
    final authState = ref.watch(authViewModelProvider);
    final user = authState.hasValue ? authState.requireValue.user : null;
    final canView =
        user?.isSuperAdmin == true || user?.hasPermission('Cobros.Ver') == true;
    final canManage =
        user?.isSuperAdmin == true ||
        user?.hasPermission('Cobros.Gestionar') == true;

    ref.listen(collectionsViewModelProvider, (previous, next) {
      final message = next.successMessage;
      if (message != null && message != previous?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.green),
        );
      }
    });

    return NeoScaffold(
      title: 'Cobros',
      subtitle: 'Cartera, pagos y QR de cobro',
      trailing: IconButton(
        tooltip: 'Actualizar',
        onPressed: !canView || state.isLoading
            ? null
            : () => ref.read(collectionsViewModelProvider.notifier).refresh(),
        icon: const Icon(Icons.refresh_rounded, color: Colors.white),
      ),
      child: canView
          ? _CollectionsContent(
              state: state,
              canManage: canManage,
              searchController: _searchController,
            )
          : const _PermissionCard(),
    );
  }
}

class _CollectionsContent extends ConsumerWidget {
  const _CollectionsContent({
    required this.state,
    required this.canManage,
    required this.searchController,
  });

  final CollectionsState state;
  final bool canManage;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryGrid(summary: state.summary),
        const SizedBox(height: 12),
        _Filters(searchController: searchController, state: state),
        const SizedBox(height: 12),
        if (state.errorMessage != null) ...[
          _ErrorCard(message: state.errorMessage!, traceId: state.traceId),
          const SizedBox(height: 12),
        ],
        if (state.isLoading && state.items.isEmpty)
          const NeoCard(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 26),
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else if (state.items.isEmpty)
          const NeoCard(
            child: Text(
              'No hay cobros para los filtros seleccionados.',
              style: TextStyle(color: AppColors.muted),
            ),
          )
        else
          for (final item in state.items) ...[
            _InvoiceCard(item: item, canManage: canManage),
            const SizedBox(height: 10),
          ],
        if (state.hasMore) ...[
          const SizedBox(height: 2),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: state.isLoadingMore
                  ? null
                  : () => ref
                        .read(collectionsViewModelProvider.notifier)
                        .loadMore(),
              child: state.isLoadingMore
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Cargar mas'),
            ),
          ),
        ],
      ],
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary});

  final CobranzaResumen summary;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 760;
    final metrics = [
      MetricCard(
        title: 'Total pendiente',
        value: formatMoney(summary.totalPendiente),
        caption: '${summary.facturasPendientes} facturas',
        tone: 'blue',
      ),
      MetricCard(
        title: 'Total vencido',
        value: formatMoney(summary.totalVencido),
        caption: '${summary.facturasVencidas} vencidas',
        tone: 'danger',
      ),
      MetricCard(
        title: 'Clientes con deuda',
        value: summary.clientesConDeuda.toString(),
        caption: 'Seguimiento activo',
        tone: 'yellow',
      ),
    ];

    return GridView.count(
      crossAxisCount: isTablet ? 3 : 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: isTablet ? 2.4 : 3.2,
      children: metrics,
    );
  }
}

class _Filters extends ConsumerWidget {
  const _Filters({required this.searchController, required this.state});

  final TextEditingController searchController;
  final CollectionsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _Segment(
                label: 'Vencidas (${state.summary.facturasVencidas})',
                selected: state.query.soloVencidas,
                onTap: () => ref
                    .read(collectionsViewModelProvider.notifier)
                    .setSoloVencidas(true),
              ),
              _Segment(
                label: 'Pendientes (${state.summary.facturasPendientes})',
                selected: !state.query.soloVencidas,
                onTap: () => ref
                    .read(collectionsViewModelProvider.notifier)
                    .setSoloVencidas(false),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: (value) =>
              ref.read(collectionsViewModelProvider.notifier).search(value),
          decoration: InputDecoration(
            hintText: 'Buscar cliente o numero de control',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: IconButton(
              tooltip: 'Buscar',
              onPressed: () => ref
                  .read(collectionsViewModelProvider.notifier)
                  .search(searchController.text),
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.line),
            ),
          ),
        ),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? AppColors.purple : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InvoiceCard extends ConsumerWidget {
  const _InvoiceCard({required this.item, required this.canManage});

  final CobroPendiente item;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(collectionsViewModelProvider);
    final statusColor = item.isVencido ? AppColors.danger : AppColors.orange;

    return NeoCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.clienteNombre ?? 'Consumidor final',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${item.numeroControl}\nVence ${formatDate(item.vencimiento)}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatMoney(item.saldo),
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _StatusChip(
                    text: item.isVencido
                        ? '${item.diasVencido} dias vencida'
                        : 'Pendiente',
                    color: statusColor,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ProgressLine(total: item.total, paid: item.pagado),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ActionTile(
                  label: 'Saldo',
                  icon: 'client',
                  tone: 'blue',
                  compact: true,
                  onTap: state.isLoadingSaldo
                      ? null
                      : () => _showSaldo(context, ref, item),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ActionTile(
                  label: 'Pago',
                  icon: 'invoice',
                  tone: canManage ? 'green' : 'muted',
                  compact: true,
                  onTap: canManage && !state.isSavingPayment
                      ? () => _showPaymentDialog(context, ref, item)
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ActionTile(
                  label: 'QR',
                  icon: 'qr',
                  tone: 'yellow',
                  compact: true,
                  onTap: state.isGeneratingQr
                      ? null
                      : () => _showQr(context, ref, item),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showSaldo(
    BuildContext context,
    WidgetRef ref,
    CobroPendiente item,
  ) async {
    final saldo = await ref
        .read(collectionsViewModelProvider.notifier)
        .loadSaldoCliente(item.clienteId);
    if (saldo == null || !context.mounted) {
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => _SaldoSheet(saldo: saldo),
    );
  }

  Future<void> _showQr(
    BuildContext context,
    WidgetRef ref,
    CobroPendiente item,
  ) async {
    final qr = await ref
        .read(collectionsViewModelProvider.notifier)
        .generarQr(item);
    if (qr == null || !context.mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => _QrDialog(qr: qr),
    );
  }

  Future<void> _showPaymentDialog(
    BuildContext context,
    WidgetRef ref,
    CobroPendiente item,
  ) async {
    final form = await showDialog<RegistrarPagoForm>(
      context: context,
      builder: (context) => _PaymentDialog(item: item),
    );
    if (form == null) {
      return;
    }
    final result = await ref
        .read(collectionsViewModelProvider.notifier)
        .registrarPago(item, form);
    if (result != null && context.mounted) {
      FocusScope.of(context).unfocus();
    }
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.total, required this.paid});

  final double total;
  final double paid;

  @override
  Widget build(BuildContext context) {
    final ratio = total <= 0 ? 0.0 : (paid / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 7,
            backgroundColor: AppColors.line,
            color: AppColors.green,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Pagado ${formatMoney(paid)} de ${formatMoney(total)}',
          style: const TextStyle(color: AppColors.muted, fontSize: 11),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({required this.item});

  final CobroPendiente item;

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  late final TextEditingController _amountController;
  final _referenceController = TextEditingController();
  final _noteController = TextEditingController();
  String _paymentMethod = 'EFECTIVO';
  bool _pendingReview = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.item.saldo.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar pago'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(labelText: 'Monto'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _paymentMethod,
              decoration: const InputDecoration(labelText: 'Forma de pago'),
              items: const [
                DropdownMenuItem(value: 'EFECTIVO', child: Text('Efectivo')),
                DropdownMenuItem(
                  value: 'TRANSFERENCIA',
                  child: Text('Transferencia'),
                ),
                DropdownMenuItem(value: 'TARJETA', child: Text('Tarjeta')),
                DropdownMenuItem(value: 'CHEQUE', child: Text('Cheque')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _paymentMethod = value);
                }
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _referenceController,
              decoration: const InputDecoration(labelText: 'Referencia'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Nota'),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _pendingReview,
              onChanged: (value) =>
                  setState(() => _pendingReview = value ?? false),
              title: const Text('Pendiente de revision'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (_error != null) ...[
              const SizedBox(height: 6),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.danger, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Guardar')),
      ],
    );
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Indica un monto mayor a cero.');
      return;
    }
    if (amount > widget.item.saldo + 0.01) {
      setState(() => _error = 'El monto no puede superar el saldo.');
      return;
    }
    Navigator.of(context).pop(
      RegistrarPagoForm(
        monto: amount,
        formaPagoCodigo: _paymentMethod,
        fecha: DateTime.now(),
        referencia: _referenceController.text,
        nota: _noteController.text,
        pendienteRevision: _pendingReview,
      ),
    );
  }
}

class _QrDialog extends ConsumerWidget {
  const _QrDialog({required this.qr});

  final CobroQr qr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = _tryDecodeQr(qr.qrPngBase64);
    final state = ref.watch(collectionsViewModelProvider);

    return AlertDialog(
      title: const Text('QR de cobro'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (bytes == null)
              const Icon(
                Icons.qr_code_rounded,
                size: 96,
                color: AppColors.muted,
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(bytes, width: 210, height: 210),
              ),
            const SizedBox(height: 12),
            Text(
              formatMoney(qr.monto),
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              qr.referencia,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 8),
            Text(
              qr.payload,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.ink, fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
        TextButton.icon(
          onPressed: state.isSharingQr
              ? null
              : () => ref
                    .read(collectionsViewModelProvider.notifier)
                    .compartirTexto(qr),
          icon: const Icon(Icons.link_rounded),
          label: const Text('Link'),
        ),
        FilledButton.icon(
          onPressed: state.isSharingQr
              ? null
              : () => ref
                    .read(collectionsViewModelProvider.notifier)
                    .compartirQr(qr),
          icon: const Icon(Icons.qr_code_rounded),
          label: const Text('QR'),
        ),
      ],
    );
  }

  Uint8List? _tryDecodeQr(String value) {
    if (value.trim().isEmpty) {
      return null;
    }
    try {
      return base64Decode(value);
    } on FormatException {
      return null;
    }
  }
}

class _SaldoSheet extends StatelessWidget {
  const _SaldoSheet({required this.saldo});

  final SaldoCliente saldo;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              saldo.clienteNombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _SmallAmount(
                    label: 'Pendiente',
                    value: formatMoney(saldo.totalPendiente),
                    color: AppColors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SmallAmount(
                    label: 'Vencido',
                    value: formatMoney(saldo.totalVencido),
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final invoice in saldo.facturas.take(5)) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      invoice.numeroControl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(formatMoney(invoice.saldo)),
                ],
              ),
              const Divider(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _SmallAmount extends StatelessWidget {
  const _SmallAmount({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, this.traceId});

  final String message;
  final String? traceId;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_rounded, color: AppColors.danger),
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

class _PermissionCard extends StatelessWidget {
  const _PermissionCard();

  @override
  Widget build(BuildContext context) {
    return const NeoCard(
      child: Text(
        'Tu usuario no tiene permiso Cobros.Ver para consultar cartera.',
        style: TextStyle(color: AppColors.muted),
      ),
    );
  }
}
