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

import pe.com.viajes.bean.negocio.Consolidador;
import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.web.servicio.ConsultaNegocioServicio;
import pe.com.viajes.web.servicio.NegocioServicio;
import pe.com.viajes.web.servicio.impl.ConsultaNegocioServicioImpl;
import pe.com.viajes.web.servicio.impl.NegocioServicioImpl;

/**
 * @author Edwin
 *
 */
@ManagedBean(name = "consolidadorMBean")
@SessionScoped()
public class ConsolidadorMBean extends BaseMBean {

	private final static Logger logger = Logger
			.getLogger(ConsolidadorMBean.class);
	/**
	 * 
	 */
	private static final long serialVersionUID = -8156747158222601055L;

	private List<Consolidador> listaConsolidador;

	private Consolidador consolidador;

	private boolean nuevoConsolidador;
	private boolean editarConsolidador;

	private NegocioServicio negocioServicio;
	private ConsultaNegocioServicio consultaNegocioServicio;

	/**
	 * 
	 */
	public ConsolidadorMBean() {
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

	public void nuevoConsolidador() {
		this.setNuevoConsolidador(true);
		this.setEditarConsolidador(false);
		this.setConsolidador(null);
		this.setNombreFormulario("Nuevo Consolidador");
	}

	public void ejecutarMetodo() {
		try {
			HttpSession session = obtenerSession(false);
			Usuario usuario = (Usuario) session.getAttribute("usuarioSession");
			if (this.isNuevoConsolidador()) {
				this.getConsolidador().setUsuarioCreacion(usuario);
				this.getConsolidador().setIpCreacion(
						this.obtenerRequest().getRemoteAddr());
				this.setShowModal(this.negocioServicio
						.ingresarConsolidador(getConsolidador()));
				this.setTipoModal("1");
				this.setMensajeModal("Consolidador ingresado Satisfactoriamente");
			} else {
				this.getConsolidador().setUsuarioModificacion(
						usuario);
				this.getConsolidador().setIpModificacion(
						this.obtenerRequest().getRemoteAddr());
				this.setShowModal(this.negocioServicio
						.actualizarConsolidador(getConsolidador()));
				this.setTipoModal("1");
				this.setMensajeModal("Consolidador actualizado Satisfactoriamente");
			}
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
			this.setShowModal(true);
			this.setTipoModal("2");
			this.setMensajeModal(e.getMessage());
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			this.setShowModal(true);
			this.setTipoModal("2");
			this.setMensajeModal(e.getMessage());
		}
	}

	public void consultarConsolidador(Integer idConsolidador) {
		try {
			Consolidador consolida = new Consolidador();
			consolida.setCodigoEntero(idConsolidador);
			this.setConsolidador(this.consultaNegocioServicio
					.consultarConsolidador(consolida));
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
			this.setShowModal(true);
			this.setTipoModal("2");
			this.setMensajeModal(e.getMessage());
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			this.setShowModal(true);
			this.setTipoModal("2");
			this.setMensajeModal(e.getMessage());
		}
	}

	/**
	 * @return the listaConsolidador
	 */
	public List<Consolidador> getListaConsolidador() {
		try {
			listaConsolidador = this.consultaNegocioServicio
					.listarConsolidador();
			this.setShowModal(false);
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
			this.setShowModal(true);
			this.setTipoModal("2");
			this.setMensajeModal(e.getMessage());
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			this.setShowModal(true);
			this.setTipoModal("2");
			this.setMensajeModal(e.getMessage());
		}
		return listaConsolidador;
	}

	/**
	 * @param listaConsolidador
	 *            the listaConsolidador to set
	 */
	public void setListaConsolidador(List<Consolidador> listaConsolidador) {
		this.listaConsolidador = listaConsolidador;
	}

	/**
	 * @return the consolidador
	 */
	public Consolidador getConsolidador() {
		if (consolidador == null) {
			consolidador = new Consolidador();
		}
		return consolidador;
	}

	/**
	 * @param consolidador
	 *            the consolidador to set
	 */
	public void setConsolidador(Consolidador consolidador) {
		this.consolidador = consolidador;
	}

	/**
	 * @return the nuevoConsolidador
	 */
	public boolean isNuevoConsolidador() {
		return nuevoConsolidador;
	}

	/**
	 * @param nuevoConsolidador
	 *            the nuevoConsolidador to set
	 */
	public void setNuevoConsolidador(boolean nuevoConsolidador) {
		this.nuevoConsolidador = nuevoConsolidador;
	}

	/**
	 * @return the editarConsolidador
	 */
	public boolean isEditarConsolidador() {
		return editarConsolidador;
	}

	/**
	 * @param editarConsolidador
	 *            the editarConsolidador to set
	 */
	public void setEditarConsolidador(boolean editarConsolidador) {
		this.editarConsolidador = editarConsolidador;
	}

	/**
	 * @return the negocioServicio
	 */
	public NegocioServicio getNegocioServicio() {
		return negocioServicio;
	}

	/**
	 * @param negocioServicio
	 *            the negocioServicio to set
	 */
	public void setNegocioServicio(NegocioServicio negocioServicio) {
		this.negocioServicio = negocioServicio;
	}

}
