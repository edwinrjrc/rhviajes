/**
 * 
 */
package pe.com.viajes.web.servicio.impl;

import java.sql.SQLException;
import java.util.List;
import java.util.Properties;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.ServletContext;

import pe.com.viajes.bean.cargaexcel.ColumnasExcel;
import pe.com.viajes.bean.cargaexcel.ReporteArchivo;
import pe.com.viajes.bean.negocio.Cliente;
import pe.com.viajes.bean.negocio.Comprobante;
import pe.com.viajes.bean.negocio.Consolidador;
import pe.com.viajes.bean.negocio.CorreoMasivo;
import pe.com.viajes.bean.negocio.CuentaBancaria;
import pe.com.viajes.bean.negocio.DocumentoAdicional;
import pe.com.viajes.bean.negocio.EventoObsAnu;
import pe.com.viajes.bean.negocio.MaestroServicio;
import pe.com.viajes.bean.negocio.PagoServicio;
import pe.com.viajes.bean.negocio.ProgramaNovios;
import pe.com.viajes.bean.negocio.Proveedor;
import pe.com.viajes.bean.negocio.ServicioAgencia;
import pe.com.viajes.bean.negocio.TipoCambio;
import pe.com.viajes.negocio.ejb.NegocioSessionRemote;
import pe.com.viajes.negocio.exception.EnvioCorreoException;
import pe.com.viajes.negocio.exception.ErrorRegistroDataException;
import pe.com.viajes.negocio.exception.ResultadoCeroDaoException;
import pe.com.viajes.web.servicio.NegocioServicio;

/**
 * @author Edwin
 *
 */
public class NegocioServicioImpl implements NegocioServicio {

	NegocioSessionRemote ejbSession;

	final String ejbBeanName = "NegocioSession";

	/**
	 * 
	 */
	public NegocioServicioImpl(ServletContext context) throws NamingException {

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
		String lookup = "java:jboss/exported/Logistica1EAR/Logistica1Negocio/NegocioSession!pe.com.viajes.negocio.ejb.NegocioSessionRemote";

		final String ejbRemoto = NegocioSessionRemote.class.getName();
		lookup = "java:jboss/exported/"
				+ context.getInitParameter("appNegocioNameEar") + "/"
				+ context.getInitParameter("appNegocioName") + "/"
				+ ejbBeanName + "!" + ejbRemoto;

		ejbSession = (NegocioSessionRemote) ctx.lookup(lookup);

	}

	@Override
	public boolean registrarProveedor(Proveedor proveedor) throws SQLException,
			Exception {
		return ejbSession.registrarProveedor(proveedor);
	}

	@Override
	public boolean actualizarProveedor(Proveedor proveedor)
			throws SQLException, Exception {
		return ejbSession.actualizarProveedor(proveedor);
	}

	@Override
	public boolean registrarCliente(Cliente cliente)
			throws ResultadoCeroDaoException, SQLException, Exception {
		return ejbSession.registrarCliente(cliente);
	}

	@Override
	public boolean actualizarCliente(Cliente cliente)
			throws ResultadoCeroDaoException, SQLException, Exception {
		return ejbSession.actualizarCliente(cliente);
	}

	@Override
	public Integer registrarNovios(ProgramaNovios programaNovios)
			throws SQLException, Exception {
		return ejbSession.registrarNovios(programaNovios);
	}

	@Override
	public Integer registrarVentaServicio(ServicioAgencia servicioAgencia)
			throws ErrorRegistroDataException, SQLException, Exception {
		return ejbSession.registrarVentaServicio(servicioAgencia);
	}

	@Override
	public Integer actualizarVentaServicio(ServicioAgencia servicioAgencia)
			throws ErrorRegistroDataException, SQLException, Exception {
		return ejbSession.actualizarVentaServicio(servicioAgencia);
	}

	@Override
	public boolean ingresarMaestroServicio(MaestroServicio servicio)
			throws ErrorRegistroDataException, SQLException, Exception {

		return ejbSession.ingresarMaestroServicio(servicio);
	}

	@Override
	public boolean actualizarMaestroServicio(MaestroServicio servicio)
			throws SQLException, Exception {

		return ejbSession.actualizarMaestroServicio(servicio);
	}

	@Override
	public Integer actualizarNovios(ProgramaNovios programaNovios)
			throws SQLException, Exception {
		return ejbSession.actualizarNovios(programaNovios);
	}

	@Override
	public int enviarCorreoMasivo(CorreoMasivo correoMasivo)
			throws EnvioCorreoException, Exception {

		return ejbSession.enviarCorreoMasivo(correoMasivo);
	}

	@Override
	public boolean ingresarConsolidador(Consolidador consolidador)
			throws SQLException, Exception {
		return ejbSession.ingresarConsolidador(consolidador);
	}

	@Override
	public boolean actualizarConsolidador(Consolidador consolidador)
			throws SQLException, Exception {
		return ejbSession.actualizarConsolidador(consolidador);
	}

	@Override
	public void registrarPago(PagoServicio pago) throws ErrorRegistroDataException, Exception {
		ejbSession.registrarPago(pago);
	}

	@Override
	public void cerrarVenta(ServicioAgencia servicioAgencia)
			throws SQLException, Exception {
		ejbSession.cerrarVenta(servicioAgencia);
	}

	@Override
	public void anularVenta(ServicioAgencia servicioAgencia)
			throws SQLException, Exception {
		ejbSession.anularVenta(servicioAgencia);
	}

	@Override
	public void registrarEventoObservacion(EventoObsAnu evento)
			throws SQLException, Exception {
		ejbSession.registrarEventoObservacion(evento);
	}

	@Override
	public void registrarEventoAnulacion(EventoObsAnu evento)
			throws SQLException, Exception {
		ejbSession.registrarEventoAnulacion(evento);
	}

	@Override
	public boolean registrarComprobantes(ServicioAgencia servicioAgencia)
			throws SQLException, Exception {
		return ejbSession.registrarComprobantes(servicioAgencia);
	}

	@Override
	public boolean registrarObligacionXPagar(Comprobante comprobante)
			throws SQLException, Exception {
		return ejbSession.registrarObligacionXPagar(comprobante);
	}

	@Override
	public void registrarPagoObligacion(PagoServicio pago) throws SQLException,
			Exception {
		ejbSession.registrarPagoObligacion(pago);
	}

	@Override
	public void registrarComprobanteObligacion(ServicioAgencia servicioAgencia)
			throws SQLException, Exception {
		ejbSession.registrarRelacionComproObligacion(servicioAgencia);
	}

	@Override
	public boolean grabarDocumentosAdicionales(List<DocumentoAdicional> lista, Integer idEmpresa)
			throws ErrorRegistroDataException, SQLException, Exception {
		return ejbSession.grabarDocumentosAdicionales(lista, idEmpresa);
	}

	@Override
	public void registrarComprobantesAdicionales(List<Comprobante> lista)
			throws ErrorRegistroDataException, SQLException, Exception {
		ejbSession.registrarComprobantesAdicionales(lista);
	}

	@Override
	public boolean grabarComprobantesReporte(ReporteArchivo reporteArchivo,
			ColumnasExcel columnasExcel, List<ColumnasExcel> dataExcel)
			throws ErrorRegistroDataException, SQLException, Exception {
		return ejbSession.grabarComprobantesReporte(reporteArchivo,
				columnasExcel, dataExcel);
	}

	@Override
	public boolean registrarCuentaBancaria(CuentaBancaria cuentaBancaria)
			throws ErrorRegistroDataException {
		return ejbSession.registrarCuentaBancaria(cuentaBancaria);
	}

	@Override
	public boolean actualizarCuentaBancaria(CuentaBancaria cuentaBancaria)
			throws ErrorRegistroDataException {
		return ejbSession.actualizarCuentaBancaria(cuentaBancaria);
	}

	@Override
	public boolean registrarTipoCambio(TipoCambio tipoCambio)
			throws SQLException {
		return ejbSession.registrarTipoCambio(tipoCambio);
	}

}
