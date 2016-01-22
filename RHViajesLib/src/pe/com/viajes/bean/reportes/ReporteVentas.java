/**
 * 
 */
package pe.com.viajes.bean.reportes;

import java.util.Date;

import pe.com.viajes.bean.base.Base;
import pe.com.viajes.bean.base.BaseVO;

/**
 * @author Edwin
 *
 */
public class ReporteVentas extends Base {

	private Date fechaDesde;
	private Date fechaHasta;
	private BaseVO vendedor;

	/**
	 * 
	 */
	private static final long serialVersionUID = -3961646032519921135L;

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
	 * @return the vendedor
	 */
	public BaseVO getVendedor() {
		if (vendedor == null) {
			vendedor = new BaseVO();
		}
		return vendedor;
	}

	/**
	 * @param vendedor
	 *            the vendedor to set
	 */
	public void setVendedor(BaseVO vendedor) {
		this.vendedor = vendedor;
	}

}
