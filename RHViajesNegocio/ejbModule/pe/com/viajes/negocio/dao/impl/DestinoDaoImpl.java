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

import pe.com.viajes.bean.negocio.Destino;
import pe.com.viajes.negocio.dao.DestinoDao;
import pe.com.viajes.negocio.util.UtilConexion;
import pe.com.viajes.negocio.util.UtilJdbc;

/**
 * @author Edwin
 *
 */
public class DestinoDaoImpl implements DestinoDao {

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * pe.com.viajes.negocio.dao.DestinoDao#ingresarDestino(pe.com.logistica
	 * .bean.negocio.Destino)
	 */
	@Override
	public boolean ingresarDestino(Destino destino) throws SQLException {
		boolean resultado = false;
		Connection conn = null;
		CallableStatement cs = null;
		String sql = "{ ? = call soporte.fn_ingresardestino(?,?,?,?,?,?,?,?) }";
		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.BOOLEAN);
			cs.setInt(i++, destino.getEmpresa().getCodigoEntero().intValue());
			cs.setInt(i++, destino.getPais().getContinente().getCodigoEntero()
					.intValue());
			cs.setInt(i++, destino.getPais().getCodigoEntero().intValue());
			cs.setInt(i++, destino.getTipoDestino().getCodigoEntero()
					.intValue());
			cs.setString(i++,
					UtilJdbc.convertirMayuscula(destino.getCodigoIATA()));
			cs.setString(i++,
					UtilJdbc.convertirMayuscula(destino.getDescripcion()));
			cs.setInt(i++, destino.getUsuarioCreacion().getCodigoEntero().intValue());
			cs.setString(i++,
					UtilJdbc.convertirMayuscula(destino.getIpCreacion()));
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

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * pe.com.viajes.negocio.dao.DestinoDao#actualizarDestino(pe.com.logistica
	 * .bean.negocio.Destino)
	 */
	@Override
	public boolean actualizarDestino(Destino destino) throws SQLException {
		boolean resultado = false;
		Connection conn = null;
		CallableStatement cs = null;
		String sql = "{ ? = call soporte.fn_actualizardestino(?,?,?,?,?,?,?,?) }";
		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.BOOLEAN);
			cs.setInt(i++, destino.getEmpresa().getCodigoEntero().intValue());
			cs.setInt(i++, destino.getCodigoEntero().intValue());
			cs.setInt(i++, destino.getPais().getContinente().getCodigoEntero()
					.intValue());
			cs.setInt(i++, destino.getPais().getCodigoEntero().intValue());
			cs.setInt(i++, destino.getTipoDestino().getCodigoEntero()
					.intValue());
			cs.setString(i++,
					UtilJdbc.convertirMayuscula(destino.getCodigoIATA()));
			cs.setString(i++,
					UtilJdbc.convertirMayuscula(destino.getDescripcion()));
			cs.setInt(i++, destino.getUsuarioModificacion().getCodigoEntero().intValue());
			cs.setString(i++,
					UtilJdbc.convertirMayuscula(destino.getIpModificacion()));
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
	public List<Destino> listarDestinos(int idEmpresa) throws SQLException {
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "{ ? = call soporte.fn_listardestinos(?) }";
		List<Destino> listaDestinos = null;
		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.OTHER);
			cs.setInt(2, idEmpresa);
			cs.execute();
			rs = (ResultSet) cs.getObject(1);

			listaDestinos = new ArrayList<Destino>();
			Destino destino = null;
			while (rs.next()) {
				destino = new Destino();
				destino.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				destino.getPais()
						.getContinente()
						.setCodigoEntero(
								UtilJdbc.obtenerNumero(rs, "idcontinente"));
				destino.getPais()
						.getContinente()
						.setNombre(
								UtilJdbc.obtenerCadena(rs, "nombrecontinente"));
				destino.getPais().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idpais"));
				destino.getPais().setDescripcion(
						UtilJdbc.obtenerCadena(rs, "nombrepais"));
				destino.setCodigoIATA(UtilJdbc.obtenerCadena(rs, "codigoiata"));
				destino.getTipoDestino().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idtipodestino"));
				destino.getTipoDestino().setNombre(
						UtilJdbc.obtenerCadena(rs, "nombretipdestino"));
				destino.setDescripcion(UtilJdbc
						.obtenerCadena(rs, "descripcion"));
				destino.getPais().setAbreviado(
						UtilJdbc.obtenerCadena(rs, "abreviado"));
				listaDestinos.add(destino);
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

		return listaDestinos;
	}

	@Override
	public Destino consultarDestino(int idDestino, int idEmpresa) throws SQLException {
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "{ ? = call soporte.fn_consultardestino(?,?) }";
		Destino destino = null;
		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.OTHER);
			cs.setInt(2, idEmpresa);
			cs.setInt(3, idDestino);
			cs.execute();

			rs = (ResultSet) cs.getObject(1);

			if (rs.next()) {
				destino = new Destino();
				destino.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				destino.setCodigoIATA(UtilJdbc.obtenerCadena(rs, "codigoiata"));
				destino.getTipoDestino().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idtipodestino"));
				destino.setDescripcion(UtilJdbc
						.obtenerCadena(rs, "descdestino"));
				destino.getPais().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idpais"));
				destino.getPais().setDescripcion(
						UtilJdbc.obtenerCadena(rs, "descpais"));
				destino.getPais().setAbreviado(
						UtilJdbc.obtenerCadena(rs, "abreviado"));
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

		return destino;
	}

	@Override
	public Destino consultarDestino(int idDestino, int idEmpresa, Connection conn)
			throws SQLException {
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "{ ? = call soporte.fn_consultardestino(?,?) }";
		Destino destino = null;
		try {
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.OTHER);
			cs.setInt(2, idEmpresa);
			cs.setInt(3, idDestino);
			cs.execute();

			rs = (ResultSet) cs.getObject(1);

			if (rs.next()) {
				destino = new Destino();
				destino.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				destino.setCodigoIATA(UtilJdbc.obtenerCadena(rs, "codigoiata"));
				destino.getTipoDestino().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idtipodestino"));
				destino.setDescripcion(UtilJdbc
						.obtenerCadena(rs, "descdestino"));
				destino.getPais().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idpais"));
				destino.getPais().setDescripcion(
						UtilJdbc.obtenerCadena(rs, "descpais"));
				destino.getPais().setAbreviado(
						UtilJdbc.obtenerCadena(rs, "abreviado"));
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

		return destino;
	}

	@Override
	public List<Destino> buscarDestinos(String nombreDestino, int idEmpresa)
			throws SQLException {
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "{ ? = call soporte.fn_buscardestinos1(?,?) }";
		List<Destino> listaDestinos = null;
		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.OTHER);
			cs.setInt(2, idEmpresa);
			cs.setString(2, UtilJdbc.convertirMayuscula(nombreDestino));
			cs.execute();
			rs = (ResultSet) cs.getObject(1);

			listaDestinos = new ArrayList<Destino>();
			Destino destino = null;
			while (rs.next()) {
				destino = new Destino();
				destino.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				destino.getPais()
						.getContinente()
						.setCodigoEntero(
								UtilJdbc.obtenerNumero(rs, "idcontinente"));
				destino.getPais()
						.getContinente()
						.setNombre(
								UtilJdbc.obtenerCadena(rs, "nombrecontinente"));
				destino.getPais().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idpais"));
				destino.getPais().setDescripcion(
						UtilJdbc.obtenerCadena(rs, "nombrepais"));
				destino.setCodigoIATA(UtilJdbc.obtenerCadena(rs, "codigoiata"));
				destino.getTipoDestino().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idtipodestino"));
				destino.getTipoDestino().setNombre(
						UtilJdbc.obtenerCadena(rs, "nombretipdestino"));
				destino.setDescripcion(UtilJdbc
						.obtenerCadena(rs, "descripcion"));
				destino.getPais().setAbreviado(
						UtilJdbc.obtenerCadena(rs, "abreviado"));
				listaDestinos.add(destino);
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

		return listaDestinos;
	}

	@Override
	public Destino consultarDestinoIATA(String codigoIATA, int idEmpresa) throws SQLException {
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "{ ? = call soporte.fn_consultardestinoiata(?,?) }";
		Destino destino = null;
		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.OTHER);
			cs.setInt(2, idEmpresa);
			cs.setString(3, codigoIATA);
			cs.execute();

			rs = (ResultSet) cs.getObject(1);

			if (rs.next()) {
				destino = new Destino();
				destino.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				destino.setCodigoIATA(UtilJdbc.obtenerCadena(rs, "codigoiata"));
				destino.getTipoDestino().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idtipodestino"));
				destino.setDescripcion(UtilJdbc
						.obtenerCadena(rs, "descdestino"));
				destino.getPais().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idpais"));
				destino.getPais().setDescripcion(
						UtilJdbc.obtenerCadena(rs, "descpais"));
				destino.getPais().setAbreviado(
						UtilJdbc.obtenerCadena(rs, "abreviado"));
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

		return destino;
	}
}
