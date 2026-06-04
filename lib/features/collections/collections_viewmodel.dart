import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'collections_repository.dart';
import 'models/collections_models.dart';

part 'collections_viewmodel.g.dart';

@riverpod
CollectionsRepository collectionsRepository(Ref ref) {
  return const CollectionsRepository();
}

@riverpod
CollectionsState collectionsViewModel(Ref ref) {
  return ref.watch(collectionsRepositoryProvider).loadCollections();
}
