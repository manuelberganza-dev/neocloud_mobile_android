import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import 'dashboard_repository.dart';
import 'models/dashboard_models.dart';

final dashboardRepositoryProvider = Provider.autoDispose<DashboardRepository>((
  ref,
) {
  return DashboardRepository(ref.watch(apiClientProvider));
});

final dashboardViewModelProvider =
    NotifierProvider.autoDispose<DashboardViewModel, DashboardState>(
      DashboardViewModel.new,
    );

class DashboardViewModel extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    return DashboardState.initial();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await ref.read(dashboardRepositoryProvider).getDashboard();
      state = DashboardState.fromEmpresa(data);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _friendlyError(error),
        traceId: error is ApiException ? error.traceId : null,
      );
    }
  }

  String _friendlyError(Object error) {
    if (error is ApiException) {
      if (error.isForbidden) {
        return 'Tu usuario no tiene permiso para ver el dashboard.';
      }
      return error.errors.isEmpty
          ? error.message
          : '${error.message} ${error.errors.join(', ')}';
    }
    return 'No se pudo cargar el dashboard.';
  }
}
