/**
 * 
 */
package pe.com.viajes.negocio.exception;

/**
 * @author Edwin
 *
 */
public class NoEnvioDatoException extends LogisticaNegocioException {

	/**
	 * 
	 */
	private static final long serialVersionUID = 4022882534029739946L;

	/**
	 * 
	 */
	public NoEnvioDatoException() {
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param arg0
	 */
	public NoEnvioDatoException(String arg0) {
		super(arg0);
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param arg0
	 */
	public NoEnvioDatoException(Throwable arg0) {
		super(arg0);
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param arg0
	 * @param arg1
	 */
	public NoEnvioDatoException(String arg0, Throwable arg1) {
		super(arg0, arg1);
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param codigo
	 * @param mensaje
	 * @param arg1
	 */
	public NoEnvioDatoException(String codigo, String mensaje, Throwable arg1) {
		super(codigo, mensaje, arg1);
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param arg0
	 * @param arg1
	 * @param arg2
	 * @param arg3
	 */
	public NoEnvioDatoException(String arg0, Throwable arg1, boolean arg2,
			boolean arg3) {
		super(arg0, arg1, arg2, arg3);
		// TODO Auto-generated constructor stub
	}

	public NoEnvioDatoException(String codigo, String mensaje) {
		super(codigo, mensaje);
	}
}
