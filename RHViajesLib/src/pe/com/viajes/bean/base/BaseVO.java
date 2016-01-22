/**
 * 
 */
package pe.com.viajes.bean.base;

/**
 * @author Edwin
 * 
 */
public class BaseVO extends Base {

	private static final long serialVersionUID = 6210620262453450979L;
	private String nombre;
	private String abreviatura;
	
	//FIXME debe colocarse esto en un objeto independiente
	private boolean valorBoolean;

	/**
	 * 
	 */
	public BaseVO() {
		// TODO Auto-generated constructor stub
	}

	public BaseVO(int id) {
		this.setCodigoEntero(id);
	}

	public BaseVO(String id) {
		this.setCodigoCadena(id);
	}

	/**
	 * @return the nombre
	 */
	public String getNombre() {
		return nombre;
	}

	/**
	 * @param nombre
	 *            the nombre to set
	 */
	public void setNombre(String nombre) {
		this.nombre = nombre;
	}

	/**
	 * @return the abreviatura
	 */
	public String getAbreviatura() {
		return abreviatura;
	}

	/**
	 * @param abreviatura
	 *            the abreviatura to set
	 */
	public void setAbreviatura(String abreviatura) {
		this.abreviatura = abreviatura;
	}

	/**
	 * @return the valorBoolean
	 */
	public boolean isValorBoolean() {
		return valorBoolean;
	}

	/**
	 * @param valorBoolean the valorBoolean to set
	 */
	public void setValorBoolean(boolean valorBoolean) {
		this.valorBoolean = valorBoolean;
	}

}
