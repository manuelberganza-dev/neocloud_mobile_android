import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/neo_card.dart';
import '../auth_viewmodel.dart';
import '../models/auth_models.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mfaController = TextEditingController();

  bool _showPassword = false;
  String? _errorText;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _mfaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authViewModelProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          if (!mounted) {
            return;
          }
          setState(() {
            _errorText = ref
                .read(authViewModelProvider.notifier)
                .friendlyError(error);
          });
        },
      );
    });

    final authState = ref.watch(authViewModelProvider);
    final health = ref.watch(healthCheckProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _BrandHeader(),
                  const SizedBox(height: 22),
                  NeoCard(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Iniciar sesion',
                            style: TextStyle(
                              color: AppColors.navy,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Usa tu usuario de empresa NeoSTP.',
                            style: TextStyle(color: AppColors.muted),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _usernameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Usuario o correo',
                              prefixIcon: Icon(Icons.person_rounded),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ingresa tu usuario o correo.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_showPassword,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: 'Contrasena',
                              prefixIcon: const Icon(Icons.lock_rounded),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _showPassword = !_showPassword;
                                  });
                                },
                                icon: Icon(
                                  _showPassword
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa tu contrasena.';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _mfaController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Codigo MFA opcional',
                              prefixIcon: Icon(Icons.pin_rounded),
                            ),
                          ),
                          if (_errorText != null) ...[
                            const SizedBox(height: 12),
                            _ErrorBanner(message: _errorText!),
                          ],
                          const SizedBox(height: 18),
                          SizedBox(
                            height: 50,
                            child: FilledButton(
                              onPressed: isLoading ? null : _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.purple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Entrar'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ConnectionStatus(health: health),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _errorText = null;
    });

    await ref
        .read(authViewModelProvider.notifier)
        .login(
          usernameOrEmail: _usernameController.text.trim(),
          password: _passwordController.text,
          mfaCode: _mfaController.text.trim(),
        );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [AppColors.purple, AppColors.blue],
            ),
          ),
          child: const Icon(
            Icons.cloud_done_rounded,
            color: Colors.white,
            size: 42,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          AppConfig.appName,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          AppConfig.appSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted),
        ),
      ],
    );
  }
}

class _ConnectionStatus extends StatelessWidget {
  const _ConnectionStatus({required this.health});

  final AsyncValue<HealthStatus> health;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      child: Row(
        children: [
          health.when(
            data: (value) => Icon(
              value.isOk ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
              color: value.isOk ? AppColors.green : AppColors.orange,
            ),
            error: (error, stackTrace) =>
                const Icon(Icons.cloud_off_rounded, color: AppColors.orange),
            loading: () => const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  health.when(
                    data: (value) =>
                        value.isOk ? 'API conectada' : 'API no disponible',
                    error: (error, stackTrace) => 'API no disponible',
                    loading: () => 'Verificando API',
                  ),
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  ApiEnvironment.baseUrl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
