/**
 * 
 */
package pe.com.viajes.bean.licencia;

import java.math.BigDecimal;
import java.util.Date;

import pe.com.viajes.bean.base.Base;

/**
 * @author Edwin
 *
 */
public class ContratoLicencia extends Base {

	private static final long serialVersionUID = 3465369279878500725L;
	
	private Integer idEmpresa;
	private Date fechaInicio;
	private Date fechaFin;
	private int numeroUsuarios;
	private BigDecimal precioUsuario;
	
	
	/**
	 * @return the idEmpresa
	 */
	public Integer getIdEmpresa() {
		return idEmpresa;
	}
	/**
	 * @param idEmpresa the idEmpresa to set
	 */
	public void setIdEmpresa(Integer idEmpresa) {
		this.idEmpresa = idEmpresa;
	}
	/**
	 * @return the fechaInicio
	 */
	public Date getFechaInicio() {
		return fechaInicio;
	}
	/**
	 * @param fechaInicio the fechaInicio to set
	 */
	public void setFechaInicio(Date fechaInicio) {
		this.fechaInicio = fechaInicio;
	}
	/**
	 * @return the fechaFin
	 */
	public Date getFechaFin() {
		return fechaFin;
	}
	/**
	 * @param fechaFin the fechaFin to set
	 */
	public void setFechaFin(Date fechaFin) {
		this.fechaFin = fechaFin;
	}
	/**
	 * @return the numeroUsuarios
	 */
	public int getNumeroUsuarios() {
		return numeroUsuarios;
	}
	/**
	 * @param numeroUsuarios the numeroUsuarios to set
	 */
	public void setNumeroUsuarios(int numeroUsuarios) {
		this.numeroUsuarios = numeroUsuarios;
	}
	/**
	 * @return the precioUsuario
	 */
	public BigDecimal getPrecioUsuario() {
		return precioUsuario;
	}
	/**
	 * @param precioUsuario the precioUsuario to set
	 */
	public void setPrecioUsuario(BigDecimal precioUsuario) {
		this.precioUsuario = precioUsuario;
	}
	
	
}
