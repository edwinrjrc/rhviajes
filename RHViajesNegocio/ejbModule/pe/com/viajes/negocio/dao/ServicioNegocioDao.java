/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Date;
import java.util.List;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.jasper.DetalleServicio;
import pe.com.viajes.bean.negocio.Comprobante;
import pe.com.viajes.bean.negocio.Pasajero;
import pe.com.viajes.bean.negocio.ServicioAgencia;
import pe.com.viajes.bean.negocio.ServicioProveedor;
import pe.com.viajes.bean.reportes.CheckIn;

/**
 * @author edwreb
 *
 */
public interface ServicioNegocioDao {

	public BigDecimal calcularCuota(ServicioAgencia servicioAgencia)
			throws SQLException;

	List<ServicioProveedor> proveedoresXServicio(BaseVO servicio)
			throws SQLException;

	public Integer ingresarPasajero(Pasajero pasajero, Connection conn) throws SQLException;
	
	List<Pasajero> consultarPasajeroHistorico(Pasajero pasajero)
			throws SQLException;

	List<DetalleServicio> consultarServicioVentaJR(Integer idServicio,
			int idEmpresa) throws SQLException;

	List<CheckIn> consultarcheckinpendientes(Date fechaHasta,
			Integer idVendedor, int idEmpresa) throws SQLException;

	List<Pasajero> consultarPasajeros(Integer idServicioDetalle, int idEmpresa,
			Connection conn) throws SQLException;
	
	List<Comprobante> consultarObligacionesPendientes(int idEmpresa,
			Date fechaHasta) throws SQLException;
}
