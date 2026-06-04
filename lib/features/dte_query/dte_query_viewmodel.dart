import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dte_query_repository.dart';
import 'models/dte_query_models.dart';

part 'dte_query_viewmodel.g.dart';

@riverpod
DteQueryRepository dteQueryRepository(Ref ref) {
  return const DteQueryRepository();
}

@riverpod
DteQueryState dteQueryViewModel(Ref ref) {
  return ref.watch(dteQueryRepositoryProvider).loadQuery();
}
