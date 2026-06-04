import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/action_tile.dart';
import '../../../shared/widgets/app_visuals.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_scaffold.dart';
import '../collections_viewmodel.dart';

class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(collectionsViewModelProvider);

    return NeoScaffold(
      title: 'Cobros',
      subtitle: 'Recordatorios y notificaciones',
      trailing: const Icon(
        Icons.notifications_none_rounded,
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SegmentedTabs(),
          const SizedBox(height: 12),
          NeoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Facturas vencidas'),
                for (final invoice in state.invoices) ...[
                  _InvoiceCard(
                    client: invoice.client,
                    number: invoice.number,
                    dueDate: invoice.dueDate,
                    amount: invoice.amount,
                  ),
                  if (invoice != state.invoices.last)
                    const SizedBox(height: 10),
                ],
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Ver todas las vencidas'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const _SectionTitle('Alertas importantes'),
          NeoCard(
            child: Column(
              children: [
                for (final alert in state.alerts) ...[
                  _AlertRow(
                    title: alert.title,
                    subtitle: alert.subtitle,
                    age: alert.age,
                    tone: alert.tone,
                  ),
                  if (alert != state.alerts.last) const Divider(height: 18),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: const [
          _Segment(label: 'Vencidas (8)', selected: true),
          _Segment(label: 'Pendientes (12)'),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.purple : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({
    required this.client,
    required this.number,
    required this.dueDate,
    required this.amount,
  });

  final String client;
  final String number;
  final String dueDate;
  final String amount;

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
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$number\n$dueDate',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  amount,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(
                  child: ActionTile(
                    label: 'WhatsApp',
                    icon: 'whatsapp',
                    tone: 'green',
                    compact: true,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ActionTile(
                    label: 'Correo',
                    icon: 'mail',
                    tone: 'blue',
                    compact: true,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ActionTile(
                    label: 'Link',
                    icon: 'link',
                    tone: 'purple',
                    compact: true,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ActionTile(
                    label: 'QR',
                    icon: 'qr',
                    tone: 'yellow',
                    compact: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({
    required this.title,
    required this.subtitle,
    required this.age,
    required this.tone,
  });

  final String title;
  final String subtitle;
  final String age;
  final String tone;

  @override
  Widget build(BuildContext context) {
    final color = toneColor(tone);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.warning_rounded, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.ink, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(age, style: const TextStyle(color: AppColors.muted, fontSize: 10)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

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
