/**
 * 
 */
package pe.com.viajes.negocio.exception;

/**
 * @author EDWREB
 *
 */
public class EjecucionSQLException extends RHViajesException {

	private static final long serialVersionUID = 4120398851674954736L;

	/**
	 * 
	 */
	public EjecucionSQLException() {
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param arg0
	 */
	public EjecucionSQLException(String arg0) {
		super(arg0);
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param arg0
	 * @param arg1
	 */
	public EjecucionSQLException(String arg0, String arg1) {
		super(arg0, arg1);
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param arg0
	 */
	public EjecucionSQLException(Throwable arg0) {
		super(arg0);
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param arg0
	 * @param arg1
	 */
	public EjecucionSQLException(String arg0, Throwable arg1) {
		super(arg0, arg1);
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param codigo
	 * @param mensaje
	 * @param arg1
	 */
	public EjecucionSQLException(String codigo, String mensaje, Throwable arg1) {
		super(codigo, mensaje, arg1);
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param arg0
	 * @param arg1
	 * @param arg2
	 * @param arg3
	 */
	public EjecucionSQLException(String arg0, Throwable arg1, boolean arg2,
			boolean arg3) {
		super(arg0, arg1, arg2, arg3);
		// TODO Auto-generated constructor stub
	}

}
