/**
 * 
 */
package pe.com.viajes.negocio.exception;

/**
 * @author Edwin
 *
 */
public class InicioSesionException extends RHViajesException {

	private static final long serialVersionUID = -7035772278974525938L;

	public InicioSesionException(String string) {
		super(string);
		this.setMensajeError(string);
	}
	
	public InicioSesionException(String string, Throwable arg0) {
		super(string, arg0);
	}
	
	public InicioSesionException(Throwable arg0) {
		super(arg0);
	}
}
