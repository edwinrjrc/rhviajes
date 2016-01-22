/**
 * 
 */
package pe.com.viajes.bean.negocio;

import pe.com.viajes.bean.base.BaseNegocio;
import pe.com.viajes.bean.base.BaseVO;

/**
 * @author Edwin
 *
 */
public class Pais extends BaseNegocio {

	/**
	 * 
	 */
	private static final long serialVersionUID = -6012716621802519026L;

	private String descripcion;
	private BaseVO continente;
	private String abreviado;

	/**
	 * 
	 */
	public Pais() {
		// TODO Auto-generated constructor stub
	}

	/**
	 * @return the continente
	 */
	public BaseVO getContinente() {
		if (continente == null) {
			continente = new BaseVO();
		}
		return continente;
	}

	/**
	 * @param continente
	 *            the continente to set
	 */
	public void setContinente(BaseVO continente) {
		this.continente = continente;
	}

	/**
	 * @return the descripcion
	 */
	public String getDescripcion() {
		return descripcion;
	}

	/**
	 * @param descripcion
	 *            the descripcion to set
	 */
	public void setDescripcion(String descripcion) {
		this.descripcion = descripcion;
	}

	/**
	 * @return the abreviado
	 */
	public String getAbreviado() {
		return abreviado;
	}

	/**
	 * @param abreviado
	 *            the abreviado to set
	 */
	public void setAbreviado(String abreviado) {
		this.abreviado = abreviado;
	}

}
