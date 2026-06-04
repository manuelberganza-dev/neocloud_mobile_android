import 'models/client_models.dart';

class ClientsRepository {
  const ClientsRepository();

  ClientDetailState loadClient() {
    return const ClientDetailState(
      name: 'Almacenes Centro, S.A.',
      nit: '0614-010203-001-3',
      tag: 'Frecuente',
      actions: [
        ClientContactAction(label: 'Llamar', icon: 'phone'),
        ClientContactAction(label: 'WhatsApp', icon: 'whatsapp'),
        ClientContactAction(label: 'Correo', icon: 'mail'),
        ClientContactAction(label: 'Facturar', icon: 'invoice'),
      ],
      metrics: [
        ClientMetric(
          title: 'Saldo pendiente',
          value: r'$8,750.00',
          tone: 'yellow',
        ),
        ClientMetric(
          title: 'Credito disponible',
          value: r'$12,000.00',
          tone: 'green',
        ),
        ClientMetric(
          title: 'Limite de credito',
          value: r'$20,750.00',
          tone: 'ink',
        ),
        ClientMetric(title: 'Dias de credito', value: '30 dias', tone: 'ink'),
      ],
    );
  }
}
