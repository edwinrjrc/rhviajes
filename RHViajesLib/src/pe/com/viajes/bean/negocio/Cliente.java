package pe.com.viajes.bean.negocio;

import java.util.ArrayList;
import java.util.List;

import pe.com.viajes.bean.base.Persona;

/**
 * @author Edwin
 * @version 1.0
 * @created 14-dic-2013 01:14:34 p.m.
 */
public class Cliente extends Persona {

	/**
	 * 
	 */
	private static final long serialVersionUID = -6169046402465472276L;
	private String correoElectronico;
	private List<Contacto> listaContactos;
	private List<CuentaBancaria> listaCuentas;

	private String telefonoInvitadoNovios;
	private Integer codigoSeleccionado;

	private int infoCliente;

	public Cliente() {

	}

	public void finalize() throws Throwable {
		super.finalize();
	}

	/**
	 * @return the correoElectronico
	 */
	public String getCorreoElectronico() {
		return correoElectronico;
	}

	/**
	 * @param correoElectronico
	 *            the correoElectronico to set
	 */
	public void setCorreoElectronico(String correoElectronico) {
		this.correoElectronico = correoElectronico;
	}

	/**
	 * @return the listaContactos
	 */
	public List<Contacto> getListaContactos() {
		if (listaContactos == null) {
			listaContactos = new ArrayList<Contacto>();
		}
		return listaContactos;
	}

	/**
	 * @param listaContactos
	 *            the listaContactos to set
	 */
	public void setListaContactos(List<Contacto> listaContactos) {
		this.listaContactos = listaContactos;
	}

	/**
	 * @return the listaCuentas
	 */
	public List<CuentaBancaria> getListaCuentas() {
		return listaCuentas;
	}

	/**
	 * @param listaCuentas
	 *            the listaCuentas to set
	 */
	public void setListaCuentas(List<CuentaBancaria> listaCuentas) {
		this.listaCuentas = listaCuentas;
	}

	/**
	 * @return the telefonoInvitadoNovios
	 */
	public String getTelefonoInvitadoNovios() {
		return telefonoInvitadoNovios;
	}

	/**
	 * @param telefonoInvitadoNovios
	 *            the telefonoInvitadoNovios to set
	 */
	public void setTelefonoInvitadoNovios(String telefonoInvitadoNovios) {
		this.telefonoInvitadoNovios = telefonoInvitadoNovios;
	}

	/**
	 * @return the codigoSeleccionado
	 */
	public Integer getCodigoSeleccionado() {
		return codigoSeleccionado;
	}

	/**
	 * @param codigoSeleccionado
	 *            the codigoSeleccionado to set
	 */
	public void setCodigoSeleccionado(Integer codigoSeleccionado) {
		this.codigoSeleccionado = codigoSeleccionado;
	}

	/**
	 * @return the infoCliente
	 */
	public int getInfoCliente() {
		return infoCliente;
	}

	/**
	 * @param infoCliente
	 *            the infoCliente to set
	 */
	public void setInfoCliente(int infoCliente) {
		this.infoCliente = infoCliente;
	}

}