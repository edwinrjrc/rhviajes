/**
 * 
 */
package pe.com.viajes.bean.cargaexcel;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import pe.com.viajes.bean.base.BaseNegocio;
import pe.com.viajes.bean.base.BaseVO;

/**
 * @author Edwin
 *
 */
public class ReporteArchivo extends BaseNegocio {

	private static final long serialVersionUID = 4535753868757301213L;

	private String nombreArchivo;
	private String nombreReporte;
	private BaseVO proveedor;
	private int numeroColumnas;
	private int numeroFilas;
	private ColumnasExcel cabeceraArchivo;
	private List<ColumnasExcel> dataExcel;
	private BaseVO tipoComprobante;
	private String numeroComprobante;
	private BaseVO moneda;
	private BigDecimal montoSubtotal;
	private BigDecimal montoIGV;
	private BigDecimal montoTotal;

	
	/**
	 * @return the nombreArchivo
	 */
	public String getNombreArchivo() {
		return nombreArchivo;
	}

	/**
	 * @param nombreArchivo
	 *            the nombreArchivo to set
	 */
	public void setNombreArchivo(String nombreArchivo) {
		this.nombreArchivo = nombreArchivo;
	}

	/**
	 * @return the nombreReporte
	 */
	public String getNombreReporte() {
		return nombreReporte;
	}

	/**
	 * @param nombreReporte
	 *            the nombreReporte to set
	 */
	public void setNombreReporte(String nombreReporte) {
		this.nombreReporte = nombreReporte;
	}

	/**
	 * @return the numeroColumnas
	 */
	public int getNumeroColumnas() {
		return numeroColumnas;
	}

	/**
	 * @param numeroColumnas
	 *            the numeroColumnas to set
	 */
	public void setNumeroColumnas(int numeroColumnas) {
		this.numeroColumnas = numeroColumnas;
	}

	/**
	 * @return the numeroFilas
	 */
	public int getNumeroFilas() {
		return numeroFilas;
	}

	/**
	 * @param numeroFilas
	 *            the numeroFilas to set
	 */
	public void setNumeroFilas(int numeroFilas) {
		this.numeroFilas = numeroFilas;
	}

	/**
	 * @return the dataExcel
	 */
	public List<ColumnasExcel> getDataExcel() {
		if (dataExcel == null) {
			dataExcel = new ArrayList<ColumnasExcel>();
		}
		return dataExcel;
	}

	/**
	 * @param dataExcel
	 *            the dataExcel to set
	 */
	public void setDataExcel(List<ColumnasExcel> dataExcel) {
		this.dataExcel = dataExcel;
	}

	/**
	 * @return the cabeceraArchivo
	 */
	public ColumnasExcel getCabeceraArchivo() {
		if (cabeceraArchivo == null) {
			cabeceraArchivo = new ColumnasExcel();
		}
		return cabeceraArchivo;
	}

	/**
	 * @param cabeceraArchivo
	 *            the cabeceraArchivo to set
	 */
	public void setCabeceraArchivo(ColumnasExcel cabeceraArchivo) {
		this.cabeceraArchivo = cabeceraArchivo;
	}

	/**
	 * @return the proveedor
	 */
	public BaseVO getProveedor() {
		if (proveedor == null) {
			proveedor = new BaseVO();
		}
		return proveedor;
	}

	/**
	 * @param proveedor
	 *            the proveedor to set
	 */
	public void setProveedor(BaseVO proveedor) {
		this.proveedor = proveedor;
	}

	/**
	 * @return the tipoComprobante
	 */
	public BaseVO getTipoComprobante() {
		if (tipoComprobante == null) {
			tipoComprobante = new BaseVO();
		}
		return tipoComprobante;
	}

	/**
	 * @param tipoComprobante
	 *            the tipoComprobante to set
	 */
	public void setTipoComprobante(BaseVO tipoComprobante) {
		this.tipoComprobante = tipoComprobante;
	}

	/**
	 * @return the numeroComprobante
	 */
	public String getNumeroComprobante() {
		return numeroComprobante;
	}

	/**
	 * @param numeroComprobante
	 *            the numeroComprobante to set
	 */
	public void setNumeroComprobante(String numeroComprobante) {
		this.numeroComprobante = numeroComprobante;
	}

	/**
	 * @return the montoSubtotal
	 */
	public BigDecimal getMontoSubtotal() {
		return montoSubtotal;
	}

	/**
	 * @param montoSubtotal the montoSubtotal to set
	 */
	public void setMontoSubtotal(BigDecimal montoSubtotal) {
		this.montoSubtotal = montoSubtotal;
	}

	/**
	 * @return the montoIGV
	 */
	public BigDecimal getMontoIGV() {
		return montoIGV;
	}

	/**
	 * @param montoIGV the montoIGV to set
	 */
	public void setMontoIGV(BigDecimal montoIGV) {
		this.montoIGV = montoIGV;
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

	/**
	 * @return the moneda
	 */
	public BaseVO getMoneda() {
		if (moneda == null){
			moneda = new BaseVO();
		}
		return moneda;
	}

	/**
	 * @param moneda the moneda to set
	 */
	public void setMoneda(BaseVO moneda) {
		this.moneda = moneda;
	}

}
