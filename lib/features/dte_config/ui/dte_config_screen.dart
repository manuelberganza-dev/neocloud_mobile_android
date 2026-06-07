import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_scaffold.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../auth/auth_viewmodel.dart';
import '../dte_config_viewmodel.dart';
import '../models/dte_config_models.dart';

class DteConfigScreen extends ConsumerStatefulWidget {
  const DteConfigScreen({super.key});

  @override
  ConsumerState<DteConfigScreen> createState() => _DteConfigScreenState();
}

class _DteConfigScreenState extends ConsumerState<DteConfigScreen> {
  final _usuario = TextEditingController();
  final _password = TextEditingController();
  final _tipoEstablecimiento = TextEditingController();
  final _codigoEstablecimiento = TextEditingController();
  final _codigoPuntoVenta = TextEditingController();
  String _ambiente = 'PRUEBAS';
  bool _syncedForm = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(dteConfigViewModelProvider.notifier).load(),
    );
  }

  @override
  void dispose() {
    _usuario.dispose();
    _password.dispose();
    _tipoEstablecimiento.dispose();
    _codigoEstablecimiento.dispose();
    _codigoPuntoVenta.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dteConfigViewModelProvider);
    final notifier = ref.read(dteConfigViewModelProvider.notifier);
    final auth = ref.watch(authViewModelProvider);
    final user = auth.hasValue ? auth.requireValue.user : null;
    final canConfigure = user?.hasPermission('DTE.Configurar') ?? false;
    final config = state.config;

    if (!_syncedForm && config != null) {
      _syncForm(config);
    }

    return NeoScaffold(
      title: 'Configuracion DTE',
      subtitle: config == null
          ? 'Estado de emision'
          : 'Ambiente ${config.ambienteCodigo}',
      trailing: IconButton(
        tooltip: 'Actualizar',
        onPressed: state.isLoading ? null : notifier.load,
        icon: const Icon(Icons.refresh_rounded, color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!canConfigure) ...[
            const _PermissionCard(),
            const SizedBox(height: 12),
          ],
          if (state.errorMessage != null) ...[
            _ErrorBanner(message: state.errorMessage!, traceId: state.traceId),
            const SizedBox(height: 12),
          ],
          if (state.isLoading)
            const LinearProgressIndicator()
          else if (config == null)
            _EmptyConfig(onRetry: notifier.load)
          else ...[
            _ReadinessCard(config: config),
            const SizedBox(height: 12),
            _ChecklistCard(config: config),
            const SizedBox(height: 12),
            _ConfigFormCard(
              enabled: canConfigure && !state.isSaving,
              ambiente: _ambiente,
              onAmbienteChanged: (value) {
                if (value != null) setState(() => _ambiente = value);
              },
              usuario: _usuario,
              password: _password,
              tipoEstablecimiento: _tipoEstablecimiento,
              codigoEstablecimiento: _codigoEstablecimiento,
              codigoPuntoVenta: _codigoPuntoVenta,
              hasStoredPassword: config.tienePasswordMh,
              isSaving: state.isSaving,
              onSave: () async {
                final ok = await notifier.save(
                  DteConfigForm(
                    ambienteCodigo: _ambiente,
                    usuarioMh: _usuario.text,
                    passwordMh: _password.text,
                    tipoEstablecimientoCodigo: _tipoEstablecimiento.text,
                    codigoEstablecimientoMh: _codigoEstablecimiento.text,
                    codigoPuntoVentaMh: _codigoPuntoVenta.text,
                  ),
                );
                if (context.mounted && ok) {
                  _password.clear();
                  _showSnack(context, 'Configuracion guardada.');
                }
              },
            ),
            const SizedBox(height: 12),
            _CertificateCard(
              config: config,
              isUploading: state.isUploadingCertificate,
              canUpload: canConfigure,
              onUpload: () => _uploadCertificate(context, ref),
            ),
            const SizedBox(height: 12),
            _ConnectionCard(
              config: config,
              lastTest: state.lastTest,
              isTesting: state.isTestingConnection,
              canTest: canConfigure,
              onTest: () async {
                final result = await notifier.testConnection();
                if (context.mounted && result != null) {
                  _showSnack(context, result.displayMessage);
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  void _syncForm(DteConfig config) {
    _syncedForm = true;
    _ambiente = config.ambienteCodigo;
    _usuario.text = config.usuarioMh ?? '';
    _tipoEstablecimiento.text = config.tipoEstablecimientoCodigo ?? '';
    _codigoEstablecimiento.text = config.codigoEstablecimientoMh ?? '';
    _codigoPuntoVenta.text = config.codigoPuntoVentaMh ?? '';
  }

  Future<void> _uploadCertificate(BuildContext context, WidgetRef ref) async {
    final password = await showDialog<String>(
      context: context,
      builder: (_) => const _CertificatePasswordDialog(),
    );
    if (password == null || !context.mounted) {
      return;
    }

    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'Certificados',
          extensions: ['p12', 'pfx'],
          mimeTypes: ['application/x-pkcs12'],
        ),
      ],
    );
    if (file == null) {
      return;
    }

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      if (context.mounted) {
        _showSnack(context, 'No se pudo leer el archivo seleccionado.');
      }
      return;
    }

    final ok = await ref
        .read(dteConfigViewModelProvider.notifier)
        .uploadCertificate(
          CertificateUpload(
            nombre: file.name,
            contenidoBase64: base64Encode(bytes),
            password: password,
          ),
        );
    if (context.mounted && ok) {
      _showSnack(context, 'Certificado cargado.');
    }
  }
}

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({required this.config});

  final DteConfig config;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor:
                (config.esCompleto ? AppColors.green : AppColors.orange)
                    .withValues(alpha: 0.12),
            child: Icon(
              config.esCompleto
                  ? Icons.verified_rounded
                  : Icons.pending_actions_rounded,
              color: config.esCompleto ? AppColors.green : AppColors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.esCompleto
                      ? 'Empresa lista para emitir'
                      : 'Configuracion incompleta',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ambiente vigente: ${config.ambienteCodigo}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          StatusChip(
            label: config.ambienteCodigo,
            tone: config.ambienteCodigo == 'PRODUCCION' ? 'green' : 'blue',
          ),
        ],
      ),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({required this.config});

  final DteConfig config;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Checklist DTE'),
          for (final item in config.checklist) _ChecklistRow(item: item),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.item});

  final DteChecklistItem item;

  @override
  Widget build(BuildContext context) {
    final color = item.isDone ? AppColors.green : AppColors.orange;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(
            item.isDone ? Icons.check_circle_rounded : Icons.warning_rounded,
            color: color,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigFormCard extends StatelessWidget {
  const _ConfigFormCard({
    required this.enabled,
    required this.ambiente,
    required this.onAmbienteChanged,
    required this.usuario,
    required this.password,
    required this.tipoEstablecimiento,
    required this.codigoEstablecimiento,
    required this.codigoPuntoVenta,
    required this.hasStoredPassword,
    required this.isSaving,
    required this.onSave,
  });

  final bool enabled;
  final String ambiente;
  final ValueChanged<String?> onAmbienteChanged;
  final TextEditingController usuario;
  final TextEditingController password;
  final TextEditingController tipoEstablecimiento;
  final TextEditingController codigoEstablecimiento;
  final TextEditingController codigoPuntoVenta;
  final bool hasStoredPassword;
  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Datos operativos'),
          DropdownButtonFormField<String>(
            initialValue: ambiente,
            decoration: const InputDecoration(labelText: 'Ambiente'),
            items: const [
              DropdownMenuItem(value: 'PRUEBAS', child: Text('PRUEBAS')),
              DropdownMenuItem(value: 'PRODUCCION', child: Text('PRODUCCION')),
            ],
            onChanged: enabled ? onAmbienteChanged : null,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: usuario,
            enabled: enabled,
            decoration: const InputDecoration(labelText: 'Usuario MH'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: password,
            enabled: enabled,
            obscureText: true,
            decoration: InputDecoration(
              labelText: hasStoredPassword
                  ? 'Password MH (dejar vacio para conservar)'
                  : 'Password MH',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: tipoEstablecimiento,
            enabled: enabled,
            decoration: const InputDecoration(
              labelText: 'Tipo establecimiento MH',
              hintText: 'M, S, B, P...',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: codigoEstablecimiento,
                  enabled: enabled,
                  decoration: const InputDecoration(
                    labelText: 'Establecimiento',
                    hintText: '001',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: codigoPuntoVenta,
                  enabled: enabled,
                  decoration: const InputDecoration(
                    labelText: 'Punto venta',
                    hintText: '001',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: enabled && !isSaving ? onSave : null,
              icon: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: const Text('Guardar configuracion'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  const _CertificateCard({
    required this.config,
    required this.isUploading,
    required this.canUpload,
    required this.onUpload,
  });

  final DteConfig config;
  final bool isUploading;
  final bool canUpload;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Certificado'),
          _InfoRow('Estado', config.tieneCertificado ? 'Cargado' : 'Pendiente'),
          _InfoRow('Nombre', config.certificadoNombre ?? '-'),
          _InfoRow('Huella', config.certificadoHuella ?? '-', mono: true),
          _InfoRow('Vence', _dateLabel(config.certificadoVence)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: canUpload && !isUploading ? onUpload : null,
              icon: isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file_rounded),
              label: const Text('Subir certificado'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  const _ConnectionCard({
    required this.config,
    required this.lastTest,
    required this.isTesting,
    required this.canTest,
    required this.onTest,
  });

  final DteConfig config;
  final DteConnectionTestResult? lastTest;
  final bool isTesting;
  final bool canTest;
  final VoidCallback onTest;

  @override
  Widget build(BuildContext context) {
    final result = lastTest;
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Conexion MH'),
          _InfoRow('Ultima prueba', _dateLabel(config.ultimaPruebaAt)),
          _InfoRow(
            'Resultado',
            result?.displayMessage ?? config.ultimaPruebaResultado ?? '-',
          ),
          if (config.ultimaPruebaDetalle != null)
            _InfoRow('Detalle', config.ultimaPruebaDetalle!),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: canTest && !isTesting ? onTest : null,
              icon: isTesting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_sync_rounded),
              label: const Text('Probar conexion MH'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CertificatePasswordDialog extends StatefulWidget {
  const _CertificatePasswordDialog();

  @override
  State<_CertificatePasswordDialog> createState() =>
      _CertificatePasswordDialogState();
}

class _CertificatePasswordDialogState
    extends State<_CertificatePasswordDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Password del certificado'),
      content: TextField(
        controller: _controller,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Password',
          helperText: 'No se mostrara ni se guardara en texto visible.',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Continuar'),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, {this.mono = false});

  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              maxLines: mono ? 3 : 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: mono ? 11 : 12,
                fontWeight: FontWeight.w800,
                fontFamily: mono ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard();

  @override
  Widget build(BuildContext context) {
    return const _NoticeCard(
      icon: Icons.lock_rounded,
      text: 'Sin permiso DTE.Configurar. Puedes ver solo si tu rol lo permite.',
    );
  }
}

class _EmptyConfig extends StatelessWidget {
  const _EmptyConfig({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _NoticeCard(
      icon: Icons.settings_suggest_rounded,
      text: 'No se pudo leer la configuracion DTE.',
      action: TextButton(onPressed: onRetry, child: const Text('Reintentar')),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      child: Row(
        children: [
          Icon(icon, color: AppColors.muted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, this.traceId});

  final String message;
  final String? traceId;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(
                color: AppColors.danger,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (traceId != null) ...[
              const SizedBox(height: 4),
              Text(
                'traceId: $traceId',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 10,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.navy,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String _dateLabel(DateTime? date) {
  if (date == null) return '-';
  final local = date.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(message)));
}
