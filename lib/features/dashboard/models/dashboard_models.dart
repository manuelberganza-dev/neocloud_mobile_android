class DashboardMetric {
  const DashboardMetric({
    required this.title,
    required this.value,
    required this.caption,
    required this.tone,
  });

  final String title;
  final String value;
  final String caption;
  final String tone;
}

class DashboardAction {
  const DashboardAction({
    required this.label,
    required this.icon,
    required this.tone,
  });

  final String label;
  final String icon;
  final String tone;
}

class ActivityItem {
  const ActivityItem({
    required this.title,
    required this.subtitle,
    required this.tone,
  });

  final String title;
  final String subtitle;
  final String tone;
}

class DashboardState {
  const DashboardState({
    required this.metrics,
    required this.actions,
    required this.activities,
  });

  final List<DashboardMetric> metrics;
  final List<DashboardAction> actions;
  final List<ActivityItem> activities;
}
