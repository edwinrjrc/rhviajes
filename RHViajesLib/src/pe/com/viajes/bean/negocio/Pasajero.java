/**
 * 
 */
package pe.com.viajes.bean.negocio;

import java.util.Date;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.base.Persona;

/**
 * @author Edwin
 *
 */
public class Pasajero extends Persona {

	private static final long serialVersionUID = 6162486453816760507L;
	
	private String correoElectronico;
	private String telefono1;
	private String telefono2;
	private String numeroPasajeroFrecuente;
	private BaseVO aerolinea;
	private BaseVO relacion;
	private Integer idServicioDetalle;
	private Integer idServicio;
	
	private Date fechaVctoPasaporte;
	private Date fechaNacimiento;
	private String codigoReserva;
	private String numeroBoleto;
	private BaseVO pais;

	public Pasajero() {
		// TODO Auto-generated constructor stub
	}

	/**
	 * @return the correoElectronico
	 */
	public String getCorreoElectronico() {
		return correoElectronico;
	}


	/**
	 * @param correoElectronico the correoElectronico to set
	 */
	public void setCorreoElectronico(String correoElectronico) {
		this.correoElectronico = correoElectronico;
	}


	/**
	 * @return the telefono1
	 */
	public String getTelefono1() {
		return telefono1;
	}


	/**
	 * @param telefono1 the telefono1 to set
	 */
	public void setTelefono1(String telefono1) {
		this.telefono1 = telefono1;
	}


	/**
	 * @return the telefono2
	 */
	public String getTelefono2() {
		return telefono2;
	}


	/**
	 * @param telefono2 the telefono2 to set
	 */
	public void setTelefono2(String telefono2) {
		this.telefono2 = telefono2;
	}


	/**
	 * @return the numeroPasajeroFrecuente
	 */
	public String getNumeroPasajeroFrecuente() {
		return numeroPasajeroFrecuente;
	}


	/**
	 * @param numeroPasajeroFrecuente the numeroPasajeroFrecuente to set
	 */
	public void setNumeroPasajeroFrecuente(String numeroPasajeroFrecuente) {
		this.numeroPasajeroFrecuente = numeroPasajeroFrecuente;
	}


	/**
	 * @return the relacion
	 */
	public BaseVO getRelacion() {
		if (relacion == null){
			relacion = new BaseVO();
		}
		return relacion;
	}


	/**
	 * @param relacion the relacion to set
	 */
	public void setRelacion(BaseVO relacion) {
		this.relacion = relacion;
	}


	/**
	 * @return the idServicioDetalle
	 */
	public Integer getIdServicioDetalle() {
		return idServicioDetalle;
	}


	/**
	 * @param idServicioDetalle the idServicioDetalle to set
	 */
	public void setIdServicioDetalle(Integer idServicioDetalle) {
		this.idServicioDetalle = idServicioDetalle;
	}


	/**
	 * @return the idServicio
	 */
	public Integer getIdServicio() {
		return idServicio;
	}


	/**
	 * @param idServicio the idServicio to set
	 */
	public void setIdServicio(Integer idServicio) {
		this.idServicio = idServicio;
	}

	/**
	 * @return the aerolinea
	 */
	public BaseVO getAerolinea() {
		if (aerolinea == null){
			aerolinea = new BaseVO();
		}
		return aerolinea;
	}

	/**
	 * @param aerolinea the aerolinea to set
	 */
	public void setAerolinea(BaseVO aerolinea) {
		this.aerolinea = aerolinea;
	}

	/**
	 * @return the fechaVctoPasaporte
	 */
	public Date getFechaVctoPasaporte() {
		return fechaVctoPasaporte;
	}

	/**
	 * @param fechaVctoPasaporte the fechaVctoPasaporte to set
	 */
	public void setFechaVctoPasaporte(Date fechaVctoPasaporte) {
		this.fechaVctoPasaporte = fechaVctoPasaporte;
	}

	/**
	 * @return the fechaNacimiento
	 */
	public Date getFechaNacimiento() {
		return fechaNacimiento;
	}

	/**
	 * @param fechaNacimiento the fechaNacimiento to set
	 */
	public void setFechaNacimiento(Date fechaNacimiento) {
		this.fechaNacimiento = fechaNacimiento;
	}

	/**
	 * @return the codigoReserva
	 */
	public String getCodigoReserva() {
		return codigoReserva;
	}

	/**
	 * @param codigoReserva the codigoReserva to set
	 */
	public void setCodigoReserva(String codigoReserva) {
		this.codigoReserva = codigoReserva;
	}

	/**
	 * @return the numeroBoleto
	 */
	public String getNumeroBoleto() {
		return numeroBoleto;
	}

	/**
	 * @param numeroBoleto the numeroBoleto to set
	 */
	public void setNumeroBoleto(String numeroBoleto) {
		this.numeroBoleto = numeroBoleto;
	}

	/**
	 * @return the pais
	 */
	public BaseVO getPais() {
		if (pais == null){
			pais = new BaseVO();
		}
		return pais;
	}

	/**
	 * @param pais the pais to set
	 */
	public void setPais(BaseVO pais) {
		this.pais = pais;
	}

}
