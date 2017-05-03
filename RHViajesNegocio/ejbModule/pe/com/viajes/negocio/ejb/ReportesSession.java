package pe.com.viajes.negocio.ejb;

import java.sql.SQLException;
import java.util.Date;
import java.util.List;

import javax.ejb.Stateless;

import pe.com.viajes.bean.negocio.Comprobante;
import pe.com.viajes.bean.negocio.DetalleServicioAgencia;
import pe.com.viajes.bean.reportes.ReporteVentas;
import pe.com.viajes.negocio.dao.ComprobanteNovaViajesDao;
import pe.com.viajes.negocio.dao.ReporteVentasDao;
import pe.com.viajes.negocio.dao.impl.ComprobanteNovaViajesDaoImpl;
import pe.com.viajes.negocio.dao.impl.ReporteVentasDaoImpl;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;

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
	
	@Override
	public List<Comprobante> generarReporteContable(Date fechaDesde, Date fechaHasta, Integer idEmpresa) throws ErrorConsultaDataException{
		try {
			ComprobanteNovaViajesDao comprobanteNovaViajesDao = new ComprobanteNovaViajesDaoImpl();
			return comprobanteNovaViajesDao.consultarReporteComprobantes(fechaDesde, fechaHasta, idEmpresa);
		} catch (SQLException e) {
			throw new ErrorConsultaDataException(e);
		}
	}
}
