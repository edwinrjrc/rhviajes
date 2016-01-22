/**
 * 
 */
package pe.com.viajes.negocio.dao.impl;

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import pe.com.viajes.bean.negocio.CuentaBancaria;
import pe.com.viajes.bean.negocio.MovimientoCuenta;
import pe.com.viajes.negocio.dao.CuentaBancariaDao;
import pe.com.viajes.negocio.util.UtilConexion;
import pe.com.viajes.negocio.util.UtilJdbc;

/**
 * @author EDWREB
 *
 */
public class CuentaBancariaDaoImpl implements CuentaBancariaDao {

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * pe.com.viajes.negocio.dao.CuentaBancariaDao#listarCuentasBancarias()
	 */
	@Override
	public List<CuentaBancaria> listarCuentasBancarias(int idEmpresa) throws SQLException {
		List<CuentaBancaria> resultado = null;
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "";

		try {
			sql = "{ ? = call negocio.fn_listarcuentasbancarias(?) }";
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.OTHER);
			cs.setInt(2, idEmpresa);
			cs.execute();

			rs = (ResultSet) cs.getObject(1);
			CuentaBancaria cuentaBancaria = null;
			resultado = new ArrayList<CuentaBancaria>();
			while (rs.next()) {
				cuentaBancaria = new CuentaBancaria();
				cuentaBancaria
						.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				cuentaBancaria.setNombreCuenta(UtilJdbc.obtenerCadena(rs,
						"nombrecuenta"));
				cuentaBancaria.setNumeroCuenta(UtilJdbc.obtenerCadena(rs,
						"numerocuenta"));
				cuentaBancaria.getTipoCuenta().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idtipocuenta"));
				cuentaBancaria.getTipoCuenta().setNombre(
						UtilJdbc.obtenerCadena(rs, "nombretipocuenta"));
				cuentaBancaria.getBanco().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idbanco"));
				cuentaBancaria.getBanco().setNombre(
						UtilJdbc.obtenerCadena(rs, "nombrebanco"));
				cuentaBancaria.getMoneda().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idmoneda"));
				cuentaBancaria.getMoneda().setNombre(
						UtilJdbc.obtenerCadena(rs, "nombremoneda"));
				cuentaBancaria.getMoneda().setAbreviatura(
						UtilJdbc.obtenerCadena(rs, "abreviatura"));
				cuentaBancaria.setSaldo(UtilJdbc.obtenerBigDecimal(rs,
						"saldocuenta"));
				cuentaBancaria.setNumeroMovimientos(UtilJdbc.obtenerNumero(rs,
						"numeroMovimientos"));
				cuentaBancaria.setEditable((cuentaBancaria
						.getNumeroMovimientos() > 0));
				resultado.add(cuentaBancaria);
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
			if (conn != null) {
				conn.close();
			}
		}

		return resultado;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * pe.com.viajes.negocio.dao.CuentaBancariaDao#registrarCuentaBancaria
	 * (pe.com.viajes.bean.negocio.CuentaBancaria)
	 */
	@Override
	public boolean registrarCuentaBancaria(CuentaBancaria cuentaBancaria)
			throws SQLException {
		Connection conn = null;
		CallableStatement cs = null;
		String sql = "";
		try {
			sql = "{ ? = call negocio.fn_registrarcuentabancaria(?,?,?,?,?,?,?,?,?)}";
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.BOOLEAN);
			cs.setInt(i++, cuentaBancaria.getEmpresa().getCodigoEntero().intValue());
			cs.setString(i++, cuentaBancaria.getNombreCuenta());
			cs.setString(i++, cuentaBancaria.getNumeroCuenta());
			cs.setInt(i++, cuentaBancaria.getTipoCuenta().getCodigoEntero()
					.intValue());
			cs.setInt(i++, cuentaBancaria.getBanco().getCodigoEntero()
					.intValue());
			cs.setInt(i++, cuentaBancaria.getMoneda().getCodigoEntero()
					.intValue());
			cs.setBigDecimal(i++, BigDecimal.ZERO);
			cs.setInt(i++, cuentaBancaria.getUsuarioCreacion().getCodigoEntero().intValue());
			cs.setString(i++, cuentaBancaria.getIpCreacion());
			cs.execute();

			return true;
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

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * pe.com.viajes.negocio.dao.CuentaBancariaDao#actualizarCuentaBancaria
	 * (pe.com.viajes.bean.negocio.CuentaBancaria)
	 */
	@Override
	public boolean actualizarCuentaBancaria(CuentaBancaria cuentaBancaria)
			throws SQLException {
		Connection conn = null;
		CallableStatement cs = null;
		String sql = "";
		try {
			sql = "{ ? = call negocio.fn_actualizarcuentabancaria(?,?,?,?,?,?,?,?)}";
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.BOOLEAN);
			cs.setInt(i++, cuentaBancaria.getEmpresa().getCodigoEntero().intValue());
			cs.setInt(i++, cuentaBancaria.getCodigoEntero().intValue());
			cs.setString(i++, cuentaBancaria.getNombreCuenta());
			cs.setString(i++, cuentaBancaria.getNumeroCuenta());
			cs.setInt(i++, cuentaBancaria.getTipoCuenta().getCodigoEntero()
					.intValue());
			cs.setInt(i++, cuentaBancaria.getBanco().getCodigoEntero()
					.intValue());
			cs.setInt(i++, cuentaBancaria.getUsuarioModificacion().getCodigoEntero().intValue());
			cs.setString(i++, cuentaBancaria.getIpModificacion());
			cs.execute();

			return true;
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

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * pe.com.viajes.negocio.dao.CuentaBancariaDao#consultaCuentaBancaria
	 * (pe.com.viajes.bean.negocio.CuentaBancaria)
	 */
	@Override
	public CuentaBancaria consultaCuentaBancaria(Integer idCuenta, int idEmpresa)
			throws SQLException {
		CuentaBancaria resultado = null;
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "";

		try {
			sql = "{ ? = call negocio.fn_consultacuentabancaria(?,?) }";
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.OTHER);
			cs.setInt(i++, idEmpresa);
			cs.setInt(i++, idCuenta.intValue());
			cs.execute();

			rs = (ResultSet) cs.getObject(1);
			if (rs.next()) {
				resultado = new CuentaBancaria();
				resultado.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				resultado.setNombreCuenta(UtilJdbc.obtenerCadena(rs,
						"nombrecuenta"));
				resultado.setNumeroCuenta(UtilJdbc.obtenerCadena(rs,
						"numerocuenta"));
				resultado.getTipoCuenta().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idtipocuenta"));
				resultado.getBanco().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idbanco"));
				resultado.getMoneda().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idmoneda"));
				resultado.setSaldo(UtilJdbc
						.obtenerBigDecimal(rs, "saldocuenta"));
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
			if (conn != null) {
				conn.close();
			}
		}

		return resultado;
	}

	@Override
	public List<CuentaBancaria> listarCuentasBancariasCombo(int idEmpresa)
			throws SQLException {
		List<CuentaBancaria> resultado = null;
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "";

		try {
			sql = "{ ? = call negocio.fn_listarcuentasbancariascombo(?) }";
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.OTHER);
			cs.setInt(2, idEmpresa);
			cs.execute();

			rs = (ResultSet) cs.getObject(1);
			CuentaBancaria cuentaBancaria = null;
			resultado = new ArrayList<CuentaBancaria>();
			while (rs.next()) {
				cuentaBancaria = new CuentaBancaria();
				cuentaBancaria
						.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				cuentaBancaria.setNombreCuenta(UtilJdbc.obtenerCadena(rs,
						"nombrecuenta"));
				resultado.add(cuentaBancaria);
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
			if (conn != null) {
				conn.close();
			}
		}

		return resultado;
	}

	@Override
	public List<MovimientoCuenta> listarMovimientoCuentaBancaria(
			Integer idCuenta, int idEmpresa) throws SQLException {
		List<MovimientoCuenta> resultado = null;
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "";

		try {
			sql = "{ ? = call negocio.fn_listarmovimientosxcuenta(?,?) }";
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.OTHER);
			cs.setInt(2, idEmpresa);
			cs.setInt(3, idCuenta.intValue());
			cs.execute();

			rs = (ResultSet) cs.getObject(1);
			MovimientoCuenta movimientoCuenta = null;
			resultado = new ArrayList<MovimientoCuenta>();
			while (rs.next()) {
				movimientoCuenta = new MovimientoCuenta();
				movimientoCuenta.setCodigoEntero(UtilJdbc.obtenerNumero(rs,
						"id"));
				movimientoCuenta.setIdCuenta(UtilJdbc.obtenerNumero(rs,
						"idcuenta"));
				movimientoCuenta.getTipoMovimiento().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idtipomovimiento"));
				movimientoCuenta.getTipoMovimiento().setNombre(
						UtilJdbc.obtenerCadena(rs, "desTipoMovimiento"));
				movimientoCuenta.getTransaccion().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idtransaccion"));
				movimientoCuenta.getTransaccion().setNombre(
						UtilJdbc.obtenerCadena(rs, "nombreTransaccion"));
				movimientoCuenta.setDescripcionMovimiento(UtilJdbc
						.obtenerCadena(rs, "descripcionnovimiento"));
				movimientoCuenta.setImporteMovimiento(UtilJdbc
						.obtenerBigDecimal(rs, "importemovimiento"));
				resultado.add(movimientoCuenta);
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
			if (conn != null) {
				conn.close();
			}
		}

		return resultado;
	}
}
