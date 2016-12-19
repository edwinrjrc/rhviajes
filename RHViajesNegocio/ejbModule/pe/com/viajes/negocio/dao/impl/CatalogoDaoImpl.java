/**
 * 
 */
package pe.com.viajes.negocio.dao.impl;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.negocio.dao.CatalogoDao;
import pe.com.viajes.negocio.exception.ConnectionException;
import pe.com.viajes.negocio.util.UtilConexion;
import pe.com.viajes.negocio.util.UtilJdbc;

/**
 * @author Edwin
 *
 */
public class CatalogoDaoImpl implements CatalogoDao {

	/**
	 * 
	 */
	public CatalogoDaoImpl() {
	}

	@Override
	public List<BaseVO> listarRoles(Integer idEmpresa, Connection conn) throws ConnectionException, SQLException {
		List<BaseVO> resultado = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "select id, nombre from seguridad.rol where idempresa = ?";

		try {
			cs = conn.prepareCall(sql);
			cs.setInt(1, idEmpresa.intValue());
			rs = cs.executeQuery();

			resultado = new ArrayList<BaseVO>();
			BaseVO rol = null;
			while (rs.next()) {
				rol = new BaseVO();
				rol.setCodigoEntero(rs.getInt("id"));
				rol.setNombre(UtilJdbc.obtenerCadena(rs, "nombre"));
				resultado.add(rol);
			}
		} catch (SQLException e) {
			resultado = null;
			throw new SQLException(e);
		} finally {
			if (rs != null) {
				rs.close();
			}
			if (cs != null) {
				cs.close();
			}
		}

		return resultado;
	}

	@Override
	public List<BaseVO> listarCatalogoMaestro(int maestro, int idempresa)
			throws ConnectionException, SQLException {
		List<BaseVO> resultado = null;
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "select * from soporte.vw_catalogomaestro where idmaestro = ? and idempresa = ?";

		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			cs.setInt(1, maestro);
			cs.setInt(2, idempresa);
			rs = cs.executeQuery();

			resultado = new ArrayList<BaseVO>();
			BaseVO maestroVO = null;
			while (rs.next()) {
				maestroVO = new BaseVO();
				maestroVO.setCodigoEntero(rs.getInt("id"));
				maestroVO.setNombre(UtilJdbc.obtenerCadena(rs, "nombre"));
				maestroVO.setAbreviatura(UtilJdbc.obtenerCadena(rs, "abreviatura"));
				resultado.add(maestroVO);
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
				} catch (SQLException e1) {
					throw new SQLException(e);
				}
			}
		}

		return resultado;
	}

	@Override
	public List<BaseVO> listaDepartamento(Integer idEmpresa) throws ConnectionException,
			SQLException {
		List<BaseVO> resultado = null;
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "select * from soporte.vw_catalogodepartamento where idempresa = ?";

		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			cs.setInt(1, idEmpresa.intValue());
			rs = cs.executeQuery();

			resultado = new ArrayList<BaseVO>();
			BaseVO maestroVO = null;
			while (rs.next()) {
				maestroVO = new BaseVO();
				maestroVO.setCodigoCadena(rs.getString("iddepartamento"));
				maestroVO.setNombre(UtilJdbc.obtenerCadena(rs, "descripcion"));
				resultado.add(maestroVO);
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
				} catch (SQLException e1) {
					throw new SQLException(e);
				}
			}
		}

		return resultado;
	}

	@Override
	public List<BaseVO> listaProvincia(String idDepartamento, Integer idEmpresa)
			throws ConnectionException, SQLException {
		List<BaseVO> resultado = null;
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "select * from soporte.vw_catalogoprovincia where iddepartamento = ? and idempresa = ?";

		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			cs.setString(1, idDepartamento);
			cs.setInt(2, idEmpresa.intValue());
			rs = cs.executeQuery();

			resultado = new ArrayList<BaseVO>();
			BaseVO maestroVO = null;
			while (rs.next()) {
				maestroVO = new BaseVO();
				maestroVO.setCodigoCadena(rs.getString("idprovincia"));
				maestroVO.setNombre(UtilJdbc.obtenerCadena(rs, "descripcion"));
				resultado.add(maestroVO);
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
				} catch (SQLException e1) {
					throw new SQLException(e);
				}
			}
		}

		return resultado;
	}

	@Override
	public List<BaseVO> listaDistrito(String idDepartamento, String idProvincia, Integer idEmpresa)
			throws ConnectionException, SQLException {
		List<BaseVO> resultado = null;
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "select * from soporte.vw_catalogodistrito where iddepartamento = ? and idprovincia = ? and idempresa = ?";

		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			cs.setString(1, idDepartamento);
			cs.setString(2, idProvincia);
			cs.setInt(3, idEmpresa.intValue());
			rs = cs.executeQuery();

			resultado = new ArrayList<BaseVO>();
			BaseVO maestroVO = null;
			while (rs.next()) {
				maestroVO = new BaseVO();
				maestroVO.setCodigoCadena(rs.getString("iddistrito"));
				maestroVO.setNombre(UtilJdbc.obtenerCadena(rs, "descripcion"));
				resultado.add(maestroVO);
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
				} catch (SQLException e1) {
					throw new SQLException(e);
				}
			}
		}

		return resultado;
	}

}
