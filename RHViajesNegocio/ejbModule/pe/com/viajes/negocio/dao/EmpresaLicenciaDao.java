/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.sql.Connection;
import java.sql.SQLException;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;

/**
 * @author Edwin
 *
 */
public interface EmpresaLicenciaDao {
	
	/**
	 * 
	 * @param nombreDominio
	 * @return
	 * @throws Exception 
	 * @throws ErrorConsultaDataException
	 */
	BaseVO consultarEmpresaLicencia(String nombreDominio, Connection conn)
			throws SQLException, Exception;

}
