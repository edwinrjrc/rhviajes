/**
 * 
 */
package pe.com.viajes.web.servicio.impl;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.Properties;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.ServletContext;

import pe.com.viajes.bean.jasper.DetalleServicio;
import pe.com.viajes.bean.negocio.Contacto;
import pe.com.viajes.bean.negocio.DetalleComprobante;
import pe.com.viajes.bean.negocio.DetalleServicioAgencia;
import pe.com.viajes.bean.negocio.Direccion;
import pe.com.viajes.bean.negocio.Pasajero;
import pe.com.viajes.bean.negocio.ServicioAgencia;
import pe.com.viajes.bean.negocio.ServicioNovios;
import pe.com.viajes.negocio.ejb.UtilNegocioSessionRemote;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;
import pe.com.viajes.negocio.exception.ErrorRegistroDataException;
import pe.com.viajes.web.servicio.UtilNegocioServicio;

/**
 * @author Edwin
 *
 */
public class UtilNegocioServicioImpl implements UtilNegocioServicio {

	UtilNegocioSessionRemote ejbSession;

	final String ejbBeanName = "UtilNegocioSession";

	public UtilNegocioServicioImpl(ServletContext context)
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
		String lookup = "java:jboss/exported/Logistica1EAR/Logistica1Negocio/NegocioSession!pe.com.viajes.negocio.ejb.NegocioSessionRemote";

		final String ejbRemoto = UtilNegocioSessionRemote.class.getName();
		lookup = "java:jboss/exported/"
				+ context.getInitParameter("appNegocioNameEar") + "/"
				+ context.getInitParameter("appNegocioName") + "/"
				+ ejbBeanName + "!" + ejbRemoto;

		ejbSession = (UtilNegocioSessionRemote) ctx.lookup(lookup);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * pe.com.viajes.web.servicio.UtilNegocioServicio#agruparServicios(java
	 * .util.List)
	 */
	@Override
	public List<DetalleServicioAgencia> agruparServicios(
			List<DetalleServicioAgencia> listaServicios, Integer idEmpresa) {
		return ejbSession.agruparServiciosHijos(listaServicios, idEmpresa);
	}

	@Override
	public List<DetalleServicioAgencia> agregarServicioVenta(
			Integer idMonedaServicio,
			List<DetalleServicioAgencia> listaServiciosVenta,
			DetalleServicioAgencia detalleServicio)
			throws ErrorRegistroDataException, SQLException, Exception {
		return ejbSession.agregarServicioVenta(idMonedaServicio,
				listaServiciosVenta, detalleServicio);
	}

	@Override
	public List<DetalleServicioAgencia> actualizarServicioVenta(
			Integer idMonedaServicio,
			List<DetalleServicioAgencia> listaServiciosVenta,
			DetalleServicioAgencia detalleServicio)
			throws ErrorRegistroDataException, SQLException, Exception {
		return ejbSession.actualizarServicioVenta(idMonedaServicio,
				listaServiciosVenta, detalleServicio);
	}

	@Override
	public BigDecimal calcularPorcentajeComision(
			DetalleServicioAgencia detalleServicio) throws SQLException,
			Exception {
		return ejbSession.calculaPorcentajeComision(detalleServicio);
	}

	@Override
	public List<DetalleServicio> consultarServiciosVenta(Integer idServicio, Integer idEmpresa)
			throws SQLException {
		return ejbSession.consultarServiciosVentaJR(idServicio, idEmpresa);
	}

	@Override
	public Direccion agregarDireccion(Direccion direccion) throws SQLException,
			Exception {
		return ejbSession.agregarDireccion(direccion);
	}

	@Override
	public Contacto agregarContacto(Contacto contacto) throws SQLException,
			Exception {
		return ejbSession.agregarContacto(contacto);
	}

	@Override
	public ServicioNovios agregarServicioNovios(ServicioNovios servicioNovios)
			throws SQLException, Exception {
		return ejbSession.agregarServicio(servicioNovios);
	}

	@Override
	public BigDecimal calcularValorCuota(ServicioAgencia servicioAgencia)
			throws SQLException, Exception {
		return ejbSession.calcularValorCuota(servicioAgencia);
	}

	@Override
	public Pasajero agregarPasajero(Pasajero pasajero)
			throws ErrorRegistroDataException {
		return ejbSession.agregarPasajero(pasajero);
	}
	
	@Override
	public List<String> generarDetalleComprobanteImpresionDocumentoCobranza(List<DetalleComprobante> listaDetalle, int idServicio, int idEmpresa) throws ErrorConsultaDataException{
		return ejbSession.generarDetalleComprobanteImpresionDocumentoCobranza(listaDetalle, idServicio, idEmpresa);
	}
	
	@Override
	public List<String> generarDetalleComprobanteImpresionBoleta(List<DetalleComprobante> listaDetalle, int idServicio, int idEmpresa) throws ErrorConsultaDataException{
		return ejbSession.generarDetalleComprobanteImpresionBoleta(listaDetalle, idServicio, idEmpresa);
	}

	@Override
	public List<Pasajero> consultarPasajerosServicio(int idServicio,
			int idEmpresa) throws ErrorConsultaDataException {
		return ejbSession.consultarPasajerosServicio(idServicio, idEmpresa);
	}
	
	@Override
	public Connection obtenerConexion(){
		return ejbSession.obtenerConexion();
	}
}
