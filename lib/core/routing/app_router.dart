import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_viewmodel.dart';
import '../../features/auth/ui/auth_screen.dart';
import '../../features/auth/ui/splash_screen.dart';
import '../../features/clients/ui/client_detail_screen.dart';
import '../../features/collections/ui/collections_screen.dart';
import '../../features/dashboard/ui/dashboard_screen.dart';
import '../../features/dte_config/ui/dte_config_screen.dart';
import '../../features/dte_query/ui/dte_query_screen.dart';
import '../../features/invoice/ui/invoice_screen.dart';
import '../../features/neoscan/ui/neoscan_screen.dart';
import '../../features/notifications/ui/notifications_screen.dart';
import '../../features/pos/ui/pos_screen.dart';
import '../../shared/widgets/main_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ValueNotifier<int>(0);
  ref.onDispose(refreshListenable.dispose);
  ref.listen(authViewModelProvider, (previous, next) {
    refreshListenable.value++;
  });

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final auth = ref.read(authViewModelProvider);
      final location = state.matchedLocation;
      final isSplash = location == '/splash';
      final isLogin = location == '/login';

      if (auth.isLoading || !auth.hasValue) {
        return isSplash ? null : '/splash';
      }

      final isAuthenticated = auth.requireValue.isAuthenticated;

      if (!isAuthenticated) {
        return isLogin ? null : '/login';
      }

      if (isLogin || isSplash) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const AuthScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'notifications',
                    name: 'notifications',
                    builder: (context, state) => const NotificationsScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/invoice',
                name: 'invoice',
                builder: (context, state) => const InvoiceScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pos',
                name: 'pos',
                builder: (context, state) => const PosScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/clients',
                name: 'clients',
                builder: (context, state) => const ClientDetailScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/neoscan',
                name: 'neoscan',
                builder: (context, state) => const NeoScanScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/collections',
                name: 'collections',
                builder: (context, state) => const CollectionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dte',
                name: 'dte',
                builder: (context, state) => const DteQueryScreen(),
                routes: [
                  GoRoute(
                    path: 'configuracion',
                    name: 'dte-config',
                    builder: (context, state) => const DteConfigScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
