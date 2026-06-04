import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'models/neoscan_models.dart';
import 'neoscan_repository.dart';

part 'neoscan_viewmodel.g.dart';

@riverpod
NeoScanRepository neoScanRepository(Ref ref) {
  return const NeoScanRepository();
}

@riverpod
NeoScanState neoScanViewModel(Ref ref) {
  return ref.watch(neoScanRepositoryProvider).loadScanPreview();
}
