/**
 * 
 */
package pe.com.viajes.negocio.dao.impl;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import pe.com.viajes.negocio.dao.EjecutaSentenciaSQLDao;

/**
 * @author EDWREB
 *
 */
public class EjecutaSentenciaSQLDaoImpl implements EjecutaSentenciaSQLDao {

	/* (non-Javadoc)
	 * @see pe.com.viajes.negocio.dao.impl.EjecutaSentenciaSQLDao#ejecutarSentencia(java.lang.String, java.sql.Connection)
	 */
	@Override
	public void ejecutarSentencia(String sql, Connection conn) throws SQLException{
		CallableStatement cs = null; 
		try {
			cs = conn.prepareCall(sql);
			cs.execute();
		} catch (SQLException e) {
			throw new SQLException(e);
		} finally{
			if (cs != null){
				cs.close();
			}
		}
	}

	/* (non-Javadoc)
	 * @see pe.com.viajes.negocio.dao.impl.EjecutaSentenciaSQLDao#ejecutarConsulta(java.lang.String, java.sql.Connection)
	 */
	@Override
	public Object ejecutarConsulta(String sql, Connection conn) throws SQLException{
		List<Map<String, Object>> resultadoSelect = new ArrayList<Map<String, Object>>();
		CallableStatement cs = null;
		ResultSet rs = null;
		
		try {
			cs = conn.prepareCall(sql);
			rs = cs.executeQuery();
			
			ResultSetMetaData rsmd = rs.getMetaData();
			
			String[] columnas = new String[rsmd.getColumnCount()];
			for (int i=0; i<columnas.length; i++){
				columnas[i] = rsmd.getColumnName(i);
			}
			
			Map<String, Object> bean = null;
			while(rs.next()){
				int i=0;
				bean = new HashMap<String, Object>();
				bean.put(columnas[i], rs.getObject(columnas[i]));
			}
			
		} catch (SQLException e) {
			throw new SQLException(e);
		} finally{
			if (rs != null){
				rs.close();
			}
			if (cs != null){
				cs.close();
			}
		}
		
		return null;
	}
}
