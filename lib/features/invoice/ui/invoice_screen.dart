import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/action_tile.dart';
import '../../../shared/widgets/app_visuals.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_scaffold.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../auth/auth_viewmodel.dart';
import '../../clients/models/client_models.dart' hide formatMoney;
import '../invoice_viewmodel.dart';
import '../models/invoice_models.dart';

class InvoiceScreen extends ConsumerWidget {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(invoiceViewModelProvider);
    final notifier = ref.read(invoiceViewModelProvider.notifier);
    final auth = ref.watch(authViewModelProvider);
    final user = auth.hasValue ? auth.requireValue.user : null;
    final canCreateCustomer = user?.hasPermission('Clientes.Crear') ?? false;
    final canViewProducts = user?.hasPermission('Productos.Ver') ?? false;
    final canConsultDte =
        user?.isSuperAdmin == true ||
        user?.hasPermission('DTE.Consultar') == true;
    final canResendDte =
        user?.isSuperAdmin == true ||
        user?.hasPermission('DTE.Reenviar') == true;

    return NeoScaffold(
      title: 'Nueva factura',
      subtitle: 'Emision rapida de DTE',
      trailing: const Icon(Icons.more_vert_rounded, color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.errorMessage != null) ...[
            _ErrorBanner(message: state.errorMessage!, traceId: state.traceId),
            const SizedBox(height: 12),
          ],
          NeoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _BlockTitle('Tipo de DTE'),
                GridView.builder(
                  itemCount: state.types.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.1,
                  ),
                  itemBuilder: (context, index) {
                    final type = state.types[index];
                    return _DteTypeTile(
                      code: type.code,
                      label: type.label,
                      selected: type.selected,
                      enabled: type.code == '01',
                      onTap: () => notifier.selectType(type.code),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          NeoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(child: _BlockTitle('Cliente')),
                    IconButton(
                      tooltip: 'Crear cliente',
                      onPressed: canCreateCustomer
                          ? () => _openQuickCustomer(context, ref)
                          : null,
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                    ),
                  ],
                ),
                if (state.selectedClient == null)
                  TextField(
                    onChanged: notifier.searchClients,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Buscar cliente por NIT o nombre',
                      suffixIcon: state.isSearchingClients
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.search_rounded,
                              color: AppColors.muted.withValues(alpha: 0.8),
                            ),
                    ),
                  )
                else
                  _SelectedLookup(
                    icon: Icons.person_rounded,
                    title: state.selectedClient!.label,
                    subtitle: state.selectedClient!.subtitle,
                    onClear: notifier.clearClient,
                  ),
                if (state.clientResults.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _LookupResults(
                    items: state.clientResults,
                    icon: Icons.person_rounded,
                    onSelected: notifier.selectClient,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          NeoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _BlockTitle('Productos (${state.itemCount})'),
                    ),
                    IconButton(
                      tooltip: 'Escanear codigo',
                      onPressed: canViewProducts
                          ? () => _scanProduct(context, ref)
                          : null,
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                    ),
                    Text(
                      'Draft local',
                      style: TextStyle(
                        color: AppColors.muted.withValues(alpha: 0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                TextField(
                  onChanged: notifier.searchProducts,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Buscar producto por codigo o nombre',
                    suffixIcon: state.isSearchingProducts
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : Icon(
                            Icons.add_rounded,
                            color: AppColors.purple.withValues(alpha: 0.85),
                          ),
                  ),
                ),
                if (state.productResults.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _LookupResults(
                    items: state.productResults,
                    icon: Icons.inventory_2_rounded,
                    onSelected: notifier.addProduct,
                  ),
                ],
                if (state.lines.isEmpty) ...[
                  const SizedBox(height: 14),
                  const _EmptyDraft(),
                ] else ...[
                  const SizedBox(height: 12),
                  for (var index = 0; index < state.lines.length; index++)
                    _ProductRow(
                      number: index + 1,
                      line: state.lines[index],
                      onMinus: () => notifier.decreaseQuantity(index),
                      onPlus: () => notifier.increaseQuantity(index),
                      onRemove: () => notifier.removeLine(index),
                    ),
                  const Divider(height: 24),
                  _AmountRow(
                    label: 'Subtotal',
                    value: formatMoney(state.subtotal),
                  ),
                  _AmountRow(
                    label: 'Descuento',
                    value: formatMoney(state.discountTotal),
                  ),
                  _AmountRow(
                    label: 'Total',
                    value: formatMoney(state.total),
                    isTotal: true,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _StepButton(
            label: 'Validar draft local',
            icon: 'seal',
            done: true,
          ),
          const SizedBox(height: 8),
          _StepButton(
            label: state.emission == null
                ? 'Firmar y enviar a Hacienda'
                : 'DTE emitido',
            icon: 'cloud',
            done: state.emission != null,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: state.canSubmit ? notifier.emitFactura : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.purple,
                disabledBackgroundColor: AppColors.line,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: state.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Firmar y enviar DTE'),
            ),
          ),
          if (state.emission != null) ...[
            const SizedBox(height: 14),
            _EmissionCard(result: state.emission!),
          ],
          const SizedBox(height: 14),
          const Center(
            child: Text(
              'PDF del DTE',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _ShareTile(
                  label: 'Descargar',
                  icon: 'pdf',
                  tone: 'purple',
                  busy: state.isDownloadingPdf,
                  enabled: state.canSharePdf && canConsultDte,
                  onTap: () async {
                    final file = await notifier.downloadPdf();
                    if (context.mounted && file != null) {
                      _showSnack(context, 'PDF descargado: ${file.fileName}');
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ShareTile(
                  label: 'WhatsApp',
                  icon: 'whatsapp',
                  tone: 'green',
                  busy: state.isSharingPdf,
                  enabled: state.canSharePdf && canConsultDte,
                  onTap: () => notifier.sharePdf(channel: 'WhatsApp'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ShareTile(
                  label: 'Correo',
                  icon: 'mail',
                  tone: 'blue',
                  busy: state.isSendingEmail,
                  enabled: state.canSharePdf && canResendDte,
                  onTap: () => _sendEmail(context, ref),
                ),
              ),
            ],
          ),
          if (state.pdfPath != null) ...[
            const SizedBox(height: 8),
            Text(
              'PDF listo para compartir.',
              style: TextStyle(
                color: AppColors.green,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openQuickCustomer(BuildContext context, WidgetRef ref) async {
    final form = await showModalBottomSheet<CustomerForm>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _QuickCustomerSheet(),
    );
    if (form == null || !context.mounted) {
      return;
    }

    final customer = await ref
        .read(invoiceViewModelProvider.notifier)
        .createQuickCustomer(form);
    if (context.mounted && customer != null) {
      _showSnack(context, 'Cliente creado y seleccionado.');
    }
  }

  Future<void> _scanProduct(BuildContext context, WidgetRef ref) async {
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _BarcodeScannerSheet(),
    );
    if (code == null || !context.mounted) {
      return;
    }

    await ref.read(invoiceViewModelProvider.notifier).addScannedProduct(code);
  }

  Future<void> _sendEmail(BuildContext context, WidgetRef ref) async {
    final state = ref.read(invoiceViewModelProvider);
    final initialEmail = state.emission?.receptorCorreo;
    final email = initialEmail?.trim().isNotEmpty == true
        ? initialEmail!.trim()
        : await showDialog<String>(
            context: context,
            builder: (context) => const _EmailDialog(),
          );

    if (email == null || !context.mounted) {
      return;
    }

    final result = await ref
        .read(invoiceViewModelProvider.notifier)
        .resendEmail(email);
    if (context.mounted && result != null) {
      _showSnack(context, result.displayMessage);
    }
  }
}

class _QuickCustomerSheet extends ConsumerStatefulWidget {
  const _QuickCustomerSheet();

  @override
  ConsumerState<_QuickCustomerSheet> createState() =>
      _QuickCustomerSheetState();
}

class _QuickCustomerSheetState extends ConsumerState<_QuickCustomerSheet> {
  final _document = TextEditingController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  String _type = 'DUI';
  NitVerification? _verification;

  @override
  void dispose() {
    _document.dispose();
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 14, 16, bottom + 18),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SheetHandle(),
            const Text(
              'Cliente rapido',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _type,
                    decoration: const InputDecoration(labelText: 'Tipo'),
                    items: const [
                      DropdownMenuItem(value: 'DUI', child: Text('DUI')),
                      DropdownMenuItem(value: 'NIT', child: Text('NIT')),
                    ],
                    onChanged: (value) =>
                        setState(() => _type = value ?? 'DUI'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _document,
                    decoration: InputDecoration(
                      labelText: 'NIT/DUI',
                      suffixIcon: IconButton(
                        tooltip: 'Verificar',
                        onPressed: _verify,
                        icon: const Icon(Icons.verified_rounded),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_verification != null) ...[
              const SizedBox(height: 8),
              StatusChip(
                label: _verification!.mensaje,
                tone: _verification!.formatoValido ? 'green' : 'danger',
              ),
            ],
            const SizedBox(height: 10),
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Telefono'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    CustomerForm(
                      tipoDocumentoCodigo: _type,
                      numeroDocumento: _document.text,
                      nombre: _name.text,
                      correo: _email.text,
                      telefono: _phone.text,
                    ),
                  );
                },
                child: const Text('Crear y seleccionar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verify() async {
    final result = await ref
        .read(invoiceViewModelProvider.notifier)
        .verifyDocument(_document.text);
    if (result == null) {
      return;
    }

    setState(() {
      _verification = result;
      _type = result.tipoDocumento == 'NIT' ? 'NIT' : 'DUI';
      _document.text = result.documentoNormalizado;
      if (result.nombre != null && _name.text.trim().isEmpty) {
        _name.text = result.nombre!;
      }
    });
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Escanear producto',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
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
                  String? code;
                  for (final barcode in capture.barcodes) {
                    final value = barcode.rawValue;
                    if (value != null && value.isNotEmpty) {
                      code = value;
                      break;
                    }
                  }
                  if (code == null || code.isEmpty) {
                    return;
                  }
                  _captured = true;
                  Navigator.of(context).pop(code);
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

class _BlockTitle extends StatelessWidget {
  const _BlockTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.navy,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _DteTypeTile extends StatelessWidget {
  const _DteTypeTile({
    required this.code,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String code;
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? AppColors.purple : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: selected ? AppColors.purple : AppColors.line),
      ),
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                code,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.navy,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.ink,
                  fontSize: 10,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!enabled) {
      return content;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: content,
    );
  }
}

class _LookupResults extends StatelessWidget {
  const _LookupResults({
    required this.items,
    required this.icon,
    required this.onSelected,
  });

  final List<InvoiceLookupOption> items;
  final IconData icon;
  final ValueChanged<InvoiceLookupOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            ListTile(
              dense: true,
              minLeadingWidth: 28,
              leading: Icon(icon, color: AppColors.purple, size: 18),
              title: Text(
                items[index].label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                items[index].subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
              trailing: const Icon(
                Icons.add_circle_rounded,
                color: AppColors.green,
                size: 19,
              ),
              onTap: () => onSelected(items[index]),
            ),
            if (index != items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _SelectedLookup extends StatelessWidget {
  const _SelectedLookup({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onClear,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.purple.withValues(alpha: 0.12),
              child: Icon(icon, color: AppColors.purple, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Cambiar',
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDraft extends StatelessWidget {
  const _EmptyDraft();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.inventory_2_rounded, color: AppColors.muted, size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Agrega productos para construir la factura.',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.number,
    required this.line,
    required this.onMinus,
    required this.onPlus,
    required this.onRemove,
  });

  final int number;
  final InvoiceLine line;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text('$number', style: const TextStyle(color: AppColors.muted)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  line.detail,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          _QuantityButton(icon: Icons.remove_rounded, onTap: onMinus),
          SizedBox(
            width: 28,
            child: Text(
              line.quantity.toStringAsFixed(0),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _QuantityButton(icon: Icons.add_rounded, onTap: onPlus),
          const SizedBox(width: 8),
          Text(
            formatMoney(line.total),
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          IconButton(
            tooltip: 'Eliminar',
            onPressed: onRemove,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.muted,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.line),
        ),
        child: Icon(icon, color: AppColors.purple, size: 16),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.ink, fontSize: 12),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? AppColors.blue : AppColors.ink,
              fontSize: isTotal ? 20 : 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.label,
    required this.icon,
    this.done = false,
  });

  final String label;
  final String icon;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.green : AppColors.ink;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(appIcon(icon), color: color, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (done)
              const Icon(Icons.check_circle_rounded, color: AppColors.green),
          ],
        ),
      ),
    );
  }
}

class _EmissionCard extends StatelessWidget {
  const _EmissionCard({required this.result});

  final DteEmissionResult result;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: _BlockTitle('Resultado de emision')),
              StatusChip(
                label: result.estadoCodigo,
                tone: result.tone,
                icon: Icons.verified_rounded,
              ),
            ],
          ),
          _ResultRow(label: 'Numero de control', value: result.numeroControl),
          _ResultRow(label: 'Total', value: formatMoney(result.totalPagar)),
          _ResultRow(
            label: 'Sello recibido',
            value: result.selloRecibido ?? 'Pendiente',
            mono: result.selloRecibido != null,
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    this.mono = false,
  });

  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: mono ? 3 : 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: mono ? 11 : 12,
                fontWeight: FontWeight.w800,
                fontFamily: mono ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareTile extends StatelessWidget {
  const _ShareTile({
    required this.label,
    required this.icon,
    required this.tone,
    required this.busy,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final String icon;
  final String tone;
  final bool busy;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: enabled && !busy ? onTap : null,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ActionTile(label: label, icon: icon, tone: tone, compact: true),
            if (busy)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
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
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enviar DTE'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'Correo destinatario',
          errorText: _error,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Enviar')),
      ],
    );
  }

  void _submit() {
    final email = _controller.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Ingresa un correo valido.');
      return;
    }
    Navigator.of(context).pop(email);
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, this.traceId});

  final String message;
  final String? traceId;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.danger,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (traceId != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'traceId: $traceId',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(message)));
}
