/**
 * 
 */
package pe.com.viajes.bean.negocio;

import java.math.BigDecimal;

import pe.com.viajes.bean.base.BaseNegocio;
import pe.com.viajes.bean.base.BaseVO;

/**
 * @author EDWREB
 *
 */
public class MovimientoCuenta extends BaseNegocio {

	private static final long serialVersionUID = -7249637986117829167L;

	private Integer idCuenta;
	private BaseVO tipoMovimiento;
	private BaseVO transaccion;
	private String descripcionMovimiento;
	private BigDecimal importeMovimiento;
	private BaseVO autorizador;
	private Integer idMovimientoPadre;

	/**
	 * @return the idCuenta
	 */
	public Integer getIdCuenta() {
		return idCuenta;
	}

	/**
	 * @param idCuenta
	 *            the idCuenta to set
	 */
	public void setIdCuenta(Integer idCuenta) {
		this.idCuenta = idCuenta;
	}

	/**
	 * @return the tipoMovimiento
	 */
	public BaseVO getTipoMovimiento() {
		return tipoMovimiento;
	}

	/**
	 * @param tipoMovimiento
	 *            the tipoMovimiento to set
	 */
	public void setTipoMovimiento(BaseVO tipoMovimiento) {
		this.tipoMovimiento = tipoMovimiento;
	}

	/**
	 * @return the transaccion
	 */
	public BaseVO getTransaccion() {
		return transaccion;
	}

	/**
	 * @param transaccion
	 *            the transaccion to set
	 */
	public void setTransaccion(BaseVO transaccion) {
		this.transaccion = transaccion;
	}

	/**
	 * @return the descripcionMovimiento
	 */
	public String getDescripcionMovimiento() {
		return descripcionMovimiento;
	}

	/**
	 * @param descripcionMovimiento
	 *            the descripcionMovimiento to set
	 */
	public void setDescripcionMovimiento(String descripcionMovimiento) {
		this.descripcionMovimiento = descripcionMovimiento;
	}

	/**
	 * @return the importeMovimiento
	 */
	public BigDecimal getImporteMovimiento() {
		return importeMovimiento;
	}

	/**
	 * @param importeMovimiento
	 *            the importeMovimiento to set
	 */
	public void setImporteMovimiento(BigDecimal importeMovimiento) {
		this.importeMovimiento = importeMovimiento;
	}

	/**
	 * @return the autorizador
	 */
	public BaseVO getAutorizador() {
		return autorizador;
	}

	/**
	 * @param autorizador
	 *            the autorizador to set
	 */
	public void setAutorizador(BaseVO autorizador) {
		this.autorizador = autorizador;
	}

	/**
	 * @return the idMovimientoPadre
	 */
	public Integer getIdMovimientoPadre() {
		return idMovimientoPadre;
	}

	/**
	 * @param idMovimientoPadre
	 *            the idMovimientoPadre to set
	 */
	public void setIdMovimientoPadre(Integer idMovimientoPadre) {
		this.idMovimientoPadre = idMovimientoPadre;
	}

}
