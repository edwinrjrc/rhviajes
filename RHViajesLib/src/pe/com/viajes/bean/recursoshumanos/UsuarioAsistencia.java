/**
 * 
 */
package pe.com.viajes.bean.recursoshumanos;

import java.util.Date;

import pe.com.viajes.bean.base.Base;
import pe.com.viajes.bean.base.BaseVO;

/**
 * @author EDWREB
 *
 */
public class UsuarioAsistencia extends Base {

	private static final long serialVersionUID = 4167052292847536474L;

	private BaseVO usuario;
	private Date fechaIngreso;

	/**
	 * @return the fechaIngreso
	 */
	public Date getFechaIngreso() {
		return fechaIngreso;
	}

	/**
	 * @param fechaIngreso
	 *            the fechaIngreso to set
	 */
	public void setFechaIngreso(Date fechaIngreso) {
		this.fechaIngreso = fechaIngreso;
	}

	/**
	 * @return the usuario
	 */
	public BaseVO getUsuario() {
		if (usuario == null) {
			usuario = new BaseVO();
		}
		return usuario;
	}

	/**
	 * @param usuario
	 *            the usuario to set
	 */
	public void setUsuario(BaseVO usuario) {
		this.usuario = usuario;
	}

}
