/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.negocio.MaestroServicio;

/**
 * @author edwreb
 *
 */
public interface MaestroServicioDao {

	public Integer ingresarMaestroServicio(MaestroServicio servicio, Connection conn)
			throws SQLException;

	public boolean actualizarMaestroServicio(MaestroServicio servicio)
			throws SQLException;

	List<MaestroServicio> listarMaestroServicios(int idEmpresa)
			throws SQLException;

	List<MaestroServicio> listarMaestroServiciosAdm(int idEmpresa)
			throws SQLException;

	List<MaestroServicio> listarMaestroServiciosFee(int idEmpresa)
			throws SQLException;

	List<MaestroServicio> listarMaestroServiciosImpto(int idEmpresa)
			throws SQLException;

	MaestroServicio consultarMaestroServicio(int idMaestroServicio,
			int idEmpresa) throws SQLException;

	MaestroServicio consultarMaestroServicio(int idMaestroServicio,
			int idEmpresa, Connection conn) throws SQLException;

	List<MaestroServicio> listarMaestroServiciosIgv(int idEmpresa)
			throws SQLException;

	List<BaseVO> consultarServicioDependientes(Integer idServicio, int idEmpresa)
			throws SQLException;

	List<MaestroServicio> consultarServiciosInvisibles(Integer idServicio,
			int idEmpresa) throws SQLException, Exception;

	void ingresarServicioMaestroServicio(MaestroServicio servicio,
			Connection conn) throws SQLException, Exception;

	List<MaestroServicio> listarMaestroServiciosPadre(int idEmpresa)
			throws SQLException;

}
