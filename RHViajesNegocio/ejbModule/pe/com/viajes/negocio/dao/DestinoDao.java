/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.negocio.Destino;

/**
 * @author Edwin
 *
 */
public interface DestinoDao {

	public boolean ingresarDestino(Destino destino) throws SQLException;

	public boolean actualizarDestino(Destino destino) throws SQLException;

	List<Destino> listarDestinos(int idEmpresa) throws SQLException;

	Destino consultarDestino(int idDestino, int idEmpresa) throws SQLException;

	Destino consultarDestino(int idDestino, int idEmpresa, Connection conn)
			throws SQLException;

	List<Destino> buscarDestinos(String nombreDestino, int idEmpresa)
			throws SQLException;

	Destino consultarDestinoIATA(String codigoIATA, int idEmpresa)
			throws SQLException;
}
