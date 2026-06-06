import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/action_tile.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_scaffold.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../auth/auth_viewmodel.dart';
import '../clients_viewmodel.dart';

class ClientDetailScreen extends ConsumerWidget {
  const ClientDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clientsViewModelProvider);
    final authState = ref.watch(authViewModelProvider);
    final user = authState.hasValue ? authState.requireValue.user : null;
    final isTablet = MediaQuery.sizeOf(context).width >= 760;

    return NeoScaffold(
      title: 'Detalle del cliente',
      subtitle: 'CRM ligero',
      trailing: const Icon(Icons.more_vert_rounded, color: Colors.white),
      child: Column(
        children: [
          NeoCard(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.purple,
                      child: Text(
                        'AC',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'NIT: ${state.nit}',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          StatusChip(
                            label: state.tag,
                            tone: 'green',
                            icon: Icons.verified_rounded,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    for (final action in state.actions)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ActionTile(
                            label: action.label,
                            icon: action.icon,
                            tone: 'ink',
                            compact: true,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Tabs(),
          const SizedBox(height: 12),
          GridView.builder(
            itemCount: state.metrics.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 4 : 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: isTablet ? 2.1 : 1.55,
            ),
            itemBuilder: (context, index) {
              final metric = state.metrics[index];
              return MetricCard(
                title: metric.title,
                value: metric.value,
                caption: 'Cliente activo',
                tone: metric.tone,
              );
            },
          ),
          const SizedBox(height: 12),
          NeoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeading('Datos basicos'),
                const _DataRow(label: 'Telefono', value: '+503 7000 1234'),
                const _DataRow(label: 'Correo', value: 'ventas@centro.com'),
                const _DataRow(
                  label: 'Direccion',
                  value: 'Av. Espana #123, SS',
                ),
                _DataRow(
                  label: 'Vendedor',
                  value: user?.displayName ?? 'Usuario',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          NeoCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeading('Notas internas'),
                      Text(
                        'Cliente importante. Prefiere facturacion quincenal.',
                        style: TextStyle(
                          color: AppColors.ink,
                          height: 1.35,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('Editar')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NeoCard(
      padding: EdgeInsets.zero,
      child: Row(
        children: const [
          _TabLabel(label: 'Resumen', selected: true),
          _TabLabel(label: 'Historial'),
          _TabLabel(label: 'Notas'),
        ],
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? AppColors.purple : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? AppColors.purple : AppColors.ink,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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

class _DataRow extends StatelessWidget {
  const _DataRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
