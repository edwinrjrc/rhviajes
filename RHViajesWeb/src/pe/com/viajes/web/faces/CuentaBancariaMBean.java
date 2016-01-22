/**
 * 
 */
package pe.com.viajes.web.faces;

import java.sql.SQLException;
import java.util.List;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;
import javax.naming.NamingException;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;

import pe.com.viajes.bean.negocio.CuentaBancaria;
import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.negocio.exception.ErrorRegistroDataException;
import pe.com.viajes.web.servicio.ConsultaNegocioServicio;
import pe.com.viajes.web.servicio.NegocioServicio;
import pe.com.viajes.web.servicio.impl.ConsultaNegocioServicioImpl;
import pe.com.viajes.web.servicio.impl.NegocioServicioImpl;

/**
 * @author EDWREB
 *
 */
@ManagedBean(name = "cuentaBancariaMBean")
@SessionScoped()
public class CuentaBancariaMBean extends BaseMBean {

	private final static Logger logger = Logger
			.getLogger(CuentaBancariaMBean.class);
	/**
	 * 
	 */
	private static final long serialVersionUID = -286142489189063441L;

	private List<CuentaBancaria> listaCuentasBancarias;
	private CuentaBancaria cuentaBancaria;

	private boolean nuevaCuentaBancaria;
	private boolean editarCuentaBancaria;

	private NegocioServicio negocioServicio;
	private ConsultaNegocioServicio consultaNegocioServicio;

	public CuentaBancariaMBean() {
		try {
			ServletContext servletContext = (ServletContext) FacesContext
					.getCurrentInstance().getExternalContext().getContext();
			negocioServicio = new NegocioServicioImpl(servletContext);
			consultaNegocioServicio = new ConsultaNegocioServicioImpl(
					servletContext);
		} catch (NamingException e) {
			logger.error(e.getMessage(), e);
		}
	}

	public void nuevaCuenta() {
		this.setCuentaBancaria(null);
		this.setNuevaCuentaBancaria(true);
		this.setEditarCuentaBancaria(false);
		this.setNombreFormulario("Nueva Cuenta Bancaria");
	}

	public void editarCuenta() {
		this.setNuevaCuentaBancaria(false);
		this.setEditarCuentaBancaria(true);
		this.setNombreFormulario("Edita Cuenta Bancaria");
	}

	public void ejecutarMetodo() {
		try {
			if (validarCuentaBancaria()) {

				if (this.isNuevaCuentaBancaria()) {

					HttpSession session = obtenerSession(false);
					Usuario usuario = (Usuario) session
							.getAttribute("usuarioSession");
					getCuentaBancaria()
							.setUsuarioCreacion(usuario);
					getCuentaBancaria().setIpCreacion(
							obtenerRequest().getRemoteAddr());

					this.negocioServicio
							.registrarCuentaBancaria(getCuentaBancaria());

					this.mostrarMensajeExito("Cuenta Bancaria registrada satisfactoriamente");
				} else {
					HttpSession session = obtenerSession(false);
					Usuario usuario = (Usuario) session
							.getAttribute("usuarioSession");
					getCuentaBancaria().setUsuarioModificacion(
							usuario);
					getCuentaBancaria().setIpModificacion(
							obtenerRequest().getRemoteAddr());

					this.negocioServicio
							.actualizarCuentaBancaria(getCuentaBancaria());

					this.mostrarMensajeExito("Cuenta Bancaria actualizada satisfactoriamente");
				}
			}
		} catch (ErrorRegistroDataException e) {
			logger.error(e.getMessage(), e);
			this.mostrarMensajeError(e.getMessage());
		}
	}

	private boolean validarCuentaBancaria() {
		boolean resultado = true;

		return resultado;
	}

	public void consultarCuenta(Integer idCuenta) {
		try {
			this.setCuentaBancaria(this.consultaNegocioServicio
					.consultarCuentaBancaria(idCuenta, this.obtenerIdEmpresa()));

			editarCuenta();
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
		}
	}

	/**
	 * @return the listaCuentasBancarias
	 */
	public List<CuentaBancaria> getListaCuentasBancarias() {

		try {
			listaCuentasBancarias = this.consultaNegocioServicio
					.listarCuentasBancarias(this.obtenerIdEmpresa());

			this.setShowModal(false);
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
		}

		return listaCuentasBancarias;
	}

	/**
	 * @param listaCuentasBancarias
	 *            the listaCuentasBancarias to set
	 */
	public void setListaCuentasBancarias(
			List<CuentaBancaria> listaCuentasBancarias) {
		this.listaCuentasBancarias = listaCuentasBancarias;
	}

	/**
	 * @return the cuentaBancaria
	 */
	public CuentaBancaria getCuentaBancaria() {
		if (cuentaBancaria == null) {
			cuentaBancaria = new CuentaBancaria();
		}
		return cuentaBancaria;
	}

	/**
	 * @param cuentaBancaria
	 *            the cuentaBancaria to set
	 */
	public void setCuentaBancaria(CuentaBancaria cuentaBancaria) {
		this.cuentaBancaria = cuentaBancaria;
	}

	/**
	 * @return the nuevaCuentaBancaria
	 */
	public boolean isNuevaCuentaBancaria() {
		return nuevaCuentaBancaria;
	}

	/**
	 * @param nuevaCuentaBancaria
	 *            the nuevaCuentaBancaria to set
	 */
	public void setNuevaCuentaBancaria(boolean nuevaCuentaBancaria) {
		this.nuevaCuentaBancaria = nuevaCuentaBancaria;
	}

	/**
	 * @return the editarCuentaBancaria
	 */
	public boolean isEditarCuentaBancaria() {
		return editarCuentaBancaria;
	}

	/**
	 * @param editarCuentaBancaria
	 *            the editarCuentaBancaria to set
	 */
	public void setEditarCuentaBancaria(boolean editarCuentaBancaria) {
		this.editarCuentaBancaria = editarCuentaBancaria;
	}

}
