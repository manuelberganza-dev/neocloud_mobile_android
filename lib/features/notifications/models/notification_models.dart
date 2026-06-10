import '../../../core/network/api_response.dart';

const _unset = Object();

class AlertSummary {
  const AlertSummary({
    required this.pendientes,
    required this.criticas,
    required this.advertencias,
  });

  final int pendientes;
  final int criticas;
  final int advertencias;

  bool get hasAlerts => pendientes > 0;

  factory AlertSummary.empty() {
    return const AlertSummary(pendientes: 0, criticas: 0, advertencias: 0);
  }

  factory AlertSummary.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return AlertSummary(
      pendientes: _int(map, 'pendientes', 'Pendientes'),
      criticas: _int(map, 'criticas', 'Criticas'),
      advertencias: _int(map, 'advertencias', 'Advertencias'),
    );
  }
}

class AppAlert {
  const AppAlert({
    required this.id,
    required this.tipoCodigo,
    required this.severidad,
    required this.titulo,
    required this.mensaje,
    required this.estadoCodigo,
    required this.createdAt,
    this.entidadTipo,
    this.entidadId,
    this.resueltaAt,
  });

  final int id;
  final String tipoCodigo;
  final String severidad;
  final String titulo;
  final String mensaje;
  final String? entidadTipo;
  final int? entidadId;
  final String estadoCodigo;
  final DateTime? createdAt;
  final DateTime? resueltaAt;

  bool get isRead => estadoCodigo.toUpperCase() != 'PENDIENTE';
  bool get isResolved => estadoCodigo.toUpperCase() == 'RESUELTA';

  String get severityTone {
    return switch (severidad.toUpperCase()) {
      'CRITICA' => 'danger',
      'ADVERTENCIA' => 'orange',
      _ => 'blue',
    };
  }

  String get ageLabel {
    final created = createdAt;
    if (created == null) {
      return '';
    }
    final diff = DateTime.now().difference(created.toLocal());
    if (diff.inMinutes < 1) {
      return 'Ahora';
    }
    if (diff.inHours < 1) {
      return 'Hace ${diff.inMinutes} min';
    }
    if (diff.inDays < 1) {
      return 'Hace ${diff.inHours} h';
    }
    return 'Hace ${diff.inDays} d';
  }

  factory AppAlert.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return AppAlert(
      id: _int(map, 'id', 'Id'),
      tipoCodigo: _text(map, 'tipoCodigo', 'TipoCodigo') ?? 'ALERTA',
      severidad: _text(map, 'severidad', 'Severidad') ?? 'INFO',
      titulo: _text(map, 'titulo', 'Titulo') ?? 'Alerta',
      mensaje: _text(map, 'mensaje', 'Mensaje') ?? '',
      entidadTipo: _text(map, 'entidadTipo', 'EntidadTipo'),
      entidadId: _nullableInt(map, 'entidadId', 'EntidadId'),
      estadoCodigo: _text(map, 'estadoCodigo', 'EstadoCodigo') ?? 'PENDIENTE',
      createdAt: _date(map, 'createdAt', 'CreatedAt'),
      resueltaAt: _date(map, 'resueltaAt', 'ResueltaAt'),
    );
  }
}

class AlertFilters {
  const AlertFilters({
    this.page = 1,
    this.pageSize = 20,
    this.estadoCodigo,
    this.tipoCodigo,
  });

  final int page;
  final int pageSize;
  final String? estadoCodigo;
  final String? tipoCodigo;

  AlertFilters firstPage() => copyWith(page: 1);

  AlertFilters copyWith({
    int? page,
    int? pageSize,
    Object? estadoCodigo = _unset,
    Object? tipoCodigo = _unset,
  }) {
    return AlertFilters(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      estadoCodigo: estadoCodigo == _unset
          ? this.estadoCodigo
          : _textValue(estadoCodigo as String?),
      tipoCodigo: tipoCodigo == _unset
          ? this.tipoCodigo
          : _textValue(tipoCodigo as String?),
    );
  }

  Map<String, dynamic> toQuery() {
    return {
      'page': page,
      'pageSize': pageSize,
      if (_textValue(estadoCodigo) != null) 'estadoCodigo': estadoCodigo,
      if (_textValue(tipoCodigo) != null) 'tipoCodigo': tipoCodigo,
    };
  }
}

class NotificationPreferences {
  const NotificationPreferences({
    required this.canal,
    required this.noMolestar,
    required this.horaInicio,
    required this.horaFin,
  });

  final String canal;
  final bool noMolestar;
  final String horaInicio;
  final String horaFin;

  factory NotificationPreferences.defaults() {
    return const NotificationPreferences(
      canal: 'PUSH',
      noMolestar: false,
      horaInicio: '07:00:00',
      horaFin: '21:00:00',
    );
  }

  NotificationPreferences copyWith({
    String? canal,
    bool? noMolestar,
    String? horaInicio,
    String? horaFin,
  }) {
    return NotificationPreferences(
      canal: canal ?? this.canal,
      noMolestar: noMolestar ?? this.noMolestar,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'canal': canal,
      'noMolestar': noMolestar,
      'horaInicio': horaInicio,
      'horaFin': horaFin,
    };
  }

  factory NotificationPreferences.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return NotificationPreferences(
      canal: _text(map, 'canal', 'Canal') ?? 'PUSH',
      noMolestar: map['noMolestar'] == true || map['NoMolestar'] == true,
      horaInicio: _text(map, 'horaInicio', 'HoraInicio') ?? '07:00:00',
      horaFin: _text(map, 'horaFin', 'HoraFin') ?? '21:00:00',
    );
  }
}

class NotificationsState {
  const NotificationsState({
    required this.summary,
    required this.alerts,
    required this.filters,
    required this.total,
    required this.totalPages,
    required this.preferences,
    required this.isLoading,
    required this.isLoadingMore,
    required this.isSummaryLoading,
    required this.isSavingPreferences,
    required this.isRegisteringDevice,
    this.errorMessage,
    this.traceId,
  });

  final AlertSummary summary;
  final List<AppAlert> alerts;
  final AlertFilters filters;
  final int total;
  final int totalPages;
  final NotificationPreferences preferences;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isSummaryLoading;
  final bool isSavingPreferences;
  final bool isRegisteringDevice;
  final String? errorMessage;
  final String? traceId;

  bool get hasMore => filters.page < totalPages;

  factory NotificationsState.initial() {
    return NotificationsState(
      summary: AlertSummary.empty(),
      alerts: const [],
      filters: const AlertFilters(),
      total: 0,
      totalPages: 0,
      preferences: NotificationPreferences.defaults(),
      isLoading: false,
      isLoadingMore: false,
      isSummaryLoading: false,
      isSavingPreferences: false,
      isRegisteringDevice: false,
    );
  }

  NotificationsState copyWith({
    AlertSummary? summary,
    List<AppAlert>? alerts,
    AlertFilters? filters,
    int? total,
    int? totalPages,
    NotificationPreferences? preferences,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSummaryLoading,
    bool? isSavingPreferences,
    bool? isRegisteringDevice,
    Object? errorMessage = _unset,
    Object? traceId = _unset,
  }) {
    return NotificationsState(
      summary: summary ?? this.summary,
      alerts: alerts ?? this.alerts,
      filters: filters ?? this.filters,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
      preferences: preferences ?? this.preferences,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSummaryLoading: isSummaryLoading ?? this.isSummaryLoading,
      isSavingPreferences: isSavingPreferences ?? this.isSavingPreferences,
      isRegisteringDevice: isRegisteringDevice ?? this.isRegisteringDevice,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      traceId: traceId == _unset ? this.traceId : traceId as String?,
    );
  }

  NotificationsState withPage(PagedResult<AppAlert> page, bool append) {
    return copyWith(
      alerts: append ? [...alerts, ...page.items] : page.items,
      total: page.total,
      totalPages: page.totalPages,
      filters: filters.copyWith(page: page.page, pageSize: page.pageSize),
      isLoading: false,
      isLoadingMore: false,
      errorMessage: null,
      traceId: null,
    );
  }
}

int _int(Map<String, dynamic> map, String camel, String pascal) {
  return (map[camel] as num?)?.toInt() ?? (map[pascal] as num?)?.toInt() ?? 0;
}

int? _nullableInt(Map<String, dynamic> map, String camel, String pascal) {
  return (map[camel] as num?)?.toInt() ?? (map[pascal] as num?)?.toInt();
}

String? _text(Map<String, dynamic> map, String camel, String pascal) {
  return _textValue((map[camel] ?? map[pascal])?.toString());
}

String? _textValue(String? value) {
  final clean = value?.trim();
  return clean == null || clean.isEmpty ? null : clean;
}

DateTime? _date(Map<String, dynamic> map, String camel, String pascal) {
  return DateTime.tryParse(_text(map, camel, pascal) ?? '');
}
