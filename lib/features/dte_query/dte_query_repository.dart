import 'models/dte_query_models.dart';

class DteQueryRepository {
  const DteQueryRepository();

  DteQueryState loadQuery() {
    return const DteQueryState(
      documents: [
        DteDocument(
          number: 'A-000123',
          date: '20/05/2026',
          party: 'Almacenes Centro, S.A.',
          amount: r'$2,450.00',
          status: 'Aceptado',
          tone: 'green',
        ),
        DteDocument(
          number: 'A-000122',
          date: '19/05/2026',
          party: 'Inversiones SA',
          amount: r'$1,750.00',
          status: 'Aceptado',
          tone: 'green',
        ),
        DteDocument(
          number: 'A-000121',
          date: '19/05/2026',
          party: 'Constructora El Sol',
          amount: r'$3,200.00',
          status: 'Rechazado',
          tone: 'danger',
        ),
        DteDocument(
          number: 'A-000120',
          date: '18/05/2026',
          party: 'Comercial XYZ, S.A.',
          amount: r'$900.00',
          status: 'Contingencia',
          tone: 'orange',
        ),
        DteDocument(
          number: 'A-000119',
          date: '17/05/2026',
          party: 'Distribuidora Uno',
          amount: r'$1,200.00',
          status: 'Pendiente',
          tone: 'yellow',
        ),
      ],
      tools: [
        ToolAction(
          label: 'Catalogo productos',
          icon: 'catalog',
          tone: 'purple',
        ),
        ToolAction(label: 'Reportes rapidos', icon: 'reports', tone: 'purple'),
        ToolAction(label: 'Perfil y empresa', icon: 'profile', tone: 'purple'),
        ToolAction(label: 'Soporte', icon: 'support', tone: 'blue'),
        ToolAction(label: 'Configuracion', icon: 'settings', tone: 'purple'),
        ToolAction(label: 'Acerca de', icon: 'info', tone: 'ink'),
      ],
    );
  }
}
