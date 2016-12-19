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
import java.util.Date;
import java.util.List;

import org.apache.commons.lang3.StringUtils;

import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.bean.recursoshumanos.UsuarioAsistencia;
import pe.com.viajes.negocio.dao.AuditoriaDao;
import pe.com.viajes.negocio.util.UtilConexion;
import pe.com.viajes.negocio.util.UtilJdbc;

/**
 * @author Edwin
 *
 */
public class AuditoriaDaoImpl implements AuditoriaDao {

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * pe.com.viajes.negocio.dao.AuditoriaDao#registrarEventoSesion(pe.com
	 * .logistica.bean.negocio.Usuario, java.lang.Integer)
	 */
	@Override
	public boolean registrarEventoSesion(Usuario usuario, Integer tipoEvento)
			throws SQLException {
		Connection conn = null;
		CallableStatement cs = null;
		String sql = "";

		try {
			sql = "{ ? = call auditoria.fn_registrareventosesionsistema(?,?,?,?,?,?) }";
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.BOOLEAN);
			cs.setInt(i++, usuario.getEmpresa().getCodigoEntero().intValue());
			cs.setInt(i++, usuario.getCodigoEntero().intValue());
			cs.setString(i++, usuario.getUsuario());
			cs.setInt(i++, tipoEvento.intValue());
			cs.setInt(i++, usuario.getUsuarioCreacion().getCodigoEntero());
			cs.setString(i++, usuario.getIpCreacion());
			cs.execute();

			return cs.getBoolean(1);
		} catch (SQLException e) {
			throw new SQLException(e);
		} finally {
			if (cs != null) {
				cs.close();
			}
			if (conn != null) {
				conn.close();
			}
		}
	}
	
	@Override
	public boolean registrarEventoSesion(Usuario usuario, Integer tipoEvento, Connection conn)
			throws SQLException {
		CallableStatement cs = null;
		String sql = "";

		try {
			sql = "{ ? = call auditoria.fn_registrareventosesionsistema(?,?,?,?,?,?) }";
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.BOOLEAN);
			cs.setInt(i++, usuario.getEmpresa().getCodigoEntero().intValue());
			cs.setInt(i++, usuario.getCodigoEntero().intValue());
			cs.setString(i++, usuario.getUsuario());
			cs.setInt(i++, tipoEvento.intValue());
			cs.setInt(i++, usuario.getUsuarioCreacion().getCodigoEntero());
			cs.setString(i++, usuario.getIpCreacion());
			cs.execute();

			return cs.getBoolean(1);
		} finally {
			if (cs != null) {
				cs.close();
			}
		}
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * pe.com.viajes.negocio.dao.AuditoriaDao#listarHoraEntradaXDia(java.
	 * util.Date)
	 */
	@Override
	public List<UsuarioAsistencia> listarHoraEntradaXDia(Date fecha, Integer idEmpresa)
			throws SQLException {
		List<UsuarioAsistencia> resultado = null;
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "";

		try {
			sql = "{ ? = call auditoria.fn_consultaasistencia(?,?) }";
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.OTHER);
			cs.setInt(i++, idEmpresa.intValue());
			cs.setDate(i++, UtilJdbc.convertirUtilDateSQLDate(fecha));
			cs.execute();

			rs = (ResultSet) cs.getObject(1);
			resultado = new ArrayList<UsuarioAsistencia>();
			UsuarioAsistencia usuarioAsitencia = null;
			while (rs.next()) {
				usuarioAsitencia = new UsuarioAsistencia();
				String nombre = UtilJdbc.obtenerCadena(rs, "nombres");
				String apellidopaterno = UtilJdbc.obtenerCadena(rs,
						"apepaterno");
				String apellidomaterno = UtilJdbc.obtenerCadena(rs,
						"apematerno");
				usuarioAsitencia.getUsuario().setNombre(
						StringUtils.normalizeSpace(nombre + " "
								+ apellidopaterno + " " + apellidomaterno));
				usuarioAsitencia.setFechaIngreso(UtilJdbc.obtenerFecha(rs,
						"horaInicio"));
				resultado.add(usuarioAsitencia);
			}

			return resultado;
		} catch (SQLException e) {
			throw new SQLException(e);
		} finally {
			if (cs != null) {
				cs.close();
			}
			if (conn != null) {
				conn.close();
			}
		}
	}

}
