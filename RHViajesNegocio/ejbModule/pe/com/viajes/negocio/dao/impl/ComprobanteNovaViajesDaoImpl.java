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

import pe.com.viajes.bean.negocio.Comprobante;
import pe.com.viajes.bean.negocio.ComprobanteBusqueda;
import pe.com.viajes.bean.negocio.DetalleComprobante;
import pe.com.viajes.negocio.dao.ComprobanteNovaViajesDao;
import pe.com.viajes.negocio.util.UtilConexion;
import pe.com.viajes.negocio.util.UtilEjb;
import pe.com.viajes.negocio.util.UtilJdbc;

/**
 * @author Edwin
 *
 */
public class ComprobanteNovaViajesDaoImpl implements ComprobanteNovaViajesDao {

	/*
	 * (non-Javadoc)
	 * 
	 * @see pe.com.viajes.negocio.dao.ComprobanteNovaViajesDao#
	 * registrarComprobanteAdicional(pe.com.viajes.bean.negocio.Comprobante,
	 * java.sql.Connection)
	 */
	@Override
	public Integer registrarComprobanteAdicional(Comprobante comprobante,
			Connection conn) throws SQLException {
		Integer resultado = 0;
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_ingresarcomprobanteadicional(?,?,?,?,?,?,?,?,?,?,?)}";
		try {
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.INTEGER);
			cs.setInt(i++, comprobante.getEmpresa().getCodigoEntero().intValue());
			cs.setInt(i++, comprobante.getIdServicio().intValue());
			cs.setInt(i++, comprobante.getTipoComprobante().getCodigoEntero()
					.intValue());
			cs.setString(i++, comprobante.getNumeroComprobante());
			cs.setInt(i++, comprobante.getTitular().getCodigoEntero()
					.intValue());
			cs.setString(i++, comprobante.getDetalleTextoComprobante());
			cs.setDate(i++, UtilJdbc.convertirUtilDateSQLDate(comprobante
					.getFechaComprobante()));
			cs.setBigDecimal(i++, comprobante.getTotalIGV());
			cs.setBigDecimal(i++, comprobante.getTotalComprobante());

			cs.setInt(i++, comprobante.getUsuarioCreacion().getCodigoEntero().intValue());
			cs.setString(i++, comprobante.getIpCreacion());

			cs.execute();

			resultado = cs.getInt(1);
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
		return resultado;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see pe.com.viajes.negocio.dao.ComprobanteNovaViajesDao#
	 * listarComprobantesAdicionales(java.lang.Integer)
	 */
	@Override
	public Integer listarComprobantesAdicionales(Integer idServicio)
			throws SQLException {
		// TODO Auto-generated method stub
		return null;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see pe.com.viajes.negocio.dao.ComprobanteNovaViajesDao#
	 * eliminarComprobantesAdicionales(java.lang.Integer)
	 */
	@Override
	public Integer eliminarComprobantesAdicionales(Integer idServicio)
			throws SQLException {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public List<Comprobante> consultarComprobantes(
			ComprobanteBusqueda comprobanteBusqueda) throws SQLException {
		List<Comprobante> resultado = null;
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "";
		try {
			sql = "{ ? = call negocio.fn_consultarcomprobantesgenerados(?,?,?,?,?,?,?,?)}";
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.OTHER);
			cs.setInt(i++, comprobanteBusqueda.getEmpresa().getCodigoEntero().intValue());
			if (comprobanteBusqueda.getCodigoEntero() != null
					&& comprobanteBusqueda.getCodigoEntero().intValue() != 0) {
				cs.setInt(i++, comprobanteBusqueda.getCodigoEntero().intValue());
			} else {
				cs.setNull(i++, Types.INTEGER);
			}
			if (comprobanteBusqueda.getIdServicio() != null
					&& comprobanteBusqueda.getIdServicio().intValue() != 0) {
				cs.setInt(i++, comprobanteBusqueda.getIdServicio().intValue());
			} else {
				cs.setNull(i++, Types.INTEGER);
			}
			if (comprobanteBusqueda.getTitular().getCodigoEntero() != null
					&& comprobanteBusqueda.getTitular().getCodigoEntero()
							.intValue() != 0) {
				cs.setInt(i++, comprobanteBusqueda.getTitular()
						.getCodigoEntero().intValue());
			} else {
				cs.setNull(i++, Types.INTEGER);
			}
			if (comprobanteBusqueda.getTipoComprobante().getCodigoEntero() != null
					&& comprobanteBusqueda.getTipoComprobante()
							.getCodigoEntero().intValue() != 0) {
				cs.setInt(i++, comprobanteBusqueda.getTipoComprobante()
						.getCodigoEntero().intValue());
			} else {
				cs.setNull(i++, Types.INTEGER);
			}
			if (StringUtils.isNotBlank(comprobanteBusqueda
					.getNumeroComprobante())) {
				cs.setString(i++, comprobanteBusqueda.getNumeroComprobante());
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (comprobanteBusqueda.getFechaDesde() != null) {
				cs.setDate(i++, UtilJdbc
						.convertirUtilDateSQLDate(comprobanteBusqueda
								.getFechaDesde()));
			} else {
				cs.setNull(i++, Types.DATE);
			}
			if (comprobanteBusqueda.getFechaHasta() != null) {
				cs.setDate(i++, UtilJdbc
						.convertirUtilDateSQLDate(comprobanteBusqueda
								.getFechaHasta()));
			} else {
				cs.setNull(i++, Types.DATE);
			}

			cs.execute();
			rs = (ResultSet) cs.getObject(1);

			resultado = new ArrayList<Comprobante>();
			Comprobante comprobante = null;
			while (rs.next()) {
				comprobante = new Comprobante();
				comprobante.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				comprobante.setIdServicio(UtilJdbc.obtenerNumero(rs, "idservicio"));
				comprobante.getTipoComprobante().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idtipocomprobante"));
				comprobante.getTipoComprobante().setNombre(
						UtilJdbc.obtenerCadena(rs, "nombre"));
				comprobante.setNumeroComprobante(UtilJdbc.obtenerCadena(rs,
						"numerocomprobante"));
				comprobante.getTitular().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idtitular"));
				comprobante.getTitular().setNombres(
						UtilJdbc.obtenerCadena(rs, "nombres"));
				comprobante.getTitular().setApellidoPaterno(
						UtilJdbc.obtenerCadena(rs, "apellidopaterno"));
				comprobante.getTitular().setApellidoMaterno(
						UtilJdbc.obtenerCadena(rs, "apellidomaterno"));
				comprobante.setFechaComprobante(UtilJdbc.obtenerFecha(rs,
						"fechacomprobante"));
				comprobante.getMoneda().setCodigoEntero(UtilJdbc.obtenerNumero(rs, "idmoneda"));
				comprobante.getMoneda().setNombre(UtilJdbc.obtenerCadena(rs, "nombremoneda"));
				comprobante.getMoneda().setAbreviatura(UtilJdbc.obtenerCadena(rs, "abreviatura"));
				comprobante.setSubTotal(UtilJdbc.obtenerBigDecimal(rs, "subtotalcomprobante"));
				comprobante.setTotalIGV(UtilJdbc.obtenerBigDecimal(rs, "totaligv"));
				comprobante.setTotalComprobante(UtilJdbc.obtenerBigDecimal(rs,
						"totalcomprobante"));
				resultado.add(comprobante);
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
				throw new SQLException(e);
			}
		}
		return resultado;
	}

	@Override
	public List<DetalleComprobante> consultarDetalleComprobante(
			Integer idComprobante, Integer idEmpresa) throws SQLException {
		List<DetalleComprobante> resultado = null;
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "";
		try {
			sql = "{ ? = call negocio.fn_consultardetallecomprobantegenerado(?)}";
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.OTHER);
			cs.setInt(i++, idEmpresa);
			cs.setInt(i++, idComprobante.intValue());

			cs.execute();
			rs = (ResultSet) cs.getObject(1);

			resultado = new ArrayList<DetalleComprobante>();
			DetalleComprobante detalleComprobante = null;
			while (rs.next()) {
				detalleComprobante = new DetalleComprobante();
				detalleComprobante.setCodigoEntero(UtilJdbc.obtenerNumero(rs,
						"id"));
				detalleComprobante.setCantidad(UtilJdbc.obtenerNumero(rs,
						"cantidad"));
				detalleComprobante.setConcepto(UtilJdbc.obtenerCadena(rs,
						"detalleconcepto"));
				detalleComprobante.setPrecioUnitario(UtilJdbc
						.obtenerBigDecimal(rs, "preciounitario"));
				detalleComprobante.setTotalDetalle(UtilJdbc.obtenerBigDecimal(
						rs, "totaldetalle"));
				resultado.add(detalleComprobante);
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
				throw new SQLException(e);
			}
		}
		return resultado;
	}

	@Override
	public Comprobante consultarObligacion(Integer idObligacion, Integer idEmpresa)
			throws SQLException {
		Comprobante comprobante = null;
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "";
		try {
			sql = UtilEjb.generaSentenciaFuncion(
					"negocio.fn_consultarobligacion", 2);
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.OTHER);
			cs.setInt(i++, idEmpresa.intValue());
			cs.setInt(i++, idObligacion.intValue());

			cs.execute();
			rs = (ResultSet) cs.getObject(1);

			if (rs.next()) {
				comprobante = new Comprobante();
				comprobante.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				comprobante.getTipoComprobante().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idtipocomprobante"));
				comprobante.getTipoComprobante().setNombre(
						UtilJdbc.obtenerCadena(rs, "nombre"));
				comprobante.setNumeroComprobante(UtilJdbc.obtenerCadena(rs,
						"numerocomprobante"));
				comprobante.getTitular().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idtitular"));
				comprobante.getTitular().setNombres(
						UtilJdbc.obtenerCadena(rs, "nombres"));
				comprobante.getTitular().setApellidoPaterno(
						UtilJdbc.obtenerCadena(rs, "apellidopaterno"));
				comprobante.getTitular().setApellidoMaterno(
						UtilJdbc.obtenerCadena(rs, "apellidomaterno"));
				comprobante.setFechaComprobante(UtilJdbc.obtenerFecha(rs,
						"fechacomprobante"));
				comprobante.setTotalComprobante(UtilJdbc.obtenerBigDecimal(rs,
						"totalcomprobante"));
				comprobante.setSaldoComprobante(UtilJdbc.obtenerBigDecimal(rs,
						"saldocomprobante"));
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
				throw new SQLException(e);
			}
		}
		return comprobante;
	}

}
