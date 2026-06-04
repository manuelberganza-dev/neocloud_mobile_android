import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'app_visuals.dart';

class ActionTile extends StatelessWidget {
  const ActionTile({
    required this.label,
    required this.icon,
    required this.tone,
    this.compact = false,
    super.key,
  });

  final String label;
  final String icon;
  final String tone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = toneColor(tone);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 9 : 12,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: compact ? 28 : 38,
              height: compact ? 28 : 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(appIcon(icon), color: color, size: compact ? 17 : 21),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 11,
                height: 1.1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
