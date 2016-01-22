/**
 * 
 */
package pe.com.viajes.negocio.dao.impl;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Types;

import pe.com.viajes.negocio.dao.ComunDao;
import pe.com.viajes.negocio.util.UtilConexion;

/**
 * @author Edwin
 *
 */
public class ComunDaoImpl implements ComunDao {

	/*
	 * (non-Javadoc)
	 * 
	 * @see pe.com.viajes.negocio.dao.ComunDao#obtenerSiguienteSecuencia()
	 */
	@Override
	public Integer obtenerSiguienteSecuencia() throws SQLException, Exception {
		Integer resultado = null;
		Connection conn = null;
		CallableStatement cs = null;
		String sql = "{ ? = call soporte.fn_siguientesequencia() }";

		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.INTEGER);
			cs.execute();
			resultado = cs.getInt(1);

		} catch (SQLException e) {
			resultado = null;
			throw new SQLException(e);
		} finally {
			try {
				if (cs != null) {
					cs.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch (SQLException e) {
				try {
					if (conn != null) {
						conn.close();
					}
					throw new SQLException(e);
				} catch (SQLException e1) {
					throw new SQLException(e);
				}
			}
		}

		return resultado;
	}

	@Override
	public Integer obtenerSiguienteSecuencia(Connection conn)
			throws SQLException, Exception {
		Integer resultado = null;
		CallableStatement cs = null;
		String sql = "{ ? = call soporte.fn_siguientesequencia() }";

		try {
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.INTEGER);
			cs.execute();
			resultado = cs.getInt(1);

		} catch (SQLException e) {
			resultado = null;
			throw new SQLException(e);
		} finally {
			try {
				if (cs != null) {
					cs.close();
				}

			} catch (SQLException e) {
				throw new SQLException(e);
			}
		}

		return resultado;
	}

}
