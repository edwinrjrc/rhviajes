/**
 * 
 */
package pe.com.viajes.web.servicio;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.jasper.DetalleServicio;
import pe.com.viajes.bean.negocio.Contacto;
import pe.com.viajes.bean.negocio.DetalleServicioAgencia;
import pe.com.viajes.bean.negocio.Direccion;
import pe.com.viajes.bean.negocio.Pasajero;
import pe.com.viajes.bean.negocio.ServicioAgencia;
import pe.com.viajes.bean.negocio.ServicioNovios;
import pe.com.viajes.negocio.exception.ErrorRegistroDataException;

/**
 * @author Edwin
 *
 */
public interface UtilNegocioServicio {

	BigDecimal calcularPorcentajeComision(DetalleServicioAgencia detalleServicio)
			throws SQLException, Exception;

	List<DetalleServicioAgencia> agregarServicioVenta(Integer idMonedaServicio,
			List<DetalleServicioAgencia> listaServiciosVenta,
			DetalleServicioAgencia detalleServicio)
			throws ErrorRegistroDataException, SQLException, Exception;

	List<DetalleServicioAgencia> actualizarServicioVenta(
			Integer idMonedaServicio,
			List<DetalleServicioAgencia> listaServiciosVenta,
			DetalleServicioAgencia detalleServicio)
			throws ErrorRegistroDataException, SQLException, Exception;

	public Direccion agregarDireccion(Direccion direccion) throws SQLException,
			Exception;

	public Contacto agregarContacto(Contacto contacto) throws SQLException,
			Exception;

	ServicioNovios agregarServicioNovios(ServicioNovios servicioNovios)
			throws SQLException, Exception;

	BigDecimal calcularValorCuota(ServicioAgencia servicioAgencia)
			throws SQLException, Exception;
	
	Pasajero agregarPasajero(Pasajero pasajero) throws ErrorRegistroDataException;

	List<DetalleServicioAgencia> agruparServicios(
			List<DetalleServicioAgencia> listaServicios, Integer idEmpresa);

	List<DetalleServicio> consultarServiciosVenta(Integer idServicio,
			Integer idEmpresa) throws SQLException;
}
