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
	public String ejecutarSentencia(String sql, Connection conn) throws SQLException{
		CallableStatement cs = null; 
		try {
			cs = conn.prepareCall(sql);
			cs.execute();
			
			int filasAfectada = cs.getUpdateCount();
			
			return filasAfectada + "filas afectadas";
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
	public Map<String, Object> ejecutarConsulta(String sql, Connection conn) throws SQLException{
		Map<String, Object> resultado = new HashMap<String, Object>();
		List<Map<String, Object>> resultadoSelect = new ArrayList<Map<String, Object>>();
		CallableStatement cs = null;
		ResultSet rs = null;
		
		try {
			cs = conn.prepareCall(sql);
			rs = cs.executeQuery();
			
			ResultSetMetaData rsmd = rs.getMetaData();
			
			String[] columnas = new String[rsmd.getColumnCount()];
			for (int i=0; i<columnas.length; i++){
				columnas[i] = rsmd.getColumnName(i+1);
			}
			
			Map<String, Object> bean = null;
			while(rs.next()){
				bean = new HashMap<String, Object>();
				for (int j=0; j<columnas.length; j++){
					bean.put(columnas[j], rs.getObject(columnas[j]));
				}
				resultadoSelect.add(bean);
			}
			
			resultado.put("cabecera", columnas);
			resultado.put("data", resultadoSelect);
			
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
		
		return resultado;
	}
}
