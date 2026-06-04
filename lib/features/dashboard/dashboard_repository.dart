import 'models/dashboard_models.dart';

class DashboardRepository {
  const DashboardRepository();

  DashboardState loadDashboard() {
    return const DashboardState(
      metrics: [
        DashboardMetric(
          title: 'Ventas del dia',
          value: r'$12,450',
          caption: '+18% vs ayer',
          tone: 'blue',
        ),
        DashboardMetric(
          title: 'Total facturado',
          value: r'$145,230',
          caption: '+12% vs mes ant.',
          tone: 'blue',
        ),
        DashboardMetric(
          title: 'DTE emitidos',
          value: '38',
          caption: 'Hoy',
          tone: 'blue',
        ),
        DashboardMetric(
          title: 'DTE rechazados',
          value: '2',
          caption: 'Hoy',
          tone: 'danger',
        ),
        DashboardMetric(
          title: 'Pendientes de cobro',
          value: r'$28,750',
          caption: 'Vencidas y por vencer',
          tone: 'yellow',
        ),
        DashboardMetric(
          title: 'Clientes con deuda',
          value: '17',
          caption: 'Seguimiento',
          tone: 'danger',
        ),
      ],
      actions: [
        DashboardAction(
          label: 'Nueva factura',
          icon: 'invoice',
          tone: 'purple',
        ),
        DashboardAction(label: 'Nuevo cliente', icon: 'client', tone: 'green'),
        DashboardAction(label: 'Escanear factura', icon: 'scan', tone: 'blue'),
        DashboardAction(label: 'Consultar DTE', icon: 'search', tone: 'purple'),
        DashboardAction(
          label: 'Enviar recordatorio',
          icon: 'mail',
          tone: 'purple',
        ),
      ],
      activities: [
        ActivityItem(
          title: 'DTE A-000123 aceptado',
          subtitle: 'Hace 5 min',
          tone: 'green',
        ),
        ActivityItem(
          title: 'Recordatorio enviado a Cliente ABC',
          subtitle: 'Hace 1 h',
          tone: 'blue',
        ),
        ActivityItem(
          title: 'Pago recibido de Inversiones SA',
          subtitle: 'Hace 2 h',
          tone: 'green',
        ),
      ],
    );
  }
}
