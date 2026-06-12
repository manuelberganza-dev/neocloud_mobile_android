# NeoCloud Mobile Android

App Flutter para Android telefono y tablet. Esta demo beta muestra el flujo
comercial principal de NeoCloud Mobile: iniciar sesion, emitir DTE, consultar
documentos, vender por POS, cobrar, escanear compras y revisar alertas.

## Estado actual

- Plataforma: Android 9 o superior.
- API conectada: `https://unknown-virgin-beyond-rom.trycloudflare.com`
- App: `NeoCloud Mobile`.
- Arquitectura: features simples con UI, ViewModel, Repository y Models.
- Estado global: Riverpod 3.

## Sprints completados

### Sprint 0: Fundaciones API y sesion

Conexion real al backend, login, token seguro, refresh automatico, usuario activo,
permisos en memoria y health check.

### Sprint 1: Demo DTE minima funcional

Busqueda de cliente/producto, factura rapida, emision real, estado final, numero de
control, sello recibido, PDF y compartir.

### Sprint 2: Gestion completa de DTE

Consulta paginada de documentos, filtros, detalle, PDF/JSON, reenvio por correo y
manejo visual de errores o rechazos.

### Sprint 3: Clientes y productos reales

CRUD ligero de clientes y productos, cliente rapido en facturacion, verificacion de
NIT/DUI y lectura de codigo de barras.

### Sprint 4: Configuracion DTE movil

Checklist de empresa lista para emitir: MH, establecimiento, punto de venta,
certificado, ambiente activo y prueba de conexion.

### Sprint 5: Dashboard y cobros

Dashboard real, resumen de cartera, pendientes/vencidas, saldo por cliente, registro
de pago, QR de cobro y compartir enlace.

### Sprint 6: Compartir DTE completo

Acciones compartidas para PDF, JSON, correo y WhatsApp desde emision y consulta DTE,
respetando permisos.

### Sprint 7: Notificaciones

Centro de alertas, badge en dashboard, marcar como leida, resolver alertas,
preferencias y base lista para FCM.

### Sprint 8: NeoScan y DTE recibidos

Bandeja de documentos recibidos, subir imagen/PDF, tomar foto con camara trasera,
corregir datos extraidos y registrar gasto, compra o DTE recibido.

### Sprint 9: Ventas sin DTE / POS

Venta rapida tradicional con carrito, busqueda de producto, ticket, compartir por
WhatsApp/correo y opcion para convertir a DTE.

### Sprint 10: Caja POS

Apertura de caja, fondo inicial, turno activo, resumen de ventas, cierre con efectivo
contado y diferencia.

## Actualizaciones recientes

- POS quedo visible en la barra inferior.
- Mas abre un menu lateral derecho con opciones administrativas.
- NeoScan ahora puede tomar foto directamente desde la app.
- Los tickets POS se pueden ver en la app, descargar y compartir.

## Estructura principal

```text
lib/
+-- core/       # configuracion, red, seguridad, rutas y tema
+-- features/   # modulos de negocio de la app
+-- shared/     # widgets reutilizables
+-- main.dart
```

## APK demo

El APK de demo se genera como:

```text
NeoCloud Mobile.apk
```

Comando manual recomendado:

```powershell
flutter build apk --profile --target-platform android-arm64; Copy-Item -LiteralPath "build\app\outputs\flutter-apk\app-profile.apk" -Destination "build\app\outputs\flutter-apk\NeoCloud Mobile.apk" -Force
```
