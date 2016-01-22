/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.negocio.Maestro;
import pe.com.viajes.bean.negocio.Pais;

/**
 * @author Edwin
 *
 */
public interface MaestroDao {

	public boolean ingresarMaestro(Maestro maestro) throws SQLException;

	public boolean ingresarHijoMaestro(Maestro maestro) throws SQLException;

	public Maestro consultarHijoMaestro(Maestro hijoMaestro)
			throws SQLException;

	public boolean actualizarMaestro(Maestro maestro) throws SQLException;

	boolean ingresarPais(Pais pais) throws SQLException;

	List<Maestro> listarMaestros(int idEmpresa) throws SQLException;

	Maestro consultarMaestro(int id, int idEmpresa) throws SQLException;

	List<Maestro> listarHijosMaestro(int idmaestro, int idEmpresa)
			throws SQLException;

	List<BaseVO> listarPaises(int idcontinente, int idEmpresa)
			throws SQLException;

}
