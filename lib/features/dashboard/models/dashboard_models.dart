class DashboardEmpresa {
  const DashboardEmpresa({
    required this.dteHoy,
    required this.dteMes,
    required this.totalPagarMes,
    required this.procesados,
    required this.rechazados,
    required this.contingencias,
    required this.pendientes,
    required this.porEstado,
    required this.porTipo,
    required this.tendenciaDiaria,
    this.planNombre,
    this.limiteDteMensual,
  });

  final int dteHoy;
  final int dteMes;
  final double totalPagarMes;
  final int procesados;
  final int rechazados;
  final int contingencias;
  final int pendientes;
  final String? planNombre;
  final int? limiteDteMensual;
  final List<DteEstadoResumen> porEstado;
  final List<DteTipoResumen> porTipo;
  final List<DteDiario> tendenciaDiaria;

  int get porcentajeUsoDte {
    final limite = limiteDteMensual;
    if (limite == null || limite <= 0) {
      return 0;
    }
    return ((dteMes / limite) * 100).round().clamp(0, 999);
  }

  factory DashboardEmpresa.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return DashboardEmpresa(
      dteHoy: _int(map, 'dteHoy', 'DteHoy'),
      dteMes: _int(map, 'dteMes', 'DteMes'),
      totalPagarMes: _double(map, 'totalPagarMes', 'TotalPagarMes'),
      procesados: _int(map, 'procesados', 'Procesados'),
      rechazados: _int(map, 'rechazados', 'Rechazados'),
      contingencias: _int(map, 'contingencias', 'Contingencias'),
      pendientes: _int(map, 'pendientes', 'Pendientes'),
      planNombre: _text(map, 'planNombre', 'PlanNombre'),
      limiteDteMensual: _nullableInt(
        map,
        'limiteDteMensual',
        'LimiteDteMensual',
      ),
      porEstado: _list(
        map,
        'porEstado',
        'PorEstado',
      ).map(DteEstadoResumen.fromJson).toList(),
      porTipo: _list(
        map,
        'porTipo',
        'PorTipo',
      ).map(DteTipoResumen.fromJson).toList(),
      tendenciaDiaria: _list(
        map,
        'tendenciaDiaria',
        'TendenciaDiaria',
      ).map(DteDiario.fromJson).toList(),
    );
  }
}

class DteEstadoResumen {
  const DteEstadoResumen({
    required this.estado,
    required this.cantidad,
    required this.totalPagar,
  });

  final String estado;
  final int cantidad;
  final double totalPagar;

  factory DteEstadoResumen.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return DteEstadoResumen(
      estado: _text(map, 'estado', 'Estado') ?? 'SIN_ESTADO',
      cantidad: _int(map, 'cantidad', 'Cantidad'),
      totalPagar: _double(map, 'totalPagar', 'TotalPagar'),
    );
  }
}

class DteTipoResumen {
  const DteTipoResumen({
    required this.tipoCodigo,
    required this.tipoNombre,
    required this.cantidad,
    required this.totalPagar,
  });

  final String tipoCodigo;
  final String tipoNombre;
  final int cantidad;
  final double totalPagar;

  factory DteTipoResumen.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return DteTipoResumen(
      tipoCodigo: _text(map, 'tipoCodigo', 'TipoCodigo') ?? '',
      tipoNombre: _text(map, 'tipoNombre', 'TipoNombre') ?? 'Documento',
      cantidad: _int(map, 'cantidad', 'Cantidad'),
      totalPagar: _double(map, 'totalPagar', 'TotalPagar'),
    );
  }
}

class DteDiario {
  const DteDiario({
    required this.fecha,
    required this.cantidad,
    required this.totalPagar,
  });

  final DateTime? fecha;
  final int cantidad;
  final double totalPagar;

  factory DteDiario.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return DteDiario(
      fecha: DateTime.tryParse(_text(map, 'fecha', 'Fecha') ?? ''),
      cantidad: _int(map, 'cantidad', 'Cantidad'),
      totalPagar: _double(map, 'totalPagar', 'TotalPagar'),
    );
  }
}

class DashboardMetric {
  const DashboardMetric({
    required this.title,
    required this.value,
    required this.caption,
    required this.tone,
  });

  final String title;
  final String value;
  final String caption;
  final String tone;
}

class DashboardAction {
  const DashboardAction({
    required this.label,
    required this.icon,
    required this.tone,
    required this.route,
  });

  final String label;
  final String icon;
  final String tone;
  final String route;
}

class ActivityItem {
  const ActivityItem({
    required this.title,
    required this.subtitle,
    required this.tone,
  });

  final String title;
  final String subtitle;
  final String tone;
}

class DashboardState {
  const DashboardState({
    required this.metrics,
    required this.actions,
    required this.activities,
    required this.isLoading,
    this.data,
    this.errorMessage,
    this.traceId,
  });

  final DashboardEmpresa? data;
  final List<DashboardMetric> metrics;
  final List<DashboardAction> actions;
  final List<ActivityItem> activities;
  final bool isLoading;
  final String? errorMessage;
  final String? traceId;

  int get alertCount {
    final source = data;
    if (source == null) {
      return 0;
    }
    return source.rechazados + source.contingencias + source.pendientes;
  }

  factory DashboardState.initial() {
    return DashboardState(
      metrics: const [],
      actions: _defaultActions,
      activities: const [],
      isLoading: false,
    );
  }

  DashboardState copyWith({
    DashboardEmpresa? data,
    List<DashboardMetric>? metrics,
    List<DashboardAction>? actions,
    List<ActivityItem>? activities,
    bool? isLoading,
    String? errorMessage,
    String? traceId,
    bool clearError = false,
  }) {
    return DashboardState(
      data: data ?? this.data,
      metrics: metrics ?? this.metrics,
      actions: actions ?? this.actions,
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      traceId: clearError ? null : traceId ?? this.traceId,
    );
  }

  factory DashboardState.fromEmpresa(DashboardEmpresa data) {
    return DashboardState(
      data: data,
      metrics: [
        DashboardMetric(
          title: 'DTE hoy',
          value: data.dteHoy.toString(),
          caption: 'Emitidos hoy',
          tone: 'blue',
        ),
        DashboardMetric(
          title: 'Total mes',
          value: formatMoney(data.totalPagarMes),
          caption: '${data.dteMes} DTE emitidos',
          tone: 'blue',
        ),
        DashboardMetric(
          title: 'Procesados',
          value: data.procesados.toString(),
          caption: 'Aceptados por MH',
          tone: 'green',
        ),
        DashboardMetric(
          title: 'Rechazados',
          value: data.rechazados.toString(),
          caption: 'Requieren revision',
          tone: 'danger',
        ),
        DashboardMetric(
          title: 'Contingencias',
          value: data.contingencias.toString(),
          caption: 'Pendientes de resolver',
          tone: 'yellow',
        ),
        DashboardMetric(
          title: data.planNombre ?? 'Uso mensual',
          value: data.limiteDteMensual == null
              ? '${data.dteMes}'
              : '${data.porcentajeUsoDte}%',
          caption: data.limiteDteMensual == null
              ? 'Sin limite configurado'
              : '${data.dteMes}/${data.limiteDteMensual} DTE',
          tone: 'purple',
        ),
      ],
      actions: _defaultActions,
      activities: _activitiesFrom(data),
      isLoading: false,
    );
  }
}

const _defaultActions = [
  DashboardAction(
    label: 'Nueva factura',
    icon: 'invoice',
    tone: 'purple',
    route: '/invoice',
  ),
  DashboardAction(
    label: 'Nuevo cliente',
    icon: 'client',
    tone: 'green',
    route: '/clients',
  ),
  DashboardAction(
    label: 'Escanear',
    icon: 'scan',
    tone: 'blue',
    route: '/neoscan',
  ),
  DashboardAction(
    label: 'Consultar DTE',
    icon: 'search',
    tone: 'purple',
    route: '/dte',
  ),
  DashboardAction(
    label: 'Cobros',
    icon: 'mail',
    tone: 'yellow',
    route: '/collections',
  ),
];

List<ActivityItem> _activitiesFrom(DashboardEmpresa data) {
  final items = <ActivityItem>[
    ActivityItem(
      title: '${data.procesados} DTE procesados',
      subtitle: 'Total del mes ${formatMoney(data.totalPagarMes)}',
      tone: 'green',
    ),
  ];

  if (data.rechazados > 0) {
    items.add(
      ActivityItem(
        title: '${data.rechazados} DTE rechazados',
        subtitle: 'Revisa trazabilidad y respuesta MH',
        tone: 'danger',
      ),
    );
  }

  if (data.contingencias > 0) {
    items.add(
      ActivityItem(
        title: '${data.contingencias} en contingencia',
        subtitle: 'Pendientes de regularizar',
        tone: 'yellow',
      ),
    );
  }

  for (final type in data.porTipo.take(2)) {
    items.add(
      ActivityItem(
        title: '${type.cantidad} ${type.tipoNombre}',
        subtitle: formatMoney(type.totalPagar),
        tone: 'blue',
      ),
    );
  }

  return items;
}

String formatMoney(double value) {
  final fixed = value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final whole = parts.first;
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    final position = whole.length - i;
    buffer.write(whole[i]);
    if (position > 1 && position % 3 == 1) {
      buffer.write(',');
    }
  }
  return '\$$buffer.${parts.last}';
}

int _int(Map<String, dynamic> map, String camel, String pascal) {
  return (map[camel] as num?)?.toInt() ?? (map[pascal] as num?)?.toInt() ?? 0;
}

int? _nullableInt(Map<String, dynamic> map, String camel, String pascal) {
  return (map[camel] as num?)?.toInt() ?? (map[pascal] as num?)?.toInt();
}

double _double(Map<String, dynamic> map, String camel, String pascal) {
  return (map[camel] as num?)?.toDouble() ??
      (map[pascal] as num?)?.toDouble() ??
      0;
}

String? _text(Map<String, dynamic> map, String camel, String pascal) {
  final value = map[camel] ?? map[pascal];
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

List<Object?> _list(Map<String, dynamic> map, String camel, String pascal) {
  return (map[camel] as List<dynamic>? ?? map[pascal] as List<dynamic>?) ??
      const [];
}
