/**
 * 
 */
package pe.com.viajes.bean.negocio;

import java.util.ArrayList;
import java.util.List;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.base.Persona;

/**
 * @author Edwin
 * 
 */
public class Usuario extends Persona {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private String usuario;
	private String credencial;
	private String credencialNueva;
	private List<BaseVO> listaRoles;
	private boolean encontrado;
	private boolean vendedor;
	private boolean credencialVencida;
	private String nombreDominioEmpresa;

	/**
	 * 
	 */
	public Usuario() {
		// TODO Auto-generated constructor stub
	}

	/**
	 * @return the usuario
	 */
	public String getUsuario() {
		return usuario;
	}

	/**
	 * @param usuario
	 *            the usuario to set
	 */
	public void setUsuario(String usuario) {
		this.usuario = usuario;
	}

	/**
	 * @return the credencial
	 */
	public String getCredencial() {
		return credencial;
	}

	/**
	 * @param credencial
	 *            the credencial to set
	 */
	public void setCredencial(String credencial) {
		this.credencial = credencial;
	}

	/**
	 * @return the encontrado
	 */
	public boolean isEncontrado() {
		return encontrado;
	}

	/**
	 * @param encontrado
	 *            the encontrado to set
	 */
	public void setEncontrado(boolean encontrado) {
		this.encontrado = encontrado;
	}

	/**
	 * @return the credencialNueva
	 */
	public String getCredencialNueva() {
		return credencialNueva;
	}

	/**
	 * @param credencialNueva
	 *            the credencialNueva to set
	 */
	public void setCredencialNueva(String credencialNueva) {
		this.credencialNueva = credencialNueva;
	}

	/**
	 * @return the vendedor
	 */
	public boolean isVendedor() {
		return vendedor;
	}

	/**
	 * @param vendedor
	 *            the vendedor to set
	 */
	public void setVendedor(boolean vendedor) {
		this.vendedor = vendedor;
	}

	/**
	 * @return the credencialVencida
	 */
	public boolean isCredencialVencida() {
		return credencialVencida;
	}

	/**
	 * @param credencialVencida
	 *            the credencialVencida to set
	 */
	public void setCredencialVencida(boolean credencialVencida) {
		this.credencialVencida = credencialVencida;
	}

	/**
	 * @return the nombreDominioEmpresa
	 */
	public String getNombreDominioEmpresa() {
		return nombreDominioEmpresa;
	}

	/**
	 * @param nombreDominioEmpresa the nombreDominioEmpresa to set
	 */
	public void setNombreDominioEmpresa(String nombreDominioEmpresa) {
		this.nombreDominioEmpresa = nombreDominioEmpresa;
	}

	/**
	 * @return the listaRoles
	 */
	public List<BaseVO> getListaRoles() {
		if (listaRoles == null){
			listaRoles = new ArrayList<BaseVO>();
		}
		return listaRoles;
	}

	/**
	 * @param listaRoles the listaRoles to set
	 */
	public void setListaRoles(List<BaseVO> listaRoles) {
		this.listaRoles = listaRoles;
	}

}
