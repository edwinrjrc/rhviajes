/**
 * 
 */
package pe.com.viajes.bean.negocio;

import pe.com.viajes.bean.base.BaseNegocio;

/**
 * @author Edwin
 *
 */
public class Consolidador extends BaseNegocio {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1349939527267297369L;

	private String nombre;

	/**
	 * 
	 */
	public Consolidador() {
		// TODO Auto-generated constructor stub
	}

	/**
	 * @return the nombre
	 */
	public String getNombre() {
		return nombre;
	}

	/**
	 * @param nombre
	 *            the nombre to set
	 */
	public void setNombre(String nombre) {
		this.nombre = nombre;
	}

}
