/**
 * 
 */
package pe.com.viajes.web.seguridad;

import javax.faces.application.NavigationHandler;
import javax.faces.context.FacesContext;
import javax.faces.event.PhaseEvent;
import javax.faces.event.PhaseId;
import javax.faces.event.PhaseListener;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;

import pe.com.viajes.bean.negocio.Usuario;

/**
 * @author Edwin
 * 
 */
public class AuthorizationListener implements PhaseListener {

	private final static Logger logger = Logger
			.getLogger(AuthorizationListener.class);

	/**
	 * 
	 */
	private static final long serialVersionUID = 2355404062399271061L;

	/**
	 * 
	 */
	public AuthorizationListener() {
		// TODO Auto-generated constructor stub
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * javax.faces.event.PhaseListener#afterPhase(javax.faces.event.PhaseEvent)
	 */
	@Override
	public void afterPhase(PhaseEvent event) {
		redirigir(event);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * javax.faces.event.PhaseListener#beforePhase(javax.faces.event.PhaseEvent)
	 */
	@Override
	public void beforePhase(PhaseEvent event) {
		// redirigir(event);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see javax.faces.event.PhaseListener#getPhaseId()
	 */
	@Override
	public PhaseId getPhaseId() {
		return PhaseId.RESTORE_VIEW;
	}

	private void redirigir(PhaseEvent event) {
		try {
			FacesContext facesContext = event.getFacesContext();
			String currentPage = facesContext.getViewRoot().getViewId();

			boolean isLoginPage = (currentPage.lastIndexOf("index.xhtml") > -1);
			HttpSession session = (HttpSession) facesContext
					.getExternalContext().getSession(false);

			if (session == null) {
				NavigationHandler nh = facesContext.getApplication()
						.getNavigationHandler();
				nh.handleNavigation(facesContext, null, "irInicioSistema");
			}

			else {
				Usuario currentUser = (Usuario) session
						.getAttribute("usuarioSession");

				if (!isLoginPage && (currentUser == null)) {
					NavigationHandler nh = facesContext.getApplication()
							.getNavigationHandler();
					nh.handleNavigation(facesContext, null, "irInicioSistema");
				}
			}
		} catch (Exception e) {
			logger.error("NO SE ENCONTRO PAGINA EN LA FASE");
		}
	}

}
