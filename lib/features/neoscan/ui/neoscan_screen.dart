import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_scaffold.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../auth/auth_viewmodel.dart';
import '../models/neoscan_models.dart';
import '../neoscan_viewmodel.dart';

class NeoScanScreen extends ConsumerStatefulWidget {
  const NeoScanScreen({super.key});

  @override
  ConsumerState<NeoScanScreen> createState() => _NeoScanScreenState();
}

class _NeoScanScreenState extends ConsumerState<NeoScanScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(neoScanViewModelProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(neoScanViewModelProvider);
    final notifier = ref.read(neoScanViewModelProvider.notifier);
    final auth = ref.watch(authViewModelProvider);
    final user = auth.hasValue ? auth.requireValue.user : null;
    final canView = user?.hasPermission('ScanAI.Ver') == true;
    final canConfirm = user?.hasPermission('ScanAI.Confirmar') == true;
    final isTablet = MediaQuery.sizeOf(context).width >= 760;

    return NeoScaffold(
      title: 'NeoScan',
      subtitle: 'Bandeja de documentos recibidos',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Subir imagen/PDF',
            onPressed: canView && !state.isUploading
                ? () => _pickAndUpload(context)
                : null,
            icon: state.isUploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.upload_file_rounded, color: Colors.white),
          ),
          IconButton(
            tooltip: 'Actualizar',
            onPressed: canView && !state.isLoading ? notifier.refresh : null,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
      child: canView
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CapturePanel(
                  isUploading: state.isUploading,
                  onUpload: () => _pickAndUpload(context),
                ),
                const SizedBox(height: 12),
                _SearchAndFilters(
                  controller: _searchController,
                  selectedStatus: state.filters.estadoCodigo,
                  onSearch: notifier.search,
                  onStatus: notifier.setStatus,
                ),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  _ErrorCard(
                    message: state.errorMessage!,
                    traceId: state.traceId,
                  ),
                ],
                const SizedBox(height: 12),
                if (isTablet)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _Inbox(
                          state: state,
                          onSelect: notifier.select,
                          onLoadMore: notifier.loadMore,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 6,
                        child: _DocumentDetail(
                          document: state.selected,
                          canConfirm: canConfirm,
                          isSaving: state.isSaving,
                          onCorrect: _correct,
                          onRegisterExpense: _registerExpense,
                          onRegisterPurchase: _registerPurchase,
                          onRegisterDte: _registerDte,
                          onReject: _reject,
                        ),
                      ),
                    ],
                  )
                else ...[
                  _Inbox(
                    state: state,
                    onSelect: notifier.select,
                    onLoadMore: notifier.loadMore,
                  ),
                  const SizedBox(height: 12),
                  _DocumentDetail(
                    document: state.selected,
                    canConfirm: canConfirm,
                    isSaving: state.isSaving,
                    onCorrect: _correct,
                    onRegisterExpense: _registerExpense,
                    onRegisterPurchase: _registerPurchase,
                    onRegisterDte: _registerDte,
                    onReject: _reject,
                  ),
                ],
              ],
            )
          : const _NoPermissionCard(),
    );
  }

  Future<void> _pickAndUpload(BuildContext context) async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'Documentos',
          extensions: ['jpg', 'jpeg', 'png', 'pdf'],
          mimeTypes: ['image/jpeg', 'image/png', 'application/pdf'],
        ),
      ],
    );
    if (file == null) {
      return;
    }

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      if (context.mounted) {
        _showSnack(context, 'El archivo esta vacio.');
      }
      return;
    }

    final uploaded = await ref
        .read(neoScanViewModelProvider.notifier)
        .upload(
          ScanUploadRequest(
            nombre: file.name,
            contentType: file.mimeType ?? _contentTypeFromName(file.name),
            contenidoBase64: base64Encode(bytes),
          ),
        );

    if (!context.mounted) {
      return;
    }
    _showSnack(
      context,
      uploaded == null
          ? 'No se pudo subir el documento.'
          : 'Documento subido. Revisa y corrige los campos.',
    );
  }

  Future<void> _correct(ScanDocument document) async {
    final fields = await _showFieldsDialog(
      context,
      title: 'Corregir campos',
      actionLabel: 'Guardar',
      document: document,
    );
    if (fields == null) {
      return;
    }
    final ok = await ref
        .read(neoScanViewModelProvider.notifier)
        .correct(document, fields);
    if (mounted) {
      _showSnack(context, ok ? 'Campos actualizados.' : 'No se pudo guardar.');
    }
  }

  Future<void> _registerExpense(ScanDocument document) async {
    final fields = await _showFieldsDialog(
      context,
      title: 'Registrar gasto',
      actionLabel: 'Registrar',
      document: document,
    );
    if (fields == null) {
      return;
    }
    final ok = await ref
        .read(neoScanViewModelProvider.notifier)
        .registerExpense(document, fields);
    if (mounted) {
      _showSnack(context, ok ? 'Gasto registrado.' : 'No se pudo registrar.');
    }
  }

  Future<void> _registerPurchase(ScanDocument document) async {
    final fields = await _showFieldsDialog(
      context,
      title: 'Registrar compra',
      actionLabel: 'Registrar',
      document: document,
    );
    if (fields == null) {
      return;
    }
    final ok = await ref
        .read(neoScanViewModelProvider.notifier)
        .registerPurchase(document, fields);
    if (mounted) {
      _showSnack(context, ok ? 'Compra registrada.' : 'No se pudo registrar.');
    }
  }

  Future<void> _registerDte(ScanDocument document) async {
    final fields = await _showFieldsDialog(
      context,
      title: 'Registrar DTE recibido',
      actionLabel: 'Registrar',
      document: document,
    );
    if (fields == null) {
      return;
    }
    final ok = await ref
        .read(neoScanViewModelProvider.notifier)
        .registerReceivedDte(document, fields);
    if (mounted) {
      _showSnack(
        context,
        ok ? 'DTE recibido registrado.' : 'No se pudo registrar.',
      );
    }
  }

  Future<void> _reject(ScanDocument document) async {
    final reason = await _showRejectDialog(context);
    if (reason == null) {
      return;
    }
    final ok = await ref
        .read(neoScanViewModelProvider.notifier)
        .reject(document, reason);
    if (mounted) {
      _showSnack(context, ok ? 'Documento rechazado.' : 'No se pudo rechazar.');
    }
  }
}

class _CapturePanel extends StatelessWidget {
  const _CapturePanel({required this.isUploading, required this.onUpload});

  final bool isUploading;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.document_scanner_rounded,
              color: AppColors.purple,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Capturar imagen/PDF',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'El OCR puede venir vacio; corrige manualmente antes de confirmar.',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: isUploading ? null : onUpload,
            icon: const Icon(Icons.add_photo_alternate_rounded),
            label: const Text('Subir'),
          ),
        ],
      ),
    );
  }
}

class _SearchAndFilters extends StatelessWidget {
  const _SearchAndFilters({
    required this.controller,
    required this.selectedStatus,
    required this.onSearch,
    required this.onStatus,
  });

  final TextEditingController controller;
  final String? selectedStatus;
  final ValueChanged<String> onSearch;
  final ValueChanged<String?> onStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          onSubmitted: onSearch,
          decoration: InputDecoration(
            hintText: 'Buscar emisor, NIT o numero de control',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: IconButton(
              tooltip: 'Buscar',
              onPressed: () => onSearch(controller.text),
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
          ),
        ),
        const SizedBox(height: 10),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _FilterSegment(
                label: 'Todos',
                selected: selectedStatus == null,
                onTap: () => onStatus(null),
              ),
              _FilterSegment(
                label: 'Revision',
                selected: selectedStatus == 'REQUIERE_REVISION',
                onTap: () => onStatus('REQUIERE_REVISION'),
              ),
              _FilterSegment(
                label: 'Confirmados',
                selected: selectedStatus == 'CONFIRMADO',
                onTap: () => onStatus('CONFIRMADO'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterSegment extends StatelessWidget {
  const _FilterSegment({
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
            padding: const EdgeInsets.symmetric(vertical: 11),
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

class _Inbox extends StatelessWidget {
  const _Inbox({
    required this.state,
    required this.onSelect,
    required this.onLoadMore,
  });

  final NeoScanState state;
  final ValueChanged<ScanDocument> onSelect;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.documents.isEmpty) {
      return const NeoCard(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 22),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (state.documents.isEmpty) {
      return const NeoCard(
        child: Text(
          'No hay documentos en la bandeja.',
          style: TextStyle(color: AppColors.muted),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle('Bandeja (${state.total})'),
        for (final document in state.documents) ...[
          _DocumentTile(
            document: document,
            selected: state.selected?.id == document.id,
            onTap: () => onSelect(document),
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
      ],
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.document,
    required this.selected,
    required this.onTap,
  });

  final ScanDocument document;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tone = scanStatusTone(document.estadoCodigo);
    return Card(
      margin: EdgeInsets.zero,
      elevation: selected ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? AppColors.purple : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.purple.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.description_rounded,
                  color: AppColors.purple,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      document.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    document.totalText,
                    style: const TextStyle(
                      color: AppColors.blue,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  StatusChip(label: document.estadoCodigo, tone: tone),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentDetail extends StatelessWidget {
  const _DocumentDetail({
    required this.document,
    required this.canConfirm,
    required this.isSaving,
    required this.onCorrect,
    required this.onRegisterExpense,
    required this.onRegisterPurchase,
    required this.onRegisterDte,
    required this.onReject,
  });

  final ScanDocument? document;
  final bool canConfirm;
  final bool isSaving;
  final ValueChanged<ScanDocument> onCorrect;
  final ValueChanged<ScanDocument> onRegisterExpense;
  final ValueChanged<ScanDocument> onRegisterPurchase;
  final ValueChanged<ScanDocument> onRegisterDte;
  final ValueChanged<ScanDocument> onReject;

  @override
  Widget build(BuildContext context) {
    final document = this.document;
    if (document == null) {
      return const NeoCard(
        child: Text(
          'Selecciona un documento para revisar campos.',
          style: TextStyle(color: AppColors.muted),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle('Campos extraidos'),
        NeoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      document.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  StatusChip(
                    label: document.estadoCodigo,
                    tone: scanStatusTone(document.estadoCodigo),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Confianza OCR ${document.confidenceLabel}',
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const Divider(height: 22),
              _FieldRow(label: 'Emisor', value: document.emisorNombre),
              _FieldRow(label: 'NIT', value: document.emisorNit),
              _FieldRow(label: 'NRC', value: document.emisorNrc),
              _FieldRow(label: 'Fecha', value: document.fechaLabel),
              _FieldRow(label: 'Tipo', value: document.tipoDocumento),
              _FieldRow(label: 'Numero control', value: document.numeroControl),
              _FieldRow(label: 'Sello recibido', value: document.selloRecibido),
              _FieldRow(label: 'Subtotal', value: _money(document.subtotal)),
              _FieldRow(label: 'IVA', value: _money(document.iva)),
              _FieldRow(label: 'Total', value: document.totalText),
              if (document.notas != null)
                _FieldRow(label: 'Notas', value: document.notas),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _ActionButtons(
          document: document,
          canConfirm: canConfirm,
          isSaving: isSaving,
          onCorrect: onCorrect,
          onRegisterExpense: onRegisterExpense,
          onRegisterPurchase: onRegisterPurchase,
          onRegisterDte: onRegisterDte,
          onReject: onReject,
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.document,
    required this.canConfirm,
    required this.isSaving,
    required this.onCorrect,
    required this.onRegisterExpense,
    required this.onRegisterPurchase,
    required this.onRegisterDte,
    required this.onReject,
  });

  final ScanDocument document;
  final bool canConfirm;
  final bool isSaving;
  final ValueChanged<ScanDocument> onCorrect;
  final ValueChanged<ScanDocument> onRegisterExpense;
  final ValueChanged<ScanDocument> onRegisterPurchase;
  final ValueChanged<ScanDocument> onRegisterDte;
  final ValueChanged<ScanDocument> onReject;

  @override
  Widget build(BuildContext context) {
    final enabled = !isSaving && !document.isRejected && !document.isConfirmed;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: enabled ? () => onCorrect(document) : null,
            icon: const Icon(Icons.edit_note_rounded),
            label: const Text('Corregir campos'),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: canConfirm && enabled
                    ? () => onRegisterExpense(document)
                    : null,
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text('Gasto'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: canConfirm && enabled
                    ? () => onRegisterPurchase(document)
                    : null,
                icon: const Icon(Icons.shopping_bag_rounded),
                label: const Text('Compra'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: canConfirm && enabled
                    ? () => onRegisterDte(document)
                    : null,
                icon: const Icon(Icons.fact_check_rounded),
                label: const Text('DTE recibido'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.outlined(
              tooltip: 'Rechazar',
              onPressed: canConfirm && enabled
                  ? () => onReject(document)
                  : null,
              icon: const Icon(Icons.block_rounded),
            ),
          ],
        ),
        if (isSaving) ...[
          const SizedBox(height: 10),
          const LinearProgressIndicator(),
        ],
        if (!canConfirm) ...[
          const SizedBox(height: 8),
          const Text(
            'Tu usuario puede revisar, pero no confirmar documentos.',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              _empty(value),
              textAlign: TextAlign.right,
              style: const TextStyle(color: AppColors.ink, fontSize: 12),
            ),
          ),
        ],
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

class _NoPermissionCard extends StatelessWidget {
  const _NoPermissionCard();

  @override
  Widget build(BuildContext context) {
    return const NeoCard(
      child: Row(
        children: [
          Icon(Icons.lock_rounded, color: AppColors.orange),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No tienes permiso ScanAI.Ver para usar NeoScan.',
              style: TextStyle(color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldsDialog extends StatefulWidget {
  const _FieldsDialog({
    required this.title,
    required this.actionLabel,
    required this.document,
  });

  final String title;
  final String actionLabel;
  final ScanDocument document;

  @override
  State<_FieldsDialog> createState() => _FieldsDialogState();
}

class _FieldsDialogState extends State<_FieldsDialog> {
  late final TextEditingController _emisor;
  late final TextEditingController _nit;
  late final TextEditingController _nrc;
  late final TextEditingController _fecha;
  late final TextEditingController _tipo;
  late final TextEditingController _numero;
  late final TextEditingController _sello;
  late final TextEditingController _subtotal;
  late final TextEditingController _iva;
  late final TextEditingController _total;
  late final TextEditingController _notas;

  @override
  void initState() {
    super.initState();
    final fields = widget.document.toFields();
    _emisor = TextEditingController(text: fields.emisorNombre);
    _nit = TextEditingController(text: fields.emisorNit);
    _nrc = TextEditingController(text: fields.emisorNrc);
    _fecha = TextEditingController(text: fields.fecha);
    _tipo = TextEditingController(text: fields.tipoDocumento);
    _numero = TextEditingController(text: fields.numeroControl);
    _sello = TextEditingController(text: fields.selloRecibido);
    _subtotal = TextEditingController(text: fields.subtotal);
    _iva = TextEditingController(text: fields.iva);
    _total = TextEditingController(text: fields.total);
    _notas = TextEditingController(text: fields.notas);
  }

  @override
  void dispose() {
    _emisor.dispose();
    _nit.dispose();
    _nrc.dispose();
    _fecha.dispose();
    _tipo.dispose();
    _numero.dispose();
    _sello.dispose();
    _subtotal.dispose();
    _iva.dispose();
    _total.dispose();
    _notas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Input(controller: _emisor, label: 'Emisor'),
            _Input(controller: _nit, label: 'NIT'),
            _Input(controller: _nrc, label: 'NRC'),
            _Input(controller: _fecha, label: 'Fecha', hint: 'YYYY-MM-DD'),
            _Input(controller: _tipo, label: 'Tipo DTE'),
            _Input(controller: _numero, label: 'Numero de control'),
            _Input(controller: _sello, label: 'Sello recibido'),
            Row(
              children: [
                Expanded(
                  child: _Input(
                    controller: _subtotal,
                    label: 'Subtotal',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Input(
                    controller: _iva,
                    label: 'IVA',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            _Input(
              controller: _total,
              label: 'Total',
              keyboardType: TextInputType.number,
            ),
            _Input(controller: _notas, label: 'Notas', maxLines: 2),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              ScanFields(
                emisorNombre: _emisor.text,
                emisorNit: _nit.text,
                emisorNrc: _nrc.text,
                fecha: _fecha.text,
                tipoDocumento: _tipo.text,
                numeroControl: _numero.text,
                selloRecibido: _sello.text,
                subtotal: _subtotal.text,
                iva: _iva.text,
                total: _total.text,
                notas: _notas.text,
              ),
            );
          },
          child: Text(widget.actionLabel),
        ),
      ],
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
    );
  }
}

Future<ScanFields?> _showFieldsDialog(
  BuildContext context, {
  required String title,
  required String actionLabel,
  required ScanDocument document,
}) {
  return showDialog<ScanFields>(
    context: context,
    builder: (context) => _FieldsDialog(
      title: title,
      actionLabel: actionLabel,
      document: document,
    ),
  );
}

Future<String?> _showRejectDialog(BuildContext context) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Rechazar documento'),
      content: TextField(
        controller: controller,
        maxLines: 2,
        decoration: const InputDecoration(labelText: 'Motivo'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          child: const Text('Rechazar'),
        ),
      ],
    ),
  ).whenComplete(controller.dispose);
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

String _contentTypeFromName(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.pdf')) {
    return 'application/pdf';
  }
  if (lower.endsWith('.png')) {
    return 'image/png';
  }
  return 'image/jpeg';
}

String _money(double? value) {
  if (value == null) {
    return r'$0.00';
  }
  return '\$${value.toStringAsFixed(2)}';
}

String _empty(String? value) {
  final clean = value?.trim();
  return clean == null || clean.isEmpty ? 'Pendiente' : clean;
}
