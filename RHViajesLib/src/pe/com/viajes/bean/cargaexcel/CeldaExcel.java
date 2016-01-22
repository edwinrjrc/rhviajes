/**
 * 
 */
package pe.com.viajes.bean.cargaexcel;

import java.math.BigDecimal;
import java.math.BigInteger;

import pe.com.viajes.bean.base.Base;

/**
 * @author EDWREB
 *
 */
public class CeldaExcel extends Base {
	/**
	 * 
	 */
	private static final long serialVersionUID = -4363013104202632368L;

	private String nombreColumna;
	private String valorCadena;
	private BigDecimal valorDecimal;
	private BigInteger valorEntero;
	private boolean mostrar;

	/**
	 * @return the nombreColumna
	 */
	public String getNombreColumna() {
		return nombreColumna;
	}

	/**
	 * @param nombreColumna
	 *            the nombreColumna to set
	 */
	public void setNombreColumna(String nombreColumna) {
		this.nombreColumna = nombreColumna;
	}

	/**
	 * @return the valorCadena
	 */
	public String getValorCadena() {
		return valorCadena;
	}

	/**
	 * @param valorCadena
	 *            the valorCadena to set
	 */
	public void setValorCadena(String valorCadena) {
		this.valorCadena = valorCadena;
	}

	/**
	 * @return the valorDecimal
	 */
	public BigDecimal getValorDecimal() {
		return valorDecimal;
	}

	/**
	 * @param valorDecimal
	 *            the valorDecimal to set
	 */
	public void setValorDecimal(BigDecimal valorDecimal) {
		this.valorDecimal = valorDecimal;
	}

	/**
	 * @return the valorEntero
	 */
	public BigInteger getValorEntero() {
		return valorEntero;
	}

	/**
	 * @param valorEntero
	 *            the valorEntero to set
	 */
	public void setValorEntero(BigInteger valorEntero) {
		this.valorEntero = valorEntero;
	}

	/**
	 * @return the mostrar
	 */
	public boolean isMostrar() {
		// mostrar = (StringUtils.isNotBlank(valorCadena) || (valorDecimal !=
		// null) || (valorEntero != null));
		return mostrar;
	}

	/**
	 * @param mostrar
	 *            the mostrar to set
	 */
	public void setMostrar(boolean mostrar) {
		this.mostrar = mostrar;
	}

}
