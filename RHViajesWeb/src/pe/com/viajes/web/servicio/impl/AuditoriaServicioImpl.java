/**
 * 
 */
package pe.com.viajes.web.servicio.impl;

import java.util.Date;
import java.util.List;
import java.util.Properties;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.ServletContext;

import pe.com.viajes.bean.recursoshumanos.UsuarioAsistencia;
import pe.com.viajes.negocio.ejb.AuditoriaSessionRemote;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;
import pe.com.viajes.web.servicio.AuditoriaServicio;

/**
 * @author EDWREB
 *
 */
public class AuditoriaServicioImpl implements AuditoriaServicio {

	AuditoriaSessionRemote ejbSession;

	final String ejbBeanName = "AuditoriaSession";

	public AuditoriaServicioImpl(ServletContext context) throws NamingException {
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
		String lookup = "java:jboss/exported/Logistica1EAR/Logistica1Negocio/AuditoriaSession!pe.com.viajes.negocio.ejb.AuditoriaSessionRemote";

		final String ejbRemoto = AuditoriaSessionRemote.class.getName();
		lookup = "java:jboss/exported/"
				+ context.getInitParameter("appNegocioNameEar") + "/"
				+ context.getInitParameter("appNegocioName") + "/"
				+ ejbBeanName + "!" + ejbRemoto;

		ejbSession = (AuditoriaSessionRemote) ctx.lookup(lookup);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see pe.com.viajes.web.servicio.AuditoriaServicio#
	 * consultarHorarioAsistenciaXDia()
	 */
	@Override
	public List<UsuarioAsistencia> consultarHorarioAsistenciaXDia(Date fecha, int idEmpresa)
			throws ErrorConsultaDataException {

		return ejbSession.consultaHorariosEntrada(fecha, idEmpresa);
	}

}
