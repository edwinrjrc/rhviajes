package pe.com.viajes.bean.negocio;

import java.math.BigDecimal;

import pe.com.viajes.bean.base.BaseNegocio;
import pe.com.viajes.bean.base.BaseVO;

/**
 * @author Edwin
 * @version 1.0
 * @created 14-dic-2013 01:14:34 p.m.
 */
public class CuentaBancaria extends BaseNegocio {

	/**
	 * 
	 */
	private static final long serialVersionUID = -8231091082712340586L;
	private BaseVO banco;
	private String numeroCuenta;
	private BaseVO tipoCuenta;
	private int prioridad;
	private String nombreCuenta;
	private BaseVO moneda;
	private BigDecimal saldo;
	private boolean editable;
	private int numeroMovimientos;

	public CuentaBancaria() {

	}

	/**
	 * @return the banco
	 */
	public BaseVO getBanco() {
		if (banco == null) {
			banco = new BaseVO();
		}
		return banco;
	}

	/**
	 * @param banco
	 *            the banco to set
	 */
	public void setBanco(BaseVO banco) {
		this.banco = banco;
	}

	/**
	 * @return the numeroCuenta
	 */
	public String getNumeroCuenta() {
		return numeroCuenta;
	}

	/**
	 * @param numeroCuenta
	 *            the numeroCuenta to set
	 */
	public void setNumeroCuenta(String numeroCuenta) {
		this.numeroCuenta = numeroCuenta;
	}

	/**
	 * @return the prioridad
	 */
	public int getPrioridad() {
		return prioridad;
	}

	/**
	 * @param prioridad
	 *            the prioridad to set
	 */
	public void setPrioridad(int prioridad) {
		this.prioridad = prioridad;
	}

	/**
	 * @return the nombreCuenta
	 */
	public String getNombreCuenta() {
		return nombreCuenta;
	}

	/**
	 * @param nombreCuenta
	 *            the nombreCuenta to set
	 */
	public void setNombreCuenta(String nombreCuenta) {
		this.nombreCuenta = nombreCuenta;
	}

	/**
	 * @return the saldo
	 */
	public BigDecimal getSaldo() {
		return saldo;
	}

	/**
	 * @param saldo
	 *            the saldo to set
	 */
	public void setSaldo(BigDecimal saldo) {
		this.saldo = saldo;
	}

	/**
	 * @return the tipoCuenta
	 */
	public BaseVO getTipoCuenta() {
		if (tipoCuenta == null) {
			tipoCuenta = new BaseVO();
		}
		return tipoCuenta;
	}

	/**
	 * @param tipoCuenta
	 *            the tipoCuenta to set
	 */
	public void setTipoCuenta(BaseVO tipoCuenta) {
		this.tipoCuenta = tipoCuenta;
	}

	/**
	 * @return the moneda
	 */
	public BaseVO getMoneda() {
		if (moneda == null) {
			moneda = new BaseVO();
		}
		return moneda;
	}

	/**
	 * @param moneda
	 *            the moneda to set
	 */
	public void setMoneda(BaseVO moneda) {
		this.moneda = moneda;
	}

	/**
	 * @return the editable
	 */
	public boolean isEditable() {
		return editable;
	}

	/**
	 * @param editable
	 *            the editable to set
	 */
	public void setEditable(boolean editable) {
		this.editable = editable;
	}

	/**
	 * @return the numeroMovimientos
	 */
	public int getNumeroMovimientos() {
		return numeroMovimientos;
	}

	/**
	 * @param numeroMovimientos
	 *            the numeroMovimientos to set
	 */
	public void setNumeroMovimientos(int numeroMovimientos) {
		this.numeroMovimientos = numeroMovimientos;
	}

}