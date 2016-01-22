/**
 * 
 */
package pe.com.viajes.bean.negocio;

import pe.com.viajes.bean.base.Base;

/**
 * @author Edwin
 *
 */
public class ClienteCorreo extends Base {

	/**
	 * 
	 */
	private static final long serialVersionUID = -4030465635352484682L;

	private String nombres;
	private String apellidos;
	private String correo;

	/**
	 * 
	 */
	public ClienteCorreo() {
		// TODO Auto-generated constructor stub
	}

	/**
	 * @return the nombres
	 */
	public String getNombres() {
		return nombres;
	}

	/**
	 * @param nombres
	 *            the nombres to set
	 */
	public void setNombres(String nombres) {
		this.nombres = nombres;
	}

	/**
	 * @return the apellidos
	 */
	public String getApellidos() {
		return apellidos;
	}

	/**
	 * @param apellidos
	 *            the apellidos to set
	 */
	public void setApellidos(String apellidos) {
		this.apellidos = apellidos;
	}

	/**
	 * @return the correo
	 */
	public String getCorreo() {
		return correo;
	}

	/**
	 * @param correo
	 *            the correo to set
	 */
	public void setCorreo(String correo) {
		this.correo = correo;
	}

}
