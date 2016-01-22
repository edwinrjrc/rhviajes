package pe.com.viajes.bean.negocio;

import java.math.BigDecimal;

import pe.com.viajes.bean.base.BaseNegocio;

/**
 * @author Edwin
 * @version 1.0
 * @created 14-dic-2013 01:20:04 p.m.
 */
public class Articulo extends BaseNegocio {

	/**
	 * 
	 */
	private static final long serialVersionUID = 5644766884731949201L;
	private Integer cantidad;
	private String descripcion;
	private String nombre;
	private BigDecimal precioUnitario;
	private int stock;

	public Articulo() {

	}

	public void finalize() throws Throwable {
		super.finalize();
	}

	/**
	 * @return the cantidad
	 */
	public Integer getCantidad() {
		return cantidad;
	}

	/**
	 * @param cantidad
	 *            the cantidad to set
	 */
	public void setCantidad(Integer cantidad) {
		this.cantidad = cantidad;
	}

	/**
	 * @return the descripcion
	 */
	public String getDescripcion() {
		return descripcion;
	}

	/**
	 * @param descripcion
	 *            the descripcion to set
	 */
	public void setDescripcion(String descripcion) {
		this.descripcion = descripcion;
	}

	/**
	 * @return the nombre
	 */
	public String getNombre() {
		return nombre;
	}

	/**
	 * @param nombre
	 *            the nombre to set
	 */
	public void setNombre(String nombre) {
		this.nombre = nombre;
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
	 * @return the stock
	 */
	public int getStock() {
		return stock;
	}

	/**
	 * @param stock
	 *            the stock to set
	 */
	public void setStock(int stock) {
		this.stock = stock;
	}

}