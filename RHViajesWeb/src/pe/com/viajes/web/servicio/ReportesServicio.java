/**
 * 
 */
package pe.com.viajes.web.servicio;

import java.sql.SQLException;
import java.util.Date;
import java.util.List;

import pe.com.viajes.bean.negocio.Comprobante;
import pe.com.viajes.bean.negocio.DetalleServicioAgencia;
import pe.com.viajes.bean.reportes.ReporteVentas;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;

/**
 * @author EDWREB
 *
 */
public interface ReportesServicio {

	public List<DetalleServicioAgencia> reporteGeneralVentas(
			ReporteVentas reporteVentas) throws SQLException;

	List<Comprobante> generarReporteContable(Date fechaDesde, Date fechaHasta, Integer idEmpresa)
			throws ErrorConsultaDataException;

}
