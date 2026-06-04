import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/action_tile.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_scaffold.dart';
import '../../../shared/widgets/status_chip.dart';
import '../neoscan_viewmodel.dart';

class NeoScanScreen extends ConsumerWidget {
  const NeoScanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(neoScanViewModelProvider);
    final isTablet = MediaQuery.sizeOf(context).width >= 760;

    return NeoScaffold(
      title: 'NeoScan',
      subtitle: 'IA + OCR',
      trailing: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flash_on_rounded, color: Colors.white),
          SizedBox(width: 14),
          Icon(Icons.help_outline_rounded, color: Colors.white),
        ],
      ),
      child: Column(
        children: [
          const _CameraPreview(),
          const SizedBox(height: 12),
          NeoCard(
            child: Column(
              children: [
                const StatusChip(
                  label: 'IA/OCR: Datos extraidos',
                  tone: 'purple',
                  icon: Icons.auto_awesome_rounded,
                ),
                const SizedBox(height: 12),
                for (final field in state.fields) ...[
                  _ExtractedRow(label: field.label, value: field.value),
                  if (field != state.fields.last) const Divider(height: 14),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            itemCount: state.actions.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 6 : 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: isTablet ? 0.95 : 0.82,
            ),
            itemBuilder: (context, index) {
              final action = state.actions[index];
              return ActionTile(
                label: action.label,
                icon: action.icon,
                tone: action.tone,
                compact: true,
              );
            },
          ),
          const SizedBox(height: 18),
          const _CameraControls(),
        ],
      ),
    );
  }
}

class _CameraPreview extends StatelessWidget {
  const _CameraPreview();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.25,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A3B2E),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Center(
              child: Transform.rotate(
                angle: -0.08,
                child: Container(
                  width: 190,
                  height: 220,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 14,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FACTURA',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (var index = 0; index < 7; index++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            height: 6,
                            width: index.isEven ? 130 : 95,
                            color: AppColors.line,
                          ),
                        ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          width: 54,
                          height: 54,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const _ScanCorner(alignment: Alignment.topLeft),
            const _ScanCorner(alignment: Alignment.topRight),
            const _ScanCorner(alignment: Alignment.bottomLeft),
            const _ScanCorner(alignment: Alignment.bottomRight),
          ],
        ),
      ),
    );
  }
}

class _ScanCorner extends StatelessWidget {
  const _ScanCorner({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 38,
        height: 38,
        margin: const EdgeInsets.all(38),
        decoration: BoxDecoration(
          border: Border(
            top: alignment.y < 0
                ? const BorderSide(color: AppColors.purple, width: 3)
                : BorderSide.none,
            bottom: alignment.y > 0
                ? const BorderSide(color: AppColors.purple, width: 3)
                : BorderSide.none,
            left: alignment.x < 0
                ? const BorderSide(color: AppColors.purple, width: 3)
                : BorderSide.none,
            right: alignment.x > 0
                ? const BorderSide(color: AppColors.purple, width: 3)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _ExtractedRow extends StatelessWidget {
  const _ExtractedRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
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
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(color: AppColors.ink, fontSize: 12),
          ),
        ),
        const SizedBox(width: 6),
        const Icon(
          Icons.check_circle_rounded,
          color: AppColors.green,
          size: 15,
        ),
      ],
    );
  }
}

class _CameraControls extends StatelessWidget {
  const _CameraControls();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.photo_library_rounded, color: AppColors.navy),
        const Spacer(),
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.purple, width: 3),
          ),
          child: const Center(
            child: CircleAvatar(radius: 23, backgroundColor: Colors.white),
          ),
        ),
        const Spacer(),
        const Icon(Icons.settings_applications_rounded, color: AppColors.navy),
      ],
    );
  }
}
