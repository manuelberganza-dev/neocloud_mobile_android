import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_scaffold.dart';
import '../models/notification_models.dart';
import '../notifications_viewmodel.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(notificationsViewModelProvider.notifier);
      notifier.load();
      notifier.prepareDeviceRegistration();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsViewModelProvider);
    final notifier = ref.read(notificationsViewModelProvider.notifier);

    return NeoScaffold(
      title: 'Notificaciones',
      subtitle: '${state.summary.pendientes} pendientes',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Preferencias',
            onPressed: () => _showPreferences(context, ref, state.preferences),
            icon: const Icon(Icons.tune_rounded, color: Colors.white),
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
          _SummaryRow(summary: state.summary),
          const SizedBox(height: 12),
          _StatusFilter(selected: state.filters.estadoCodigo),
          const SizedBox(height: 12),
          if (state.errorMessage != null) ...[
            _ErrorCard(message: state.errorMessage!, traceId: state.traceId),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: state.isLoading ? null : notifier.markAllRead,
                  icon: const Icon(Icons.done_all_rounded),
                  label: const Text('Leer todas'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.isLoading && state.alerts.isEmpty)
            const NeoCard(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (state.alerts.isEmpty)
            const NeoCard(
              child: Text(
                'No hay notificaciones para mostrar.',
                style: TextStyle(color: AppColors.muted),
              ),
            )
          else
            for (final alert in state.alerts) ...[
              _AlertCard(alert: alert),
              const SizedBox(height: 10),
            ],
          if (state.hasMore)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: state.isLoadingMore ? null : notifier.loadMore,
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
      ),
    );
  }

  Future<void> _showPreferences(
    BuildContext context,
    WidgetRef ref,
    NotificationPreferences preferences,
  ) async {
    final result = await showDialog<NotificationPreferences>(
      context: context,
      builder: (context) => _PreferencesDialog(preferences: preferences),
    );
    if (result == null) {
      return;
    }
    await ref
        .read(notificationsViewModelProvider.notifier)
        .savePreferences(result);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preferencias guardadas.')));
    }
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.summary});

  final AlertSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            label: 'Pendientes',
            value: summary.pendientes.toString(),
            color: AppColors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryTile(
            label: 'Criticas',
            value: summary.criticas.toString(),
            color: AppColors.danger,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryTile(
            label: 'Advertencias',
            value: summary.advertencias.toString(),
            color: AppColors.orange,
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
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFilter extends ConsumerWidget {
  const _StatusFilter({required this.selected});

  final String? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _Segment(
            label: 'Activas',
            selected: selected == null,
            onTap: () => ref
                .read(notificationsViewModelProvider.notifier)
                .setStatus(null),
          ),
          _Segment(
            label: 'Leidas',
            selected: selected == 'LEIDA',
            onTap: () => ref
                .read(notificationsViewModelProvider.notifier)
                .setStatus('LEIDA'),
          ),
          _Segment(
            label: 'Resueltas',
            selected: selected == 'RESUELTA',
            onTap: () => ref
                .read(notificationsViewModelProvider.notifier)
                .setStatus('RESUELTA'),
          ),
        ],
      ),
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
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

class _AlertCard extends ConsumerWidget {
  const _AlertCard({required this.alert});

  final AppAlert alert;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _toneColor(alert.severityTone);

    return NeoCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _openAlert(context, ref, alert),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: color.withValues(alpha: 0.12),
                    child: Icon(_alertIcon(alert), color: color, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.titulo,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: alert.isRead
                                ? AppColors.ink
                                : AppColors.navy,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alert.mensaje,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    alert.ageLabel,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _MiniChip(label: alert.estadoCodigo, color: color),
                  const Spacer(),
                  TextButton(
                    onPressed: alert.isResolved
                        ? null
                        : () => ref
                              .read(notificationsViewModelProvider.notifier)
                              .resolve(alert),
                    child: const Text('Resolver'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openAlert(
    BuildContext context,
    WidgetRef ref,
    AppAlert alert,
  ) async {
    await ref.read(notificationsViewModelProvider.notifier).markRead(alert);
    if (!context.mounted) {
      return;
    }

    final target = _routeFor(alert);
    if (target == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alerta marcada como leida.')),
      );
      return;
    }
    context.go(target);
  }

  String? _routeFor(AppAlert alert) {
    final entity = alert.entidadTipo?.toUpperCase().replaceAll('_', '');
    return switch (entity) {
      'DTE' || 'DTEDOCUMENTO' || 'DOCUMENTO' => '/dte',
      'CLIENTE' => '/clients',
      'PRODUCTO' => '/clients',
      'COBRO' || 'COBRANZA' || 'CXC' => '/collections',
      'CERTIFICADO' || 'CONFIGURACIONDTE' => '/dte/configuracion',
      _ => null,
    };
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.color});

  final String label;
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
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PreferencesDialog extends StatefulWidget {
  const _PreferencesDialog({required this.preferences});

  final NotificationPreferences preferences;

  @override
  State<_PreferencesDialog> createState() => _PreferencesDialogState();
}

class _PreferencesDialogState extends State<_PreferencesDialog> {
  late String _canal;
  late bool _noMolestar;

  @override
  void initState() {
    super.initState();
    _canal = widget.preferences.canal;
    _noMolestar = widget.preferences.noMolestar;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Preferencias'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _canal,
            decoration: const InputDecoration(labelText: 'Canal'),
            items: const [
              DropdownMenuItem(value: 'PUSH', child: Text('Push')),
              DropdownMenuItem(value: 'CORREO', child: Text('Correo')),
              DropdownMenuItem(value: 'AMBOS', child: Text('Ambos')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _canal = value);
              }
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _noMolestar,
            onChanged: (value) => setState(() => _noMolestar = value),
            title: const Text('No molestar'),
            subtitle: const Text('Respeta horario 21:00 a 07:00'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              widget.preferences.copyWith(
                canal: _canal,
                noMolestar: _noMolestar,
              ),
            );
          },
          child: const Text('Guardar'),
        ),
      ],
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

IconData _alertIcon(AppAlert alert) {
  return switch (alert.tipoCodigo.toUpperCase()) {
    'DTE_RECHAZADO' => Icons.error_rounded,
    'CERTIFICADO_VENCE' ||
    'CERTIFICADO_PROXIMO_VENCER' => Icons.verified_user_rounded,
    'COBRO_VENCIDO' || 'FACTURA_VENCIDA' => Icons.event_busy_rounded,
    _ => Icons.notifications_active_rounded,
  };
}

Color _toneColor(String tone) {
  return switch (tone) {
    'danger' => AppColors.danger,
    'orange' => AppColors.orange,
    'green' => AppColors.green,
    'purple' => AppColors.purple,
    _ => AppColors.blue,
  };
}
