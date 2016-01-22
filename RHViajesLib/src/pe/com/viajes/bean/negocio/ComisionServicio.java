/**
 * 
 */
package pe.com.viajes.bean.negocio;

import java.math.BigDecimal;

import pe.com.viajes.bean.base.BaseNegocio;
import pe.com.viajes.bean.base.BaseVO;

/**
 * @author Edwin
 *
 */
public class ComisionServicio extends BaseNegocio {

	private static final long serialVersionUID = -8111558983068749362L;
	
	private BigDecimal valorComision;
	private BaseVO tipoComision;
	private boolean aplicaIGV;
	private boolean montoConIGV;
	
	private BigDecimal valorComisionSinIGV;
	private BigDecimal valorIGVComision;
	private BigDecimal montoTotal;

	public ComisionServicio() {
		// TODO Auto-generated constructor stub
	}

	/**
	 * @return the valorComision
	 */
	public BigDecimal getValorComision() {
		return valorComision;
	}

	/**
	 * @param valorComision the valorComision to set
	 */
	public void setValorComision(BigDecimal valorComision) {
		this.valorComision = valorComision;
	}

	/**
	 * @return the tipoComision
	 */
	public BaseVO getTipoComision() {
		if(tipoComision == null){
			tipoComision = new BaseVO();
		}
		return tipoComision;
	}

	/**
	 * @param tipoComision the tipoComision to set
	 */
	public void setTipoComision(BaseVO tipoComision) {
		this.tipoComision = tipoComision;
	}

	/**
	 * @return the aplicaIGV
	 */
	public boolean isAplicaIGV() {
		return aplicaIGV;
	}

	/**
	 * @param aplicaIGV the aplicaIGV to set
	 */
	public void setAplicaIGV(boolean aplicaIGV) {
		this.aplicaIGV = aplicaIGV;
	}

	/**
	 * @return the montoConIGV
	 */
	public boolean isMontoConIGV() {
		return montoConIGV;
	}

	/**
	 * @param montoConIGV the montoConIGV to set
	 */
	public void setMontoConIGV(boolean montoConIGV) {
		this.montoConIGV = montoConIGV;
	}

	/**
	 * @return the valorComisionSinIGV
	 */
	public BigDecimal getValorComisionSinIGV() {
		return valorComisionSinIGV;
	}

	/**
	 * @param valorComisionSinIGV the valorComisionSinIGV to set
	 */
	public void setValorComisionSinIGV(BigDecimal valorComisionSinIGV) {
		this.valorComisionSinIGV = valorComisionSinIGV;
	}

	/**
	 * @return the valorIGVComision
	 */
	public BigDecimal getValorIGVComision() {
		return valorIGVComision;
	}

	/**
	 * @param valorIGVComision the valorIGVComision to set
	 */
	public void setValorIGVComision(BigDecimal valorIGVComision) {
		this.valorIGVComision = valorIGVComision;
	}

	/**
	 * @return the montoTotal
	 */
	public BigDecimal getMontoTotal() {
		return montoTotal;
	}

	/**
	 * @param montoTotal the montoTotal to set
	 */
	public void setMontoTotal(BigDecimal montoTotal) {
		this.montoTotal = montoTotal;
	}

}
