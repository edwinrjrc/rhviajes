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

import pe.com.viajes.bean.negocio.Parametro;
import pe.com.viajes.negocio.dao.ParametroDao;
import pe.com.viajes.negocio.util.UtilConexion;
import pe.com.viajes.negocio.util.UtilJdbc;

/**
 * @author Edwin
 *
 */
public class ParametroDaoImpl implements ParametroDao {

	/**
	 * 
	 */
	public ParametroDaoImpl() {
		// TODO Auto-generated constructor stub
	}

	@Override
	public List<Parametro> listarParametros(int idEmpresa) throws SQLException {
		List<Parametro> resultado = null;
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "select * from soporte.vw_listaparametros where idempresa = ?";

		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			cs.setInt(1, idEmpresa);
			rs = cs.executeQuery();

			resultado = new ArrayList<Parametro>();
			Parametro parametro = null;
			while (rs.next()) {
				parametro = new Parametro();
				parametro.setCodigoEntero(rs.getInt("id"));
				parametro.setNombre(UtilJdbc.obtenerCadena(rs, "nombre"));
				parametro.setDescripcion(UtilJdbc.obtenerCadena(rs,
						"descripcion"));
				parametro.setValor(UtilJdbc.obtenerCadena(rs, "valor"));
				parametro.getEstado().setCodigoCadena(
						UtilJdbc.obtenerCadena(rs, "estado"));
				parametro.getEstado()
						.setNombre(
								"A".equals(parametro.getEstado()
										.getCodigoCadena()) ? "Activo"
										: "Inactivo");
				parametro.setEditable(rs.getBoolean("editable"));
				resultado.add(parametro);
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

	@Override
	public void registrarParametro(Parametro parametro) throws SQLException {
		Connection conn = null;
		CallableStatement cs = null;
		String sql = "{ ? = call soporte.fn_ingresarparametro(?,?,?,?,?,?) }";

		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.BOOLEAN);
			cs.setInt(i++, parametro.getEmpresa().getCodigoEntero().intValue());
			cs.setString(i++,
					UtilJdbc.convertirMayuscula(parametro.getNombre()));
			cs.setString(i++,
					UtilJdbc.convertirMayuscula(parametro.getDescripcion()));
			cs.setString(i++, UtilJdbc.convertirMayuscula(parametro.getValor()));
			cs.setInt(i++, parametro.getUsuarioCreacion().getCodigoEntero().intValue());
			cs.setString(i++, parametro.getIpCreacion());

			cs.execute();
		} catch (SQLException e) {
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
	}

	@Override
	public void actualizarParametro(Parametro parametro) throws SQLException {
		Connection conn = null;
		CallableStatement cs = null;
		String sql = "{ ? = call soporte.fn_actualizarparametro(?,?,?,?,?,?,?) }";

		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.BOOLEAN);
			cs.setInt(i++, parametro.getEmpresa().getCodigoEntero().intValue());
			cs.setInt(i++, parametro.getCodigoEntero());
			cs.setString(i++,
					UtilJdbc.convertirMayuscula(parametro.getNombre()));
			cs.setString(i++,
					UtilJdbc.convertirMayuscula(parametro.getDescripcion()));
			cs.setString(i++, UtilJdbc.convertirMayuscula(parametro.getValor()));
			cs.setString(i++, UtilJdbc.convertirMayuscula(parametro.getEstado()
					.getCodigoCadena()));
			cs.setBoolean(i++, parametro.isEditable());

			cs.execute();
		} catch (SQLException e) {
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
	}

	@Override
	public Parametro consultarParametro(int id, int idEmpresa) throws SQLException {
		Parametro resultado = null;
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "select * from soporte.vw_listaparametros where id = ? and idempresa = ?";

		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			cs.setInt(1, id);
			cs.setInt(2, idEmpresa);
			rs = cs.executeQuery();

			if (rs.next()) {
				resultado = new Parametro();
				resultado.setCodigoEntero(rs.getInt("id"));
				resultado.setNombre(UtilJdbc.obtenerCadena(rs, "nombre"));
				resultado.setDescripcion(UtilJdbc.obtenerCadena(rs,
						"descripcion"));
				resultado.setValor(UtilJdbc.obtenerCadena(rs, "valor"));
				resultado.getEstado().setCodigoCadena(
						UtilJdbc.obtenerCadena(rs, "estado"));
				resultado.setEditable(rs.getBoolean("editable"));
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
