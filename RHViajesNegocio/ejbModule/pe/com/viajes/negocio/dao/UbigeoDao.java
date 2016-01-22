/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.sql.SQLException;

import pe.com.viajes.bean.negocio.Ubigeo;

/**
 * @author Edwin
 *
 */
public interface UbigeoDao {

	public Ubigeo consultarUbigeo(String idUbigeo) throws SQLException;
}
