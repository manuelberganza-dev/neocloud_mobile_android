import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/clients/ui/client_detail_screen.dart';
import '../../features/collections/ui/collections_screen.dart';
import '../../features/dashboard/ui/dashboard_screen.dart';
import '../../features/dte_query/ui/dte_query_screen.dart';
import '../../features/invoice/ui/invoice_screen.dart';
import '../../features/neoscan/ui/neoscan_screen.dart';
import '../../shared/widgets/main_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
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
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
