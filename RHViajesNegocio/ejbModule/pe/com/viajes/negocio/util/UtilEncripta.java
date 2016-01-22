/**
 * 
 */
package pe.com.viajes.negocio.util;

import org.jasypt.encryption.pbe.StandardPBEStringEncryptor;
import org.jasypt.exceptions.EncryptionOperationNotPossibleException;

import pe.com.viajes.negocio.exception.ErrorEncriptacionException;

/**
 * @author edwreb
 *
 */
public class UtilEncripta {

	/**
	 * 
	 */
	public UtilEncripta() {
		// TODO Auto-generated constructor stub
	}

	public static String encriptaCadena(String cadena)
			throws ErrorEncriptacionException {
		try {
			StandardPBEStringEncryptor s = new StandardPBEStringEncryptor();
			s.setPassword("uniquekey");

			return s.encrypt(cadena);
		} catch (EncryptionOperationNotPossibleException e) {
			throw new ErrorEncriptacionException("Error en la Encriptacion");
		} catch (Exception e) {
			throw new ErrorEncriptacionException("Error en la Encriptacion");
		}
	}

	public static String desencriptaCadena(String cadena)
			throws ErrorEncriptacionException {
		try {
			StandardPBEStringEncryptor s = new StandardPBEStringEncryptor();
			s.setPassword("uniquekey");

			return s.decrypt(cadena);

		} catch (EncryptionOperationNotPossibleException e) {
			throw new ErrorEncriptacionException("Error en la Desencriptacion");
		} catch (Exception e) {
			throw new ErrorEncriptacionException("Error en la Desencriptacion");
		}
	}
}
