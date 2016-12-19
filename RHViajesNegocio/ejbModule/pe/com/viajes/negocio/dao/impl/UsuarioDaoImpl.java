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

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.negocio.dao.UsuarioDao;
import pe.com.viajes.negocio.exception.ErrorEncriptacionException;
import pe.com.viajes.negocio.util.UtilConexion;
import pe.com.viajes.negocio.util.UtilEncripta;
import pe.com.viajes.negocio.util.UtilJdbc;

/**
 * @author Edwin
 *
 */
public class UsuarioDaoImpl implements UsuarioDao {

	private Integer idEmpresa = null;

	public UsuarioDaoImpl(Integer idEmpresa) {
		this.idEmpresa = idEmpresa;
	}

	@Override
	public Integer registrarUsuario(Usuario usuario, Connection conn) throws SQLException,
			ErrorEncriptacionException {
		Integer resultado = 0;
		CallableStatement cs = null;
		String sql = "{? = call seguridad.fn_ingresarusuario(?,?,?,?,?,?,?,?,?,?)}";

		try {
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.INTEGER);
			cs.setInt(2, idEmpresa.intValue());
			cs.setString(3, usuario.getUsuario());
			cs.setString(4,
					UtilEncripta.encriptaCadena(usuario.getCredencial()));
			cs.setString(5, UtilJdbc.convertirMayuscula(usuario.getNombres()));
			cs.setString(6,
					UtilJdbc.convertirMayuscula(usuario.getApellidoPaterno()));
			cs.setString(7,
					UtilJdbc.convertirMayuscula(usuario.getApellidoMaterno()));
			cs.setDate(8, UtilJdbc.convertirUtilDateSQLDate(usuario
					.getFechaNacimiento()));
			cs.setBoolean(9, usuario.isVendedor());
			cs.setInt(10, usuario.getUsuarioCreacion().getCodigoEntero().intValue());
			cs.setString(11, usuario.getUsuarioCreacion().getIpCreacion());
			cs.execute();

			resultado = cs.getInt(1);
		} catch (SQLException e) {
			resultado = 0;
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

	@Override
	public boolean actualizarUsuario(Usuario usuario, Connection conn) throws SQLException {
		boolean resultado = false;
		CallableStatement cs = null;
		String sql = "{? = call seguridad.fn_actualizarusuario(?,?,?,?,?,?,?)}";

		try {
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.BOOLEAN);
			cs.setInt(2, idEmpresa.intValue());
			cs.setInt(3, usuario.getCodigoEntero());
			cs.setString(4, UtilJdbc.convertirMayuscula(usuario.getNombres()));
			cs.setString(5,
					UtilJdbc.convertirMayuscula(usuario.getApellidoPaterno()));
			cs.setString(6,
					UtilJdbc.convertirMayuscula(usuario.getApellidoMaterno()));
			cs.setInt(7, usuario.getUsuarioModificacion().getCodigoEntero().intValue());
			cs.setString(8, usuario.getIpModificacion());

			cs.execute();

			resultado = cs.getBoolean(1);
		} finally {
			if (cs != null) {
				cs.close();
			}
		}

		return resultado;
	}

	@Override
	public List<Usuario> listarUsuarios(Connection conn) throws SQLException {
		List<Usuario> resultado = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "select * from seguridad.vw_listarusuarios where idempresa = ?";

		try {
			cs = conn.prepareCall(sql);
			cs.setInt(1, idEmpresa.intValue());
			rs = cs.executeQuery();

			resultado = new ArrayList<Usuario>();
			Usuario usuario = null;
			while (rs.next()) {
				usuario = new Usuario();
				usuario.setCodigoEntero(rs.getInt("id"));
				usuario.setUsuario(UtilJdbc.obtenerCadena(rs, "usuario"));
				usuario.setNombres(UtilJdbc.obtenerCadena(rs, "nombres"));
				usuario.setApellidoPaterno(UtilJdbc.obtenerCadena(rs,
						"apepaterno"));
				usuario.setApellidoMaterno(UtilJdbc.obtenerCadena(rs,
						"apematerno"));
				usuario.setVendedor(UtilJdbc.obtenerBoolean(rs, "vendedor"));
				usuario.setFechaNacimiento(UtilJdbc.obtenerFecha(rs,
						"fecnacimiento"));
				usuario.setListaRoles(this.listarRolesUsuario(usuario.getCodigoEntero(), conn));
				resultado.add(usuario);
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
			} catch (SQLException e) {
				throw new SQLException(e);
			}
		}

		return resultado;
	}

	@Override
	public Usuario consultarUsuario(int id, Connection conn) throws SQLException {
		Usuario resultado = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "select id, usuario, credencial, nombres, apepaterno, "
				+ "apematerno, fecnacimiento, vendedor"
				+ " from seguridad.vw_listarusuarios where id = ? and idempresa = ?";

		try {
			cs = conn.prepareCall(sql);
			cs.setInt(1, id);
			cs.setInt(2, idEmpresa.intValue());
			rs = cs.executeQuery();

			resultado = new Usuario();
			if (rs.next()) {
				resultado.setCodigoEntero(rs.getInt("id"));
				resultado.setUsuario(UtilJdbc.obtenerCadena(rs, "usuario"));
				resultado.setCredencial(UtilJdbc
						.obtenerCadena(rs, "credencial"));
				resultado.setNombres(UtilJdbc.obtenerCadena(rs, "nombres"));
				resultado.setApellidoPaterno(UtilJdbc.obtenerCadena(rs,
						"apepaterno"));
				resultado.setApellidoMaterno(UtilJdbc.obtenerCadena(rs,
						"apematerno"));
				resultado.setFechaNacimiento(UtilJdbc.obtenerFecha(rs,
						"fecnacimiento"));
				resultado.setVendedor(UtilJdbc.obtenerBoolean(rs, "vendedor"));
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
	public boolean inicioSesion(Usuario usuario) throws SQLException,
			ErrorEncriptacionException {
		boolean resultado = false;
		Connection conn = null;
		CallableStatement cs = null;
		String sql = "{? = call seguridad.fn_iniciosesion(?,?,?)}";

		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.BOOLEAN);
			cs.setInt(i++, idEmpresa.intValue());
			cs.setString(i++, UtilJdbc.convertirMayuscula(usuario.getUsuario()));
			cs.setString(i++,
					UtilEncripta.encriptaCadena(usuario.getCredencial()));

			cs.execute();

			resultado = cs.getBoolean(1);
		} catch (SQLException e) {
			resultado = false;
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
	public Usuario inicioSesion2(Usuario usuario, Connection conn) throws SQLException,
			ErrorEncriptacionException {
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "{ ? = call seguridad.fn_consultarusuarios(?) }";

		try {
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.OTHER);
			cs.setString(2, UtilJdbc.convertirMayuscula(usuario.getUsuario()));
			cs.execute();

			rs = (ResultSet) cs.getObject(1);

			if (rs.next()) {
				usuario.setCodigoEntero(rs.getInt("id"));
				usuario.setUsuario(UtilJdbc.obtenerCadena(rs, "usuario"));
				usuario.setNombres(UtilJdbc.obtenerCadena(rs, "nombres"));
				usuario.setApellidoPaterno(UtilJdbc.obtenerCadena(rs,
						"apepaterno"));
				usuario.setApellidoMaterno(UtilJdbc.obtenerCadena(rs,
						"apematerno"));
				String credencial = UtilJdbc.obtenerCadena(rs, "credencial");
				usuario.setEncontrado(UtilEncripta.desencriptaCadena(
						credencial).equals(usuario.getCredencial()));
				boolean caducaCredencial = UtilJdbc.obtenerBoolean(rs,
						"cambiarclave");
				Date fechaVctoCredencial = UtilJdbc.obtenerFecha(rs,
						"feccaducacredencial");
				usuario.setVendedor(UtilJdbc.obtenerBoolean(rs, "vendedor"));

				usuario.setCredencialVencida(caducaCredencial);
				if (!caducaCredencial) {
					if (fechaVctoCredencial != null) {
						usuario.setCredencialVencida((new Date())
								.after(fechaVctoCredencial));
					} else {
						usuario.setCredencialVencida(true);
					}
				}
				usuario.setListaRoles(this.listarRolesUsuario(usuario.getCodigoEntero(), conn));
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

		return usuario;
	}

	@Override
	public boolean cambiarClaveUsuario(Usuario usuario) throws SQLException,
			ErrorEncriptacionException {
		boolean resultado = false;
		Connection conn = null;
		CallableStatement cs = null;
		String sql = "{? = call seguridad.fn_cambiarclaveusuario2(?,?,?)}";

		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.BOOLEAN);
			cs.setInt(i++, idEmpresa.intValue());
			cs.setInt(i++, usuario.getCodigoEntero());
			cs.setString(i++,
					UtilEncripta.encriptaCadena(usuario.getCredencialNueva()));
			cs.execute();

			resultado = cs.getBoolean(1);
		} catch (SQLException e) {
			resultado = false;
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
	public boolean actualizarClaveUsuario(Usuario usuario, Connection conn) throws SQLException,
			ErrorEncriptacionException {
		boolean resultado = false;
		CallableStatement cs = null;
		String sql = "{? = call seguridad.fn_actualizarclaveusuario(?,?,?,?,?)}";

		try {
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.BOOLEAN);
			cs.setInt(2, idEmpresa.intValue());
			cs.setInt(3, usuario.getCodigoEntero());
			cs.setString(4,
					UtilEncripta.encriptaCadena(usuario.getCredencialNueva()));
			cs.setInt(5, usuario.getUsuarioModificacion().getCodigoEntero().intValue());
			cs.setString(6, usuario.getIpModificacion());
			cs.execute();

			resultado = cs.getBoolean(1);
		} catch (SQLException e) {
			resultado = false;
			throw new SQLException(e);
		} finally {
			if (cs != null) {
				cs.close();
			}
		}

		return resultado;
	}

	@Override
	public List<Usuario> listarVendedores(Connection conn) throws SQLException {
		List<Usuario> resultado = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "{? = call seguridad.fn_listarvendedores(?)}";

		try {
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.OTHER);
			cs.setInt(i++, idEmpresa.intValue());
			cs.execute();

			rs = (ResultSet) cs.getObject(1);
			Usuario usuario = null;
			resultado = new ArrayList<Usuario>();
			while (rs.next()) {
				usuario = new Usuario();
				usuario.setCodigoEntero(rs.getInt("id"));
				usuario.setUsuario(UtilJdbc.obtenerCadena(rs, "usuario"));
				usuario.setNombres(UtilJdbc.obtenerCadena(rs, "nombres"));
				usuario.setApellidoPaterno(UtilJdbc.obtenerCadena(rs,
						"apepaterno"));
				usuario.setApellidoMaterno(UtilJdbc.obtenerCadena(rs,
						"apematerno"));
				usuario.setVendedor(UtilJdbc.obtenerBoolean(rs, "vendedor"));
				usuario.setFechaNacimiento(UtilJdbc.obtenerFecha(rs,
						"fecnacimiento"));
				resultado.add(usuario);
			}
		} catch (SQLException e) {
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
	public boolean actualizarCredencialVencida(Usuario usuario)
			throws SQLException, ErrorEncriptacionException {
		boolean resultado = false;
		Connection conn = null;
		CallableStatement cs = null;
		String sql = "{? = call seguridad.fn_actualizarcredencialvencida(?,?,?,?,?)}";

		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.BOOLEAN);
			cs.setInt(i++, idEmpresa.intValue());
			cs.setInt(i++, usuario.getCodigoEntero());
			cs.setString(i++,
					UtilEncripta.encriptaCadena(usuario.getCredencialNueva()));
			cs.setInt(i++, usuario.getUsuarioCreacion().getCodigoEntero().intValue());
			cs.setString(i++, usuario.getIpCreacion());
			cs.execute();

			resultado = cs.getBoolean(1);
		} catch (SQLException e) {
			resultado = false;
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
	public boolean validarAgregarUsuario(Connection conn)
			throws SQLException {
		boolean resultado = false;
		CallableStatement cs = null;
		String sql = "{? = call seguridad.fn_puedeagregarusuario(?)}";

		try {
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.BOOLEAN);
			cs.setInt(2, idEmpresa.intValue());
			cs.execute();

			resultado = cs.getBoolean(1);
		} finally {
			if (cs != null) {
				cs.close();
			}
		}

		return resultado;
	}
	
	@Override
	public List<BaseVO> listarRolesUsuario(Integer idUsuario, Connection conn) throws SQLException {
		List<BaseVO> resultado = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "{? = call seguridad.fn_consultarrolesusuario(?,?)}";

		try {
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.OTHER);
			cs.setInt(2, idEmpresa.intValue());
			cs.setInt(3, idUsuario.intValue());
			cs.execute();

			rs = (ResultSet) cs.getObject(1);
			BaseVO rol = null;
			resultado = new ArrayList<BaseVO>();
			while (rs.next()) {
				rol = new BaseVO();
				rol.setCodigoEntero(rs.getInt("idrol"));
				rol.setNombre(UtilJdbc.obtenerCadena(rs, "nombre"));
				
				resultado.add(rol);
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
	
	@Override
	public boolean ingresarRolUsuario(List<BaseVO> roles, Integer idUsuario, Connection conn) throws SQLException{
		boolean resultado = false;
		CallableStatement cs = null;
		String sql = "{? = call seguridad.fn_ingresarusuariorol(?,?,?,?,?)}";

		try {
			for (BaseVO baseVO : roles) {
				cs = conn.prepareCall(sql);
				cs.registerOutParameter(1, Types.BOOLEAN);
				cs.setInt(2, idEmpresa.intValue());
				cs.setInt(3, idUsuario.intValue());
				cs.setInt(4, baseVO.getCodigoEntero().intValue());
				cs.setInt(5, baseVO.getUsuarioCreacion().getCodigoEntero().intValue());
				cs.setString(6, baseVO.getIpCreacion());
				cs.execute();

				resultado = cs.getBoolean(1);
				cs.close();
			}
			
		} catch (SQLException e) {
			resultado = false;
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
	
}
