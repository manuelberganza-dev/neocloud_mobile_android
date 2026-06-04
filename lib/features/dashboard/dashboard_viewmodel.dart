import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dashboard_repository.dart';
import 'models/dashboard_models.dart';

part 'dashboard_viewmodel.g.dart';

@riverpod
DashboardRepository dashboardRepository(Ref ref) {
  return const DashboardRepository();
}

@riverpod
DashboardState dashboardViewModel(Ref ref) {
  return ref.watch(dashboardRepositoryProvider).loadDashboard();
}
