/**
 * 
 */
package pe.com.viajes.bean.base;

/**
 * @author Edwin
 *
 */
public class CorreoElectronico extends Base {

	/**
	 * 
	 */
	private static final long serialVersionUID = -2802017659577078384L;

	private String direccion;
	private boolean seleccionado;
	private boolean recibirPromociones;

	/**
	 * @return the direccion
	 */
	public String getDireccion() {
		return direccion;
	}

	/**
	 * @param direccion
	 *            the direccion to set
	 */
	public void setDireccion(String direccion) {
		this.direccion = direccion;
	}

	/**
	 * @return the seleccionado
	 */
	public boolean isSeleccionado() {
		return seleccionado;
	}

	/**
	 * @param seleccionado
	 *            the seleccionado to set
	 */
	public void setSeleccionado(boolean seleccionado) {
		this.seleccionado = seleccionado;
	}

	/**
	 * @return the recibirPromociones
	 */
	public boolean isRecibirPromociones() {
		return recibirPromociones;
	}

	/**
	 * @param recibirPromociones
	 *            the recibirPromociones to set
	 */
	public void setRecibirPromociones(boolean recibirPromociones) {
		this.recibirPromociones = recibirPromociones;
	}
}
