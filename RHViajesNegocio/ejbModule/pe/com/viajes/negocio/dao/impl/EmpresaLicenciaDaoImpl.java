/**
 * 
 */
package pe.com.viajes.negocio.dao.impl;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.negocio.dao.EmpresaLicenciaDao;
import pe.com.viajes.negocio.util.UtilJdbc;

/**
 * @author Edwin
 *
 */
public class EmpresaLicenciaDaoImpl implements EmpresaLicenciaDao {

	/* (non-Javadoc)
	 * @see pe.com.viajes.negocio.dao.EmpresaLicenciaDao#consultarEmpresaLicencia(java.lang.String)
	 */
	@Override
	public BaseVO consultarEmpresaLicencia(String nombreDominio, Connection conn)
			throws SQLException, Exception {
		BaseVO empresa = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "";
		try{
			sql = "{ ? = call licencia.fn_consultaempresa(?) }";
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.OTHER);
			cs.setString(2, nombreDominio);
			
			cs.execute();
			
			rs = (ResultSet) cs.getObject(1);
			empresa = new BaseVO();
			if (rs.next()){
				empresa.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				empresa.setNombre(UtilJdbc.obtenerCadena(rs, "nombrecomercial"));
			}
			
			return empresa;
		}
		catch (SQLException e){
			throw new SQLException(e);
		}
		finally{
			if (rs != null){
				rs.close();
			}
			if (cs != null){
				cs.close();
			}
		}
	}

}
