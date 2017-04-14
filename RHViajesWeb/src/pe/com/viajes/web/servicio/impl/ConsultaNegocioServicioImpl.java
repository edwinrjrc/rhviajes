/**
 * 
 */
package pe.com.viajes.web.servicio.impl;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.Date;
import java.util.List;
import java.util.Properties;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.ServletContext;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.base.Persona;
import pe.com.viajes.bean.cargaexcel.ReporteArchivoBusqueda;
import pe.com.viajes.bean.negocio.Cliente;
import pe.com.viajes.bean.negocio.Comprobante;
import pe.com.viajes.bean.negocio.ComprobanteBusqueda;
import pe.com.viajes.bean.negocio.Consolidador;
import pe.com.viajes.bean.negocio.CorreoClienteMasivo;
import pe.com.viajes.bean.negocio.CuentaBancaria;
import pe.com.viajes.bean.negocio.CuotaPago;
import pe.com.viajes.bean.negocio.DetalleServicioAgencia;
import pe.com.viajes.bean.negocio.DocumentoAdicional;
import pe.com.viajes.bean.negocio.ImpresionArchivoCargado;
import pe.com.viajes.bean.negocio.MaestroServicio;
import pe.com.viajes.bean.negocio.MovimientoCuenta;
import pe.com.viajes.bean.negocio.PagoServicio;
import pe.com.viajes.bean.negocio.Pasajero;
import pe.com.viajes.bean.negocio.ProgramaNovios;
import pe.com.viajes.bean.negocio.Proveedor;
import pe.com.viajes.bean.negocio.ServicioAgencia;
import pe.com.viajes.bean.negocio.ServicioAgenciaBusqueda;
import pe.com.viajes.bean.negocio.ServicioProveedor;
import pe.com.viajes.bean.negocio.TipoCambio;
import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.bean.reportes.CheckIn;
import pe.com.viajes.negocio.ejb.ConsultaNegocioSessionRemote;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;
import pe.com.viajes.web.servicio.ConsultaNegocioServicio;

/**
 * @author EDWREB
 *
 */
public class ConsultaNegocioServicioImpl implements ConsultaNegocioServicio {

	ConsultaNegocioSessionRemote ejbSession;

	final String ejbBeanName = "ConsultaNegocioSession";

	public ConsultaNegocioServicioImpl(ServletContext context)
			throws NamingException {

		Properties props = new Properties();
		/*
		 * props.setProperty("java.naming.factory.initial",
		 * "org.jnp.interfaces.NamingContextFactory");
		 * props.setProperty("java.naming.factory.url.pkgs",
		 * "org.jboss.naming"); props.setProperty("java.naming.provider.url",
		 * "localhost:1099");
		 */
		props.put(Context.URL_PKG_PREFIXES, "org.jboss.ejb.client.naming");

		Context ctx = new InitialContext(props);
		// String lookup =
		// "ejb:Logistica1EAR/Logistica1Negocio/SeguridadSession!pe.com.viajes.negocio.ejb.SeguridadRemote";
		String lookup = "java:jboss/exported/Logistica1EAR/Logistica1Negocio/NegocioSession!pe.com.viajes.negocio.ejb.ConsultaNegocioSessionRemote";

		final String ejbRemoto = ConsultaNegocioSessionRemote.class.getName();
		lookup = "java:jboss/exported/"
				+ context.getInitParameter("appNegocioNameEar") + "/"
				+ context.getInitParameter("appNegocioName") + "/"
				+ ejbBeanName + "!" + ejbRemoto;

		ejbSession = (ConsultaNegocioSessionRemote) ctx.lookup(lookup);

	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see pe.com.viajes.web.servicio.ConsultaNegocioServicio#listarProveedor
	 * (pe.com.viajes.bean.negocio.Proveedor)
	 */
	@Override
	public List<Proveedor> listarProveedor(Proveedor proveedor)
			throws SQLException {
		return ejbSession.listarProveedor(proveedor);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * pe.com.viajes.web.servicio.ConsultaNegocioServicio#consultarProveedor
	 * (int)
	 */
	@Override
	public Proveedor consultarProveedor(int codigoProveedor, Integer idEmpresa)
			throws SQLException, Exception {
		return ejbSession.consultarProveedor(codigoProveedor, idEmpresa);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see pe.com.viajes.web.servicio.ConsultaNegocioServicio#buscarProveedor
	 * (pe.com.viajes.bean.negocio.Proveedor)
	 */
	@Override
	public List<Proveedor> buscarProveedor(Proveedor proveedor)
			throws SQLException {
		return ejbSession.buscarProveedor(proveedor);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see pe.com.viajes.web.servicio.ConsultaNegocioServicio#listarCliente()
	 */
	@Override
	public List<Cliente> listarCliente(Cliente cliente) throws SQLException {
		return ejbSession.listarCliente(cliente);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see pe.com.viajes.web.servicio.ConsultaNegocioServicio#buscarCliente(pe
	 * .com.logistica.bean.negocio.Cliente)
	 */
	@Override
	public List<Cliente> buscarCliente(Cliente cliente) throws SQLException {
		return ejbSession.buscarCliente(cliente);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see pe.com.viajes.web.servicio.ConsultaNegocioServicio#consultarCliente
	 * (int)
	 */
	@Override
	public Cliente consultarCliente(int idcliente, Integer idEmpresa) throws SQLException,
			Exception {
		return ejbSession.consultarCliente(idcliente, idEmpresa);
	}

	@Override
	public List<Cliente> listarClientesNovios(String genero, Integer idEmpresa)
			throws SQLException, Exception {
		return ejbSession.listarClientesNovios(genero, idEmpresa);
	}

	@Override
	public List<Cliente> buscarClientesNovios(Cliente cliente, Integer idEmpresa)
			throws SQLException, Exception {
		return ejbSession.consultarClientesNovios(cliente, idEmpresa);
	}

	@Override
	public List<ProgramaNovios> consultarNovios(ProgramaNovios programaNovios)
			throws SQLException, Exception {
		return ejbSession.consultarNovios(programaNovios);
	}

	@Override
	public List<CuotaPago> consultarCronogramaPago(
			ServicioAgencia servicioAgencia) throws SQLException, Exception {
		return ejbSession.consultarCronograma(servicioAgencia);
	}

	@Override
	public ServicioAgencia consultarVentaServicio(int idServicio, Integer idEmpresa)
			throws SQLException, Exception {
		return ejbSession.consultarServicioVenta(idServicio, idEmpresa);
	}

	@Override
	public List<ServicioAgencia> listarVentaServicio(
			ServicioAgenciaBusqueda servicioAgencia) throws SQLException,
			Exception {
		return ejbSession.listarServicioVenta(servicioAgencia);
	}

	@Override
	public List<Cliente> consultarCliente2(Cliente cliente)
			throws SQLException, Exception {
		return ejbSession.consultarCliente2(cliente);
	}

	@Override
	public List<ServicioProveedor> proveedoresXServicio(int idServicio, int idEmpresa)
			throws SQLException, Exception {
		BaseVO servicio = new BaseVO(idServicio);
		servicio.getEmpresa().setCodigoEntero(idEmpresa);

		return ejbSession.proveedoresXServicio(servicio);
	}

	@Override
	public ProgramaNovios consultarProgramaNovios(int idProgramaNovios, Integer idEmpresa)
			throws SQLException, Exception {
		return ejbSession.consultarProgramaNovios(idProgramaNovios, idEmpresa);
	}

	@Override
	public List<MaestroServicio> listarMaestroServicio(Integer idEmpresa) throws SQLException,
			Exception {

		return ejbSession.listarMaestroServicio(idEmpresa);
	}

	@Override
	public List<MaestroServicio> listarMaestroServicioAdm(Integer idEmpresa)
			throws SQLException, Exception {

		return ejbSession.listarMaestroServicioAdm(idEmpresa);
	}

	@Override
	public List<MaestroServicio> listarMaestroServicioFee(Integer idEmpresa)
			throws SQLException, Exception {

		return ejbSession.listarMaestroServicioFee(idEmpresa);
	}

	@Override
	public List<MaestroServicio> listarMaestroServicioImpto(Integer idEmpresa)
			throws SQLException, Exception {

		return ejbSession.listarMaestroServicioImpto(idEmpresa);
	}

	@Override
	public MaestroServicio consultarMaestroServicio(int idMaestroServicio, Integer idEmpresa)
			throws SQLException, Exception {

		return ejbSession.consultarMaestroServicio(idMaestroServicio, idEmpresa);
	}

	@Override
	public List<CorreoClienteMasivo> listarClientesCorreo(Integer idEmpresa)
			throws SQLException, Exception {

		return ejbSession.listarClientesCorreo(idEmpresa);
	}

	@Override
	public List<Cliente> listarClientesCumples(Integer idEmpresa) throws SQLException, Exception {
		return ejbSession.listarClientesCumples(idEmpresa);
	}

	@Override
	public List<MaestroServicio> listarMaestroServicioIgv(Integer idEmpresa)
			throws SQLException, Exception {

		return ejbSession.listarMaestroServicioIgv(idEmpresa);
	}

	@Override
	public List<BaseVO> consultaServiciosDependientes(Integer idServicio, Integer idEmpresa)
			throws SQLException, Exception {
		return ejbSession.consultaServiciosDependientes(idServicio, idEmpresa);
	}

	@Override
	public List<Consolidador> listarConsolidador() throws SQLException,
			Exception {
		return ejbSession.listarConsolidador();
	}

	@Override
	public Consolidador consultarConsolidador(Consolidador consolidador)
			throws SQLException, Exception {
		return ejbSession.consultarConsolidador(consolidador);
	}

	@Override
	public List<PagoServicio> listarPagosServicio(Integer idServicio, Integer idEmpresa)
			throws SQLException, Exception {

		return ejbSession.listarPagosServicio(idServicio, idEmpresa);
	}

	@Override
	public List<PagoServicio> listarPagosObligacion(Integer idObligacion, Integer idEmpresa)
			throws SQLException, Exception {

		return ejbSession.listarPagosObligacion(idObligacion, idEmpresa);
	}

	@Override
	public BigDecimal consultarSaldoServicio(Integer idServicio, Integer idEmpresa)
			throws SQLException, Exception {

		return ejbSession.consultarSaldoServicio(idServicio, idEmpresa);
	}

	@Override
	public List<DetalleServicioAgencia> consultarDetalleComprobantes(
			Integer idServicio, Integer idEmpresa) throws SQLException, Exception {
		return ejbSession.consultarDetalleServicioComprobante(idServicio, idEmpresa);
	}

	@Override
	public List<DetalleServicioAgencia> consultarDetServComprobanteObligacion(
			Integer idServicio, Integer idEmpresa) throws SQLException, Exception {
		return ejbSession.consultarDetServComprobanteObligacion(idServicio, idEmpresa);
	}

	@Override
	public List<Comprobante> listarObligacionXPagar(Comprobante comprobante)
			throws SQLException, Exception {
		return ejbSession.listarObligacionXPagar(comprobante);
	}

	@Override
	public List<DocumentoAdicional> listarDocumentosAdicionales(
			Integer idServicio, Integer idEmpresa) throws SQLException {
		return ejbSession.listarDocumentosAdicionales(idServicio, idEmpresa);
	}

	@Override
	public List<Comprobante> consultarComprobantesGenerados(
			ComprobanteBusqueda comprobanteBusqueda)
			throws ErrorConsultaDataException {
		return ejbSession.consultarComprobantesGenerados(comprobanteBusqueda);
	}

	@Override
	public Comprobante consultarComprobanteGenerado(Integer idComprobante, Integer idEmpresa)
			throws ErrorConsultaDataException {
		return ejbSession.consultarComprobante(idComprobante, idEmpresa);
	}

	@Override
	public List<ReporteArchivoBusqueda> consultarArchivosCargados(
			ReporteArchivoBusqueda reporteArchivoBusqueda)
			throws ErrorConsultaDataException {
		return ejbSession.consultarArchivosCargados(reporteArchivoBusqueda);
	}

	@Override
	public DetalleServicioAgencia consultarDetalleServicioDetalle(
			int idServicio, int idDetServicio, Integer idEmpresa) throws SQLException {
		return ejbSession.consultaDetalleServicioDetalle(idServicio,
				idDetServicio, idEmpresa);
	}

	@Override
	public List<CuentaBancaria> listarCuentasBancarias(Integer idEmpresa) throws SQLException {
		return ejbSession.listarCuentasBancarias(idEmpresa);
	}

	@Override
	public CuentaBancaria consultarCuentaBancaria(Integer idCuenta, Integer idEmpresa)
			throws SQLException {
		return ejbSession.consultaCuentaBancaria(idCuenta, idEmpresa);
	}

	@Override
	public List<CuentaBancaria> listarCuentasBancariasCombo(Integer idEmpresa)
			throws SQLException {
		return ejbSession.listarCuentasBancariasCombo(idEmpresa);
	}

	@Override
	public Comprobante consultarComprobanteObligacion(Integer idObligacion, Integer idEmpresa)
			throws SQLException {
		return ejbSession.consultarComprobanteObligacion(idObligacion, idEmpresa);
	}

	@Override
	public List<CuentaBancaria> listarCuentasBancariasProveedor(
			Integer idProveedor, Integer idEmpresa) throws SQLException {
		return ejbSession.listarCuentasBancariasProveedor(idProveedor, idEmpresa);
	}

	@Override
	public List<MovimientoCuenta> listarMovimientosXCuenta(Integer idCuenta, Integer idEmpresa)
			throws SQLException {
		return ejbSession.listarMovimientosXCuenta(idCuenta, idEmpresa);
	}

	@Override
	public List<TipoCambio> listarTipoCambio(Date fecha, Integer idEmpresa) throws SQLException {
		return ejbSession.listarTipoCambio(fecha, idEmpresa);
	}
	@Override
	public List<CheckIn> consultarCheckInPendiente(Usuario usuario) throws SQLException {
		return ejbSession.consultarCheckInPendientes(usuario);
	}

	@Override
	public List<ImpresionArchivoCargado> consultaImpresionArchivoCargado(
			Integer idArchivoCargado, Integer idEmpresa) throws SQLException {
		return ejbSession.consultaImpresionArchivoCargado(idArchivoCargado, idEmpresa);
	}
	
	@Override
	public List<Pasajero> consultarPasajeroHistorico(Pasajero pasajero) throws ErrorConsultaDataException{
		return ejbSession.consultarPasajeroHistorico(pasajero);
	}
	
	@Override
	public List<Comprobante> consultarObligacionesPendientes(int idEmpresa) throws ErrorConsultaDataException{
		return ejbSession.consultarObligacionesPendientes(idEmpresa);
	}
	
	@Override
	public List<DocumentoAdicional> listarAdjuntosPersona(Persona persona) throws ErrorConsultaDataException{
		return ejbSession.listarDocumentosAdicionales(persona);
	}

	@Override
	public Pasajero consultaClientePasajero(Pasajero pasajero)
			throws ErrorConsultaDataException {
		return ejbSession.consultaClientePasajero(pasajero);
	}

	@Override
	public Pasajero consultarContactoPasajero(Pasajero pasajero)
			throws ErrorConsultaDataException {
		return ejbSession.consultaContactoPasajero(pasajero);
	}
	
	@Override
	public TipoCambio consultarTipoCambio (Integer idEmpresa) throws ErrorConsultaDataException{
		return ejbSession.consultarTipoCambio(idEmpresa);
	}
	
	@Override
	public List<DetalleServicioAgencia> consultarDescripcionServicioDC(Integer idEmpresa, Integer idServicio, Integer idComprobante) throws ErrorConsultaDataException{
		return ejbSession.consultarDescripcionServicioDC(idEmpresa, idServicio, idComprobante);
	}
	
	@Override
	public List<DetalleServicioAgencia> consultarDescripcionServicioBL(Comprobante comprobante) throws ErrorConsultaDataException{
		return ejbSession.consultarDescripcionServicioBL(comprobante.getEmpresa().getCodigoEntero(), comprobante.getCodigoEntero(), comprobante.getIdServicio());
	}
	
	@Override
	public List<BaseVO> listarTarjetasPago() throws ErrorConsultaDataException{
		return ejbSession.obtenerListaTarjetasPago();
	}
}