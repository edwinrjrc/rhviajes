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

import pe.com.viajes.bean.negocio.CorreoClienteMasivo;
import pe.com.viajes.negocio.dao.CorreoMasivoDao;
import pe.com.viajes.negocio.util.UtilConexion;
import pe.com.viajes.negocio.util.UtilJdbc;

/**
 * @author Edwin
 *
 */
public class CorreoMasivoDaoImpl implements CorreoMasivoDao {

	/*
	 * (non-Javadoc)
	 * 
	 * @see pe.com.viajes.negocio.dao.CorreoMasivoDao#listarClientesCorreo()
	 */
	@Override
	public List<CorreoClienteMasivo> listarClientesCorreo(int idEmpresa) throws SQLException {
		List<CorreoClienteMasivo> resultado = null;
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "{ ? = call negocio.fn_listarclientescorreo(?)}";

		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.OTHER);
			cs.setInt(i++, idEmpresa);

			cs.execute();
			rs = (ResultSet) cs.getObject(1);

			resultado = new ArrayList<CorreoClienteMasivo>();
			CorreoClienteMasivo correoClienteMasivo = null;
			while (rs.next()) {
				correoClienteMasivo = new CorreoClienteMasivo();
				correoClienteMasivo.getCliente().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idcliente"));
				correoClienteMasivo.getCliente().setNombres(
						UtilJdbc.obtenerCadena(rs, "nomcliente"));
				correoClienteMasivo.getCliente().setApellidoPaterno(
						UtilJdbc.obtenerCadena(rs, "apepatcliente"));
				correoClienteMasivo.getCliente().setApellidoMaterno(
						UtilJdbc.obtenerCadena(rs, "apematcliente"));
				correoClienteMasivo.getContacto().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idcontacto"));
				correoClienteMasivo.getContacto().setNombres(
						UtilJdbc.obtenerCadena(rs, "nomcontacto"));
				correoClienteMasivo.getContacto().setApellidoPaterno(
						UtilJdbc.obtenerCadena(rs, "apepatcontacto"));
				correoClienteMasivo.getContacto().setApellidoMaterno(
						UtilJdbc.obtenerCadena(rs, "apematcontacto"));
				correoClienteMasivo.getCorreoElectronico().setDireccion(
						UtilJdbc.obtenerCadena(rs, "correo"));
				correoClienteMasivo.setEnviarCorreo(UtilJdbc.obtenerBoolean(rs,
						"recibirPromociones"));

				resultado.add(correoClienteMasivo);
			}

		} catch (SQLException e) {
			resultado = null;
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

}
