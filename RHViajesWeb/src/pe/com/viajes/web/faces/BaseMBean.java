/**
 * 
 */
package pe.com.viajes.web.faces;

import java.io.Serializable;

import javax.faces.application.FacesMessage;
import javax.faces.application.FacesMessage.Severity;
import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.negocio.Usuario;

/**
 * @author Edwin
 * 
 */
public abstract class BaseMBean implements Serializable {
	private static final long serialVersionUID = -8144858026084650982L;

	private String nombreFormulario;
	private String mensajeModal;
	private String tipoModal;
	private String modalNombre;

	private boolean showModal;
	private boolean transaccionExito;

	public static final String TIPO_MODAL_EXITO = "1";
	public static final String TIPO_MODAL_ERROR = "2";
	public static final String USUARIO_SESSION = "usuarioSession";
	public static final String EMPRESA_USUARIO_SESSION = "empresaUsuarioSession";
	public static final String TIPO_CAMBIO_SESSION = "tipoCambioSession";

	public BaseMBean() {
		// TODO Auto-generated constructor stub
	}

	public void aceptarBoton() {
		this.setShowModal(false);
		this.setTipoModal("");
		this.setMensajeModal("");
	}

	/**
	 * @return the nombreFormulario
	 */
	public String getNombreFormulario() {
		return nombreFormulario;
	}

	/**
	 * @param nombreFormulario
	 *            the nombreFormulario to set
	 */
	public void setNombreFormulario(String nombreFormulario) {
		this.nombreFormulario = nombreFormulario;
	}

	/**
	 * @return the mensajeModal
	 */
	public String getMensajeModal() {
		return mensajeModal;
	}

	/**
	 * @param mensajeModal
	 *            the mensajeModal to set
	 */
	public void setMensajeModal(String mensajeModal) {
		this.mensajeModal = mensajeModal;
	}

	/**
	 * @return the tipoModal
	 */
	public String getTipoModal() {
		return tipoModal;
	}

	/**
	 * @param tipoModal
	 *            the tipoModal to set
	 */
	public void setTipoModal(String tipoModal) {
		this.tipoModal = tipoModal;
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
	 * @return the showModal
	 */
	public boolean isShowModal() {
		return showModal;
	}

	/**
	 * @param showModal
	 *            the showModal to set
	 */
	public void setShowModal(boolean showModal) {
		this.showModal = showModal;
	}

	public HttpSession obtenerSession(boolean sesion) {

		return (HttpSession) obtenerContexto().getExternalContext().getSession(
				sesion);
	}

	public FacesContext obtenerContexto() {

		return FacesContext.getCurrentInstance();
	}

	public HttpServletRequest obtenerRequest() {
		return (HttpServletRequest) obtenerContexto().getExternalContext()
				.getRequest();
	}

	public HttpServletResponse obtenerResponse() {
		return (HttpServletResponse) obtenerContexto().getExternalContext()
				.getResponse();
	}

	public ExternalContext obtenerContextoExterno() {
		return obtenerContexto().getExternalContext();
	}

	public void agregarMensaje(String idComponente, String mensajeSuma,
			String mensajeDetalle, Severity severity) {
		FacesMessage faceMessage = new FacesMessage(severity, mensajeSuma,
				mensajeDetalle);
		obtenerContexto().addMessage(idComponente, faceMessage);
	}

	/**
	 * @return the transaccionExito
	 */
	public boolean isTransaccionExito() {
		return transaccionExito;
	}

	/**
	 * @param transaccionExito
	 *            the transaccionExito to set
	 */
	public void setTransaccionExito(boolean transaccionExito) {
		this.transaccionExito = transaccionExito;
	}

	public void mostrarMensajeError(String mensaje) {
		this.setShowModal(true);
		this.setMensajeModal(mensaje);
		this.setTipoModal(TIPO_MODAL_ERROR);
	}

	public void mostrarMensajeExito(String mensaje) {
		this.setShowModal(true);
		this.setMensajeModal(mensaje);
		this.setTipoModal(TIPO_MODAL_EXITO);
	}
	
	public Integer obtenerIdEmpresa(){
		return obtenerEmpresa().getCodigoEntero();
	}
	
	public BaseVO obtenerEmpresa(){
		BaseVO empresa = (BaseVO)this.obtenerSession(false).getAttribute(EMPRESA_USUARIO_SESSION);
		
		return empresa;
	}
	
	public Usuario obtenerUsuarioSession(){
		HttpSession session = obtenerSession(false);
		Usuario usuario = (Usuario) session
				.getAttribute(USUARIO_SESSION);
		return usuario;
	}
	
	public String obtenerIpMaquina(){
		return obtenerRequest().getRemoteAddr();
	}
}
