/**
 * 
 */
package pe.com.viajes.negocio.exception;

/**
 * @author Edwin
 *
 */
public class LogisticaNegocioException extends Exception {

	private String codigoError = "";
	private String mensajeError = "";
	/**
	 * 
	 */
	private static final long serialVersionUID = 3005964831488327481L;

	/**
	 * 
	 */
	public LogisticaNegocioException() {
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param arg0
	 */
	public LogisticaNegocioException(String arg0) {
		super(arg0);
		mensajeError = arg0;
		// TODO Auto-generated constructor stub
	}

	public LogisticaNegocioException(String arg0, String arg1) {
		super(arg1);
		codigoError = arg0;
		mensajeError = arg1;
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param arg0
	 */
	public LogisticaNegocioException(Throwable arg0) {
		super(arg0);
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param arg0
	 * @param arg1
	 */
	public LogisticaNegocioException(String arg0, Throwable arg1) {
		super(arg0, arg1);
		mensajeError = arg0;
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param arg0
	 * @param arg1
	 */
	public LogisticaNegocioException(String codigo, String mensaje,
			Throwable arg1) {
		super(mensaje, arg1);
		mensajeError = mensaje;
		codigoError = codigo;
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param arg0
	 * @param arg1
	 * @param arg2
	 * @param arg3
	 */
	public LogisticaNegocioException(String arg0, Throwable arg1, boolean arg2,
			boolean arg3) {
		super(arg0, arg1, arg2, arg3);
		mensajeError = arg0;
		// TODO Auto-generated constructor stub
	}

	/**
	 * @return the codigoError
	 */
	public String getCodigoError() {
		return codigoError;
	}

	/**
	 * @param codigoError
	 *            the codigoError to set
	 */
	public void setCodigoError(String codigoError) {
		this.codigoError = codigoError;
	}

	/**
	 * @return the mensajeError
	 */
	public String getMensajeError() {
		return mensajeError;
	}

	/**
	 * @param mensajeError
	 *            the mensajeError to set
	 */
	public void setMensajeError(String mensajeError) {
		this.mensajeError = mensajeError;
	}

}
