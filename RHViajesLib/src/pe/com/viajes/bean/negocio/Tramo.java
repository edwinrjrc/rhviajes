/**
 * 
 */
package pe.com.viajes.bean.negocio;

import java.math.BigDecimal;
import java.util.Date;

import pe.com.viajes.bean.base.BaseNegocio;
import pe.com.viajes.bean.base.BaseVO;

/**
 * @author Edwin
 *
 */
public class Tramo extends BaseNegocio {

	/**
	 * 
	 */
	private static final long serialVersionUID = 6761433969306849962L;

	private Destino origen;
	private Date fechaSalida;
	private Destino destino;
	private Date fechaLlegada;
	private BigDecimal precio;
	private BaseVO aerolinea;

	/**
	 * @return the origen
	 */
	public Destino getOrigen() {
		if (origen == null) {
			origen = new Destino();
		}
		return origen;
	}

	/**
	 * @param origen
	 *            the origen to set
	 */
	public void setOrigen(Destino origen) {
		this.origen = origen;
	}

	/**
	 * @return the fechaSalida
	 */
	public Date getFechaSalida() {
		return fechaSalida;
	}

	/**
	 * @param fechaSalida
	 *            the fechaSalida to set
	 */
	public void setFechaSalida(Date fechaSalida) {
		this.fechaSalida = fechaSalida;
	}

	/**
	 * @return the destino
	 */
	public Destino getDestino() {
		if (destino == null) {
			destino = new Destino();
		}
		return destino;
	}

	/**
	 * @param destino
	 *            the destino to set
	 */
	public void setDestino(Destino destino) {
		this.destino = destino;
	}

	/**
	 * @return the fechaLlegada
	 */
	public Date getFechaLlegada() {
		return fechaLlegada;
	}

	/**
	 * @param fechaLlegada
	 *            the fechaLlegada to set
	 */
	public void setFechaLlegada(Date fechaLlegada) {
		this.fechaLlegada = fechaLlegada;
	}

	/**
	 * @return the precio
	 */
	public BigDecimal getPrecio() {
		return precio;
	}

	/**
	 * @param precio
	 *            the precio to set
	 */
	public void setPrecio(BigDecimal precio) {
		this.precio = precio;
	}

	/**
	 * @return the aerolinea
	 */
	public BaseVO getAerolinea() {
		if (aerolinea == null) {
			aerolinea = new BaseVO();
		}
		return aerolinea;
	}

	/**
	 * @param aerolinea
	 *            the aerolinea to set
	 */
	public void setAerolinea(BaseVO aerolinea) {
		this.aerolinea = aerolinea;
	}

}
