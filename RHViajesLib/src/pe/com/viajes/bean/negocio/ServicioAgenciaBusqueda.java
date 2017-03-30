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
	
	private boolean ventaAnulada;

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

	/**
	 * @return the ventaAnulada
	 */
	public boolean isVentaAnulada() {
		return ventaAnulada;
	}

	/**
	 * @param ventaAnulada the ventaAnulada to set
	 */
	public void setVentaAnulada(boolean ventaAnulada) {
		this.ventaAnulada = ventaAnulada;
	}

}
