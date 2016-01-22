/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.sql.Connection;
import java.sql.SQLException;

/**
 * @author Edwin
 *
 */
public interface ComunDao {

	public Integer obtenerSiguienteSecuencia() throws SQLException, Exception;

	Integer obtenerSiguienteSecuencia(Connection conn) throws SQLException,
			Exception;

}
