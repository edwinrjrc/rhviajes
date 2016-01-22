package pe.com.viajes.negocio.ejb;

import java.sql.SQLException;
import java.util.List;

import javax.ejb.Stateless;

import pe.com.viajes.bean.negocio.DetalleServicioAgencia;
import pe.com.viajes.bean.reportes.ReporteVentas;
import pe.com.viajes.negocio.dao.ReporteVentasDao;
import pe.com.viajes.negocio.dao.impl.ReporteVentasDaoImpl;

/**
 * Session Bean implementation class Reportes
 */
@Stateless(name = "ReportesSession")
public class ReportesSession implements ReportesSessionRemote,
		ReportesSessionLocal {

	@Override
	public List<DetalleServicioAgencia> reporteGeneralVentas(
			ReporteVentas reporteVentas) throws SQLException {
		ReporteVentasDao reporteVentasDao = new ReporteVentasDaoImpl();

		return reporteVentasDao.reporteGeneralVentas(reporteVentas);
	}
}
