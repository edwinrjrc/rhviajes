/**
 * 
 */
package pe.com.viajes.bean.negocio;

import java.util.Date;

import pe.com.viajes.bean.base.BaseNegocio;

/**
 * @author Edwin
 *
 */
public class CotizacionCabecera extends BaseNegocio {

	private static final long serialVersionUID = -3034655232299139776L;
	
	private Cliente cliente1;
	private Cliente cliente2;
	private Date fechaCotizacion;
	
	
	/**
	 * @return the cliente1
	 */
	public Cliente getCliente1() {
		return cliente1;
	}
	/**
	 * @param cliente1 the cliente1 to set
	 */
	public void setCliente1(Cliente cliente1) {
		this.cliente1 = cliente1;
	}
	/**
	 * @return the cliente2
	 */
	public Cliente getCliente2() {
		return cliente2;
	}
	/**
	 * @param cliente2 the cliente2 to set
	 */
	public void setCliente2(Cliente cliente2) {
		this.cliente2 = cliente2;
	}
	/**
	 * @return the fechaCotizacion
	 */
	public Date getFechaCotizacion() {
		return fechaCotizacion;
	}
	/**
	 * @param fechaCotizacion the fechaCotizacion to set
	 */
	public void setFechaCotizacion(Date fechaCotizacion) {
		this.fechaCotizacion = fechaCotizacion;
	}
	
	
	
}
