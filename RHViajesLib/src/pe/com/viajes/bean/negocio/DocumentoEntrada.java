package pe.com.viajes.bean.negocio;

import java.math.BigDecimal;
import java.util.List;

import pe.com.viajes.bean.base.BaseNegocio;
import pe.com.viajes.bean.base.BaseVO;

/**
 * @author Edwin
 * @version 1.0
 * @created 14-dic-2013 01:14:34 p.m.
 */
public class DocumentoEntrada extends BaseNegocio {

	/**
	 * 
	 */
	private static final long serialVersionUID = -6718651294519406863L;
	private List<Articulo> articulos;
	private BigDecimal montoIgv;
	private String numeroDocumento;
	private Proveedor proveedor;
	private String serieDocumento;
	private BigDecimal subtotal;
	private BaseVO tipoDocumento;
	private BigDecimal totalFacturado;

	public DocumentoEntrada() {

	}

	public void finalize() throws Throwable {
		super.finalize();
	}

	/**
	 * @return the articulos
	 */
	public List<Articulo> getArticulos() {
		return articulos;
	}

	/**
	 * @param articulos
	 *            the articulos to set
	 */
	public void setArticulos(List<Articulo> articulos) {
		this.articulos = articulos;
	}

	/**
	 * @return the montoIgv
	 */
	public BigDecimal getMontoIgv() {
		return montoIgv;
	}

	/**
	 * @param montoIgv
	 *            the montoIgv to set
	 */
	public void setMontoIgv(BigDecimal montoIgv) {
		this.montoIgv = montoIgv;
	}

	/**
	 * @return the numeroDocumento
	 */
	public String getNumeroDocumento() {
		return numeroDocumento;
	}

	/**
	 * @param numeroDocumento
	 *            the numeroDocumento to set
	 */
	public void setNumeroDocumento(String numeroDocumento) {
		this.numeroDocumento = numeroDocumento;
	}

	/**
	 * @return the proveedor
	 */
	public Proveedor getProveedor() {
		return proveedor;
	}

	/**
	 * @param proveedor
	 *            the proveedor to set
	 */
	public void setProveedor(Proveedor proveedor) {
		this.proveedor = proveedor;
	}

	/**
	 * @return the serieDocumento
	 */
	public String getSerieDocumento() {
		return serieDocumento;
	}

	/**
	 * @param serieDocumento
	 *            the serieDocumento to set
	 */
	public void setSerieDocumento(String serieDocumento) {
		this.serieDocumento = serieDocumento;
	}

	/**
	 * @return the subtotal
	 */
	public BigDecimal getSubtotal() {
		return subtotal;
	}

	/**
	 * @param subtotal
	 *            the subtotal to set
	 */
	public void setSubtotal(BigDecimal subtotal) {
		this.subtotal = subtotal;
	}

	/**
	 * @return the tipoDocumento
	 */
	public BaseVO getTipoDocumento() {
		return tipoDocumento;
	}

	/**
	 * @param tipoDocumento
	 *            the tipoDocumento to set
	 */
	public void setTipoDocumento(BaseVO tipoDocumento) {
		this.tipoDocumento = tipoDocumento;
	}

	/**
	 * @return the totalFacturado
	 */
	public BigDecimal getTotalFacturado() {
		return totalFacturado;
	}

	/**
	 * @param totalFacturado
	 *            the totalFacturado to set
	 */
	public void setTotalFacturado(BigDecimal totalFacturado) {
		this.totalFacturado = totalFacturado;
	}

}