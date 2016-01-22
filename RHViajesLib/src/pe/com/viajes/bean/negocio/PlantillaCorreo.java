/**
 * 
 */
package pe.com.viajes.bean.negocio;

import pe.com.viajes.bean.base.BaseNegocio;

/**
 * @author Edwin
 *
 */
public class PlantillaCorreo extends BaseNegocio {

	/**
	 * 
	 */
	private static final long serialVersionUID = -567041942387599970L;

	private String nombre;
	private String contenidoPlantilla;

	/**
	 * 
	 */
	public PlantillaCorreo() {
		// TODO Auto-generated constructor stub
	}

	/**
	 * @return the contenidoPlantilla
	 */
	public String getContenidoPlantilla() {
		return contenidoPlantilla;
	}

	/**
	 * @param contenidoPlantilla
	 *            the contenidoPlantilla to set
	 */
	public void setContenidoPlantilla(String contenidoPlantilla) {
		this.contenidoPlantilla = contenidoPlantilla;
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
