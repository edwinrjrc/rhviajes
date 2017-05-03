package pe.com.viajes.negocio.ejb;

import java.sql.SQLException;
import java.util.Date;
import java.util.List;

import javax.ejb.Remote;

import pe.com.viajes.bean.negocio.Comprobante;
import pe.com.viajes.bean.negocio.DetalleServicioAgencia;
import pe.com.viajes.bean.reportes.ReporteVentas;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;

@Remote
public interface ReportesSessionRemote {

	List<DetalleServicioAgencia> reporteGeneralVentas(
			ReporteVentas reporteVentas) throws SQLException;

	List<Comprobante> generarReporteContable(Date fechaDesde, Date fechaHasta, Integer idEmpresa) throws ErrorConsultaDataException;
}
