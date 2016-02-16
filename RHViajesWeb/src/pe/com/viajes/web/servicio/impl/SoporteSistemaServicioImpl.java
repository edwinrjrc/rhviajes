/**
 * 
 */
package pe.com.viajes.web.servicio.impl;

import java.util.List;
import java.util.Properties;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.ServletContext;

import pe.com.viajes.bean.administracion.SentenciaSQL;
import pe.com.viajes.bean.licencia.ContratoLicencia;
import pe.com.viajes.bean.licencia.EmpresaAgenciaViajes;
import pe.com.viajes.bean.negocio.Maestro;
import pe.com.viajes.negocio.ejb.SoporteSistemaSessionRemote;
import pe.com.viajes.negocio.exception.EjecucionSQLException;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;
import pe.com.viajes.negocio.exception.ErrorRegistroDataException;
import pe.com.viajes.negocio.exception.RHViajesException;
import pe.com.viajes.web.servicio.SoporteSistemaServicio;

/**
 * @author EDWREB
 *
 */
public class SoporteSistemaServicioImpl implements SoporteSistemaServicio {
	
	SoporteSistemaSessionRemote ejbSession;
	final String ejbBeanName = "SoporteSistemaSession";
	
	public SoporteSistemaServicioImpl(ServletContext context) throws NamingException {
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
		final String ejbRemoto = SoporteSistemaSessionRemote.class.getName();
		lookup = "java:jboss/exported/"
				+ context.getInitParameter("appNegocioNameEar") + "/"
				+ context.getInitParameter("appNegocioName") + "/"
				+ ejbBeanName + "!" + ejbRemoto;

		ejbSession = (SoporteSistemaSessionRemote) ctx.lookup(lookup);
	}

	/* (non-Javadoc)
	 * @see pe.com.viajes.web.servicio.SoporteSistemaServicio#ejecutarSentenciaSQL(pe.com.viajes.bean.administracion.SentenciaSQL)
	 */
	@Override
	public SentenciaSQL ejecutarSentenciaSQL(SentenciaSQL sentenciaSQL)
			throws EjecucionSQLException, RHViajesException {
		try {
			return ejbSession.ejecutarSentenciaSQL(sentenciaSQL);
		} catch (RHViajesException e) {
			throw new RHViajesException(e);
		}
	}

	/*
	 * (non-Javadoc)
	 * @see pe.com.viajes.web.servicio.SoporteSistemaServicio#listarMaestro(int)
	 */
	@Override
	public List<Maestro> listarMaestro(int idMaestro) throws ErrorConsultaDataException, RHViajesException{
		return ejbSession.listarMaestro(idMaestro);
	}
	
	/*
	 * (non-Javadoc)
	 * @see pe.com.viajes.web.servicio.SoporteSistemaServicio#grabarEmpresa(pe.com.viajes.bean.licencia.EmpresaAgenciaViajes)
	 */
	@Override
	public boolean grabarEmpresa(EmpresaAgenciaViajes empresa) throws ErrorRegistroDataException, RHViajesException{
		return ejbSession.grabarEmpresa(empresa);
	}
	
	/*
	 * (non-Javadoc)
	 * @see pe.com.viajes.web.servicio.SoporteSistemaServicio#listarEmpresas()
	 */
	@Override
	public List<EmpresaAgenciaViajes> listarEmpresas() throws ErrorConsultaDataException, RHViajesException{
		return ejbSession.listarEmpresas();
	}
	
	/*
	 * (non-Javadoc)
	 * @see pe.com.viajes.web.servicio.SoporteSistemaServicio#listarContratos()
	 */
	@Override
	public List<ContratoLicencia> listarContratos() throws ErrorConsultaDataException, RHViajesException{
		return ejbSession.listarContratos();
	}
	
	/*
	 * (non-Javadoc)
	 * @see pe.com.viajes.web.servicio.SoporteSistemaServicio#grabarEmpresa(pe.com.viajes.bean.licencia.EmpresaAgenciaViajes)
	 */
	@Override
	public boolean grabarContrato(ContratoLicencia contrato) throws ErrorRegistroDataException, RHViajesException{
		return ejbSession.grabarContrato(contrato);
	}
}
