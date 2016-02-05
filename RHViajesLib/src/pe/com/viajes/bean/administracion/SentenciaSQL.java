/**
 * 
 */
package pe.com.viajes.bean.administracion;

import pe.com.viajes.bean.base.Base;

/**
 * @author EDWREB
 *
 */
public class SentenciaSQL extends Base{

	private static final long serialVersionUID = 241659016511321104L;
	
	private String script;
	private boolean consulta;
	private boolean insercion;
	private boolean actualizacion;
	private boolean eliminacion;
	

	public SentenciaSQL() {
		// TODO Auto-generated constructor stub
	}


	/**
	 * @return the script
	 */
	public String getScript() {
		return script;
	}


	/**
	 * @param script the script to set
	 */
	public void setScript(String script) {
		this.script = script;
	}


	/**
	 * @return the consulta
	 */
	public boolean isConsulta() {
		return consulta;
	}


	/**
	 * @param consulta the consulta to set
	 */
	public void setConsulta(boolean consulta) {
		this.consulta = consulta;
	}


	/**
	 * @return the insercion
	 */
	public boolean isInsercion() {
		return insercion;
	}


	/**
	 * @param insercion the insercion to set
	 */
	public void setInsercion(boolean insercion) {
		this.insercion = insercion;
	}


	/**
	 * @return the actualizacion
	 */
	public boolean isActualizacion() {
		return actualizacion;
	}


	/**
	 * @param actualizacion the actualizacion to set
	 */
	public void setActualizacion(boolean actualizacion) {
		this.actualizacion = actualizacion;
	}


	/**
	 * @return the eliminacion
	 */
	public boolean isEliminacion() {
		return eliminacion;
	}


	/**
	 * @param eliminacion the eliminacion to set
	 */
	public void setEliminacion(boolean eliminacion) {
		this.eliminacion = eliminacion;
	}
}
