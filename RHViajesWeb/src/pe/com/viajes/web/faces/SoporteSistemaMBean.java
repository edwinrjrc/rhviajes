/**
 * 
 */
package pe.com.viajes.web.faces;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

import pe.com.viajes.bean.administracion.SentenciaSQL;

/**
 * @author Edwin
 *
 */
@ManagedBean(name = "soporteSistemaMBean")
@SessionScoped()
public class SoporteSistemaMBean extends BaseMBean {

	private static final long serialVersionUID = 31300859656846100L;

	private SentenciaSQL sentenciaSQL;
	
	public SoporteSistemaMBean() {
		// TODO Auto-generated constructor stub
	}
	
	public void ejecutarSentencia(){
		
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
	
	

}
