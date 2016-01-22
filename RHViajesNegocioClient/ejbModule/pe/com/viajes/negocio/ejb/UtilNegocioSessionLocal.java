package pe.com.viajes.negocio.ejb;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

import javax.ejb.Local;

import pe.com.viajes.bean.jasper.DetalleServicio;
import pe.com.viajes.bean.negocio.Contacto;
import pe.com.viajes.bean.negocio.DetalleServicioAgencia;
import pe.com.viajes.bean.negocio.Direccion;
import pe.com.viajes.negocio.exception.ErrorRegistroDataException;

@Local
public interface UtilNegocioSessionLocal {

	List<DetalleServicioAgencia> agruparServiciosHijos(
			List<DetalleServicioAgencia> listaServicios, Integer idEmpresa);

	public List<DetalleServicioAgencia> agregarServicioVenta(
			Integer idMonedaServicio,
			List<DetalleServicioAgencia> listaServiciosVenta,
			DetalleServicioAgencia detalleServicio)
			throws ErrorRegistroDataException, SQLException, Exception;

	public List<DetalleServicioAgencia> actualizarServicioVenta(
			Integer idMonedaServicio,
			List<DetalleServicioAgencia> listaServiciosVenta,
			DetalleServicioAgencia detalleServicio)
			throws ErrorRegistroDataException, SQLException, Exception;

	public BigDecimal calculaPorcentajeComision(
			DetalleServicioAgencia detalleServicio) throws SQLException,
			Exception;

	public List<DetalleServicio> consultarServiciosVentaJR(Integer idServicio, Integer idEmpresa)
			throws SQLException;

	public Direccion agregarDireccion(Direccion direccion) throws SQLException,
			Exception;

	public Contacto agregarContacto(Contacto contacto) throws SQLException,
			Exception;

	public String obtenerDireccionCompleta(Direccion direccion)
			throws SQLException, Exception;

	BigDecimal desglozarMontoSinIGV(BigDecimal monto, Integer idEmpresa) throws SQLException;

	BigDecimal obtenerMontoIGV(BigDecimal monto, Integer idEmpresa) throws SQLException;
}
