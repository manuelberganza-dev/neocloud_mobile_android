import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_scaffold.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../auth/auth_viewmodel.dart';
import '../../auth/models/auth_models.dart';
import '../clients_viewmodel.dart';
import '../models/client_models.dart';

class ClientDetailScreen extends ConsumerStatefulWidget {
  const ClientDetailScreen({super.key});

  @override
  ConsumerState<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends ConsumerState<ClientDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _customerSearch = TextEditingController();
  final _productSearch = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      final notifier = ref.read(clientsViewModelProvider.notifier);
      notifier.loadCustomers();
      notifier.loadProducts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customerSearch.dispose();
    _productSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clientsViewModelProvider);
    final notifier = ref.read(clientsViewModelProvider.notifier);
    final auth = ref.watch(authViewModelProvider);
    final user = auth.hasValue ? auth.requireValue.user : null;
    final canViewCustomers = _can(user, 'Clientes.Ver');
    final canCreateCustomers = _can(user, 'Clientes.Crear');
    final canEditCustomers = _can(user, 'Clientes.Editar');
    final canViewProducts = _can(user, 'Productos.Ver');
    final canCreateProducts = _can(user, 'Productos.Crear');
    final canEditProducts = _can(user, 'Productos.Editar');

    return NeoScaffold(
      title: 'Clientes y productos',
      subtitle: 'Datos maestros para emitir DTE',
      trailing: const Icon(Icons.inventory_2_rounded, color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.errorMessage != null) ...[
            _ErrorBanner(message: state.errorMessage!, traceId: state.traceId),
            const SizedBox(height: 12),
          ],
          NeoCard(
            padding: EdgeInsets.zero,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.purple,
              unselectedLabelColor: AppColors.ink,
              indicatorColor: AppColors.purple,
              tabs: const [
                Tab(text: 'Clientes'),
                Tab(text: 'Productos'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              if (_tabController.index == 0) {
                return _CustomersPanel(
                  state: state,
                  searchController: _customerSearch,
                  canView: canViewCustomers,
                  canCreate: canCreateCustomers,
                  canEdit: canEditCustomers,
                  onSearch: () =>
                      notifier.loadCustomers(search: _customerSearch.text),
                  onLoadMore: () => notifier.loadCustomers(append: true),
                  onCreate: () => _openCustomerForm(context),
                  onEdit: (customer) =>
                      _openCustomerForm(context, customer: customer),
                  onDeactivate: notifier.deactivateCustomer,
                );
              }

              return _ProductsPanel(
                state: state,
                searchController: _productSearch,
                canView: canViewProducts,
                canCreate: canCreateProducts,
                canEdit: canEditProducts,
                onSearch: () =>
                    notifier.loadProducts(search: _productSearch.text),
                onLoadMore: () => notifier.loadProducts(append: true),
                onCreate: () => _openProductForm(context),
                onEdit: (product) =>
                    _openProductForm(context, product: product),
                onDeactivate: notifier.deactivateProduct,
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openCustomerForm(
    BuildContext context, {
    Customer? customer,
  }) async {
    final form = await showModalBottomSheet<CustomerForm>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _CustomerFormSheet(customer: customer),
    );
    if (form == null || !context.mounted) {
      return;
    }

    final result = await ref
        .read(clientsViewModelProvider.notifier)
        .saveCustomer(form);
    if (context.mounted && result != null) {
      _showSnack(context, 'Cliente guardado.');
    }
  }

  Future<void> _openProductForm(
    BuildContext context, {
    Product? product,
  }) async {
    final form = await showModalBottomSheet<ProductForm>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ProductFormSheet(product: product),
    );
    if (form == null || !context.mounted) {
      return;
    }

    final result = await ref
        .read(clientsViewModelProvider.notifier)
        .saveProduct(form);
    if (context.mounted && result != null) {
      _showSnack(context, 'Producto guardado.');
    }
  }

  bool _can(AuthUser? user, String permission) {
    return user?.hasPermission(permission) ?? false;
  }
}

class _CustomersPanel extends StatelessWidget {
  const _CustomersPanel({
    required this.state,
    required this.searchController,
    required this.canView,
    required this.canCreate,
    required this.canEdit,
    required this.onSearch,
    required this.onLoadMore,
    required this.onCreate,
    required this.onEdit,
    required this.onDeactivate,
  });

  final MasterDataState state;
  final TextEditingController searchController;
  final bool canView;
  final bool canCreate;
  final bool canEdit;
  final VoidCallback onSearch;
  final VoidCallback onLoadMore;
  final VoidCallback onCreate;
  final ValueChanged<Customer> onEdit;
  final ValueChanged<int> onDeactivate;

  @override
  Widget build(BuildContext context) {
    if (!canView) {
      return const _PermissionCard(text: 'Sin permiso Clientes.Ver.');
    }

    return Column(
      children: [
        _SearchAndCreate(
          controller: searchController,
          hint: 'Buscar cliente',
          onSearch: onSearch,
          onCreate: canCreate ? onCreate : null,
        ),
        const SizedBox(height: 12),
        if (state.isLoadingCustomers)
          const LinearProgressIndicator()
        else if (state.customers.isEmpty)
          const _EmptyCard(text: 'No hay clientes para mostrar.')
        else
          for (final customer in state.customers) ...[
            _CustomerCard(
              customer: customer,
              canEdit: canEdit,
              onEdit: () => onEdit(customer),
              onDeactivate: () => onDeactivate(customer.id),
            ),
            const SizedBox(height: 10),
          ],
        if (state.hasMoreCustomers)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: state.isLoadingCustomers ? null : onLoadMore,
              icon: const Icon(Icons.expand_more_rounded),
              label: const Text('Cargar mas clientes'),
            ),
          ),
      ],
    );
  }
}

class _ProductsPanel extends StatelessWidget {
  const _ProductsPanel({
    required this.state,
    required this.searchController,
    required this.canView,
    required this.canCreate,
    required this.canEdit,
    required this.onSearch,
    required this.onLoadMore,
    required this.onCreate,
    required this.onEdit,
    required this.onDeactivate,
  });

  final MasterDataState state;
  final TextEditingController searchController;
  final bool canView;
  final bool canCreate;
  final bool canEdit;
  final VoidCallback onSearch;
  final VoidCallback onLoadMore;
  final VoidCallback onCreate;
  final ValueChanged<Product> onEdit;
  final ValueChanged<int> onDeactivate;

  @override
  Widget build(BuildContext context) {
    if (!canView) {
      return const _PermissionCard(text: 'Sin permiso Productos.Ver.');
    }

    return Column(
      children: [
        _SearchAndCreate(
          controller: searchController,
          hint: 'Buscar producto',
          onSearch: onSearch,
          onCreate: canCreate ? onCreate : null,
        ),
        const SizedBox(height: 12),
        if (state.isLoadingProducts)
          const LinearProgressIndicator()
        else if (state.products.isEmpty)
          const _EmptyCard(text: 'No hay productos para mostrar.')
        else
          for (final product in state.products) ...[
            _ProductCard(
              product: product,
              canEdit: canEdit,
              onEdit: () => onEdit(product),
              onDeactivate: () => onDeactivate(product.id),
            ),
            const SizedBox(height: 10),
          ],
        if (state.hasMoreProducts)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: state.isLoadingProducts ? null : onLoadMore,
              icon: const Icon(Icons.expand_more_rounded),
              label: const Text('Cargar mas productos'),
            ),
          ),
      ],
    );
  }
}

class _SearchAndCreate extends StatelessWidget {
  const _SearchAndCreate({
    required this.controller,
    required this.hint,
    required this.onSearch,
    this.onCreate,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onSearch;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onSearch(),
              decoration: InputDecoration(
                hintText: hint,
                suffixIcon: IconButton(
                  tooltip: 'Buscar',
                  onPressed: onSearch,
                  icon: const Icon(Icons.search_rounded),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            tooltip: 'Crear',
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({
    required this.customer,
    required this.canEdit,
    required this.onEdit,
    required this.onDeactivate,
  });

  final Customer customer;
  final bool canEdit;
  final VoidCallback onEdit;
  final VoidCallback onDeactivate;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.purple,
            child: Icon(Icons.person_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  customer.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          StatusChip(
            label: customer.estadoCodigo,
            tone: customer.estadoCodigo == 'ACTIVO' ? 'green' : 'orange',
          ),
          if (canEdit)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'off') onDeactivate();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Editar')),
                PopupMenuItem(value: 'off', child: Text('Inactivar')),
              ],
            ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.canEdit,
    required this.onEdit,
    required this.onDeactivate,
  });

  final Product product;
  final bool canEdit;
  final VoidCallback onEdit;
  final VoidCallback onDeactivate;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.blue,
            child: Icon(Icons.inventory_2_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  product.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            product.priceLabel,
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (canEdit)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'off') onDeactivate();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Editar')),
                PopupMenuItem(value: 'off', child: Text('Inactivar')),
              ],
            ),
        ],
      ),
    );
  }
}

class _CustomerFormSheet extends ConsumerStatefulWidget {
  const _CustomerFormSheet({this.customer});

  final Customer? customer;

  @override
  ConsumerState<_CustomerFormSheet> createState() => _CustomerFormSheetState();
}

class _CustomerFormSheetState extends ConsumerState<_CustomerFormSheet> {
  late final TextEditingController _documento;
  late final TextEditingController _nombre;
  late final TextEditingController _nrc;
  late final TextEditingController _correo;
  late final TextEditingController _telefono;
  late final TextEditingController _direccion;
  String _tipoDocumento = 'DUI';
  String _tipoContribuyente = 'CONSUMIDOR_FINAL';
  NitVerification? _verification;

  @override
  void initState() {
    super.initState();
    final customer = widget.customer;
    _tipoDocumento = customer?.tipoDocumentoCodigo ?? 'DUI';
    _tipoContribuyente =
        customer?.tipoContribuyenteCodigo ?? 'CONSUMIDOR_FINAL';
    _documento = TextEditingController(text: customer?.numeroDocumento ?? '');
    _nombre = TextEditingController(text: customer?.nombre ?? '');
    _nrc = TextEditingController(text: customer?.nrc ?? '');
    _correo = TextEditingController(text: customer?.correo ?? '');
    _telefono = TextEditingController(text: customer?.telefono ?? '');
    _direccion = TextEditingController(text: customer?.direccion ?? '');
  }

  @override
  void dispose() {
    _documento.dispose();
    _nombre.dispose();
    _nrc.dispose();
    _correo.dispose();
    _telefono.dispose();
    _direccion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 14, 16, bottom + 18),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetHandle(),
            Text(
              widget.customer == null ? 'Nuevo cliente' : 'Editar cliente',
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _tipoDocumento,
                    decoration: const InputDecoration(labelText: 'Tipo'),
                    items: const [
                      DropdownMenuItem(value: 'DUI', child: Text('DUI')),
                      DropdownMenuItem(value: 'NIT', child: Text('NIT')),
                    ],
                    onChanged: (value) =>
                        setState(() => _tipoDocumento = value ?? 'DUI'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _documento,
                    decoration: InputDecoration(
                      labelText: 'NIT/DUI',
                      suffixIcon: IconButton(
                        tooltip: 'Verificar',
                        icon: const Icon(Icons.verified_rounded),
                        onPressed: _verify,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_verification != null) ...[
              const SizedBox(height: 8),
              StatusChip(
                label: _verification!.mensaje,
                tone: _verification!.formatoValido ? 'green' : 'danger',
              ),
            ],
            const SizedBox(height: 10),
            TextField(
              controller: _nombre,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nrc,
              decoration: const InputDecoration(labelText: 'NRC'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _tipoContribuyente,
              decoration: const InputDecoration(
                labelText: 'Tipo contribuyente',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'CONSUMIDOR_FINAL',
                  child: Text('Consumidor final'),
                ),
                DropdownMenuItem(
                  value: 'CONTRIBUYENTE',
                  child: Text('Contribuyente'),
                ),
              ],
              onChanged: (value) => setState(
                () => _tipoContribuyente = value ?? 'CONSUMIDOR_FINAL',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _correo,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _telefono,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Telefono'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _direccion,
              decoration: const InputDecoration(labelText: 'Direccion'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    CustomerForm(
                      id: widget.customer?.id,
                      tipoDocumentoCodigo: _tipoDocumento,
                      numeroDocumento: _documento.text,
                      nrc: _nrc.text,
                      nombre: _nombre.text,
                      tipoContribuyenteCodigo: _tipoContribuyente,
                      correo: _correo.text,
                      telefono: _telefono.text,
                      direccion: _direccion.text,
                    ),
                  );
                },
                child: const Text('Guardar cliente'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verify() async {
    final result = await ref
        .read(clientsViewModelProvider.notifier)
        .verifyDocument(_documento.text);
    if (result == null) return;
    setState(() {
      _verification = result;
      _tipoDocumento = result.tipoDocumento == 'NIT' ? 'NIT' : 'DUI';
      _documento.text = result.documentoNormalizado;
      if (result.nombre != null && _nombre.text.trim().isEmpty) {
        _nombre.text = result.nombre!;
      }
      if (result.nrc != null && _nrc.text.trim().isEmpty) {
        _nrc.text = result.nrc!;
      }
      if (result.tipoContribuyente != null) {
        _tipoContribuyente = result.tipoContribuyente!;
      }
    });
  }
}

class _ProductFormSheet extends StatefulWidget {
  const _ProductFormSheet({this.product});

  final Product? product;

  @override
  State<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<_ProductFormSheet> {
  late final TextEditingController _codigo;
  late final TextEditingController _barra;
  late final TextEditingController _nombre;
  late final TextEditingController _descripcion;
  late final TextEditingController _precio;
  late final TextEditingController _costo;
  bool _aplicaIva = true;
  String _tipoItem = 'BIEN';

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _codigo = TextEditingController(text: product?.codigoInterno ?? '');
    _barra = TextEditingController(text: product?.codigoBarra ?? '');
    _nombre = TextEditingController(text: product?.nombre ?? '');
    _descripcion = TextEditingController(text: product?.descripcion ?? '');
    _precio = TextEditingController(
      text: product?.precioUnitario.toStringAsFixed(2) ?? '',
    );
    _costo = TextEditingController(
      text: product?.costoUnitario?.toStringAsFixed(2) ?? '',
    );
    _aplicaIva = product?.aplicaIva ?? true;
    _tipoItem = product?.tipoItem ?? 'BIEN';
  }

  @override
  void dispose() {
    _codigo.dispose();
    _barra.dispose();
    _nombre.dispose();
    _descripcion.dispose();
    _precio.dispose();
    _costo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 14, 16, bottom + 18),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetHandle(),
            Text(
              widget.product == null ? 'Nuevo producto' : 'Editar producto',
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codigo,
              decoration: const InputDecoration(labelText: 'Codigo interno'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _barra,
              decoration: const InputDecoration(labelText: 'Codigo de barras'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nombre,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descripcion,
              decoration: const InputDecoration(labelText: 'Descripcion'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _tipoItem,
              decoration: const InputDecoration(labelText: 'Tipo item'),
              items: const [
                DropdownMenuItem(value: 'BIEN', child: Text('Bien')),
                DropdownMenuItem(value: 'SERVICIO', child: Text('Servicio')),
              ],
              onChanged: (value) => setState(() => _tipoItem = value ?? 'BIEN'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _precio,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Precio'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _costo,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Costo'),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              value: _aplicaIva,
              onChanged: (value) => setState(() => _aplicaIva = value),
              title: const Text('Aplica IVA'),
              contentPadding: EdgeInsets.zero,
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    ProductForm(
                      id: widget.product?.id,
                      codigoInterno: _codigo.text,
                      codigoBarra: _barra.text,
                      nombre: _nombre.text,
                      descripcion: _descripcion.text,
                      tipoItem: _tipoItem,
                      precioUnitario: _parseDouble(_precio.text),
                      costoUnitario: _tryParseDouble(_costo.text),
                      aplicaIva: _aplicaIva,
                    ),
                  );
                },
                child: const Text('Guardar producto'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _parseDouble(String value) {
    return double.tryParse(value.replaceAll(',', '.')) ?? 0;
  }

  double? _tryParseDouble(String value) {
    return value.trim().isEmpty ? null : _parseDouble(value);
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 4,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.line,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return _EmptyCard(text: text);
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.muted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
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

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(message)));
}
