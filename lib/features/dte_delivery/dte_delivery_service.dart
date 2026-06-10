import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/network/api_exception.dart';
import '../auth/auth_viewmodel.dart';
import 'dte_delivery_repository.dart';
import 'models/dte_delivery_models.dart';

final dteDeliveryServiceProvider = Provider.autoDispose<DteDeliveryService>((
  ref,
) {
  return DteDeliveryService(
    repository: ref.watch(dteDeliveryRepositoryProvider),
    ref: ref,
  );
});

class DteDeliveryService {
  const DteDeliveryService({
    required DteDeliveryRepository repository,
    required Ref ref,
  }) : _repository = repository,
       _ref = ref;

  final DteDeliveryRepository _repository;
  final Ref _ref;

  Future<DteDeliveryFile> downloadPdf(DteDeliveryDocument document) async {
    _ensurePermission('DTE.Consultar');
    return _downloadFile(document, DteDeliveryFileKind.pdf, temporary: false);
  }

  Future<DteDeliveryFile> downloadJson(DteDeliveryDocument document) async {
    _ensurePermission('DTE.Consultar');
    return _downloadFile(document, DteDeliveryFileKind.json, temporary: false);
  }

  Future<DteDeliveryFile> sharePdf(
    DteDeliveryDocument document, {
    required String channel,
  }) async {
    _ensurePermission('DTE.Consultar');
    final file = await _downloadFile(
      document,
      DteDeliveryFileKind.pdf,
      temporary: true,
    );

    await SharePlus.instance.share(
      ShareParams(
        title: 'Compartir DTE',
        subject: 'DTE ${document.numeroControl}',
        text:
            'DTE ${document.numeroControl} - '
            '${formatDteMoney(document.totalPagar)}',
        files: [
          XFile(file.path, mimeType: file.kind.mimeType, name: file.fileName),
        ],
        fileNameOverrides: [file.fileName],
      ),
    );

    return file;
  }

  Future<DteEmailDeliveryResult> resendEmail({
    required DteDeliveryDocument document,
    required String email,
  }) {
    _ensurePermission('DTE.Reenviar');
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      throw const ApiException(
        message: 'Indica un correo valido para reenviar el DTE.',
        errors: ['VALIDATION'],
      );
    }

    return _repository.resendEmail(documentId: document.id, email: cleanEmail);
  }

  Future<DteDeliveryFile> _downloadFile(
    DteDeliveryDocument document,
    DteDeliveryFileKind kind, {
    required bool temporary,
  }) async {
    final bytes = kind == DteDeliveryFileKind.pdf
        ? await _repository.downloadPdf(document.id)
        : await _repository.downloadJson(document.id);
    if (bytes.isEmpty) {
      throw const ApiException(message: 'El archivo descargado esta vacio.');
    }

    final directory = temporary
        ? await getTemporaryDirectory()
        : (await getExternalStorageDirectory()) ??
              await getTemporaryDirectory();
    final fileName = _fileName(document, kind);
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);

    return DteDeliveryFile(path: file.path, fileName: fileName, kind: kind);
  }

  String _fileName(DteDeliveryDocument document, DteDeliveryFileKind kind) {
    final safeNumber = document.numeroControl.replaceAll(
      RegExp(r'[^A-Za-z0-9_-]+'),
      '_',
    );
    return '$safeNumber.${kind.extension}';
  }

  void _ensurePermission(String permission) {
    final auth = _ref.read(authViewModelProvider);
    final hasPermission =
        auth.hasValue &&
        (auth.requireValue.user?.isSuperAdmin == true ||
            auth.requireValue.hasPermission(permission));

    if (!hasPermission) {
      throw ApiException(
        message: 'Tu usuario no tiene permiso $permission.',
        statusCode: 403,
        errors: [permission],
      );
    }
  }
}
