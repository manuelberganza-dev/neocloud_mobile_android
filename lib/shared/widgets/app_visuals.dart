import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

IconData appIcon(String name) {
  return switch (name) {
    'invoice' => Icons.receipt_long_rounded,
    'client' => Icons.group_rounded,
    'scan' => Icons.document_scanner_rounded,
    'search' => Icons.manage_search_rounded,
    'mail' => Icons.mail_rounded,
    'whatsapp' => Icons.chat_rounded,
    'link' => Icons.link_rounded,
    'pdf' => Icons.picture_as_pdf_rounded,
    'json' => Icons.data_object_rounded,
    'seal' => Icons.verified_rounded,
    'phone' => Icons.call_rounded,
    'catalog' => Icons.inventory_2_rounded,
    'reports' => Icons.bar_chart_rounded,
    'profile' => Icons.person_rounded,
    'support' => Icons.headset_mic_rounded,
    'settings' => Icons.settings_rounded,
    'info' => Icons.info_rounded,
    'camera' => Icons.camera_alt_rounded,
    'cloud' => Icons.cloud_done_rounded,
    'qr' => Icons.qr_code_2_rounded,
    _ => Icons.circle_rounded,
  };
}

Color toneColor(String tone) {
  return switch (tone) {
    'purple' => AppColors.purple,
    'green' => AppColors.green,
    'blue' => AppColors.blue,
    'yellow' => AppColors.yellow,
    'danger' => AppColors.danger,
    'orange' => AppColors.orange,
    _ => AppColors.ink,
  };
}
