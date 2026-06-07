import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/action_tile.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_scaffold.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../auth/auth_viewmodel.dart';
import '../../auth/models/auth_models.dart';
import '../dte_query_viewmodel.dart';
import '../models/dte_query_models.dart';

class DteQueryScreen extends ConsumerStatefulWidget {
  const DteQueryScreen({super.key});

  @override
  ConsumerState<DteQueryScreen> createState() => _DteQueryScreenState();
}

class _DteQueryScreenState extends ConsumerState<DteQueryScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(dteQueryViewModelProvider.notifier).loadFirstPage();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dteQueryViewModelProvider);
    final notifier = ref.read(dteQueryViewModelProvider.notifier);
    final authState = ref.watch(authViewModelProvider);
    final user = authState.hasValue ? authState.requireValue.user : null;

    return NeoScaffold(
      title: 'Consulta DTE',
      subtitle: '${state.total} documentos emitidos',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Configuracion DTE',
            onPressed: () => context.push('/dte/configuracion'),
            icon: const Icon(Icons.settings_rounded, color: Colors.white),
          ),
          IconButton(
            tooltip: 'Actualizar',
            onPressed: state.isLoading ? null : notifier.refresh,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FiltersCard(
            state: state,
            searchController: _searchController,
            onSearch: () => notifier.applyFilters(
              search: _searchController.text,
              estadoCodigo: state.filters.estadoCodigo,
              tipoDteCodigo: state.filters.tipoDteCodigo,
              desde: state.filters.desde,
              hasta: state.filters.hasta,
            ),
            onStatusChanged: notifier.setStatus,
            onTypeChanged: notifier.setType,
            onDatesChanged: notifier.setDateRange,
            onClear: () {
              _searchController.clear();
              notifier.clearFilters();
            },
          ),
          const SizedBox(height: 12),
          if (state.errorMessage != null) ...[
            _ErrorBanner(
              message: state.errorMessage!,
              traceId: state.traceId,
              onRetry: notifier.refresh,
            ),
            const SizedBox(height: 12),
          ],
          if (state.isLoading)
            const _LoadingList()
          else if (state.isEmpty)
            const _EmptyState()
          else ...[
            for (final document in state.documents) ...[
              _DocumentCard(
                document: document,
                onTap: () => _openDetail(context, ref, document.id),
              ),
              const SizedBox(height: 10),
            ],
            if (state.hasMore)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: state.isLoadingMore ? null : notifier.loadMore,
                  icon: state.isLoadingMore
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.expand_more_rounded),
                  label: const Text('Cargar mas'),
                ),
              ),
          ],
          const SizedBox(height: 8),
          if (user != null) _ProfileCompanyCard(user: user),
        ],
      ),
    );
  }

  Future<void> _openDetail(
    BuildContext context,
    WidgetRef ref,
    int documentId,
  ) async {
    await ref.read(dteQueryViewModelProvider.notifier).loadDetail(documentId);
    if (!context.mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => const _DteDetailSheet(),
    );
  }
}

class _FiltersCard extends StatelessWidget {
  const _FiltersCard({
    required this.state,
    required this.searchController,
    required this.onSearch,
    required this.onStatusChanged,
    required this.onTypeChanged,
    required this.onDatesChanged,
    required this.onClear,
  });

  final DteQueryState state;
  final TextEditingController searchController;
  final VoidCallback onSearch;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onTypeChanged;
  final void Function(DateTime? desde, DateTime? hasta) onDatesChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: searchController,
            onSubmitted: (_) => onSearch(),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Buscar numero, cliente o codigo',
              suffixIcon: IconButton(
                tooltip: 'Buscar',
                onPressed: onSearch,
                icon: const Icon(Icons.search_rounded),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _FilterRow(
            title: 'Estado',
            children: [
              _FilterChipButton(
                label: 'Todos',
                selected: state.filters.estadoCodigo == null,
                onTap: () => onStatusChanged(null),
              ),
              for (final status in const [
                'PROCESADO',
                'RECHAZADO',
                'CONTINGENCIA',
                'BORRADOR',
              ])
                _FilterChipButton(
                  label: status,
                  selected: state.filters.estadoCodigo == status,
                  onTap: () => onStatusChanged(status),
                ),
            ],
          ),
          const SizedBox(height: 10),
          _FilterRow(
            title: 'Tipo',
            children: [
              _FilterChipButton(
                label: 'Todos',
                selected: state.filters.tipoDteCodigo == null,
                onTap: () => onTypeChanged(null),
              ),
              for (final type in const ['01', '03', '05', '06', '11'])
                _FilterChipButton(
                  label: dteTypeLabel(type),
                  selected: state.filters.tipoDteCodigo == type,
                  onTap: () => onTypeChanged(type),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _DateButton(
                  label: 'Desde',
                  value: state.filters.desde,
                  onTap: () async {
                    final picked = await _pickDate(
                      context,
                      state.filters.desde,
                    );
                    if (picked != null) {
                      onDatesChanged(picked, state.filters.hasta);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DateButton(
                  label: 'Hasta',
                  value: state.filters.hasta,
                  onTap: () async {
                    final picked = await _pickDate(
                      context,
                      state.filters.hasta,
                    );
                    if (picked != null) {
                      onDatesChanged(state.filters.desde, picked);
                    }
                  },
                ),
              ),
              IconButton(
                tooltip: 'Limpiar filtros',
                onPressed: onClear,
                icon: const Icon(Icons.filter_alt_off_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _pickDate(BuildContext context, DateTime? value) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: children),
        ),
      ],
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        selectedColor: AppColors.purple,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.ink,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.calendar_today_rounded, size: 15),
      label: Text(
        value == null ? label : _formatDate(value!),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.document, required this.onTap});

  final DteListItem document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: NeoCard(
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
                        document.numeroControl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${document.dateLabel} - ${document.typeLabel}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        document.receptorNombre ?? 'Consumidor final',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusChip(
                      label: document.statusLabel,
                      tone: document.tone,
                      icon: Icons.check_circle_rounded,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      document.amountLabel,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                _MiniChip('PDF'),
                SizedBox(width: 6),
                _MiniChip('JSON'),
                SizedBox(width: 6),
                _MiniChip('Detalle'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DteDetailSheet extends ConsumerWidget {
  const _DteDetailSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dteQueryViewModelProvider);
    final notifier = ref.read(dteQueryViewModelProvider.notifier);
    final detail = state.selectedDetail;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      minChildSize: 0.45,
      maxChildSize: 0.96,
      builder: (context, controller) {
        if (state.isDetailLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (detail == null) {
          return _SheetFrame(
            controller: controller,
            child: _ErrorBanner(
              message: state.errorMessage ?? 'No se pudo cargar el detalle.',
              traceId: state.traceId,
              onRetry: () {},
            ),
          );
        }

        return _SheetFrame(
          controller: controller,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detail.numeroControl,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${detail.typeLabel} - ${detail.dateLabel}',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(
                    label: detail.statusLabel,
                    tone: detail.tone,
                    icon: Icons.verified_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (detail.estadoCodigo.toUpperCase() == 'RECHAZADO' &&
                  detail.rejectionMessage != null) ...[
                _RejectionCard(message: detail.rejectionMessage!),
                const SizedBox(height: 12),
              ],
              _DetailBlock(
                rows: [
                  _InfoRow(
                    'Cliente',
                    detail.receptorNombre ?? 'Consumidor final',
                  ),
                  _InfoRow('Documento', detail.receptorNumeroDocumento ?? '-'),
                  _InfoRow('Correo', detail.receptorCorreo ?? '-'),
                  _InfoRow('Ambiente', detail.ambienteCodigo),
                  _InfoRow('Total', detail.amountLabel),
                  _InfoRow(
                    'Sello',
                    detail.selloRecibido ?? 'Pendiente',
                    mono: true,
                  ),
                  _InfoRow(
                    'Codigo generacion',
                    detail.codigoGeneracion,
                    mono: true,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const _SectionTitle('Detalle'),
              if (detail.detalles.isEmpty)
                const Text(
                  'Sin lineas de detalle.',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                )
              else
                for (final line in detail.detalles) _LineRow(line: line),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SheetAction(
                      label: 'PDF',
                      icon: 'pdf',
                      tone: 'purple',
                      busy: state.isFileBusy,
                      onTap: () async {
                        final file = await notifier.downloadPdf();
                        if (context.mounted && file != null) {
                          _showSnack(
                            context,
                            'PDF descargado: ${file.fileName}',
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SheetAction(
                      label: 'JSON',
                      icon: 'json',
                      tone: 'blue',
                      busy: state.isFileBusy,
                      onTap: () async {
                        final file = await notifier.downloadJson();
                        if (context.mounted && file != null) {
                          _showSnack(
                            context,
                            'JSON descargado: ${file.fileName}',
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SheetAction(
                      label: 'Reenviar',
                      icon: 'mail',
                      tone: 'green',
                      busy: state.isSendingEmail,
                      onTap: () => _resendEmail(context, ref, detail),
                    ),
                  ),
                ],
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 12),
                _ErrorBanner(
                  message: state.errorMessage!,
                  traceId: state.traceId,
                  onRetry: () => notifier.loadDetail(detail.id),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _resendEmail(
    BuildContext context,
    WidgetRef ref,
    DteDetail detail,
  ) async {
    final email = await showDialog<String>(
      context: context,
      builder: (context) => _EmailDialog(initialEmail: detail.receptorCorreo),
    );
    if (email == null || !context.mounted) {
      return;
    }

    final result = await ref
        .read(dteQueryViewModelProvider.notifier)
        .resendEmail(email);
    if (context.mounted && result != null) {
      _showSnack(context, result.displayMessage);
    }
  }
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.controller, required this.child});

  final ScrollController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
      children: [
        Center(
          child: Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _EmailDialog extends StatefulWidget {
  const _EmailDialog({required this.initialEmail});

  final String? initialEmail;

  @override
  State<_EmailDialog> createState() => _EmailDialogState();
}

class _EmailDialogState extends State<_EmailDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reenviar DTE'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'Correo destinatario',
          prefixIcon: Icon(Icons.mail_rounded),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Enviar'),
        ),
      ],
    );
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({required this.rows});

  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: rows),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, {this.mono = false});

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
              maxLines: mono ? 4 : 2,
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

class _LineRow extends StatelessWidget {
  const _LineRow({required this.line});

  final DteLineItem line;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(
            line.numeroLinea.toString(),
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.descripcion,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 12,
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
          Text(
            line.totalLabel,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.label,
    required this.icon,
    required this.tone,
    required this.busy,
    required this.onTap,
  });

  final String label;
  final String icon;
  final String tone;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: busy ? null : onTap,
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
    );
  }
}

class _RejectionCard extends StatelessWidget {
  const _RejectionCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.report_problem_rounded,
              color: AppColors.danger,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.danger,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCompanyCard extends ConsumerWidget {
  const _ProfileCompanyCard({required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NeoCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.purple,
            child: Text(
              user.initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Perfil y empresa'),
                Text(
                  user.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  user.companyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Cerrar sesion',
            onPressed: () => ref.read(authViewModelProvider.notifier).logout(),
            icon: const Icon(Icons.logout_rounded, color: AppColors.purple),
          ),
        ],
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const LinearProgressIndicator(),
        const SizedBox(height: 12),
        for (var index = 0; index < 3; index++) ...[
          NeoCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _Skeleton(width: 170),
                      SizedBox(height: 8),
                      _Skeleton(width: 110),
                    ],
                  ),
                ),
                const _Skeleton(width: 74),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 12,
      decoration: BoxDecoration(
        color: AppColors.line,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const NeoCard(
      child: Row(
        children: [
          Icon(Icons.search_off_rounded, color: AppColors.muted),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No hay DTE para los filtros seleccionados.',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.onRetry,
    this.traceId,
  });

  final String message;
  final String? traceId;
  final VoidCallback onRetry;

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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              tooltip: 'Reintentar',
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, color: AppColors.danger),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.navy,
          fontWeight: FontWeight.w900,
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

String _formatDate(DateTime date) {
  final local = date.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}
