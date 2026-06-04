import 'models/collections_models.dart';

class CollectionsRepository {
  const CollectionsRepository();

  CollectionsState loadCollections() {
    return const CollectionsState(
      invoices: [
        CollectionInvoice(
          client: 'Almacenes Centro, S.A.',
          number: 'A-000123',
          dueDate: 'Venc. 15/05/2026',
          amount: r'$2,450.00',
        ),
        CollectionInvoice(
          client: 'Inversiones SA',
          number: 'A-000122',
          dueDate: 'Venc. 10/05/2026',
          amount: r'$1,750.00',
        ),
        CollectionInvoice(
          client: 'Constructora El Sol',
          number: 'A-000120',
          dueDate: 'Venc. 05/05/2026',
          amount: r'$3,200.00',
        ),
      ],
      alerts: [
        AlertItem(
          title: 'DTE rechazado',
          subtitle: 'A-000119 fue rechazado por MH',
          age: 'Hace 20 min',
          tone: 'danger',
        ),
        AlertItem(
          title: 'Certificado proximo a vencer',
          subtitle: 'Mi certificado vence en 7 dias',
          age: 'Hace 1 dia',
          tone: 'orange',
        ),
        AlertItem(
          title: 'IVA/F-07 proxima',
          subtitle: 'Vence el 31/05/2026',
          age: 'Hace 2 dias',
          tone: 'blue',
        ),
        AlertItem(
          title: 'Error de comunicacion MH',
          subtitle: 'Intermitencia con conexion',
          age: 'Hace 2 dias',
          tone: 'orange',
        ),
      ],
    );
  }
}
