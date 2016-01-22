/**
 * 
 */
package pe.com.viajes.negocio.dao.impl;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import pe.com.viajes.bean.base.CorreoElectronico;
import pe.com.viajes.negocio.dao.CorreoElectronicoDao;
import pe.com.viajes.negocio.util.UtilConexion;
import pe.com.viajes.negocio.util.UtilJdbc;

/**
 * @author Edwin
 * 
 */
public class CorreoElectronicoDaoImpl implements CorreoElectronicoDao {

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * pe.com.viajes.negocio.dao.CorreoElectronicoDao#consultarCorreosXPersona
	 * ()
	 */
	@Override
	public List<CorreoElectronico> consultarCorreosXPersona(int idPersona, int idEmpresa)
			throws SQLException {
		Connection conn = null;
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_telefonosxpersona(?,?) }";
		ResultSet rs = null;
		List<CorreoElectronico> resultado = null;

		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.OTHER);
			cs.setInt(i++, idEmpresa);
			cs.setInt(i++, idPersona);
			cs.execute();

			rs = (ResultSet) cs.getObject(1);
			resultado = new ArrayList<CorreoElectronico>();
			CorreoElectronico bean = null;
			while (rs.next()) {
				bean = new CorreoElectronico();
				bean.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				bean.setDireccion(UtilJdbc.obtenerCadena(rs, "correo"));
				resultado.add(bean);
			}
		} catch (SQLException e) {
			throw new SQLException(e);
		} finally {
			try {
				if (rs != null) {
					rs.close();
				}
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
	public List<CorreoElectronico> consultarCorreosXPersona(int idPersona, int idEmpresa,
			Connection conn) throws SQLException {
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_telefonosxpersona(?,?) }";
		ResultSet rs = null;
		List<CorreoElectronico> resultado = null;

		try {
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.OTHER);
			cs.setInt(i++, idEmpresa);
			cs.setInt(i++, idPersona);
			cs.execute();

			rs = (ResultSet) cs.getObject(1);
			resultado = new ArrayList<CorreoElectronico>();
			CorreoElectronico bean = null;
			while (rs.next()) {
				bean = new CorreoElectronico();
				bean.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				bean.setDireccion(UtilJdbc.obtenerCadena(rs, "correo"));
				resultado.add(bean);
			}
		} catch (SQLException e) {
			throw new SQLException(e);
		} finally {
			try {
				if (rs != null) {
					rs.close();
				}
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
