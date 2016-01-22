/**
 * 
 */
package pe.com.viajes.bean.negocio;

import java.util.Date;

/**
 * @author EDWREB
 *
 */
public class ComprobanteBusqueda extends Comprobante {
	/**
	 * 
	 */
	private static final long serialVersionUID = 3078905319575486174L;

	private Date fechaDesde;
	private Date fechaHasta;

	/**
	 * 
	 */
	public ComprobanteBusqueda() {
		// TODO Auto-generated constructor stub
	}

	/**
	 * @return the fechaDesde
	 */
	public Date getFechaDesde() {
		return fechaDesde;
	}

	/**
	 * @param fechaDesde
	 *            the fechaDesde to set
	 */
	public void setFechaDesde(Date fechaDesde) {
		this.fechaDesde = fechaDesde;
	}

	/**
	 * @return the fechaHasta
	 */
	public Date getFechaHasta() {
		return fechaHasta;
	}

	/**
	 * @param fechaHasta
	 *            the fechaHasta to set
	 */
	public void setFechaHasta(Date fechaHasta) {
		this.fechaHasta = fechaHasta;
	}

}
