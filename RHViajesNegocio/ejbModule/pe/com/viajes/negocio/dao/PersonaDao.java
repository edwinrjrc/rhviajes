/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.sql.Connection;
import java.sql.SQLException;

import pe.com.viajes.bean.base.Persona;

/**
 * @author Edwin
 * 
 */
public interface PersonaDao {

	int registrarPersona(Persona persona, Connection conexion)
			throws SQLException;

	int actualizarPersona(Persona persona, Connection conexion)
			throws SQLException;

}
