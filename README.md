# NeoCloud Mobile Android

Aplicacion Flutter para Android telefono y tablet. Esta primera base construye
solo las pantallas y la parte visual, siguiendo los sprints y la propuesta del
producto sin implementar logica de negocio ni consumo real de API.

## Arquitectura definida

Clean Architecture sin "Clean Hell": responsabilidades claras y features como
mini-MVC modernos.

```text
lib/
+-- core/
|   +-- config/        # Constantes globales, flags, entorno
|   +-- routing/       # go_router y rutas principales
|   +-- theme/         # Paleta NeoCloud, ThemeData y estilos base
+-- features/
|   +-- dashboard/
|   |   +-- ui/
|   |   +-- dashboard_viewmodel.dart
|   |   +-- dashboard_repository.dart
|   |   +-- models/
|   +-- invoice/
|   +-- clients/
|   +-- neoscan/
|   +-- collections/
|   +-- dte_query/
+-- shared/
|   +-- widgets/       # Componentes visuales reutilizables
+-- main.dart
```

## Regla por feature

- `ui/`: widgets que solo dibujan el estado recibido.
- `*_viewmodel.dart`: presentacion y estado expuesto con Riverpod 3 y
  anotaciones `@riverpod`.
- `*_repository.dart`: fuente de datos mock, reemplazable por API/cache.
- `models/`: clases simples de datos de pantalla.

Flujo esperado:

```text
UI -> ViewModel -> Repository -> ViewModel -> UI
```

## Sprints visuales cubiertos

- Sprint 1: base de app, navegacion, tema y estructura para auth/API futura.
- Sprint 2: Inicio / Dashboard rapido.
- Sprint 3: Emision rapida de DTE.
- Sprint 4: CRM ligero y catalogo desde herramientas.
- Sprint 5: NeoScan / OCR visual.
- Sprint 6: Consulta DTE, cobros, alertas y herramientas.
- Sprint 7: base responsive telefono/tablet y estados visuales listos para QA.

A new Flutter project.
