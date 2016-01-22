/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.negocio.Cliente;
import pe.com.viajes.bean.negocio.ProgramaNovios;
import pe.com.viajes.bean.negocio.ServicioNovios;

/**
 * @author Edwin
 *
 */
public interface ServicioNoviosDao {

	public Integer registrarNovios(ProgramaNovios programaNovios)
			throws SQLException;

	Integer registrarNovios(ProgramaNovios programaNovios, Connection conn)
			throws SQLException, Exception;

	boolean registrarInvitado(Cliente invitado, Integer idnovios,
			Connection conn) throws SQLException, Exception;

	public List<ProgramaNovios> consultarNovios(ProgramaNovios programaNovios)
			throws SQLException;

	boolean ingresarServicioNovios(ServicioNovios servicioNovios, int idnovios,
			Connection conexion) throws SQLException;

	List<Cliente> consultarInvitasosNovios(int idnovios, Connection conexion)
			throws SQLException;

	List<ProgramaNovios> consultarNovios(ProgramaNovios programaNovios,
			Connection conn) throws SQLException;

	Integer actualizarNovios(ProgramaNovios programaNovios, Connection conn)
			throws SQLException, Exception;

	boolean eliminarInvitadosNovios(ProgramaNovios programaNovios,
			Connection conn) throws SQLException, Exception;
}
