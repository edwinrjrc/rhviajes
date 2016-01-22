/**
 * 
 */
package pe.com.viajes.web.faces;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.naming.NamingException;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.negocio.Destino;
import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.web.servicio.SoporteServicio;
import pe.com.viajes.web.servicio.impl.SoporteServicioImpl;
import pe.com.viajes.web.util.UtilWeb;

/**
 * @author Edwin
 * 
 */
@ManagedBean(name = "destinoMBean")
@SessionScoped()
public class DestinoMBean extends BaseMBean {

	private final static Logger logger = Logger.getLogger(DestinoMBean.class);
	/**
	 * 
	 */
	private static final long serialVersionUID = 2050307546226802791L;

	private Destino destino;

	private SoporteServicio soporteServicio;

	private List<SelectItem> listaPais;
	private List<Destino> listaDestino;

	public boolean nuevoDestino;
	public boolean editarDestino;

	/**
	 * 
	 */
	public DestinoMBean() {
		try {
			ServletContext servletContext = (ServletContext) FacesContext
					.getCurrentInstance().getExternalContext().getContext();
			soporteServicio = new SoporteServicioImpl(servletContext);
		} catch (NamingException e) {
			logger.error(e.getMessage(), e);
		}
	}

	public void nuevoDestino() {
		this.setNuevoDestino(true);
		this.setEditarDestino(false);
		this.setDestino(null);
		this.setListaDestino(null);
		this.setListaPais(null);
		this.setNombreFormulario("Nuevo Destino");
	}

	public void ejecutarMetodo() {
		try {
			if (this.isNuevoDestino()) {
				HttpSession session = obtenerSession(false);
				Usuario usuario = (Usuario) session
						.getAttribute("usuarioSession");
				getDestino().setUsuarioCreacion(usuario);
				getDestino().setIpCreacion(obtenerRequest().getRemoteAddr());
				this.soporteServicio.ingresarDestino(getDestino());

				this.mostrarMensajeExito("Destino registrado Satisfactoriamente");
				
			} else if (this.isEditarDestino()) {
				HttpSession session = obtenerSession(false);
				Usuario usuario = (Usuario) session
						.getAttribute("usuarioSession");
				getDestino().setUsuarioCreacion(usuario);
				getDestino().setIpCreacion(obtenerRequest().getRemoteAddr());
				getDestino().setUsuarioModificacion(usuario);
				getDestino()
						.setIpModificacion(obtenerRequest().getRemoteAddr());
				this.soporteServicio.actualizarDestino(getDestino());
				
				this.mostrarMensajeExito("Destino actualizado Satisfactoriamente");
			}

		} catch (SQLException e) {
			this.mostrarMensajeError(e.getMessage());
			logger.error(e.getMessage(), e);
		} catch (Exception e) {
			this.mostrarMensajeError(e.getMessage());
			logger.error(e.getMessage(), e);
		}
	}

	public void cambiarPais(ValueChangeEvent e) {
		this.setListaPais(null);
	}

	/**
	 * @return the destino
	 */
	public Destino getDestino() {
		if (destino == null) {
			destino = new Destino();
		}
		return destino;
	}

	/**
	 * @param destino
	 *            the destino to set
	 */
	public void setDestino(Destino destino) {
		this.destino = destino;
	}

	/**
	 * @return the nuevoDestino
	 */
	public boolean isNuevoDestino() {
		return nuevoDestino;
	}

	/**
	 * @param nuevoDestino
	 *            the nuevoDestino to set
	 */
	public void setNuevoDestino(boolean nuevoDestino) {
		this.nuevoDestino = nuevoDestino;
	}

	/**
	 * @return the editarDestino
	 */
	public boolean isEditarDestino() {
		return editarDestino;
	}

	/**
	 * @param editarDestino
	 *            the editarDestino to set
	 */
	public void setEditarDestino(boolean editarDestino) {
		this.editarDestino = editarDestino;
	}

	/**
	 * @return the listaPais
	 */
	public List<SelectItem> getListaPais() {
		try {
			if (listaPais == null || listaPais.isEmpty()) {
				if (getDestino().getPais().getContinente().getCodigoEntero() != null) {
					List<BaseVO> lista = soporteServicio
							.consultarPaises(getDestino().getPais()
									.getContinente().getCodigoEntero(), this.obtenerIdEmpresa());
					listaPais = UtilWeb.convertirSelectItem(lista);
				}
			}

		} catch (SQLException e) {
			listaPais = new ArrayList<SelectItem>();
			logger.error(e.getMessage(), e);
		} catch (Exception e) {
			listaPais = new ArrayList<SelectItem>();
			logger.error(e.getMessage(), e);
		}
		return listaPais;
	}

	/**
	 * @param listaPais
	 *            the listaPais to set
	 */
	public void setListaPais(List<SelectItem> listaPais) {
		this.listaPais = listaPais;
	}

	/**
	 * @return the listaDestino
	 */
	public List<Destino> getListaDestino() {
		try {
			listaDestino = this.soporteServicio.listarDestinos(this.obtenerIdEmpresa());

			this.setShowModal(false);
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
		}
		return listaDestino;
	}

	/**
	 * @param listaDestino
	 *            the listaDestino to set
	 */
	public void setListaDestino(List<Destino> listaDestino) {
		this.listaDestino = listaDestino;
	}
}
