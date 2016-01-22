/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.base.CorreoElectronico;

/**
 * @author Edwin
 *
 */
public interface CorreoElectronicoDao {

	List<CorreoElectronico> consultarCorreosXPersona(int idPersona,
			int idEmpresa, Connection conn) throws SQLException;

	List<CorreoElectronico> consultarCorreosXPersona(int idPersona,
			int idEmpresa) throws SQLException;
}
