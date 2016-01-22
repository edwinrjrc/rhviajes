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

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.negocio.ConfiguracionTipoServicio;
import pe.com.viajes.bean.negocio.Destino;
import pe.com.viajes.bean.negocio.Maestro;
import pe.com.viajes.bean.negocio.Pais;
import pe.com.viajes.bean.negocio.Proveedor;
import pe.com.viajes.negocio.ejb.SoporteRemote;
import pe.com.viajes.negocio.exception.ConnectionException;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;
import pe.com.viajes.web.servicio.SoporteServicio;

/**
 * @author Edwin
 *
 */
public class SoporteServicioImpl implements SoporteServicio {

	SoporteRemote ejbSession;
	final String ejbBeanName = "SoporteSession";

	/**
	 * @param servletContext
	 * @throws NamingException
	 * 
	 */
	public SoporteServicioImpl(ServletContext context) throws NamingException {
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
		String lookup = "java:jboss/exported/Logistica1EAR/Logistica1Negocio/SoporteSession!pe.com.viajes.negocio.ejb.SoporteRemote";
		final String ejbRemoto = SoporteRemote.class.getName();
		lookup = "java:jboss/exported/"
				+ context.getInitParameter("appNegocioNameEar") + "/"
				+ context.getInitParameter("appNegocioName") + "/"
				+ ejbBeanName + "!" + ejbRemoto;

		ejbSession = (SoporteRemote) ctx.lookup(lookup);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see pe.com.viajes.web.servicio.SoporteServicio#listarMaestros()
	 */
	@Override
	public List<Maestro> listarMaestros(Integer idEmpresa) throws SQLException {
		return ejbSession.listarMaestros(idEmpresa);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * pe.com.viajes.web.servicio.SoporteServicio#listarHijosMaestro(int)
	 */
	@Override
	public List<Maestro> listarHijosMaestro(int idmaestro, Integer idEmpresa) throws SQLException {
		return ejbSession.listarHijosMaestro(idmaestro, idEmpresa);
	}

	/*
	 * (non-Javadoc)
	 * @see pe.com.viajes.web.servicio.SoporteServicio#consultarMaestro(int)
	 */
	@Override
	public Maestro consultarMaestro(int idmaestro, Integer idEmpresa) throws SQLException {
		return ejbSession.consultarMaestro(idmaestro, idEmpresa);
	}

	@Override
	public Maestro consultarHijoMaestro(Maestro hijo) throws SQLException {
		return ejbSession.consultarHijoMaestro(hijo);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * pe.com.viajes.web.servicio.SoporteServicio#ingresarMaestro(pe.com.
	 * logistica.bean.negocio.Maestro)
	 */
	@Override
	public boolean ingresarMaestro(Maestro maestro) throws SQLException {
		return ejbSession.ingresarMaestro(maestro);

	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * pe.com.viajes.web.servicio.SoporteServicio#ingresarHijoMaestro(pe.
	 * com.logistica.bean.negocio.Maestro)
	 */
	@Override
	public boolean ingresarHijoMaestro(Maestro maestro) throws SQLException {
		return ejbSession.ingresarHijoMaestro(maestro);
	}

	@Override
	public boolean actualizarMaestro(Maestro maestro) throws SQLException {
		return ejbSession.actualizarMaestro(maestro);
	}

	@Override
	public List<BaseVO> listarCatalogoMaestro(int idmaestro, Integer idEmpresa)
			throws SQLException, ConnectionException {
		return ejbSession.listarCatalogoMaestro(idmaestro, idEmpresa);
	}

	@Override
	public List<BaseVO> listarCatalogoDepartamento(Integer idEmpresa) throws SQLException,
			ConnectionException {
		return ejbSession.listarCatalogoDepartamento(idEmpresa);
	}

	@Override
	public List<BaseVO> listarCatalogoProvincia(String idProvincia, Integer idEmpresa)
			throws SQLException, ConnectionException {
		return ejbSession.listarCatalogoProvincia(idProvincia, idEmpresa);
	}

	@Override
	public List<BaseVO> listarCatalogoDistrito(String idDepartamento,
			String idProvincia, Integer idEmpresa) throws SQLException, ConnectionException {
		return ejbSession.listarCatalogoDistrito(idDepartamento, idProvincia, idEmpresa);
	}

	@Override
	public List<BaseVO> listarContinentes(Integer idEmpresa) throws SQLException,
			ConnectionException {
		return ejbSession.listarContinentes(idEmpresa);
	}

	@Override
	public List<BaseVO> consultarPaises(int idcontinente, Integer idEmpresa) throws SQLException,
			Exception {
		return ejbSession.consultarPaisesContinente(idcontinente, idEmpresa);
	}

	@Override
	public boolean ingresarPais(Pais pais) throws SQLException, Exception {
		return ejbSession.ingresarPais(pais);
	}

	@Override
	public boolean ingresarDestino(Destino destino) throws SQLException,
			Exception {
		return ejbSession.ingresarDestino(destino);
	}

	@Override
	public boolean actualizarDestino(Destino destino) throws SQLException,
			Exception {
		return ejbSession.actualizarDestino(destino);
	}

	@Override
	public List<Destino> listarDestinos(Integer idEmpresa) throws SQLException, Exception {
		return ejbSession.listarDestinos(idEmpresa);
	}

	@Override
	public ConfiguracionTipoServicio consultarConfiguracionServicio(
			int convertirCadenaEntero, Integer idEmpresa) {
		try {
			return ejbSession
					.consultarConfiguracionServicio(convertirCadenaEntero, idEmpresa);
		} catch (SQLException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	@Override
	public List<Proveedor> listarComboProveedorTipo(BaseVO proveedor)
			throws SQLException, Exception {

		return ejbSession.listarProveedorTipo(proveedor);
	}

	@Override
	public boolean esDestinoNacional(Integer destino, Integer idEmpresa)
			throws ErrorConsultaDataException, SQLException, Exception {
		return ejbSession.esDestinoNacional(destino, idEmpresa);
	}

	@Override
	public List<ConfiguracionTipoServicio> listarConfiguracionServicios(Integer idEmpresa)
			throws SQLException, Exception {
		return ejbSession.listarConfiguracionServicios(idEmpresa);
	}

	@Override
	public List<BaseVO> listarTiposServicios(Integer idEmpresa) throws SQLException, Exception {
		return ejbSession.listarTipoServicios(idEmpresa);
	}

	@Override
	public boolean guardarConfiguracionServicio(
			List<ConfiguracionTipoServicio> listaConfigServicios)
			throws SQLException, Exception {
		return ejbSession.guardarConfiguracionServicio(listaConfigServicios);
	}

	@Override
	public List<Destino> consultarOrigen(String descripcion, Integer idEmpresa)
			throws SQLException, Exception {
		return ejbSession.buscarDestinos(descripcion, idEmpresa);
	}

	@Override
	public List<Destino> consultarDestino(String descripcion, Integer idEmpresa)
			throws SQLException, Exception {
		return ejbSession.buscarDestinos(descripcion, idEmpresa);
	}

	@Override
	public Destino consultaDestinoIATA(String codigoIATA, Integer idEmpresa) throws SQLException {
		return ejbSession.consultaDestinoIATA(codigoIATA, idEmpresa);
	}

}
