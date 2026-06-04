import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'clients_repository.dart';
import 'models/client_models.dart';

part 'clients_viewmodel.g.dart';

@riverpod
ClientsRepository clientsRepository(Ref ref) {
  return const ClientsRepository();
}

@riverpod
ClientDetailState clientsViewModel(Ref ref) {
  return ref.watch(clientsRepositoryProvider).loadClient();
}
