/**
 * 
 */
package pe.com.viajes.bean.negocio;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import pe.com.viajes.bean.base.BaseNegocio;
import pe.com.viajes.bean.base.BaseVO;

/**
 * @author Edwin
 *
 */
public class Comprobante extends BaseNegocio {
	/**
	 * 
	 */
	private static final long serialVersionUID = -4234081010839284200L;

	private BaseVO tipoComprobante;
	private String numeroComprobante;
	private Cliente titular;
	private Proveedor proveedor;
	private Date fechaComprobante;
	private BaseVO moneda;
	private BigDecimal subTotal;
	private BigDecimal totalIGV;
	private BigDecimal totalComprobante;
	private BigDecimal saldoComprobante;
	private Integer idServicio;

	private Date fechaPago;

	private List<DetalleComprobante> detalleComprobante;
	private String detalleTextoComprobante;
	private Integer codigoSeleccionado;

	private boolean tieneDetraccion;
	private boolean tieneRetencion;

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
	 * @return the titular
	 */
	public Cliente getTitular() {
		if (titular == null) {
			titular = new Cliente();
		}
		return titular;
	}

	/**
	 * @param titular
	 *            the titular to set
	 */
	public void setTitular(Cliente titular) {
		this.titular = titular;
	}

	/**
	 * @return the fechaComprobante
	 */
	public Date getFechaComprobante() {
		return fechaComprobante;
	}

	/**
	 * @param fechaComprobante
	 *            the fechaComprobante to set
	 */
	public void setFechaComprobante(Date fechaComprobante) {
		this.fechaComprobante = fechaComprobante;
	}

	/**
	 * @return the totalIGV
	 */
	public BigDecimal getTotalIGV() {
		return totalIGV;
	}

	/**
	 * @param totalIGV
	 *            the totalIGV to set
	 */
	public void setTotalIGV(BigDecimal totalIGV) {
		this.totalIGV = totalIGV;
	}

	/**
	 * @return the totalComprobante
	 */
	public BigDecimal getTotalComprobante() {
		return totalComprobante;
	}

	/**
	 * @param totalComprobante
	 *            the totalComprobante to set
	 */
	public void setTotalComprobante(BigDecimal totalComprobante) {
		this.totalComprobante = totalComprobante;
	}

	/**
	 * @return the detalleComprobante
	 */
	public List<DetalleComprobante> getDetalleComprobante() {
		if (detalleComprobante == null) {
			detalleComprobante = new ArrayList<DetalleComprobante>();
		}
		return detalleComprobante;
	}

	/**
	 * @param detalleComprobante
	 *            the detalleComprobante to set
	 */
	public void setDetalleComprobante(
			List<DetalleComprobante> detalleComprobante) {
		this.detalleComprobante = detalleComprobante;
	}

	/**
	 * @return the idServicio
	 */
	public Integer getIdServicio() {
		return idServicio;
	}

	/**
	 * @param idServicio
	 *            the idServicio to set
	 */
	public void setIdServicio(Integer idServicio) {
		this.idServicio = idServicio;
	}

	/**
	 * @return the proveedor
	 */
	public Proveedor getProveedor() {
		if (proveedor == null) {
			proveedor = new Proveedor();
		}
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
	 * @return the fechaPago
	 */
	public Date getFechaPago() {
		return fechaPago;
	}

	/**
	 * @param fechaPago
	 *            the fechaPago to set
	 */
	public void setFechaPago(Date fechaPago) {
		this.fechaPago = fechaPago;
	}

	/**
	 * @return the detalleTextoComprobante
	 */
	public String getDetalleTextoComprobante() {
		return detalleTextoComprobante;
	}

	/**
	 * @param detalleTextoComprobante
	 *            the detalleTextoComprobante to set
	 */
	public void setDetalleTextoComprobante(String detalleTextoComprobante) {
		this.detalleTextoComprobante = detalleTextoComprobante;
	}

	/**
	 * @return the codigoSeleccionado
	 */
	public Integer getCodigoSeleccionado() {
		return codigoSeleccionado;
	}

	/**
	 * @param codigoSeleccionado
	 *            the codigoSeleccionado to set
	 */
	public void setCodigoSeleccionado(Integer codigoSeleccionado) {
		this.codigoSeleccionado = codigoSeleccionado;
	}

	/**
	 * @return the tieneDetraccion
	 */
	public boolean isTieneDetraccion() {
		return tieneDetraccion;
	}

	/**
	 * @param tieneDetraccion
	 *            the tieneDetraccion to set
	 */
	public void setTieneDetraccion(boolean tieneDetraccion) {
		this.tieneDetraccion = tieneDetraccion;
	}

	/**
	 * @return the tieneRetencion
	 */
	public boolean isTieneRetencion() {
		return tieneRetencion;
	}

	/**
	 * @param tieneRetencion
	 *            the tieneRetencion to set
	 */
	public void setTieneRetencion(boolean tieneRetencion) {
		this.tieneRetencion = tieneRetencion;
	}

	/**
	 * @return the saldoComprobante
	 */
	public BigDecimal getSaldoComprobante() {
		return saldoComprobante;
	}

	/**
	 * @param saldoComprobante
	 *            the saldoComprobante to set
	 */
	public void setSaldoComprobante(BigDecimal saldoComprobante) {
		this.saldoComprobante = saldoComprobante;
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

	/**
	 * @return the subTotal
	 */
	public BigDecimal getSubTotal() {
		return subTotal;
	}

	/**
	 * @param subTotal the subTotal to set
	 */
	public void setSubTotal(BigDecimal subTotal) {
		this.subTotal = subTotal;
	}

}
