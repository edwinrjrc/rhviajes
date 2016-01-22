/**
 * 
 */
package pe.com.viajes.web.faces;

import java.sql.SQLException;
import java.util.Date;
import java.util.List;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;
import javax.naming.NamingException;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;

import pe.com.viajes.bean.negocio.TipoCambio;
import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.web.servicio.ConsultaNegocioServicio;
import pe.com.viajes.web.servicio.NegocioServicio;
import pe.com.viajes.web.servicio.impl.ConsultaNegocioServicioImpl;
import pe.com.viajes.web.servicio.impl.NegocioServicioImpl;

/**
 * @author Edwin
 *
 */
@ManagedBean(name = "tipoCambioMBean")
@SessionScoped()
public class TipoCambioMBean extends BaseMBean {

	private final static Logger logger = Logger
			.getLogger(TipoCambioMBean.class);

	private static final long serialVersionUID = 7385254040705801393L;

	private TipoCambio tipoCambio;

	private List<TipoCambio> listaTipoCambio;

	private NegocioServicio negocioServicio;
	private ConsultaNegocioServicio consultaNegocioServicio;

	private boolean nuevoTipoCambio;

	public TipoCambioMBean() {
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

	public void nuevoTipoCambio() {
		this.setTipoCambio(null);
		this.setNuevoTipoCambio(true);
	}

	public void ejecutarMetodo() {

		try {
			if (validatTipoCambio()) {
				HttpSession session = obtenerSession(false);
				Usuario usuario = (Usuario) session
						.getAttribute("usuarioSession");
				getTipoCambio().setUsuarioCreacion(usuario);
				getTipoCambio().setIpCreacion(obtenerRequest().getRemoteAddr());

				this.negocioServicio.registrarTipoCambio(getTipoCambio());

				this.mostrarMensajeExito("Tipo de cambio registrado satisfactoriamente");

				this.setListaTipoCambio(this.consultaNegocioServicio
						.listarTipoCambio(new Date(), this.obtenerIdEmpresa()));

				this.setNuevoTipoCambio(false);
			}
		} catch (SQLException e) {
			this.mostrarMensajeError(e.getMessage());
		} catch (Exception e) {
			this.mostrarMensajeError(e.getMessage());
		}

	}

	private boolean validatTipoCambio() {
		// TODO Auto-generated method stub
		return true;
	}

	public void listarTipoCambio(ActionEvent e) {
		try {
			this.setListaTipoCambio(this.consultaNegocioServicio
					.listarTipoCambio(new Date(), this.obtenerIdEmpresa()));

		} catch (SQLException ex) {
			logger.error(ex.getMessage(), ex);
		}
	}

	/**
	 * @return the tipoCambio
	 */
	public TipoCambio getTipoCambio() {
		if (tipoCambio == null) {
			tipoCambio = new TipoCambio();
		}
		return tipoCambio;
	}

	/**
	 * @param tipoCambio
	 *            the tipoCambio to set
	 */
	public void setTipoCambio(TipoCambio tipoCambio) {
		this.tipoCambio = tipoCambio;
	}

	/**
	 * @return the nuevoTipoCambio
	 */
	public boolean isNuevoTipoCambio() {
		return nuevoTipoCambio;
	}

	/**
	 * @param nuevoTipoCambio
	 *            the nuevoTipoCambio to set
	 */
	public void setNuevoTipoCambio(boolean nuevoTipoCambio) {
		this.nuevoTipoCambio = nuevoTipoCambio;
	}

	/**
	 * @return the listaTipoCambio
	 */
	public List<TipoCambio> getListaTipoCambio() {
		return listaTipoCambio;
	}

	/**
	 * @param listaTipoCambio
	 *            the listaTipoCambio to set
	 */
	public void setListaTipoCambio(List<TipoCambio> listaTipoCambio) {
		this.listaTipoCambio = listaTipoCambio;
	}

}
