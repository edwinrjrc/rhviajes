/**
 * 
 */
package pe.com.viajes.bean.negocio;

import java.util.Date;

/**
 * @author Edwin
 *
 */
public class ServicioAgenciaBusqueda extends ServicioAgencia {
	/**
	 * 
	 */
	private static final long serialVersionUID = 5186626095915043758L;

	private Date fechaDesde;
	private Date fechaHasta;

	/**
	 * 
	 */
	public ServicioAgenciaBusqueda() {
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
