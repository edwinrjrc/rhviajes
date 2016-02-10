/**
 * 
 */
package pe.com.viajes.web.faces;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;
import javax.naming.NamingException;
import javax.servlet.ServletContext;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;

import pe.com.viajes.bean.administracion.SentenciaSQL;
import pe.com.viajes.negocio.exception.EjecucionSQLException;
import pe.com.viajes.negocio.exception.RHViajesException;
import pe.com.viajes.web.servicio.SoporteSistemaServicio;
import pe.com.viajes.web.servicio.impl.SoporteSistemaServicioImpl;

/**
 * @author Edwin
 *
 */
@ManagedBean(name = "soporteSistemaMBean")
@SessionScoped()
public class SoporteSistemaMBean extends BaseMBean {
	private final static Logger logger = Logger.getLogger(SoporteSistemaMBean.class);
	
	private static final long serialVersionUID = 31300859656846100L;

	private SentenciaSQL sentenciaSQL;
	
	private SoporteSistemaServicio soporteSistemaServicio;
	
	private String[] cabeceraResultado;
	private List<Map<String, Object>> listaResultado;
	
	private int tamanioLista;
	
	public SoporteSistemaMBean() {
		try {
			ServletContext servletContext = (ServletContext) FacesContext
					.getCurrentInstance().getExternalContext().getContext();
			soporteSistemaServicio = new SoporteSistemaServicioImpl(servletContext);
		} catch (NamingException e) {
			logger.error(e.getMessage(), e);
		}
	}
	
	public void ejecutarSentencia(){
		try {
			if (StringUtils.isNotBlank(getSentenciaSQL().getScript())){
				this.setSentenciaSQL(soporteSistemaServicio.ejecutarSentenciaSQL(getSentenciaSQL()));
				
				if (this.getSentenciaSQL().isConsulta()){
					this.setCabeceraResultado((String[]) this.getSentenciaSQL().getResultadoConsulta().get("cabecera"));
					this.setListaResultado((List<Map<String, Object>>) this.getSentenciaSQL().getResultadoConsulta().get("data"));
					
					this.setTamanioLista(this.getCabeceraResultado().length);
				}
			}
			else {
				getSentenciaSQL().setMsjeTransaccion("No se ingreso script");
			}
			
		} catch (EjecucionSQLException e) {
			getSentenciaSQL().setResultadoConsulta(null);
			getSentenciaSQL().setMsjeTransaccion(e.getMessage());
			logger.error(e.getMessage(), e);
		} catch (RHViajesException e) {
			getSentenciaSQL().setResultadoConsulta(null);
			getSentenciaSQL().setMsjeTransaccion(e.getMessage());
			logger.error(e.getMessage(), e);
		}
	}

	/**
	 * @return the sentenciaSQL
	 */
	public SentenciaSQL getSentenciaSQL() {
		if (sentenciaSQL == null){
			sentenciaSQL = new SentenciaSQL();
		}
		return sentenciaSQL;
	}

	/**
	 * @param sentenciaSQL the sentenciaSQL to set
	 */
	public void setSentenciaSQL(SentenciaSQL sentenciaSQL) {
		this.sentenciaSQL = sentenciaSQL;
	}

	/**
	 * @return the listaResultado
	 */
	public List<Map<String, Object>> getListaResultado() {
		if (listaResultado == null){
			listaResultado = new ArrayList<Map<String,Object>>();
		}
		return listaResultado;
	}

	/**
	 * @param listaResultado the listaResultado to set
	 */
	public void setListaResultado(List<Map<String, Object>> listaResultado) {
		this.listaResultado = listaResultado;
	}

	/**
	 * @return the tamanioLista
	 */
	public int getTamanioLista() {
		return tamanioLista;
	}

	/**
	 * @param tamanioLista the tamanioLista to set
	 */
	public void setTamanioLista(int tamanioLista) {
		this.tamanioLista = tamanioLista;
	}

	/**
	 * @return the cabeceraResultado
	 */
	public String[] getCabeceraResultado() {
		return cabeceraResultado;
	}

	/**
	 * @param cabeceraResultado the cabeceraResultado to set
	 */
	public void setCabeceraResultado(String[] cabeceraResultado) {
		this.cabeceraResultado = cabeceraResultado;
	}
}
