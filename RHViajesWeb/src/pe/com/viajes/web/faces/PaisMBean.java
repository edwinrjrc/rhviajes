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

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.negocio.Maestro;
import pe.com.viajes.bean.negocio.Pais;
import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.negocio.exception.ConnectionException;
import pe.com.viajes.web.servicio.SoporteServicio;
import pe.com.viajes.web.servicio.impl.SoporteServicioImpl;

/**
 * @author Edwin
 *
 */
@ManagedBean(name = "paisMBean")
@SessionScoped()
public class PaisMBean extends BaseMBean {

	/**
	 * 
	 */
	private static final long serialVersionUID = -980891844670492853L;

	private final static Logger logger = Logger.getLogger(PaisMBean.class);

	private BaseVO continente;
	private Pais pais;

	private List<BaseVO> listaContinente;
	private List<BaseVO> listaPaisContinente;

	private boolean nuevoPais;
	private boolean editarPais;

	private SoporteServicio soporteServicio;

	/**
	 * 
	 */
	public PaisMBean() {
		try {
			ServletContext servletContext = (ServletContext) FacesContext
					.getCurrentInstance().getExternalContext().getContext();
			soporteServicio = new SoporteServicioImpl(servletContext);
		} catch (NamingException e) {
			logger.error(e.getMessage(), e);
		}
	}

	public String consultarPaises(int idcontinente) {

		try {
			Maestro hijo = new Maestro();
			hijo.setCodigoMaestro(10);
			hijo.setCodigoEntero(idcontinente);
			hijo.setEmpresa(this.obtenerEmpresa());
			this.setContinente(this.soporteServicio.consultarHijoMaestro(hijo));
			this.setListaPaisContinente(this.soporteServicio
					.consultarPaises(idcontinente, this.obtenerIdEmpresa()));
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
		}

		return "irPaises";
	}

	public void nuevoPais() {
		this.setNuevoPais(true);
		this.setEditarPais(false);
		this.setPais(null);
		this.setNombreFormulario("Nuevo Pais");
	}

	public void ejecutarMetodo() {
		try {
			if (this.isNuevoPais()) {
				HttpSession session = obtenerSession(false);
				Usuario usuario = (Usuario) session
						.getAttribute("usuarioSession");
				getPais().setUsuarioCreacion(usuario);
				getPais().setIpCreacion(obtenerRequest().getRemoteAddr());
				getPais().setEmpresa(this.obtenerEmpresa());
				this.getPais().setContinente(getContinente());
				this.soporteServicio.ingresarPais(getPais());
				this.mostrarMensajeExito("Pais registrado Satisfactoriamente");
			} else if (this.isEditarPais()) {

			}
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
			this.mostrarMensajeError(e.getMessage());
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			this.mostrarMensajeError(e.getMessage());
		}
	}

	/**
	 * @return the listaContinente
	 */
	public List<BaseVO> getListaContinente() {
		try {
			listaContinente = this.soporteServicio.listarContinentes(this.obtenerIdEmpresa());
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
		} catch (ConnectionException e) {
			logger.error(e.getMessage(), e);
		}
		return listaContinente;
	}

	/**
	 * @param listaContinente
	 *            the listaContinente to set
	 */
	public void setListaContinente(List<BaseVO> listaContinente) {
		this.listaContinente = listaContinente;
	}

	/**
	 * @return the listaPaisContinente
	 */
	public List<BaseVO> getListaPaisContinente() {

		this.consultarPaises(getContinente().getCodigoEntero());
		this.setShowModal(false);

		return listaPaisContinente;
	}

	/**
	 * @param listaPaisContinente
	 *            the listaPaisContinente to set
	 */
	public void setListaPaisContinente(List<BaseVO> listaPaisContinente) {
		this.listaPaisContinente = listaPaisContinente;
	}

	/**
	 * @return the continente
	 */
	public BaseVO getContinente() {
		if (continente == null){
			continente = new BaseVO();
		}
		return continente;
	}

	/**
	 * @param continente
	 *            the continente to set
	 */
	public void setContinente(BaseVO continente) {
		this.continente = continente;
	}

	/**
	 * @return the nuevoPais
	 */
	public boolean isNuevoPais() {
		return nuevoPais;
	}

	/**
	 * @param nuevoPais
	 *            the nuevoPais to set
	 */
	public void setNuevoPais(boolean nuevoPais) {
		this.nuevoPais = nuevoPais;
	}

	/**
	 * @return the editarPais
	 */
	public boolean isEditarPais() {
		return editarPais;
	}

	/**
	 * @param editarPais
	 *            the editarPais to set
	 */
	public void setEditarPais(boolean editarPais) {
		this.editarPais = editarPais;
	}

	/**
	 * @return the pais
	 */
	public Pais getPais() {
		if (pais == null) {
			pais = new Pais();
		}
		return pais;
	}

	/**
	 * @param pais
	 *            the pais to set
	 */
	public void setPais(Pais pais) {
		this.pais = pais;
	}

}
