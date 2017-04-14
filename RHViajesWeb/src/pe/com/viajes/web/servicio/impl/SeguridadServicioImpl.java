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
import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.negocio.ejb.SeguridadRemote;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;
import pe.com.viajes.negocio.exception.ErrorEncriptacionException;
import pe.com.viajes.negocio.exception.ErrorRegistroDataException;
import pe.com.viajes.negocio.exception.InicioSesionException;
import pe.com.viajes.web.servicio.SeguridadServicio;

/**
 * @author Edwin
 *
 */
public class SeguridadServicioImpl implements SeguridadServicio {

	SeguridadRemote ejbSession;
	final String ejbBeanName = "SeguridadSession";

	/**
	 * @param servletContext
	 * @throws NamingException
	 * 
	 */
	public SeguridadServicioImpl(ServletContext context) throws NamingException {
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
		String lookup = "java:jboss/exported/Logistica1EAR/Logistica1Negocio/SeguridadSession!pe.com.viajes.negocio.ejb.SeguridadRemote";

		final String ejbRemoto = SeguridadRemote.class.getName();
		lookup = "java:jboss/exported/"
				+ context.getInitParameter("appNegocioNameEar") + "/"
				+ context.getInitParameter("appNegocioName") + "/"
				+ ejbBeanName + "!" + ejbRemoto;
		ejbSession = (SeguridadRemote) ctx.lookup(lookup);

	}

	@Override
	public boolean registrarUsuario(Usuario usuario) throws SQLException,
			ErrorEncriptacionException, ErrorRegistroDataException {
		return ejbSession.registrarUsuario(usuario);
	}

	@Override
	public List<Usuario> listarUsuarios(Integer idEmpresa) throws ErrorConsultaDataException {
		return ejbSession.listarUsuarios(idEmpresa);
	}

	@Override
	public List<BaseVO> listarRoles(Integer idEmpresa) throws ErrorConsultaDataException {
		return ejbSession.listarRoles(idEmpresa);
	}

	@Override
	public Usuario consultarUsuario(int id, Integer idEmpresa) throws ErrorConsultaDataException  {
		return ejbSession.consultarUsuario(id, idEmpresa);
	}

	@Override
	public boolean actualizarUsuario(Usuario usuario) throws ErrorEncriptacionException, ErrorRegistroDataException {
		return ejbSession.actualizarUsuario(usuario);
	}

	@Override
	public Usuario inicioSesion(Usuario usuario) throws InicioSesionException {
		return ejbSession.inicioSesion(usuario);
	}

	@Override
	public boolean cambiarClaveUsuario(Usuario usuario) throws SQLException,
			Exception {
		return ejbSession.cambiarClaveUsuario(usuario);
	}

	@Override
	public boolean actualizarClaveUsuario(Usuario usuario) throws SQLException,
			Exception {
		return ejbSession.actualizarClaveUsuario(usuario);
	}

	@Override
	public List<Usuario> listarVendedores(Integer idEmpresa) throws ErrorConsultaDataException {
		return ejbSession.listarVendedores(idEmpresa);
	}

	@Override
	public boolean actualizarCredencialVencida(Usuario usuario)
			throws SQLException, Exception {
		return ejbSession.actualizarCredencialVencida(usuario);
	}
	
	@Override
	public boolean validarAgregarUsuario(int idEmpresa) throws ErrorConsultaDataException{
		return ejbSession.validaAgregarUsuario(idEmpresa);
	}
}
