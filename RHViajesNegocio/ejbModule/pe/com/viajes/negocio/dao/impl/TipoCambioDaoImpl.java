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

import org.apache.log4j.Logger;

import pe.com.viajes.bean.negocio.TipoCambio;
import pe.com.viajes.negocio.dao.TipoCambioDao;
import pe.com.viajes.negocio.util.UtilConexion;
import pe.com.viajes.negocio.util.UtilJdbc;

/**
 * @author EDWREB
 *
 */
public class TipoCambioDaoImpl implements TipoCambioDao {

	private final static Logger logger = Logger
			.getLogger(TipoCambioDaoImpl.class);
	
	private Integer idEmpresa = null;
	
	public TipoCambioDaoImpl(Integer idEmpresa) {
		this.idEmpresa = idEmpresa;
	}

	@Override
	public boolean registrarTipoCambio(TipoCambio tipoCambio)
			throws SQLException {
		Connection conn = null;
		CallableStatement cs = null;
		String sql = "";

		try {
			sql = "{ ? = call negocio.fn_ingresartipocambio(?,?,?,?,?,?,?) }";
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.BOOLEAN);
			cs.setInt(2, idEmpresa.intValue());
			cs.setDate(3, UtilJdbc.convertirUtilDateSQLDate(tipoCambio
					.getFechaTipoCambio()));
			cs.setInt(4, tipoCambio.getMonedaOrigen().getCodigoEntero()
					.intValue());
			cs.setInt(5, tipoCambio.getMonedaDestino().getCodigoEntero()
					.intValue());
			cs.setBigDecimal(6, tipoCambio.getMontoCambio());
			cs.setInt(7, tipoCambio.getUsuarioCreacion().getCodigoEntero().intValue());
			cs.setString(8, tipoCambio.getIpCreacion());
			cs.execute();

			return cs.getBoolean(1);
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
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
	public TipoCambio consultarTipoCambio(Integer idMonedaOrigen,
			Integer idMonedaDestino, Connection conn) throws SQLException {
		TipoCambio resultado = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "";

		try {
			sql = "{ ? = call negocio.fn_consultartipocambio(?,?,?) }";
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.OTHER);
			cs.setInt(2, idEmpresa.intValue());
			cs.setInt(3, idMonedaOrigen.intValue());
			cs.setInt(4, idMonedaDestino.intValue());
			cs.execute();

			rs = (ResultSet) cs.getObject(1);

			if (rs.next()) {
				resultado = new TipoCambio();
				resultado.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				resultado.getMonedaOrigen().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idmonedaorigen"));
				resultado.getMonedaOrigen().setNombre(
						UtilJdbc.obtenerCadena(rs, "nombreMonOrigen"));
				resultado.getMonedaDestino().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idmonedadestino"));
				resultado.getMonedaDestino().setNombre(
						UtilJdbc.obtenerCadena(rs, "nombreMonDestino"));
				resultado.setMontoCambio(UtilJdbc.obtenerBigDecimal(rs,
						"montocambio"));
				resultado.setFechaTipoCambio(UtilJdbc.obtenerFecha(rs, "fechatipocambio"));
			}

			return resultado;
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
			throw new SQLException(e);
		} finally {
			if (rs != null) {
				rs.close();
			}
			if (cs != null) {
				cs.close();
			}
		}
	}
	
	@Override
	public TipoCambio consultarTipoCambio(Integer idMonedaOrigen,
			Integer idMonedaDestino) throws SQLException {
		Connection conn = null;
		TipoCambio resultado = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "";

		try {
			sql = "{ ? = call negocio.fn_consultartipocambio(?,?,?) }";
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.OTHER);
			cs.setInt(2, idEmpresa.intValue());
			cs.setInt(3, idMonedaOrigen.intValue());
			cs.setInt(4, idMonedaDestino.intValue());
			cs.execute();

			rs = (ResultSet) cs.getObject(1);

			if (rs.next()) {
				resultado = new TipoCambio();
				resultado.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				resultado.getMonedaOrigen().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idmonedaorigen"));
				resultado.getMonedaOrigen().setNombre(
						UtilJdbc.obtenerCadena(rs, "nombreMonOrigen"));
				resultado.getMonedaDestino().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idmonedadestino"));
				resultado.getMonedaDestino().setNombre(
						UtilJdbc.obtenerCadena(rs, "nombreMonDestino"));
				resultado.setMontoCambio(UtilJdbc.obtenerBigDecimal(rs,
						"montocambio"));
				resultado.setFechaTipoCambio(UtilJdbc.obtenerFecha(rs, "fechatipocambio"));
			}

			return resultado;
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
			throw new SQLException(e);
		} finally {
			if (rs != null) {
				rs.close();
			}
			if (cs != null) {
				cs.close();
			}
			if (conn != null){
				conn.close();
			}
		}
	}

	@Override
	public List<TipoCambio> listarTipoCambio(Date fecha) throws SQLException {
		List<TipoCambio> resultado = null;
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "";

		try {
			sql = "{ ? = call negocio.fn_listartipocambio(?,?) }";
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.OTHER);
			cs.setInt(2, idEmpresa.intValue());
			if (fecha != null) {
				cs.setDate(3, UtilJdbc.convertirUtilDateSQLDate(fecha));
			} else {
				cs.setNull(3, Types.DATE);
			}
			cs.execute();

			rs = (ResultSet) cs.getObject(1);
			resultado = new ArrayList<TipoCambio>();
			TipoCambio tipoCambio = null;
			while (rs.next()) {
				tipoCambio = new TipoCambio();
				tipoCambio.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				tipoCambio.setFechaTipoCambio(UtilJdbc.obtenerFecha(rs,
						"fechatipocambio"));
				tipoCambio.getMonedaOrigen().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idmonedaorigen"));
				tipoCambio.getMonedaOrigen().setNombre(
						UtilJdbc.obtenerCadena(rs, "nombreMonOrigen"));
				tipoCambio.getMonedaDestino().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idmonedadestino"));
				tipoCambio.getMonedaDestino().setNombre(
						UtilJdbc.obtenerCadena(rs, "nombreMonDestino"));
				tipoCambio.setMontoCambio(UtilJdbc.obtenerBigDecimal(rs,
						"montocambio"));

				resultado.add(tipoCambio);
			}

			return resultado;
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
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
