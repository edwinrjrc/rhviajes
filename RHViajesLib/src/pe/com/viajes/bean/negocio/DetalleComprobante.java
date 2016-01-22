/**
 * 
 */
package pe.com.viajes.bean.negocio;

import java.math.BigDecimal;

import pe.com.viajes.bean.base.BaseNegocio;

/**
 * @author Edwin
 *
 */
public class DetalleComprobante extends BaseNegocio {
	/**
	 * 
	 */
	private static final long serialVersionUID = 4282109616323759962L;

	private Integer idComprobante;
	private int cantidad;
	private String concepto;
	private BigDecimal precioUnitario;
	private BigDecimal totalDetalle;
	private Integer idServicioDetalle;

	private boolean tieneDetraccion;
	private boolean tieneRetencion;

	/**
	 * 
	 */
	public DetalleComprobante() {
		// TODO Auto-generated constructor stub
	}

	/**
	 * @return the idComprobante
	 */
	public Integer getIdComprobante() {
		return idComprobante;
	}

	/**
	 * @param idComprobante
	 *            the idComprobante to set
	 */
	public void setIdComprobante(Integer idComprobante) {
		this.idComprobante = idComprobante;
	}

	/**
	 * @return the cantidad
	 */
	public int getCantidad() {
		return cantidad;
	}

	/**
	 * @param cantidad
	 *            the cantidad to set
	 */
	public void setCantidad(int cantidad) {
		this.cantidad = cantidad;
	}

	/**
	 * @return the concepto
	 */
	public String getConcepto() {
		return concepto;
	}

	/**
	 * @param concepto
	 *            the concepto to set
	 */
	public void setConcepto(String concepto) {
		this.concepto = concepto;
	}

	/**
	 * @return the precioUnitario
	 */
	public BigDecimal getPrecioUnitario() {
		return precioUnitario;
	}

	/**
	 * @param precioUnitario
	 *            the precioUnitario to set
	 */
	public void setPrecioUnitario(BigDecimal precioUnitario) {
		this.precioUnitario = precioUnitario;
	}

	/**
	 * @return the totalDetalle
	 */
	public BigDecimal getTotalDetalle() {
		return totalDetalle;
	}

	/**
	 * @param totalDetalle
	 *            the totalDetalle to set
	 */
	public void setTotalDetalle(BigDecimal totalDetalle) {
		this.totalDetalle = totalDetalle;
	}

	/**
	 * @return the idServicioDetalle
	 */
	public Integer getIdServicioDetalle() {
		return idServicioDetalle;
	}

	/**
	 * @param idServicioDetalle
	 *            the idServicioDetalle to set
	 */
	public void setIdServicioDetalle(Integer idServicioDetalle) {
		this.idServicioDetalle = idServicioDetalle;
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

}
