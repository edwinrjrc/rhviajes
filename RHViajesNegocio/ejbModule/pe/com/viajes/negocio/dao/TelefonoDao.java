/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.negocio.Telefono;

/**
 * @author Edwin
 *
 */
public interface TelefonoDao {

	public int registrarTelefono(Telefono telefono, Connection conexion)
			throws SQLException;

	public int actualizarTelefono(Telefono telefono, Connection conexion)
			throws SQLException;

	void registrarTelefonoDireccion(int idTelefono, int idDireccion,
			Connection conexion) throws SQLException;

	void registrarTelefonoPersona(int idTelefono, int idPersona,
			Connection conexion) throws SQLException;

	List<Telefono> consultarTelefonoDireccion(int idDireccion, Connection conn)
			throws SQLException;

	List<Telefono> consultarTelefonosDireccion(int idDireccion)
			throws SQLException;

	List<Telefono> consultarTelefonoContacto(int idcontacto, Connection conn)
			throws SQLException;

	List<Telefono> consultarTelefonosDireccion(int idDireccion, Connection conn)
			throws SQLException;

	List<Telefono> consultarTelefonosXPersona(int idPersona)
			throws SQLException;

	List<Telefono> consultarTelefonosXPersona(int idPersona, Connection conn)
			throws SQLException;
}
