/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.base.Persona;
import pe.com.viajes.bean.negocio.Cliente;

/**
 * @author Edwin
 *
 */
public interface ClienteDao {

	public List<Cliente> consultarPersona(Persona persona) throws SQLException;

	void registroCliente(Cliente cliente, Connection conexion)
			throws SQLException;

	void actualizarPersonaAdicional(Cliente cliente, Connection conexion)
			throws SQLException;

	List<Cliente> buscarPersona(Persona persona) throws SQLException;

	List<Cliente> listarClientes(Persona persona) throws SQLException;

	List<Cliente> listarClientes(Persona persona, Connection conn)
			throws SQLException;

	List<Cliente> consultarClientesNovios(Cliente cliente) throws SQLException;

	Cliente consultarCliente(int idcliente, int idEmpresa) throws SQLException;

	List<Cliente> listarClientesNovios(String genero, int idEmpresa)
			throws SQLException;

	List<Cliente> listarClienteCumpleanieros(int idEmpresa) throws SQLException;
}