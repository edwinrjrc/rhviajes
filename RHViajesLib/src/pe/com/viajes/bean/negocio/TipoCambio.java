/**
 * 
 */
package pe.com.viajes.bean.negocio;

import java.math.BigDecimal;
import java.util.Date;

import pe.com.viajes.bean.base.BaseNegocio;
import pe.com.viajes.bean.base.BaseVO;

/**
 * @author EDWREB
 *
 */
public class TipoCambio extends BaseNegocio {

	private static final long serialVersionUID = 2005247919865347800L;

	private BaseVO monedaOrigen;
	private BaseVO monedaDestino;
	private Date fechaTipoCambio;
	private BigDecimal montoCambio;

	/**
	 * @return the monedaOrigen
	 */
	public BaseVO getMonedaOrigen() {
		if (monedaOrigen == null) {
			monedaOrigen = new BaseVO();
		}
		return monedaOrigen;
	}

	/**
	 * @param monedaOrigen
	 *            the monedaOrigen to set
	 */
	public void setMonedaOrigen(BaseVO monedaOrigen) {
		this.monedaOrigen = monedaOrigen;
	}

	/**
	 * @return the monedaDestino
	 */
	public BaseVO getMonedaDestino() {
		if (monedaDestino == null) {
			monedaDestino = new BaseVO();
		}
		return monedaDestino;
	}

	/**
	 * @param monedaDestino
	 *            the monedaDestino to set
	 */
	public void setMonedaDestino(BaseVO monedaDestino) {
		this.monedaDestino = monedaDestino;
	}

	/**
	 * @return the fechaTipoCambio
	 */
	public Date getFechaTipoCambio() {
		return fechaTipoCambio;
	}

	/**
	 * @param fechaTipoCambio
	 *            the fechaTipoCambio to set
	 */
	public void setFechaTipoCambio(Date fechaTipoCambio) {
		this.fechaTipoCambio = fechaTipoCambio;
	}

	/**
	 * @return the montoCambio
	 */
	public BigDecimal getMontoCambio() {
		return montoCambio;
	}

	/**
	 * @param montoCambio
	 *            the montoCambio to set
	 */
	public void setMontoCambio(BigDecimal montoCambio) {
		this.montoCambio = montoCambio;
	}

}
