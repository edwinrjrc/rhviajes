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

import pe.com.viajes.bean.negocio.DetalleServicioAgencia;
import pe.com.viajes.bean.reportes.ReporteVentas;
import pe.com.viajes.negocio.dao.ReporteVentasDao;
import pe.com.viajes.negocio.util.UtilConexion;
import pe.com.viajes.negocio.util.UtilJdbc;

/**
 * @author Edwin
 *
 */
public class ReporteVentasDaoImpl implements ReporteVentasDao {

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * pe.com.viajes.negocio.dao.ReporteVentasDao#reporteGeneralVentas(java
	 * .util.Date, java.util.Date)
	 */
	@Override
	public List<DetalleServicioAgencia> reporteGeneralVentas(
			ReporteVentas reporteVentas) throws SQLException {
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "{ ? = call reportes.fn_re_generalventas(?,?,?,?) }";
		List<DetalleServicioAgencia> resultado = null;

		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.OTHER);
			cs.setInt(i++, reporteVentas.getEmpresa().getCodigoEntero().intValue());
			cs.setDate(i++, UtilJdbc.convertirUtilDateSQLDate(reporteVentas
					.getFechaDesde()));
			cs.setDate(i++, UtilJdbc.convertirUtilDateSQLDate(reporteVentas
					.getFechaHasta()));
			if (reporteVentas.getVendedor().getCodigoEntero() != null
					&& reporteVentas.getVendedor().getCodigoEntero().intValue() != 0) {
				cs.setInt(i++, reporteVentas.getVendedor().getCodigoEntero()
						.intValue());
			} else {
				cs.setNull(i++, Types.INTEGER);
			}
			cs.execute();
			rs = (ResultSet) cs.getObject(1);
			resultado = new ArrayList<DetalleServicioAgencia>();
			DetalleServicioAgencia detalle = null;
			while (rs.next()) {
				detalle = new DetalleServicioAgencia();
				detalle.getTipoServicio().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idtiposervicio"));
				detalle.getTipoServicio().setNombre(
						UtilJdbc.obtenerCadena(rs, "nombre"));
				detalle.setCantidad(UtilJdbc.obtenerNumero(rs, "cantidad"));
				detalle.setTotalAgrupados(UtilJdbc.obtenerBigDecimal(rs,
						"montototal"));
				detalle.setMontoComision(UtilJdbc.obtenerBigDecimal(rs,
						"montocomision"));
				resultado.add(detalle);
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

}
