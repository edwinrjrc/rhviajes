/**
 * 
 */
package pe.com.viajes.bean.negocio;

import java.util.ArrayList;
import java.util.List;

import pe.com.viajes.bean.base.BaseNegocio;

/**
 * @author Edwin
 *
 */
public class Ruta extends BaseNegocio {
	/**
	 * 
	 */
	private static final long serialVersionUID = 7358273367993273258L;

	private List<Tramo> tramos;
	private String descripcionRuta;
	private Tramo tramo;

	/**
	 * @return the tramos
	 */
	public List<Tramo> getTramos() {
		if (tramos == null) {
			tramos = new ArrayList<Tramo>();
		}
		return tramos;
	}

	/**
	 * @param tramos
	 *            the tramos to set
	 */
	public void setTramos(List<Tramo> tramos) {
		this.tramos = tramos;
	}

	/**
	 * @return the tramo
	 */
	public Tramo getTramo() {
		if (tramo == null) {
			tramo = new Tramo();
		}
		return tramo;
	}

	/**
	 * @param tramo
	 *            the tramo to set
	 */
	public void setTramo(Tramo tramo) {
		this.tramo = tramo;
	}

	/**
	 * @return the descripcionRuta
	 */
	public String getDescripcionRuta() {
		return descripcionRuta;
	}

	/**
	 * @param descripcionRuta
	 *            the descripcionRuta to set
	 */
	public void setDescripcionRuta(String descripcionRuta) {
		this.descripcionRuta = descripcionRuta;
	}

}
