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

import org.apache.log4j.Logger;

import pe.com.viajes.bean.negocio.Parametro;
import pe.com.viajes.web.servicio.ParametroServicio;
import pe.com.viajes.web.servicio.impl.ParametroServicioImpl;

/**
 * @author Edwin
 *
 */
@ManagedBean(name = "parametroMBean")
@SessionScoped()
public class ParametroMBean extends BaseMBean {

	private final static Logger logger = Logger.getLogger(ParametroMBean.class);

	/**
	 * 
	 */
	private static final long serialVersionUID = 3310865321325342819L;

	private List<Parametro> listaParametros;

	private Parametro parametro;

	private boolean nuevoParametro;
	private boolean editarParametro;

	private ParametroServicio parametroServicio;

	/**
	 * 
	 */
	public ParametroMBean() {
		try {
			ServletContext servletContext = (ServletContext) FacesContext
					.getCurrentInstance().getExternalContext().getContext();
			parametroServicio = new ParametroServicioImpl(servletContext);
		} catch (NamingException e) {
			logger.error(e.getMessage(), e);
		}
	}

	public void nuevoParametro() {
		this.setNuevoParametro(true);
		this.setEditarParametro(false);
		this.setParametro(null);
		this.setNombreFormulario("Nuevo Parametro");
	}

	public void ejecutarMetodo() {
		try {
			if (this.isNuevoParametro()) {
				parametroServicio.registrarParametro(parametro);
				this.setShowModal(true);
				this.setTipoModal("1");
				this.setMensajeModal("Parametro registrado Satisfactoriamente");
			} else if (this.isEditarParametro()) {
				parametroServicio.actualizarParametro(parametro);
				this.setShowModal(true);
				this.setTipoModal("1");
				this.setMensajeModal("Parametro actualizado Satisfactoriamente");
			}
		} catch (Exception e) {
			this.setShowModal(true);
			this.setTipoModal("2");
			this.setMensajeModal(e.getMessage());
			logger.error(e.getMessage(), e);
		}
	}

	public void consultarParametro(Integer id) {
		try {
			this.setNombreFormulario("Editar Parametro");
			this.setEditarParametro(true);
			this.setNuevoParametro(false);
			this.setParametro(parametroServicio.consultarParametro(id, this.obtenerIdEmpresa()));
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
			this.setShowModal(true);
			this.setTipoModal("2");
			this.setMensajeModal(e.getMessage());
		}
	}

	/**
	 * x|
	 * 
	 * @return the listaParametros
	 */
	public List<Parametro> getListaParametros() {
		try {
			listaParametros = parametroServicio.listarParametros(this.obtenerIdEmpresa());
			this.setShowModal(false);
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
			this.setShowModal(true);
			this.setTipoModal("2");
			this.setMensajeModal(e.getMessage());
		}
		return listaParametros;
	}

	/**
	 * @param listaParametros
	 *            the listaParametros to set
	 */
	public void setListaParametros(List<Parametro> listaParametros) {
		this.listaParametros = listaParametros;
	}

	/**
	 * @return the parametro
	 */
	public Parametro getParametro() {
		if (parametro == null) {
			parametro = new Parametro();
		}
		return parametro;
	}

	/**
	 * @param parametro
	 *            the parametro to set
	 */
	public void setParametro(Parametro parametro) {
		this.parametro = parametro;
	}

	/**
	 * @return the nuevoParametro
	 */
	public boolean isNuevoParametro() {
		return nuevoParametro;
	}

	/**
	 * @param nuevoParametro
	 *            the nuevoParametro to set
	 */
	public void setNuevoParametro(boolean nuevoParametro) {
		this.nuevoParametro = nuevoParametro;
	}

	/**
	 * @return the editarParametro
	 */
	public boolean isEditarParametro() {
		return editarParametro;
	}

	/**
	 * @param editarParametro
	 *            the editarParametro to set
	 */
	public void setEditarParametro(boolean editarParametro) {
		this.editarParametro = editarParametro;
	}

}
