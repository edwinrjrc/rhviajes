/**
 * 
 */
package pe.com.viajes.web.servicio;

import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.negocio.Parametro;

/**
 * @author Edwin
 *
 */
public interface ParametroServicio {

	public void registrarParametro(Parametro parametro) throws SQLException;

	public void actualizarParametro(Parametro parametro) throws SQLException;

	List<Parametro> listarParametros(Integer idEmpresa) throws SQLException;

	Parametro consultarParametro(int id, Integer idEmpresa) throws SQLException;
}
