/**
 * 
 */
package pe.com.viajes.negocio.dao;

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
	 * @throws ErrorConsultaDataException
	 */
	public BaseVO consultarEmpresaLicencia(String nombreDominio) throws SQLException;

}
