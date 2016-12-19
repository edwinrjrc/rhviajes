/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.negocio.exception.ConnectionException;

/**
 * @author Edwin
 *
 */
public interface CatalogoDao {

	List<BaseVO> listarRoles(Integer idEmpresa, Connection conn) throws ConnectionException,
			SQLException;

	List<BaseVO> listarCatalogoMaestro(int maestro, int idempresa)
			throws ConnectionException, SQLException;

	List<BaseVO> listaDepartamento(Integer idEmpresa)
			throws ConnectionException, SQLException;

	List<BaseVO> listaDistrito(String idDepartamento, String idProvincia,
			Integer idEmpresa) throws ConnectionException, SQLException;

	List<BaseVO> listaProvincia(String idDepartamento, Integer idEmpresa)
			throws ConnectionException, SQLException;
}
