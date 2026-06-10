import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../auth/auth_viewmodel.dart';
import 'models/notification_models.dart';
import 'notifications_repository.dart';

final notificationsRepositoryProvider =
    Provider.autoDispose<NotificationsRepository>((ref) {
      return NotificationsRepository(ref.watch(apiClientProvider));
    });

final notificationsViewModelProvider =
    NotifierProvider.autoDispose<NotificationsViewModel, NotificationsState>(
      NotificationsViewModel.new,
    );

class NotificationsViewModel extends Notifier<NotificationsState> {
  @override
  NotificationsState build() {
    return NotificationsState.initial();
  }

  Future<void> loadSummary() async {
    state = state.copyWith(
      isSummaryLoading: true,
      errorMessage: null,
      traceId: null,
    );
    try {
      final summary = await ref
          .read(notificationsRepositoryProvider)
          .getSummary();
      state = state.copyWith(isSummaryLoading: false, summary: summary);
    } catch (error) {
      _setError(error, isSummaryLoading: false);
    }
  }

  Future<void> load() async {
    final filters = state.filters.firstPage();
    state = state.copyWith(
      isLoading: true,
      filters: filters,
      errorMessage: null,
      traceId: null,
    );
    try {
      final repository = ref.read(notificationsRepositoryProvider);
      final summary = await repository.getSummary();
      final preferences = await repository.getPreferences();
      final page = await repository.list(filters);
      state = state
          .copyWith(
            summary: summary,
            preferences: preferences,
            isLoading: false,
          )
          .withPage(page, false);
    } catch (error) {
      _setError(error, isLoading: false);
    }
  }

  Future<void> refresh() {
    return load();
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.isLoadingMore) {
      return;
    }
    final filters = state.filters.copyWith(page: state.filters.page + 1);
    state = state.copyWith(filters: filters, isLoadingMore: true);
    try {
      final page = await ref
          .read(notificationsRepositoryProvider)
          .list(filters);
      state = state.withPage(page, true);
    } catch (error) {
      _setError(error, isLoadingMore: false);
    }
  }

  Future<void> setStatus(String? status) async {
    final filters = state.filters.copyWith(estadoCodigo: status).firstPage();
    state = state.copyWith(filters: filters, isLoading: true);
    try {
      final page = await ref
          .read(notificationsRepositoryProvider)
          .list(filters);
      final summary = await ref
          .read(notificationsRepositoryProvider)
          .getSummary();
      state = state.copyWith(summary: summary).withPage(page, false);
    } catch (error) {
      _setError(error, isLoading: false);
    }
  }

  Future<void> markRead(AppAlert alert) async {
    if (alert.isRead) {
      return;
    }
    try {
      await ref.read(notificationsRepositoryProvider).markRead(alert.id);
      await _refreshAfterMutation();
    } catch (error) {
      _setError(error);
    }
  }

  Future<void> resolve(AppAlert alert) async {
    try {
      await ref.read(notificationsRepositoryProvider).resolve(alert.id);
      await _refreshAfterMutation();
    } catch (error) {
      _setError(error);
    }
  }

  Future<void> markAllRead() async {
    state = state.copyWith(isLoading: true, errorMessage: null, traceId: null);
    try {
      await ref.read(notificationsRepositoryProvider).markAllRead();
      await _refreshAfterMutation();
    } catch (error) {
      _setError(error, isLoading: false);
    }
  }

  Future<void> savePreferences(NotificationPreferences preferences) async {
    state = state.copyWith(
      isSavingPreferences: true,
      errorMessage: null,
      traceId: null,
    );
    try {
      final saved = await ref
          .read(notificationsRepositoryProvider)
          .savePreferences(preferences);
      state = state.copyWith(preferences: saved, isSavingPreferences: false);
    } catch (error) {
      _setError(error, isSavingPreferences: false);
    }
  }

  Future<void> prepareDeviceRegistration() async {
    final auth = ref.read(authViewModelProvider);
    final user = auth.hasValue ? auth.requireValue.user : null;
    if (user == null) {
      return;
    }
    state = state.copyWith(isRegisteringDevice: true);
    try {
      final token = 'mock-fcm-android-user-${user.id}';
      await ref.read(notificationsRepositoryProvider).registerDevice(token);
      state = state.copyWith(isRegisteringDevice: false);
    } catch (error) {
      _setError(error, isRegisteringDevice: false);
    }
  }

  Future<void> _refreshAfterMutation() async {
    final repository = ref.read(notificationsRepositoryProvider);
    final summary = await repository.getSummary();
    final page = await repository.list(state.filters.firstPage());
    state = state
        .copyWith(summary: summary, isLoading: false)
        .withPage(page, false);
  }

  void _setError(
    Object error, {
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSummaryLoading,
    bool? isSavingPreferences,
    bool? isRegisteringDevice,
  }) {
    final apiError = error is ApiException ? error : null;
    state = state.copyWith(
      isLoading: isLoading,
      isLoadingMore: isLoadingMore,
      isSummaryLoading: isSummaryLoading,
      isSavingPreferences: isSavingPreferences,
      isRegisteringDevice: isRegisteringDevice,
      errorMessage: _friendlyError(error),
      traceId: apiError?.traceId,
    );
  }

  String _friendlyError(Object error) {
    if (error is ApiException) {
      return error.errors.isEmpty
          ? error.message
          : '${error.message} ${error.errors.join(', ')}';
    }
    return 'No se pudieron cargar las notificaciones.';
  }
}
