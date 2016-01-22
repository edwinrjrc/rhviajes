/**
 * 
 */
package pe.com.viajes.bean.jasper;

import pe.com.viajes.bean.base.Base;

/**
 * @author Edwin
 *
 */
public class DetalleServicio extends Base {

	private static final long serialVersionUID = -6680735799955362882L;

	private String cantidad;
	private String fechaIda;
	private String descripcionServicio;
	private String precioUnitario;
	private String total;

	/**
	 * @return the cantidad
	 */
	public String getCantidad() {
		return cantidad;
	}

	/**
	 * @param cantidad
	 *            the cantidad to set
	 */
	public void setCantidad(String cantidad) {
		this.cantidad = cantidad;
	}

	/**
	 * @return the fechaIda
	 */
	public String getFechaIda() {
		return fechaIda;
	}

	/**
	 * @param fechaIda
	 *            the fechaIda to set
	 */
	public void setFechaIda(String fechaIda) {
		this.fechaIda = fechaIda;
	}

	/**
	 * @return the descripcionServicio
	 */
	public String getDescripcionServicio() {
		return descripcionServicio;
	}

	/**
	 * @param descripcionServicio
	 *            the descripcionServicio to set
	 */
	public void setDescripcionServicio(String descripcionServicio) {
		this.descripcionServicio = descripcionServicio;
	}

	/**
	 * @return the precioUnitario
	 */
	public String getPrecioUnitario() {
		return precioUnitario;
	}

	/**
	 * @param precioUnitario
	 *            the precioUnitario to set
	 */
	public void setPrecioUnitario(String precioUnitario) {
		this.precioUnitario = precioUnitario;
	}

	/**
	 * @return the total
	 */
	public String getTotal() {
		return total;
	}

	/**
	 * @param total
	 *            the total to set
	 */
	public void setTotal(String total) {
		this.total = total;
	}

}
