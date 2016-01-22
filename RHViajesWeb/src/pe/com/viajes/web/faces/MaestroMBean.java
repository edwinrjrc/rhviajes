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

import pe.com.viajes.bean.negocio.Maestro;
import pe.com.viajes.web.servicio.SoporteServicio;
import pe.com.viajes.web.servicio.impl.SoporteServicioImpl;

/**
 * @author Edwin
 * 
 */
@ManagedBean(name = "maestroMBean")
@SessionScoped()
public class MaestroMBean extends BaseMBean {

	private final static Logger logger = Logger.getLogger(MaestroMBean.class);
	/**
	 * 
	 */
	private static final long serialVersionUID = 8487737481921274643L;
	private List<Maestro> listaMaestros;
	private List<Maestro> listaHijosMaestro;

	private Maestro maestro;
	private Maestro hijoMaestro;

	private boolean nuevoMaestro;
	private boolean editarMaestro;

	private SoporteServicio soporteServicio;

	/**
	 * 
	 */
	public MaestroMBean() {
		try {
			ServletContext servletContext = (ServletContext) FacesContext
					.getCurrentInstance().getExternalContext().getContext();
			soporteServicio = new SoporteServicioImpl(servletContext);
		} catch (NamingException e) {
			logger.error(e.getMessage(), e);
		}
	}

	public void consultarMaestro(Integer id) {
		try {
			this.setNombreFormulario("Editar Maestro");
			this.setEditarMaestro(true);
			this.setNuevoMaestro(false);
			this.setMaestro(soporteServicio.consultarMaestro(id, this.obtenerIdEmpresa()));
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
			this.mostrarMensajeError(e.getMessage());
		}
	}

	public String consultarHijosMaestro(Integer idMaestro) {
		try {
			this.setMaestro(soporteServicio.consultarMaestro(idMaestro, this.obtenerIdEmpresa()));
			this.setListaHijosMaestro(soporteServicio
					.listarHijosMaestro(idMaestro, this.obtenerIdEmpresa()));

			return "irHijoMaestro";
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
		}

		return "";
	}

	public String consultarHijoMaestro(Integer idMaestro) {
		try {
			this.getHijoMaestro().setCodigoEntero(idMaestro);
			this.getHijoMaestro().setCodigoMaestro(
					this.getMaestro().getCodigoEntero());

			this.setHijoMaestro(soporteServicio.consultarHijoMaestro(this
					.getHijoMaestro()));
			this.setListaHijosMaestro(soporteServicio
					.listarHijosMaestro(idMaestro, this.obtenerIdEmpresa()));
			this.setNombreFormulario("Editar Hijo Maestro");
			this.setEditarMaestro(true);
			this.setNuevoMaestro(false);

		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
		}

		return "";
	}

	public void nuevoMaestro() {
		this.setNuevoMaestro(true);
		this.setEditarMaestro(false);
		this.setMaestro(null);
		this.setNombreFormulario("Nuevo Maestro");
	}

	public void nuevoHijoMaestro() {
		this.setNuevoMaestro(true);
		this.setEditarMaestro(false);
		this.setHijoMaestro(null);
		this.setNombreFormulario("Nuevo Hijo Maestro");
		this.getHijoMaestro().setCodigoMaestro(
				this.getMaestro().getCodigoEntero());
	}

	public void ejecutarMetodo() {
		try {
			if (this.isNuevoMaestro()) {
				soporteServicio.ingresarMaestro(maestro);
				this.mostrarMensajeExito("Maestro registrado Satisfactoriamente");
				
			} else if (this.isEditarMaestro()) {
				soporteServicio.actualizarMaestro(getMaestro());
				this.mostrarMensajeError("Maestro actualizado Satisfactoriamente");
			}
		} catch (Exception e) {
			this.mostrarMensajeError(e.getMessage());
			logger.error(e.getMessage(), e);
		}
	}

	public void ejecutarMetodoHijo() {
		try {
			if (this.isNuevoMaestro()) {
				soporteServicio.ingresarHijoMaestro(this.getHijoMaestro());
				this.setShowModal(true);
				this.setTipoModal("1");
				this.setMensajeModal("Hijo Maestro registrado Satisfactoriamente");
			} else if (this.isEditarMaestro()) {
				this.setShowModal(soporteServicio.actualizarMaestro(this
						.getHijoMaestro()));
				this.setTipoModal("1");
				this.setMensajeModal("Hijo Maestro actualizado Satisfactoriamente");
			}
		} catch (Exception e) {
			this.setShowModal(true);
			this.setTipoModal("2");
			this.setMensajeModal(e.getMessage());
			logger.error(e.getMessage(), e);
		}
	}

	/**
	 * @return the listaMaestros
	 */
	public List<Maestro> getListaMaestros() {
		try {

			listaMaestros = soporteServicio.listarMaestros(this.obtenerIdEmpresa());
			this.setShowModal(false);
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
			this.setShowModal(true);
			this.setTipoModal("2");
			this.setMensajeModal(e.getMessage());
		}

		return listaMaestros;
	}

	/**
	 * @param listaMaestros
	 *            the listaMaestros to set
	 */
	public void setListaMaestros(List<Maestro> listaMaestros) {
		this.listaMaestros = listaMaestros;
	}

	/**
	 * @return the maestro
	 */
	public Maestro getMaestro() {
		if (maestro == null) {
			maestro = new Maestro();
		}
		return maestro;
	}

	/**
	 * @param maestro
	 *            the maestro to set
	 */
	public void setMaestro(Maestro maestro) {
		this.maestro = maestro;
	}

	/**
	 * @return the nuevoMaestro
	 */
	public boolean isNuevoMaestro() {
		return nuevoMaestro;
	}

	/**
	 * @param nuevoMaestro
	 *            the nuevoMaestro to set
	 */
	public void setNuevoMaestro(boolean nuevoMaestro) {
		this.nuevoMaestro = nuevoMaestro;
	}

	/**
	 * @return the editarMaestro
	 */
	public boolean isEditarMaestro() {
		return editarMaestro;
	}

	/**
	 * @param editarMaestro
	 *            the editarMaestro to set
	 */
	public void setEditarMaestro(boolean editarMaestro) {
		this.editarMaestro = editarMaestro;
	}

	/**
	 * @return the listaHijosMaestro
	 */
	public List<Maestro> getListaHijosMaestro() {
		try {
			this.setListaHijosMaestro(soporteServicio.listarHijosMaestro(this
					.getMaestro().getCodigoEntero(), this.obtenerIdEmpresa()));
			this.setShowModal(false);
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
			this.setShowModal(true);
			this.setTipoModal("2");
			this.setMensajeModal(e.getMessage());
		}
		return listaHijosMaestro;
	}

	/**
	 * @param listaHijosMaestro
	 *            the listaHijosMaestro to set
	 */
	public void setListaHijosMaestro(List<Maestro> listaHijosMaestro) {
		this.listaHijosMaestro = listaHijosMaestro;
	}

	/**
	 * @return the hijoMaestro
	 */
	public Maestro getHijoMaestro() {
		if (hijoMaestro == null) {
			hijoMaestro = new Maestro();
		}
		return hijoMaestro;
	}

	/**
	 * @param hijoMaestro
	 *            the hijoMaestro to set
	 */
	public void setHijoMaestro(Maestro hijoMaestro) {
		this.hijoMaestro = hijoMaestro;
	}

}
