import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/action_tile.dart';
import '../../../shared/widgets/app_visuals.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_scaffold.dart';
import '../../auth/auth_viewmodel.dart';
import '../dashboard_viewmodel.dart';
import '../models/dashboard_models.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardViewModelProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardViewModelProvider);
    final authState = ref.watch(authViewModelProvider);
    final user = authState.hasValue ? authState.requireValue.user : null;

    return NeoScaffold(
      title: 'Hola, ${user?.displayName ?? 'Usuario'}!',
      subtitle: '${user?.companyName ?? 'Empresa'} - Resumen del dia',
      trailing: IconButton(
        tooltip: 'Actualizar',
        onPressed: state.isLoading
            ? null
            : () => ref.read(dashboardViewModelProvider.notifier).load(),
        icon: const Icon(Icons.refresh_rounded, color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.isLoading && state.data == null)
            const _LoadingCard()
          else ...[
            if (state.errorMessage != null) ...[
              _ErrorCard(
                message: state.errorMessage!,
                traceId: state.traceId,
                onRetry: () =>
                    ref.read(dashboardViewModelProvider.notifier).load(),
              ),
              const SizedBox(height: 12),
            ],
            _MetricGrid(metrics: state.metrics),
            const SizedBox(height: 10),
            _AlertSummary(state: state),
            const SizedBox(height: 16),
            const Text(
              'Accesos rapidos',
              style: TextStyle(
                color: AppColors.navy,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            _ActionGrid(actions: state.actions),
            const SizedBox(height: 18),
            _ActivityCard(activities: state.activities),
          ],
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const NeoCard(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.onRetry,
    this.traceId,
  });

  final String message;
  final String? traceId;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'No se pudo cargar el dashboard',
            style: TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(message, style: const TextStyle(color: AppColors.muted)),
          if (traceId != null) ...[
            const SizedBox(height: 6),
            Text(
              'traceId: $traceId',
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.metrics});

  final List<DashboardMetric> metrics;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) {
      return const NeoCard(
        child: Text(
          'Sin datos de dashboard para mostrar.',
          style: TextStyle(color: AppColors.muted),
        ),
      );
    }

    final isTablet = MediaQuery.sizeOf(context).width >= 760;
    final crossAxisCount = isTablet ? 3 : 2;

    return GridView.builder(
      itemCount: metrics.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: isTablet ? 2.3 : 1.65,
      ),
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return MetricCard(
          title: metric.title,
          value: metric.value,
          caption: metric.caption,
          tone: metric.tone,
        );
      },
    );
  }
}

class _AlertSummary extends StatelessWidget {
  const _AlertSummary({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final count = state.alertCount;
    return NeoCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alertas operativas',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  count.toString(),
                  style: TextStyle(
                    color: count > 0 ? AppColors.orange : AppColors.green,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.go('/dte'),
            child: const Text('Ver DTE'),
          ),
        ],
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.actions});

  final List<DashboardAction> actions;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 760;

    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 5 : 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.92,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return ActionTile(
          label: action.label,
          icon: action.icon,
          tone: action.tone,
          onTap: () => context.go(action.route),
        );
      },
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activities});

  final List<ActivityItem> activities;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actividad reciente',
            style: TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          if (activities.isEmpty)
            const Text(
              'Cuando emitas documentos, veras aqui el resumen de actividad.',
              style: TextStyle(color: AppColors.muted),
            )
          else
            for (final activity in activities) ...[
              _ActivityRow(
                title: activity.title,
                subtitle: activity.subtitle,
                tone: activity.tone,
              ),
              if (activity != activities.last) const Divider(height: 18),
            ],
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.title,
    required this.subtitle,
    required this.tone,
  });

  final String title;
  final String subtitle;
  final String tone;

  @override
  Widget build(BuildContext context) {
    final color = toneColor(tone);

    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(Icons.check_rounded, color: color, size: 15),
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
                  color: AppColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
