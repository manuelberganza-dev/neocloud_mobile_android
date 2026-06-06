import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/action_tile.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_scaffold.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../auth/auth_viewmodel.dart';
import '../../auth/models/auth_models.dart';
import '../dte_query_viewmodel.dart';

class DteQueryScreen extends ConsumerWidget {
  const DteQueryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dteQueryViewModelProvider);
    final authState = ref.watch(authViewModelProvider);
    final user = authState.hasValue ? authState.requireValue.user : null;
    final isTablet = MediaQuery.sizeOf(context).width >= 760;

    return NeoScaffold(
      title: 'Consulta DTE',
      subtitle: 'Historial y herramientas',
      trailing: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_rounded, color: Colors.white),
          SizedBox(width: 14),
          Icon(Icons.filter_alt_rounded, color: Colors.white),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SegmentedTabs(),
          const SizedBox(height: 12),
          for (final document in state.documents) ...[
            _DocumentCard(
              number: document.number,
              date: document.date,
              party: document.party,
              amount: document.amount,
              status: document.status,
              tone: document.tone,
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 6),
          if (user != null) ...[
            _ProfileCompanyCard(user: user),
            const SizedBox(height: 14),
          ],
          const _SectionTitle('Mas herramientas'),
          GridView.builder(
            itemCount: state.tools.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 6 : 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: isTablet ? 1.1 : 0.95,
            ),
            itemBuilder: (context, index) {
              final tool = state.tools[index];
              return ActionTile(
                label: tool.label,
                icon: tool.icon,
                tone: tool.tone,
                compact: true,
              );
            },
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
          _Segment(label: 'Emitidos', selected: true),
          _Segment(label: 'Recibidos'),
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

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.number,
    required this.date,
    required this.party,
    required this.amount,
    required this.status,
    required this.tone,
  });

  final String number;
  final String date;
  final String party;
  final String amount;
  final String status;
  final String tone;

  @override
  Widget build(BuildContext context) {
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
                      number,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$date\n$party',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusChip(
                    label: status,
                    tone: tone,
                    icon: Icons.check_circle_rounded,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    amount,
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
              _MiniChip('Sello'),
            ],
          ),
        ],
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
            radius: 24,
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
                const SizedBox(height: 3),
                Text(
                  user.companyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  user.email ?? user.roleLabel,
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
