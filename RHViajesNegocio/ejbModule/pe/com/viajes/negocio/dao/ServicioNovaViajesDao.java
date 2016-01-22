/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.negocio.Comprobante;
import pe.com.viajes.bean.negocio.CuotaPago;
import pe.com.viajes.bean.negocio.DetalleComprobante;
import pe.com.viajes.bean.negocio.DetalleServicioAgencia;
import pe.com.viajes.bean.negocio.DocumentoAdicional;
import pe.com.viajes.bean.negocio.EventoObsAnu;
import pe.com.viajes.bean.negocio.PagoServicio;
import pe.com.viajes.bean.negocio.Ruta;
import pe.com.viajes.bean.negocio.ServicioAgencia;
import pe.com.viajes.bean.negocio.ServicioAgenciaBusqueda;
import pe.com.viajes.bean.negocio.Tramo;

/**
 * @author edwreb
 *
 */
public interface ServicioNovaViajesDao {

	Integer ingresarCabeceraServicio(ServicioAgencia servicioAgencia)
			throws SQLException;

	Integer ingresarCabeceraServicio(ServicioAgencia servicioAgencia,
			Connection conn) throws SQLException;

	Integer ingresarDetalleServicio(DetalleServicioAgencia detalleServicio,
			int idServicio, Connection conn) throws SQLException;

	boolean generarCronogramaPago(ServicioAgencia servicioAgencia,
			Connection conn) throws SQLException;

	List<CuotaPago> consultarCronogramaPago(ServicioAgencia servicioAgencia)
			throws SQLException;

	public ServicioAgencia consultarServiciosVenta2(int idServicio)
			throws SQLException;

	public List<DetalleServicioAgencia> consultaServicioDetalle(int idServicio)
			throws SQLException;

	List<ServicioAgencia> consultarServiciosVenta(
			ServicioAgenciaBusqueda servicioAgencia) throws SQLException;

	List<DetalleServicioAgencia> consultaServicioDetalle(int idServicio,
			Connection conn) throws SQLException;

	ServicioAgencia consultarServiciosVenta2(int idServicio, Connection conn)
			throws SQLException;

	Integer actualizarCabeceraServicio(ServicioAgencia servicioAgencia)
			throws SQLException;

	Integer eliminarDetalleServicio(ServicioAgencia servicioAgencia)
			throws SQLException;

	boolean eliminarDetalleServicio(ServicioAgencia servicioAgencia,
			Connection conn) throws SQLException;

	Integer actualizarCabeceraServicio(ServicioAgencia servicioAgencia,
			Connection conn) throws SQLException;

	boolean eliminarCronogramaServicio(ServicioAgencia servicioAgencia)
			throws SQLException;

	boolean eliminarCronogramaServicio(ServicioAgencia servicioAgencia,
			Connection conn) throws SQLException;

	List<DetalleServicioAgencia> consultaServicioDetalleHijos(int idServicio,
			int idSerPadre, Connection conn) throws SQLException;

	void registrarSaldosServicio(ServicioAgencia servicioAgencia,
			Connection conn) throws SQLException;

	void registrarPagoServicio(PagoServicio pago) throws SQLException;

	List<PagoServicio> listarPagosServicio(Integer idServicio)
			throws SQLException;

	BigDecimal consultarSaldoServicio(Integer idServicio) throws SQLException;

	void actualizarServicioVenta(ServicioAgencia servicioAgencia)
			throws SQLException, Exception;

	boolean registrarEventoObsAnu(EventoObsAnu evento) throws SQLException,
			Exception;

	Integer registrarComprobante(Comprobante comprobante, Connection conn)
			throws SQLException, Exception;

	public Integer registrarDetalleComprobante(
			List<DetalleComprobante> listaDetalle, Integer idComprobante,
			Connection conn) throws SQLException, Exception;

	void actualizarComprobantesServicio(boolean generoComprobantes,
			ServicioAgencia servicio, Connection conn) throws SQLException,
			Exception;

	List<DetalleServicioAgencia> consultaServicioDetalleComprobante(
			int idServicio) throws SQLException;

	List<Comprobante> consultaObligacionXPagar(Comprobante comprobante)
			throws SQLException;

	boolean registrarObligacionXPagar(Comprobante comprobante)
			throws SQLException;

	void registrarPagoObligacion(PagoServicio pago) throws SQLException;

	List<PagoServicio> listarPagosObligacion(Integer idObligacion)
			throws SQLException;

	boolean guardarRelacionComproObligacion(DetalleServicioAgencia detalle,
			Connection conn) throws SQLException, Exception;

	void actualizarRelacionComprobantes(boolean relacionComprobantes,
			ServicioAgencia servicio, Connection conn) throws SQLException,
			Exception;

	List<DetalleServicioAgencia> consultaServDetComprobanteObligacion(
			int idServicio, Connection conn) throws SQLException;

	boolean grabarDocumentoAdicional(DocumentoAdicional documento,
			Connection conn) throws SQLException;

	List<DocumentoAdicional> listarDocumentosAdicionales(Integer idServicio)
			throws SQLException;

	boolean eliminarDocumentoAdicional(DocumentoAdicional documento,
			Connection conn) throws SQLException;

	List<DetalleServicioAgencia> consultaServicioDetallePadre(int idServicio,
			Connection conn) throws SQLException;

	List<DetalleServicioAgencia> consultaServicioDetalleHijo(int idServicio,
			int idSerDetaPadre, Connection conn) throws SQLException;

	List<DetalleServicioAgencia> consultaServicioDetalleComprobanteHijo(
			int idServicio, int idDetaServicio) throws SQLException;

	List<DetalleServicioAgencia> consultaServDetComprobanteObligacionHijo(
			int idServicio, int idDetaServicio, Connection conn)
			throws SQLException;

	DetalleServicioAgencia consultaDetalleServicioDetalle(int idServicio,
			int idDetServicio, Connection conn) throws SQLException;

	Tramo registrarTramo(Tramo tramo, Connection conn) throws SQLException;

	boolean registrarRuta(Ruta ruta, Connection conn) throws SQLException;

	Integer obtenerSiguienteRuta(Connection conn) throws SQLException;

	List<Tramo> consultarTramos(Integer codigoEntero, Connection conn) throws SQLException;
}
