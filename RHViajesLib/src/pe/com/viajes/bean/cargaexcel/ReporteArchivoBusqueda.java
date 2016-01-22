/**
 * 
 */
package pe.com.viajes.bean.cargaexcel;

import java.util.Date;

/**
 * @author Edwin
 *
 */
public class ReporteArchivoBusqueda extends ReporteArchivo {

	/**
	 * 
	 */
	private static final long serialVersionUID = 8812065609633987340L;

	private Date fechaDesde;
	private Date fechaHasta;
	private int numeroSeleccionados;

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
	 * @return the numeroSeleccionados
	 */
	public int getNumeroSeleccionados() {
		return numeroSeleccionados;
	}

	/**
	 * @param numeroSeleccionados
	 *            the numeroSeleccionados to set
	 */
	public void setNumeroSeleccionados(int numeroSeleccionados) {
		this.numeroSeleccionados = numeroSeleccionados;
	}

}
