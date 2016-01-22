/**
 * 
 */
package pe.com.viajes.bean.negocio;

import pe.com.viajes.bean.base.BaseNegocio;
import pe.com.viajes.bean.base.BaseVO;

/**
 * @author Edwin
 *
 */
public class Telefono extends BaseNegocio {

	/**
	 * 
	 */
	private static final long serialVersionUID = 3012859645915798758L;

	private int id;
	private String numeroTelefono;
	private BaseVO empresaOperadora;

	/**
	 * 
	 */
	public Telefono() {
		// TODO Auto-generated constructor stub
	}

	/**
	 * @return the id
	 */
	public int getId() {
		return id;
	}

	/**
	 * @param id
	 *            the id to set
	 */
	public void setId(int id) {
		this.id = id;
	}

	/**
	 * @return the numeroTelefono
	 */
	public String getNumeroTelefono() {
		return numeroTelefono;
	}

	/**
	 * @param numeroTelefono
	 *            the numeroTelefono to set
	 */
	public void setNumeroTelefono(String numeroTelefono) {
		this.numeroTelefono = numeroTelefono;
	}

	/**
	 * @return the empresaOperadora
	 */
	public BaseVO getEmpresaOperadora() {
		if (empresaOperadora == null) {
			empresaOperadora = new BaseVO();
		}
		return empresaOperadora;
	}

	/**
	 * @param empresaOperadora
	 *            the empresaOperadora to set
	 */
	public void setEmpresaOperadora(BaseVO empresaOperadora) {
		this.empresaOperadora = empresaOperadora;
	}

}
