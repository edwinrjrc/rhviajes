/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.negocio.ConfiguracionTipoServicio;

/**
 * @author Edwin
 *
 */
public interface ConfiguracionServicioDao {

	boolean eliminarConfiguracion(
			ConfiguracionTipoServicio configuracionTipoServicio, Connection conn)
			throws SQLException;

	public boolean registrarConfiguracionServicio(
			ConfiguracionTipoServicio configuracion, Connection conn)
			throws SQLException;

	ConfiguracionTipoServicio consultarConfiguracionServicio(
			Integer idTipoServicio, Integer idEmpresa) throws SQLException,
			Exception;

	List<ConfiguracionTipoServicio> listarConfiguracionServicios(
			Integer idEmpresa) throws SQLException, Exception;

	List<BaseVO> listarTipoServicios(Integer idEmpresa) throws SQLException,
			Exception;
}
