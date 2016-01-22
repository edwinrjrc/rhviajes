/**
 * 
 */
package pe.com.viajes.bean.negocio;

import java.math.BigDecimal;
import java.util.Date;

import pe.com.viajes.bean.base.BaseNegocio;
import pe.com.viajes.bean.base.BaseVO;

/**
 * @author edwreb
 *
 */
public class CuotaPago extends BaseNegocio {

	private int nroCuota;
	private Date fechaVencimiento;
	private BigDecimal capital;
	private BigDecimal interes;
	private BigDecimal totalCuota;
	private BaseVO estadoCuota;
	/**
	 * 
	 */
	private static final long serialVersionUID = -1557368623620708153L;

	/**
	 * 
	 */
	public CuotaPago() {
		// TODO Auto-generated constructor stub
	}

	/**
	 * @return the nroCuota
	 */
	public int getNroCuota() {
		return nroCuota;
	}

	/**
	 * @param nroCuota
	 *            the nroCuota to set
	 */
	public void setNroCuota(int nroCuota) {
		this.nroCuota = nroCuota;
	}

	/**
	 * @return the fechaVencimiento
	 */
	public Date getFechaVencimiento() {
		return fechaVencimiento;
	}

	/**
	 * @param fechaVencimiento
	 *            the fechaVencimiento to set
	 */
	public void setFechaVencimiento(Date fechaVencimiento) {
		this.fechaVencimiento = fechaVencimiento;
	}

	/**
	 * @return the capital
	 */
	public BigDecimal getCapital() {
		return capital;
	}

	/**
	 * @param capital
	 *            the capital to set
	 */
	public void setCapital(BigDecimal capital) {
		this.capital = capital;
	}

	/**
	 * @return the interes
	 */
	public BigDecimal getInteres() {
		return interes;
	}

	/**
	 * @param interes
	 *            the interes to set
	 */
	public void setInteres(BigDecimal interes) {
		this.interes = interes;
	}

	/**
	 * @return the totalCuota
	 */
	public BigDecimal getTotalCuota() {
		return totalCuota;
	}

	/**
	 * @param totalCuota
	 *            the totalCuota to set
	 */
	public void setTotalCuota(BigDecimal totalCuota) {
		this.totalCuota = totalCuota;
	}

	/**
	 * @return the estadoCuota
	 */
	public BaseVO getEstadoCuota() {
		if (estadoCuota == null) {
			estadoCuota = new BaseVO();
		}
		return estadoCuota;
	}

	/**
	 * @param estadoCuota
	 *            the estadoCuota to set
	 */
	public void setEstadoCuota(BaseVO estadoCuota) {
		this.estadoCuota = estadoCuota;
	}

}
