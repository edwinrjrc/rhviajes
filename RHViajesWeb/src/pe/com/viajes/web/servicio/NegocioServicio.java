/**
 * 
 */
package pe.com.viajes.web.servicio;

import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.cargaexcel.ColumnasExcel;
import pe.com.viajes.bean.cargaexcel.ReporteArchivo;
import pe.com.viajes.bean.negocio.Cliente;
import pe.com.viajes.bean.negocio.Comprobante;
import pe.com.viajes.bean.negocio.Consolidador;
import pe.com.viajes.bean.negocio.CorreoMasivo;
import pe.com.viajes.bean.negocio.CuentaBancaria;
import pe.com.viajes.bean.negocio.DocumentoAdicional;
import pe.com.viajes.bean.negocio.EventoObsAnu;
import pe.com.viajes.bean.negocio.MaestroServicio;
import pe.com.viajes.bean.negocio.PagoServicio;
import pe.com.viajes.bean.negocio.ProgramaNovios;
import pe.com.viajes.bean.negocio.Proveedor;
import pe.com.viajes.bean.negocio.ServicioAgencia;
import pe.com.viajes.bean.negocio.TipoCambio;
import pe.com.viajes.negocio.exception.EnvioCorreoException;
import pe.com.viajes.negocio.exception.ErrorRegistroDataException;
import pe.com.viajes.negocio.exception.ResultadoCeroDaoException;

/**
 * @author Edwin
 * 
 */
public interface NegocioServicio {

	public boolean registrarProveedor(Proveedor proveedor) throws SQLException,
			Exception;

	public boolean actualizarProveedor(Proveedor proveedor)
			throws SQLException, Exception;

	public boolean registrarCliente(Cliente cliente)
			throws ResultadoCeroDaoException, SQLException, Exception;

	public boolean actualizarCliente(Cliente cliente)
			throws ResultadoCeroDaoException, SQLException, Exception;

	public Integer registrarNovios(ProgramaNovios programaNovios)
			throws SQLException, Exception;

	Integer registrarVentaServicio(ServicioAgencia servicioAgencia)
			throws ErrorRegistroDataException, SQLException, Exception;

	public boolean ingresarMaestroServicio(MaestroServicio servicio)
			throws ErrorRegistroDataException, SQLException, Exception;

	public boolean actualizarMaestroServicio(MaestroServicio servicio)
			throws SQLException, Exception;

	public Integer actualizarNovios(ProgramaNovios programaNovios)
			throws SQLException, Exception;

	Integer actualizarVentaServicio(ServicioAgencia servicioAgencia)
			throws ErrorRegistroDataException, SQLException, Exception;

	public int enviarCorreoMasivo(CorreoMasivo correoMasivo)
			throws EnvioCorreoException, Exception;

	boolean ingresarConsolidador(Consolidador consolidador)
			throws SQLException, Exception;

	public boolean actualizarConsolidador(Consolidador consolidador)
			throws SQLException, Exception;

	public void registrarPago(PagoServicio pago) throws ErrorRegistroDataException, Exception;

	void cerrarVenta(ServicioAgencia servicioAgencia) throws SQLException,
			Exception;

	public void anularVenta(ServicioAgencia servicioAgencia)
			throws SQLException, Exception;

	void registrarEventoObservacion(EventoObsAnu evento) throws SQLException,
			Exception;

	void registrarEventoAnulacion(EventoObsAnu evento) throws SQLException,
			Exception;

	public boolean registrarComprobantes(ServicioAgencia servicioAgencia)
			throws SQLException, Exception;

	boolean registrarObligacionXPagar(Comprobante comprobante)
			throws SQLException, Exception;

	void registrarPagoObligacion(PagoServicio pago) throws SQLException,
			Exception;

	void registrarComprobanteObligacion(ServicioAgencia servicioAgencia)
			throws SQLException, Exception;

	void registrarComprobantesAdicionales(List<Comprobante> lista)
			throws ErrorRegistroDataException, SQLException, Exception;

	public boolean grabarComprobantesReporte(ReporteArchivo reporteArchivo,
			ColumnasExcel columnasExcel, List<ColumnasExcel> dataExcel)
			throws ErrorRegistroDataException, SQLException, Exception;

	boolean registrarCuentaBancaria(CuentaBancaria cuentaBancaria)
			throws ErrorRegistroDataException;

	boolean actualizarCuentaBancaria(CuentaBancaria cuentaBancaria)
			throws ErrorRegistroDataException;

	boolean registrarTipoCambio(TipoCambio tipoCambio) throws SQLException;

	boolean grabarDocumentosAdicionales(List<DocumentoAdicional> lista,
			Integer idEmpresa) throws ErrorRegistroDataException, SQLException,
			Exception;
}
