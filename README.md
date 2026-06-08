# NeoCloud Mobile Android

Aplicacion Flutter para Android telefono y tablet. Esta beta demo permite
mostrar el flujo comercial principal de NeoCloud Mobile: iniciar sesion, emitir
DTE, consultar documentos, administrar clientes/productos, revisar configuracion
DTE y dar seguimiento a cobros.

## Estado actual

- Plataforma: Android 9 o superior.
- API conectada: `https://excluded-supplements-anyway-broken.trycloudflare.com`
- Arquitectura: features simples con UI, ViewModel, Repository y Models.
- Estado global: Riverpod 3.

## Sprints completados

### Sprint 0: Fundaciones API y sesion

La app ya se conecta al backend real, maneja sesion con token, refresca credenciales
y valida el usuario activo al abrir. Tambien incluye health check para confirmar si
la API esta disponible.

### Sprint 1: Demo DTE minima funcional

La app permite buscar cliente y producto, armar una factura, emitirla contra el
backend y ver el resultado final. Tambien permite descargar y compartir el PDF.

### Sprint 2: Gestion completa de DTE

Se agrego consulta de documentos emitidos con filtros, detalle, descarga de PDF/JSON
y reenvio por correo. Tambien se muestran estados de carga, error y documentos vacios.

### Sprint 3: Clientes y productos reales

Se agrego gestion ligera de clientes y productos, creacion rapida durante facturacion,
verificacion de NIT/DUI y busqueda de productos por codigo de barras.

### Sprint 4: Configuracion DTE movil

La app muestra si la empresa esta lista para emitir: credenciales MH, establecimiento,
punto de venta, certificado y ambiente activo. Tambien permite subir certificado y
probar conexion con MH sin exponer secretos.

### Sprint 5: Dashboard y cobros para demo comercial

El dashboard ya muestra informacion real de la empresa. Cobros incluye resumen,
pendientes, vencidas, saldo por cliente, registro de pago, generacion de QR y compartir
enlace/QR.

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
NeoCloud-Mobile-DEMO-BETA.apk
```

Esta version esta pensada para pruebas comerciales en dispositivos Android 9 o
superiores.
