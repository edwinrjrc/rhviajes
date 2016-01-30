/**
 * 
 */
package pe.com.viajes.web.faces;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.Enumeration;
import java.util.List;

import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;
import javax.naming.NamingException;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;

import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.bean.recursoshumanos.UsuarioAsistencia;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;
import pe.com.viajes.negocio.exception.InicioSesionException;
import pe.com.viajes.negocio.exception.ValidacionException;
import pe.com.viajes.web.servicio.AuditoriaServicio;
import pe.com.viajes.web.servicio.SeguridadServicio;
import pe.com.viajes.web.servicio.impl.AuditoriaServicioImpl;
import pe.com.viajes.web.servicio.impl.SeguridadServicioImpl;

/**
 * @author Edwin
 * 
 */
@ManagedBean(name = "usuarioMBean")
@SessionScoped()
public class UsuarioMBean extends BaseMBean {

	private final static Logger logger = Logger.getLogger(UsuarioMBean.class);
	/**
	 * 
	 */
	private static final long serialVersionUID = 6495326572788019729L;

	private List<Usuario> listaUsuarios;

	private Usuario usuario;

	private String credencialNueva;
	private String reCredencial;
	private String msjeError;
	private String idModalPopup;

	private String modalNombre;
	private Date fechaAsistencia;

	private List<UsuarioAsistencia> listaAsistenciaUsuario;

	private boolean nuevoUsuario;
	private boolean editarUsuario;

	private SeguridadServicio seguridadServicio;
	private AuditoriaServicio auditoriaServicio;

	/**
	 * 
	 */
	public UsuarioMBean() {
		try {
			ServletContext servletContext = (ServletContext) FacesContext
					.getCurrentInstance().getExternalContext().getContext();
			seguridadServicio = new SeguridadServicioImpl(servletContext);
			auditoriaServicio = new AuditoriaServicioImpl(servletContext);
		} catch (NamingException e) {
			logger.error(e.getMessage(), e);
		}
		usuario = new Usuario();
	}

	public void nuevoUsuario() {
		this.setNuevoUsuario(true);
		this.setEditarUsuario(false);
		this.setUsuario(null);
		this.setNombreFormulario("Nuevo Usuario");
		this.setIdModalPopup("idModalformusuario");
	}

	public void consultarUsuario(Integer id) {
		try {
			this.setNombreFormulario("Editar Usuario");
			this.setIdModalPopup("idModalformusuario");
			this.setEditarUsuario(true);
			this.setNuevoUsuario(false);
			this.setUsuario(this.seguridadServicio.consultarUsuario(id, this.obtenerIdEmpresa()));
			this.setReCredencial(this.getUsuario().getCredencial());
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
		}
	}

	public void registrarUsuario() {
		try {
			seguridadServicio.registrarUsuario(getUsuario());
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void ejecutarMetodo(ActionEvent e) {
		try {
			if (validarUsuarioFormulario()) {
				HttpSession session = obtenerSession(false);
				Usuario usuario = (Usuario) session
						.getAttribute("usuarioSession");
				getUsuario().setUsuarioCreacion(
						usuario);
				getUsuario().setIpCreacion(
						obtenerRequest().getRemoteAddr());
				getUsuario().setUsuarioModificacion(
						usuario);
				getUsuario().setIpModificacion(
						obtenerRequest().getRemoteAddr());
				getUsuario().setEmpresa(usuario.getEmpresa());
				
				if (this.isNuevoUsuario()) {
					seguridadServicio.registrarUsuario(getUsuario());
					this.setShowModal(true);
					this.setTipoModal("1");
					this.setMensajeModal("Usuario registrado Satisfactoriamente");
				} else if (this.isEditarUsuario()) {
					seguridadServicio.actualizarUsuario(getUsuario());
					this.setShowModal(true);
					this.setTipoModal("1");
					this.setMensajeModal("Usuario actualizado Satisfactoriamente");
				}
			}

		} catch (SQLException ex) {
			logger.error(ex.getMessage(), ex);

		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

	private boolean validarUsuarioFormulario() {
		String idFormulario = "idFormUsuario";
		if (!this.getUsuario().getCredencial().equals(this.getReCredencial())) {
			this.agregarMensaje(idFormulario + ":idReClave",
					"Las claves no coinciden", "", FacesMessage.SEVERITY_ERROR);
			return false;
		}
		return true;
	}

	public String inicioSesion() {
		try {
			this.getUsuario().setIpCreacion(obtenerRequest().getRemoteAddr());
			this.getUsuario().setIpModificacion(obtenerRequest().getRemoteAddr());
			usuario = seguridadServicio.inicioSesion(this.getUsuario());

			HttpSession session = (HttpSession) obtenerSession(true);
			session.setAttribute(this.USUARIO_SESSION, usuario);
			session.setAttribute(this.EMPRESA_USUARIO_SESSION, usuario.getEmpresa());
			return "irInicio";

		} catch (InicioSesionException e) {
			this.mostrarMensajeError(e.getMessage());
			obtenerRequest().setAttribute("msjeError", e.getMessage());
			logger.error(e.getMessage());
		} catch (SQLException e) {
			this.mostrarMensajeError(e.getMessage());
			obtenerRequest().setAttribute("msjeError",
					"No se pudo iniciar sesion");
			logger.error(e.getMessage());
		} catch (Exception e) {
			this.mostrarMensajeError(e.getMessage());
			obtenerRequest().setAttribute("msjeError",
					"No se pudo iniciar sesion");
			logger.error(e.getMessage());
		}

		return "";
	}

	public void cambiarClave() {
		try {
			if (validarClave()) {
				getUsuario().setUsuarioCreacion(
						usuario);
				getUsuario().setIpCreacion(
						obtenerRequest().getRemoteAddr());
				getUsuario().setUsuarioModificacion(
						usuario);
				getUsuario().setIpModificacion(
						obtenerRequest().getRemoteAddr());
				getUsuario().setEmpresa(usuario.getEmpresa());
				
				this.seguridadServicio.cambiarClaveUsuario(getUsuario());

				this.setShowModal(true);
				this.setTipoModal("1");
				this.setMensajeModal("Cambio de clave Satisfactorio");
			}

		} catch (SQLException e) {
			this.setTipoModal("2");
			this.setShowModal(true);
			this.setMensajeModal(e.getMessage());
			logger.error(e.getMessage(), e);
		} catch (Exception e) {
			this.setTipoModal("2");
			this.setShowModal(true);
			this.setMensajeModal(e.getMessage());
			logger.error(e.getMessage(), e);
		}
	}

	public void cambiarClaveVencida() {
		try {
			if (validarClave()) {
				getUsuario().setUsuarioCreacion(
						usuario);
				getUsuario().setIpCreacion(
						obtenerRequest().getRemoteAddr());
				getUsuario().setUsuarioModificacion(
						usuario);
				getUsuario().setIpModificacion(
						obtenerRequest().getRemoteAddr());
				getUsuario().setEmpresa(usuario.getEmpresa());
				
				if (getUsuario().getCredencial().equals(
						getUsuario().getCredencialNueva())) {
					throw new ValidacionException(
							"La contraseña nueva no puede ser igual a la vencida");
				}
				this.seguridadServicio
						.actualizarCredencialVencida(getUsuario());

				this.setShowModal(true);
				this.setTipoModal("1");
				this.setMensajeModal("Se renovaron las credenciales satisfactoriamente");

				getUsuario().setCredencialVencida(false);
			}
		} catch (ValidacionException e) {
			this.setTipoModal("2");
			this.setShowModal(true);
			this.setMensajeModal(e.getMessage());
			logger.error(e.getMessage(),e);
		} catch (SQLException e) {
			this.setTipoModal("2");
			this.setShowModal(true);
			this.setMensajeModal(e.getMessage());
			logger.error(e.getMessage(), e);
		} catch (Exception e) {
			this.setTipoModal("2");
			this.setShowModal(true);
			this.setMensajeModal(e.getMessage());
			logger.error(e.getMessage(), e);
		}
	}

	public void actualizarClave() {
		try {
			if (validarClave()) {
				this.seguridadServicio.actualizarClaveUsuario(getUsuario());

				this.setShowModal(true);
				this.setTipoModal("1");
				this.setMensajeModal("Cambio de clave Satisfactorio");
			}

		} catch (ValidacionException e) {
			this.setTipoModal("2");
			this.setShowModal(true);
			this.setMensajeModal(e.getMessage());
		} catch (SQLException e) {
			this.setTipoModal("2");
			this.setShowModal(true);
			this.setMensajeModal(e.getMessage());
			logger.error(e.getMessage(), e);
		} catch (Exception e) {
			this.setTipoModal("2");
			this.setShowModal(true);
			this.setMensajeModal(e.getMessage());
			logger.error(e.getMessage(), e);
		}
	}

	private boolean validarClave() throws ValidacionException {
		if (!getUsuario().getCredencialNueva()
				.equals(this.getCredencialNueva())) {
			throw new ValidacionException("Las claves no coinciden");
		}
		return true;
	}

	public String salirSesion() {
		try {
			HttpSession session = (HttpSession) FacesContext
					.getCurrentInstance().getExternalContext().getSession(true);
			Enumeration<String> enuatributos = session.getAttributeNames();

			while (enuatributos.hasMoreElements()) {
				session.removeAttribute(enuatributos.nextElement());
			}
			session.invalidate();
		} catch (Exception e) {
			logger.error("Error cerrando sesion");
			logger.error(e.getMessage(), e);
		}

		return "irSalirSistema";
	}

	public void consultarCambioClave(Integer id) {
		try {
			this.setIdModalPopup("idModalfrcambioclaveusuario");
			this.setUsuario(this.seguridadServicio.consultarUsuario(id, this.obtenerIdEmpresa()));
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public void consultaAsistenciaXDia() {
		try {
			this.setListaAsistenciaUsuario(this.auditoriaServicio
					.consultarHorarioAsistenciaXDia(getFechaAsistencia(), this.obtenerIdEmpresa()));

		} catch (ErrorConsultaDataException e) {
			logger.error(e.getMessage(), e);
			this.mostrarMensajeError(e.getMessage());
		}
	}

	public String consultarAsistencia() {
		this.setFechaAsistencia(new Date());
		this.consultaAsistenciaXDia();

		return "irConsultaAsistencia";
	}

	/**
	 * ========================================================================
	 * =================================
	 */

	/**
	 * @return the listaUsuarios
	 */
	public List<Usuario> getListaUsuarios() {
		try {
			this.setShowModal(false);
			listaUsuarios = seguridadServicio.listarUsuarios(this.obtenerIdEmpresa());

		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
		}
		return listaUsuarios;
	}

	/**
	 * @param listaUsuarios
	 *            the listaUsuarios to set
	 */
	public void setListaUsuarios(List<Usuario> listaUsuarios) {
		this.listaUsuarios = listaUsuarios;
	}

	/**
	 * @return the usuario
	 */
	public Usuario getUsuario() {
		if (usuario == null) {
			usuario = new Usuario();
		}
		return usuario;
	}

	/**
	 * @param usuario
	 *            the usuario to set
	 */
	public void setUsuario(Usuario usuario) {
		this.usuario = usuario;
	}

	/**
	 * @return the reCredencial
	 */
	public String getReCredencial() {
		return reCredencial;
	}

	/**
	 * @param reCredencial
	 *            the reCredencial to set
	 */
	public void setReCredencial(String reCredencial) {
		this.reCredencial = reCredencial;
	}

	/**
	 * @return the nuevoUsuario
	 */
	public boolean isNuevoUsuario() {
		return nuevoUsuario;
	}

	/**
	 * @param nuevoUsuario
	 *            the nuevoUsuario to set
	 */
	public void setNuevoUsuario(boolean nuevoUsuario) {
		this.nuevoUsuario = nuevoUsuario;
	}

	/**
	 * @return the editarUsuario
	 */
	public boolean isEditarUsuario() {
		return editarUsuario;
	}

	/**
	 * @param editarUsuario
	 *            the editarUsuario to set
	 */
	public void setEditarUsuario(boolean editarUsuario) {
		this.editarUsuario = editarUsuario;
	}

	/**
	 * @return the msjeError
	 */
	public String getMsjeError() {
		return msjeError;
	}

	/**
	 * @param msjeError
	 *            the msjeError to set
	 */
	public void setMsjeError(String msjeError) {
		this.msjeError = msjeError;
	}

	/**
	 * @return the modalNombre
	 */
	public String getModalNombre() {
		return modalNombre;
	}

	/**
	 * @param modalNombre
	 *            the modalNombre to set
	 */
	public void setModalNombre(String modalNombre) {
		this.modalNombre = modalNombre;
	}

	/**
	 * @return the seguridadServicio
	 */
	public SeguridadServicio getSeguridadServicio() {
		return seguridadServicio;
	}

	/**
	 * @param seguridadServicio
	 *            the seguridadServicio to set
	 */
	public void setSeguridadServicio(SeguridadServicio seguridadServicio) {
		this.seguridadServicio = seguridadServicio;
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
	 * @return the idModalPopup
	 */
	public String getIdModalPopup() {
		return idModalPopup;
	}

	/**
	 * @param idModalPopup
	 *            the idModalPopup to set
	 */
	public void setIdModalPopup(String idModalPopup) {
		this.idModalPopup = idModalPopup;
	}

	/**
	 * @return the fechaAsistencia
	 */
	public Date getFechaAsistencia() {
		return fechaAsistencia;
	}

	/**
	 * @param fechaAsistencia
	 *            the fechaAsistencia to set
	 */
	public void setFechaAsistencia(Date fechaAsistencia) {
		this.fechaAsistencia = fechaAsistencia;
	}

	/**
	 * @return the listaAsistenciaUsuario
	 */
	public List<UsuarioAsistencia> getListaAsistenciaUsuario() {
		if (listaAsistenciaUsuario == null) {
			listaAsistenciaUsuario = new ArrayList<UsuarioAsistencia>();
		}
		return listaAsistenciaUsuario;
	}

	/**
	 * @param listaAsistenciaUsuario
	 *            the listaAsistenciaUsuario to set
	 */
	public void setListaAsistenciaUsuario(
			List<UsuarioAsistencia> listaAsistenciaUsuario) {
		this.listaAsistenciaUsuario = listaAsistenciaUsuario;
	}

}
