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

import org.apache.commons.lang3.StringUtils;

import pe.com.viajes.bean.base.Persona;
import pe.com.viajes.bean.negocio.Direccion;
import pe.com.viajes.bean.negocio.Telefono;
import pe.com.viajes.negocio.dao.TelefonoDao;
import pe.com.viajes.negocio.util.UtilConexion;
import pe.com.viajes.negocio.util.UtilJdbc;

/**
 * @author Edwin
 *
 */
public class TelefonoDaoImpl implements TelefonoDao {
	
	private Integer idEmpresa = null;

	/**
	 * 
	 */
	public TelefonoDaoImpl(Integer idEmpresa) {
		this.idEmpresa = idEmpresa;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * pe.com.viajes.negocio.dao.TelefonoDao#registrarTelefono(pe.com.logistica
	 * .bean.negocio.Telefono)
	 */
	@Override
	public int registrarTelefono(Telefono telefono, Connection conexion)
			throws SQLException {
		int resultado = 0;
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_ingresartelefono(?,?,?,?,?) }";

		try {
			cs = conexion.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.INTEGER);
			cs.setInt(i++, idEmpresa.intValue());
			if (StringUtils.isNotBlank(telefono.getNumeroTelefono())) {
				cs.setString(i++, UtilJdbc.quitaEspaciosInternos(telefono.getNumeroTelefono()));
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (telefono.getEmpresaOperadora().getCodigoEntero() != null) {
				cs.setInt(i++, telefono.getEmpresaOperadora().getCodigoEntero());
			} else {
				cs.setNull(i++, Types.INTEGER);
			}
			if (telefono.getUsuarioCreacion().getCodigoEntero() != null) {
				cs.setInt(i++, telefono.getUsuarioCreacion().getCodigoEntero().intValue());
			} else {
				cs.setNull(i++, Types.INTEGER);
			}
			if (StringUtils.isNotBlank(telefono.getIpCreacion())) {
				cs.setString(i++, telefono.getIpCreacion());
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}

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
	public void registrarTelefonoDireccion(Telefono telefono, Direccion direccion,
			Connection conexion) throws SQLException {
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_ingresartelefonodireccion(?,?,?,?,?) }";

		try {
			cs = conexion.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.BOOLEAN);
			cs.setInt(i++, idEmpresa.intValue());
			cs.setInt(i++, telefono.getCodigoEntero().intValue());
			cs.setInt(i++, direccion.getCodigoEntero().intValue());
			cs.setInt(i++, direccion.getUsuarioCreacion().getCodigoEntero().intValue());
			cs.setString(i++, direccion.getIpCreacion());

			cs.execute();
		} catch (SQLException e) {
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
	}

	@Override
	public void registrarTelefonoPersona(Telefono telefono, Persona persona,
			Connection conexion) throws SQLException {
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_ingresartelefonopersona(?,?,?,?,?) }";

		try {
			cs = conexion.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.BOOLEAN);
			cs.setInt(i++, idEmpresa.intValue());
			cs.setInt(i++, telefono.getCodigoEntero().intValue());
			cs.setInt(i++, persona.getCodigoEntero().intValue());
			cs.setInt(i++, persona.getUsuarioCreacion().getCodigoEntero().intValue());
			cs.setString(i++, persona.getIpCreacion());

			cs.execute();
		} catch (SQLException e) {
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
	}

	@Override
	public List<Telefono> consultarTelefonoDireccion(int idDireccion,
			Connection conn) throws SQLException {
		List<Telefono> resultado = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "select * "
				+ " from negocio.vw_telefonodireccion where iddireccion = ? and idempresa = ?";

		try {
			cs = conn.prepareCall(sql);
			cs.setInt(1, idDireccion);
			cs.setInt(2, idEmpresa.intValue());
			rs = cs.executeQuery();

			resultado = new ArrayList<Telefono>();
			Telefono telefono = null;
			while (rs.next()) {
				telefono = new Telefono();
				telefono.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				telefono.setNumeroTelefono(UtilJdbc.obtenerCadena(rs, "numero"));
				telefono.getEmpresaOperadora().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idempresaproveedor"));
				resultado.add(telefono);
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
				try {
					if (cs != null) {
						cs.close();
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
	public List<Telefono> consultarTelefonoContacto(int idcontacto,
			Connection conn) throws SQLException {
		List<Telefono> resultado = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "select * "
				+ " from negocio.vw_telefonocontacto where idpersona = ? and idempresa = ?";

		try {
			cs = conn.prepareCall(sql);
			cs.setInt(1, idcontacto);
			cs.setInt(2, idEmpresa.intValue());
			rs = cs.executeQuery();

			resultado = new ArrayList<Telefono>();
			Telefono telefono = null;
			while (rs.next()) {
				telefono = new Telefono();
				telefono.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				telefono.setNumeroTelefono(UtilJdbc.obtenerCadena(rs, "numero"));
				telefono.getEmpresaOperadora().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idempresaproveedor"));
				resultado.add(telefono);
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
				try {
					if (cs != null) {
						cs.close();
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
	public int actualizarTelefono(Telefono telefono, Connection conexion)
			throws SQLException {
		int resultado = 0;
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_ingresartelefono(?,?,?,?,?,?) }";

		try {
			cs = conexion.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.INTEGER);
			cs.setInt(i++, idEmpresa.intValue());
			if (StringUtils.isNotBlank(telefono.getNumeroTelefono())) {
				cs.setString(i++, UtilJdbc.convertirMayuscula(telefono
						.getNumeroTelefono()));
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (telefono.getEmpresaOperadora().getCodigoEntero() != null) {
				cs.setInt(i++, telefono.getEmpresaOperadora().getCodigoEntero());
			} else {
				cs.setNull(i++, Types.INTEGER);
			}
			if (telefono.getUsuarioModificacion().getCodigoEntero() != null) {
				cs.setInt(i++, telefono.getUsuarioModificacion().getCodigoEntero().intValue());
			} else {
				cs.setNull(i++, Types.INTEGER);
			}
			if (StringUtils.isNotBlank(telefono.getIpModificacion())) {
				cs.setString(i++, telefono.getIpModificacion());
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			cs.setInt(i++, telefono.getCodigoEntero().intValue());

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
	public List<Telefono> consultarTelefonosDireccion(int idDireccion)
			throws SQLException {
		Connection conn = null;
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_telefonosxdireccion(?,?) }";
		ResultSet rs = null;
		List<Telefono> resultado = null;

		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.OTHER);
			cs.setInt(i++, idEmpresa.intValue());
			cs.setInt(i++, idDireccion);
			cs.execute();

			rs = (ResultSet) cs.getObject(1);
			resultado = new ArrayList<Telefono>();
			Telefono telefono = null;
			while (rs.next()) {
				telefono = new Telefono();
				telefono.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				telefono.setNumeroTelefono(UtilJdbc.obtenerCadena(rs, "numero"));
				telefono.getEmpresaOperadora().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idempresaproveedor"));
				resultado.add(telefono);
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
	public List<Telefono> consultarTelefonosDireccion(int idDireccion,
			Connection conn) throws SQLException {
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_telefonosxdireccion(?,?) }";
		ResultSet rs = null;
		List<Telefono> resultado = null;

		try {
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.OTHER);
			cs.setInt(i++, idEmpresa.intValue());
			cs.setInt(i++, idDireccion);
			cs.execute();

			rs = (ResultSet) cs.getObject(1);
			resultado = new ArrayList<Telefono>();
			Telefono telefono = null;
			while (rs.next()) {
				telefono = new Telefono();
				telefono.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				telefono.setNumeroTelefono(UtilJdbc.obtenerCadena(rs, "numero"));
				telefono.getEmpresaOperadora().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idempresaproveedor"));
				resultado.add(telefono);
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
	public List<Telefono> consultarTelefonosXPersona(int idPersona)
			throws SQLException {
		Connection conn = null;
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_telefonosxpersona(?,?) }";
		ResultSet rs = null;
		List<Telefono> resultado = null;

		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.OTHER);
			cs.setInt(i++, idEmpresa.intValue());
			cs.setInt(i++, idPersona);
			cs.execute();

			rs = (ResultSet) cs.getObject(1);
			resultado = new ArrayList<Telefono>();
			Telefono telefono = null;
			while (rs.next()) {
				telefono = new Telefono();
				telefono.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				telefono.setNumeroTelefono(UtilJdbc.obtenerCadena(rs, "numero"));
				telefono.getEmpresaOperadora().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idempresaproveedor"));
				resultado.add(telefono);
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
	public List<Telefono> consultarTelefonosXPersona(int idPersona,
			Connection conn) throws SQLException {
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_telefonosxpersona(?,?) }";
		ResultSet rs = null;
		List<Telefono> resultado = null;

		try {
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.OTHER);
			cs.setInt(i++, idEmpresa.intValue());
			cs.setInt(i++, idPersona);
			cs.execute();

			rs = (ResultSet) cs.getObject(1);
			resultado = new ArrayList<Telefono>();
			Telefono telefono = null;
			while (rs.next()) {
				telefono = new Telefono();
				telefono.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				telefono.setNumeroTelefono(UtilJdbc.obtenerCadena(rs, "numero"));
				telefono.getEmpresaOperadora().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idempresaproveedor"));
				resultado.add(telefono);
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
