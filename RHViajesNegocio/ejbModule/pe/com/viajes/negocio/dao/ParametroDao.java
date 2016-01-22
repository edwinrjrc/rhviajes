/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.negocio.Parametro;

/**
 * @author Edwin
 *
 */
public interface ParametroDao {

	public void registrarParametro(Parametro parametro) throws SQLException;

	public void actualizarParametro(Parametro parametro) throws SQLException;

	List<Parametro> listarParametros(int idEmpresa) throws SQLException;

	Parametro consultarParametro(int id, int idEmpresa) throws SQLException;
}
