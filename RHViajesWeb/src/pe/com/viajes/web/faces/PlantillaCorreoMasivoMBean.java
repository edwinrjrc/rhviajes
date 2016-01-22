/**
 * 
 */
package pe.com.viajes.web.faces;

import java.util.List;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.event.ActionEvent;

import pe.com.viajes.bean.negocio.PlantillaCorreo;

/**
 * @author Edwin
 *
 */
@ManagedBean(name = "plantillaCorreoMasivoMBean")
@SessionScoped()
public class PlantillaCorreoMasivoMBean extends BaseMBean {

	/**
	 * 
	 */
	private static final long serialVersionUID = -3476265246805865520L;

	private List<PlantillaCorreo> listaPlantilla;

	private PlantillaCorreo plantillaCorreo;

	private boolean nuevaPlantillaCorreo;
	private boolean editarPlantillaCorreo;

	/**
	 * 
	 */
	public PlantillaCorreoMasivoMBean() {
		// TODO Auto-generated constructor stub
	}

	public void nuevaPlantilla() {
		this.setNuevaPlantillaCorreo(true);
		this.setEditarPlantillaCorreo(false);
		this.setNombreFormulario("Nueva Plantilla Correo");
	}

	public void ejecutarMetodo(ActionEvent e) {

	}

	/**
	 * @return the listaPlantilla
	 */
	public List<PlantillaCorreo> getListaPlantilla() {
		return listaPlantilla;
	}

	/**
	 * @param listaPlantilla
	 *            the listaPlantilla to set
	 */
	public void setListaPlantilla(List<PlantillaCorreo> listaPlantilla) {
		this.listaPlantilla = listaPlantilla;
	}

	/**
	 * @return the plantillaCorreo
	 */
	public PlantillaCorreo getPlantillaCorreo() {
		if (plantillaCorreo == null) {
			plantillaCorreo = new PlantillaCorreo();
		}
		return plantillaCorreo;
	}

	/**
	 * @param plantillaCorreo
	 *            the plantillaCorreo to set
	 */
	public void setPlantillaCorreo(PlantillaCorreo plantillaCorreo) {
		this.plantillaCorreo = plantillaCorreo;
	}

	/**
	 * @return the nuevaPlantillaCorreo
	 */
	public boolean isNuevaPlantillaCorreo() {
		return nuevaPlantillaCorreo;
	}

	/**
	 * @param nuevaPlantillaCorreo
	 *            the nuevaPlantillaCorreo to set
	 */
	public void setNuevaPlantillaCorreo(boolean nuevaPlantillaCorreo) {
		this.nuevaPlantillaCorreo = nuevaPlantillaCorreo;
	}

	/**
	 * @return the editarPlantillaCorreo
	 */
	public boolean isEditarPlantillaCorreo() {
		return editarPlantillaCorreo;
	}

	/**
	 * @param editarPlantillaCorreo
	 *            the editarPlantillaCorreo to set
	 */
	public void setEditarPlantillaCorreo(boolean editarPlantillaCorreo) {
		this.editarPlantillaCorreo = editarPlantillaCorreo;
	}
}
