/**
 * 
 */
package pe.com.viajes.negocio.exception;

/**
 * @author edwreb
 *
 */
public class EnvioCorreoException extends LogisticaNegocioException {

	/**
	 * 
	 */
	private static final long serialVersionUID = -2426446969763828723L;

	private String mensajeException;

	/**
	 * 
	 */
	public EnvioCorreoException() {
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param arg0
	 */
	public EnvioCorreoException(String arg0) {
		super(arg0);
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param arg0
	 * @param arg1
	 */
	public EnvioCorreoException(String arg0, String arg1) {
		super(arg0, arg1);
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param arg0
	 */
	public EnvioCorreoException(Throwable arg0) {
		super(arg0);
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param arg0
	 * @param arg1
	 */
	public EnvioCorreoException(String arg0, Throwable arg1) {
		super(arg0, arg1);
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param codigo
	 * @param mensaje
	 * @param arg1
	 */
	public EnvioCorreoException(String codigo, String mensaje, Throwable arg1) {
		super(codigo, mensaje, arg1);
		// TODO Auto-generated constructor stub
	}

	public EnvioCorreoException(String codigo, String mensaje,
			String mensajeExcep, Throwable arg1) {
		super(codigo, mensaje, arg1);
		this.setMensajeException(mensajeExcep);
	}

	/**
	 * @param arg0
	 * @param arg1
	 * @param arg2
	 * @param arg3
	 */
	public EnvioCorreoException(String arg0, Throwable arg1, boolean arg2,
			boolean arg3) {
		super(arg0, arg1, arg2, arg3);
		// TODO Auto-generated constructor stub
	}

	/**
	 * @return the mensajeException
	 */
	public String getMensajeException() {
		return mensajeException;
	}

	/**
	 * @param mensajeException
	 *            the mensajeException to set
	 */
	public void setMensajeException(String mensajeException) {
		this.mensajeException = mensajeException;
	}

}
