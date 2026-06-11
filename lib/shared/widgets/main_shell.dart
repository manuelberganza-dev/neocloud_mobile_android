import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/auth_viewmodel.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _items = [
    _NavItem('Inicio', Icons.home_rounded),
    _NavItem('Facturar', Icons.receipt_long_rounded),
    _NavItem('POS', Icons.point_of_sale_rounded),
    _NavItem('Clientes', Icons.group_rounded),
    _NavItem('Escanear', Icons.document_scanner_rounded),
    _NavItem('Mas', Icons.menu_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 760;
    final selectedIndex = _selectedNavIndex(
      widget.navigationShell.currentIndex,
    );
    final auth = ref.watch(authViewModelProvider);
    final user = auth.hasValue ? auth.requireValue.user : null;

    if (isTablet) {
      return Scaffold(
        key: _scaffoldKey,
        endDrawer: _MoreDrawer(
          displayName: user?.displayName ?? 'Usuario',
          companyName: user?.companyName ?? 'Empresa',
          onRoute: _goRoute,
          onProfile: _showProfile,
          onAbout: _showAbout,
          onLogout: _logout,
        ),
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              backgroundColor: AppColors.navy,
              selectedIconTheme: const IconThemeData(color: Colors.white),
              unselectedIconTheme: const IconThemeData(color: Colors.white70),
              selectedLabelTextStyle: const TextStyle(color: Colors.white),
              unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: _CloudBadge(),
              ),
              destinations: [
                for (final item in _items)
                  NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: _SelectedRailIcon(icon: item.icon),
                    label: Text(item.label),
                  ),
              ],
              onDestinationSelected: _onNavTap,
            ),
            Expanded(child: widget.navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      body: widget.navigationShell,
      endDrawer: _MoreDrawer(
        displayName: user?.displayName ?? 'Usuario',
        companyName: user?.companyName ?? 'Empresa',
        onRoute: _goRoute,
        onProfile: _showProfile,
        onAbout: _showAbout,
        onLogout: _logout,
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: selectedIndex,
        items: _items,
        onTap: _onNavTap,
      ),
    );
  }

  int _selectedNavIndex(int branchIndex) {
    return branchIndex <= 4 ? branchIndex : 5;
  }

  void _onNavTap(int index) {
    if (index == 5) {
      _scaffoldKey.currentState?.openEndDrawer();
      return;
    }

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  void _goRoute(String route) {
    Navigator.of(context).pop();
    context.go(route);
  }

  void _showProfile() {
    Navigator.of(context).pop();
    final auth = ref.read(authViewModelProvider);
    final user = auth.hasValue ? auth.requireValue.user : null;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Perfil y empresa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoLine(label: 'Usuario', value: user?.displayName ?? 'Usuario'),
            _InfoLine(label: 'Empresa', value: user?.companyName ?? 'Empresa'),
            _InfoLine(label: 'Rol', value: user?.roleLabel ?? 'Usuario'),
            if (user?.email != null)
              _InfoLine(label: 'Correo', value: user!.email!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    Navigator.of(context).pop();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Soporte'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoLine(label: 'App', value: AppConfig.appName),
            _InfoLine(label: 'Version', value: 'Demo beta'),
            _InfoLine(label: 'Canal', value: 'Soporte NeoCloud'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    Navigator.of(context).pop();
    await ref.read(authViewModelProvider.notifier).logout();
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 68,
        decoration: const BoxDecoration(
          color: AppColors.navy,
          border: Border(top: BorderSide(color: Color(0xFF27314F))),
        ),
        child: Row(
          children: [
            for (var index = 0; index < items.length; index++)
              Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  child: _BottomNavItem(
                    item: items[index],
                    isSelected: currentIndex == index,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({required this.item, required this.isSelected});

  final _NavItem item;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.purple : Colors.white70;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(item.icon, size: 21, color: color),
        const SizedBox(height: 4),
        Text(
          item.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MoreDrawer extends StatelessWidget {
  const _MoreDrawer({
    required this.displayName,
    required this.companyName,
    required this.onRoute,
    required this.onProfile,
    required this.onAbout,
    required this.onLogout,
  });

  final String displayName;
  final String companyName;
  final ValueChanged<String> onRoute;
  final VoidCallback onProfile;
  final VoidCallback onAbout;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.sizeOf(context).width.clamp(300, 360).toDouble(),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              child: Row(
                children: [
                  const _CloudBadge(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          companyName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.manage_search_rounded,
                    label: 'Consulta DTE',
                    onTap: () => onRoute('/dte'),
                  ),
                  _DrawerItem(
                    icon: Icons.settings_rounded,
                    label: 'Configuracion DTE',
                    onTap: () => onRoute('/dte/configuracion'),
                  ),
                  _DrawerItem(
                    icon: Icons.add_card_rounded,
                    label: 'Cobros',
                    onTap: () => onRoute('/collections'),
                  ),
                  _DrawerItem(
                    icon: Icons.notifications_none_rounded,
                    label: 'Notificaciones',
                    onTap: () => onRoute('/notifications'),
                  ),
                  _DrawerItem(
                    icon: Icons.person_rounded,
                    label: 'Perfil / empresa',
                    onTap: onProfile,
                  ),
                  _DrawerItem(
                    icon: Icons.headset_mic_rounded,
                    label: 'Soporte / acerca de',
                    onTap: onAbout,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Cerrar sesion'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.purple),
      title: Text(
        label,
        style: const TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w800,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
      onTap: onTap,
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedRailIcon extends StatelessWidget {
  const _SelectedRailIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.purple,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _CloudBadge extends StatelessWidget {
  const _CloudBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [AppColors.purple, AppColors.blue],
        ),
      ),
      child: const Icon(Icons.cloud_done_rounded, color: Colors.white),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon);

  final String label;
  final IconData icon;
}
