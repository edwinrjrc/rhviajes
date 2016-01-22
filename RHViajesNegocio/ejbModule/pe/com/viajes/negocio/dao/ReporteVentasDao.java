/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.negocio.DetalleServicioAgencia;
import pe.com.viajes.bean.reportes.ReporteVentas;

/**
 * @author Edwin
 *
 */
public interface ReporteVentasDao {

	public List<DetalleServicioAgencia> reporteGeneralVentas(
			ReporteVentas reporteVentas) throws SQLException;
}
