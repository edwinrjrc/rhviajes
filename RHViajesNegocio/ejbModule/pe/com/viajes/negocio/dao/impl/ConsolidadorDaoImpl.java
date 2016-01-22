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

import pe.com.viajes.bean.negocio.Consolidador;
import pe.com.viajes.negocio.dao.ConsolidadorDao;
import pe.com.viajes.negocio.util.UtilConexion;
import pe.com.viajes.negocio.util.UtilJdbc;

/**
 * @author Edwin
 *
 */
public class ConsolidadorDaoImpl implements ConsolidadorDao {

	/**
	 * 
	 */
	public ConsolidadorDaoImpl() {
		// TODO Auto-generated constructor stub
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * pe.com.viajes.negocio.dao.ConsolidadorDao#ingresarConsolidador(pe.
	 * com.logistica.bean.negocio.Consolidador)
	 */
	@Override
	public boolean ingresarConsolidador(Consolidador consolidador)
			throws SQLException, Exception {
		boolean resultado = false;
		Connection conn = null;
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_ingresarconsolidador(?,?,?) }";

		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.BOOLEAN);
			cs.setString(i++,
					UtilJdbc.convertirMayuscula(consolidador.getNombre()));
			cs.setInt(i++, consolidador
					.getUsuarioCreacion().getCodigoEntero().intValue());
			cs.setString(i++, consolidador.getIpCreacion());

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
				throw new SQLException(e);
			}
		}

		return resultado;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * pe.com.viajes.negocio.dao.ConsolidadorDao#actualizarConsolidador(pe
	 * .com.logistica.bean.negocio.Consolidador)
	 */
	@Override
	public boolean actualizarConsolidador(Consolidador consolidador)
			throws SQLException, Exception {
		boolean resultado = false;
		Connection conn = null;
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_actualizarconsolidador(?,?,?,?) }";

		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.BOOLEAN);
			cs.setInt(i++, consolidador.getCodigoEntero().intValue());
			cs.setString(i++,
					UtilJdbc.convertirMayuscula(consolidador.getNombre()));
			cs.setInt(i++, consolidador
					.getUsuarioCreacion().getCodigoEntero().intValue());
			cs.setString(i++, consolidador.getIpCreacion());

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
				throw new SQLException(e);
			}
		}

		return resultado;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see pe.com.viajes.negocio.dao.ConsolidadorDao#listarConsolidador()
	 */
	@Override
	public List<Consolidador> listarConsolidador() throws SQLException,
			Exception {
		Connection conn = null;
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_listarconsolidadores() }";
		List<Consolidador> resultado = null;
		ResultSet rs = null;

		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.OTHER);

			cs.execute();
			rs = (ResultSet) cs.getObject(1);
			resultado = new ArrayList<Consolidador>();
			Consolidador consolidador = null;
			while (rs.next()) {
				consolidador = new Consolidador();
				consolidador.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				consolidador.setNombre(UtilJdbc.obtenerCadena(rs, "nombre"));
				resultado.add(consolidador);
			}
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
				throw new SQLException(e);
			}
		}

		return resultado;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * pe.com.viajes.negocio.dao.ConsolidadorDao#consultarConsolidador(pe
	 * .com.logistica.bean.negocio.Consolidador)
	 */
	@Override
	public Consolidador consultarConsolidador(Consolidador consolidador)
			throws SQLException, Exception {
		Connection conn = null;
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_consultarconsolidador(?) }";
		Consolidador consolidador2 = null;
		ResultSet rs = null;

		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.OTHER);
			cs.setInt(i++, consolidador.getCodigoEntero().intValue());

			cs.execute();
			rs = (ResultSet) cs.getObject(1);
			if (rs.next()) {
				consolidador2 = new Consolidador();
				consolidador2.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				consolidador2.setNombre(UtilJdbc.obtenerCadena(rs, "nombre"));
			}
		} catch (SQLException e) {
			consolidador2 = null;
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
				throw new SQLException(e);
			}
		}

		return consolidador2;
	}

}
