class ApiEndpoints {
  const ApiEndpoints._();

  static const health = '/health';

  static const authLogin = '/api/auth/login';
  static const authRefresh = '/api/auth/refresh';
  static const authLogout = '/api/auth/logout';
  static const authMe = '/api/auth/me';
  static const authChangePassword = '/api/auth/change-password';
  static const authMfaEnroll = '/api/auth/mfa/enroll';
  static const authMfaConfirm = '/api/auth/mfa/confirm';
  static const authMfaDisable = '/api/auth/mfa/disable';

  static const dteConfiguracion = '/api/dte/configuracion';
  static const dteConfiguracionCertificado =
      '/api/dte/configuracion/certificado';
  static const dteConfiguracionProbarConexion =
      '/api/dte/configuracion/probar-conexion';

  static const dteEmitir = '/api/dte/emitir';
  static const dteEmitirFactura = '/api/dte/emitir/factura';
  static const dteEmitirCreditoFiscal = '/api/dte/emitir/credito-fiscal';
  static const dteEmitirNotaCredito = '/api/dte/emitir/nota-credito';
  static const dteEmitirNotaDebito = '/api/dte/emitir/nota-debito';
  static const dteEmitirSujetoExcluido = '/api/dte/emitir/sujeto-excluido';

  static const dteDocumentos = '/api/dte/documentos';

  static String dteDocumento(int id) => '/api/dte/documentos/$id';
  static String dteDocumentoPdf(int id) => '/api/dte/documentos/$id/pdf';
  static String dteDocumentoJson(int id) => '/api/dte/documentos/$id/json';
  static String dteDocumentoReenviar(int id) =>
      '/api/dte/documentos/$id/reenviar';

  static const clientes = '/api/clientes';
  static String cliente(int id) => '/api/clientes/$id';
  static String clienteInactivar(int id) => '/api/clientes/$id/inactivar';
  static String clienteEtiqueta(int id) => '/api/clientes/$id/etiqueta';

  static const productos = '/api/productos';
  static String producto(int id) => '/api/productos/$id';
  static String productoInactivar(int id) => '/api/productos/$id/inactivar';

  static const lookupsClientes = '/api/lookups/clientes';
  static const lookupsProductos = '/api/lookups/productos';
  static const lookupsSucursales = '/api/lookups/sucursales';
  static const lookupsDepartamentos = '/api/lookups/departamentos';
  static const lookupsMunicipios = '/api/lookups/municipios';
  static const lookupsDistritos = '/api/lookups/distritos';
  static const lookupsVerificarNit = '/api/lookups/verificar-nit';
  static String lookupsCatalogo(String codigo) =>
      '/api/lookups/catalogo/$codigo';

  static const dashboardEmpresa = '/api/dashboard/empresa';

  static const cobrosResumen = '/api/cobros/resumen';
  static const cobrosPendientes = '/api/cobros/pendientes';
  static const cobrosCuentas = '/api/cobros/cuentas';
  static const cobrosQr = '/api/cobros/qr';
  static String cobrosCliente(int clienteId) =>
      '/api/cobros/clientes/$clienteId';
  static String cobrosDtePagos(int dteId) => '/api/cobros/dte/$dteId/pagos';
  static String cobrosPagoConfirmar(int pagoId) =>
      '/api/cobros/pagos/$pagoId/confirmar';
  static String cobrosPagoAnular(int pagoId) =>
      '/api/cobros/pagos/$pagoId/anular';

  static const alertas = '/api/alertas';
  static const alertasResumen = '/api/alertas/resumen';
  static const alertasLeerTodas = '/api/alertas/leer-todas';
  static const alertasGenerar = '/api/alertas/generar';
  static const alertasDispositivos = '/api/alertas/dispositivos';
  static const alertasDispositivosEliminar =
      '/api/alertas/dispositivos/eliminar';
  static const alertasPreferencias = '/api/alertas/preferencias';
  static String alertaLeer(int id) => '/api/alertas/$id/leer';
  static String alertaResolver(int id) => '/api/alertas/$id/resolver';

  static const scanAiDocumentos = '/api/scanai/documentos';
  static String scanAiDocumento(int id) => '/api/scanai/documentos/$id';
  static String scanAiArchivo(int id) => '/api/scanai/documentos/$id/archivo';
  static String scanAiCampos(int id) => '/api/scanai/documentos/$id/campos';
  static String scanAiResultado(int id) =>
      '/api/scanai/documentos/$id/resultado';
  static String scanAiRegistrarGasto(int id) =>
      '/api/scanai/documentos/$id/registrar-gasto';
  static String scanAiRegistrarCompra(int id) =>
      '/api/scanai/documentos/$id/registrar-compra';
  static String scanAiRegistrarDteRecibido(int id) =>
      '/api/scanai/documentos/$id/registrar-dte-recibido';
  static String scanAiRechazar(int id) => '/api/scanai/documentos/$id/rechazar';
}
