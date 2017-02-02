package pe.com.viajes.negocio.ejb;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.Date;
import java.util.List;

import javax.ejb.Remote;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.base.Persona;
import pe.com.viajes.bean.cargaexcel.ReporteArchivoBusqueda;
import pe.com.viajes.bean.negocio.Cliente;
import pe.com.viajes.bean.negocio.Comprobante;
import pe.com.viajes.bean.negocio.ComprobanteBusqueda;
import pe.com.viajes.bean.negocio.Consolidador;
import pe.com.viajes.bean.negocio.CorreoClienteMasivo;
import pe.com.viajes.bean.negocio.CuentaBancaria;
import pe.com.viajes.bean.negocio.CuotaPago;
import pe.com.viajes.bean.negocio.DetalleServicioAgencia;
import pe.com.viajes.bean.negocio.DocumentoAdicional;
import pe.com.viajes.bean.negocio.ImpresionArchivoCargado;
import pe.com.viajes.bean.negocio.MaestroServicio;
import pe.com.viajes.bean.negocio.MovimientoCuenta;
import pe.com.viajes.bean.negocio.PagoServicio;
import pe.com.viajes.bean.negocio.Pasajero;
import pe.com.viajes.bean.negocio.ProgramaNovios;
import pe.com.viajes.bean.negocio.Proveedor;
import pe.com.viajes.bean.negocio.ServicioAgencia;
import pe.com.viajes.bean.negocio.ServicioAgenciaBusqueda;
import pe.com.viajes.bean.negocio.ServicioProveedor;
import pe.com.viajes.bean.negocio.TipoCambio;
import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.bean.reportes.CheckIn;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;
import pe.com.viajes.negocio.exception.ValidacionException;

@Remote
public interface ConsultaNegocioSessionRemote {

	List<Proveedor> listarProveedor(Proveedor proveedor) throws SQLException;

	List<Proveedor> buscarProveedor(Proveedor proveedor) throws SQLException;

	List<Cliente> listarCliente(Cliente cliente) throws SQLException;

	List<Cliente> buscarCliente(Cliente cliente) throws SQLException;

	List<ProgramaNovios> consultarNovios(ProgramaNovios programaNovios)
			throws SQLException, Exception;

	List<CuotaPago> consultarCronograma(ServicioAgencia servicioAgencia)
			throws SQLException, Exception;

	List<ServicioAgencia> listarServicioVenta(
			ServicioAgenciaBusqueda servicioAgencia) throws SQLException,
			Exception;

	List<Cliente> consultarCliente2(Cliente cliente) throws SQLException,
			Exception;

	List<ServicioProveedor> proveedoresXServicio(BaseVO servicio)
			throws SQLException, Exception;

	List<Consolidador> listarConsolidador() throws SQLException, Exception;

	Consolidador consultarConsolidador(Consolidador consolidador)
			throws SQLException, Exception;

	List<Comprobante> listarObligacionXPagar(Comprobante comprobante)
			throws SQLException, Exception;

	List<Comprobante> consultarComprobantesGenerados(
			ComprobanteBusqueda comprobanteBusqueda)
			throws ErrorConsultaDataException;

	List<ReporteArchivoBusqueda> consultarArchivosCargados(
			ReporteArchivoBusqueda reporteArchivoBusqueda)
			throws ErrorConsultaDataException;

	List<CheckIn> consultarCheckInPendientes(Usuario usuario)
			throws SQLException;

	List<Pasajero> consultarPasajeroHistorico(Pasajero pasajero)
			throws ErrorConsultaDataException;

	Proveedor consultarProveedor(int codigoProveedor, Integer idEmpresa)
			throws SQLException, Exception;

	Cliente consultarCliente(int idcliente, Integer idEmpresa)
			throws SQLException, Exception;

	List<Cliente> listarClientesNovios(String genero, Integer idEmpresa)
			throws SQLException, Exception;

	List<Cliente> consultarClientesNovios(Cliente cliente, Integer idEmpresa)
			throws SQLException, Exception;

	ServicioAgencia consultarServicioVenta(int idServicio, Integer idEmpresa)
			throws SQLException, Exception;

	ProgramaNovios consultarProgramaNovios(int idProgramaNovios,
			Integer idEmpresa) throws ValidacionException, SQLException,
			Exception;

	List<MaestroServicio> listarMaestroServicio(Integer idEmpresa)
			throws SQLException, Exception;

	List<MaestroServicio> listarMaestroServicioAdm(Integer idEmpresa)
			throws SQLException, Exception;

	List<MaestroServicio> listarMaestroServicioFee(Integer idEmpresa)
			throws SQLException, Exception;

	List<MaestroServicio> listarMaestroServicioIgv(Integer idEmpresa)
			throws SQLException, Exception;

	List<MaestroServicio> listarMaestroServicioImpto(Integer idEmpresa)
			throws SQLException, Exception;

	MaestroServicio consultarMaestroServicio(int idMaestroServicio,
			Integer idEmpresa) throws SQLException, Exception;

	List<CorreoClienteMasivo> listarClientesCorreo(Integer idEmpresa)
			throws SQLException, Exception;

	List<Cliente> listarClientesCumples(Integer idEmpresa) throws SQLException,
			Exception;

	List<BaseVO> consultaServiciosDependientes(Integer idServicio,
			Integer idEmpresa) throws SQLException, Exception;

	List<PagoServicio> listarPagosServicio(Integer idServicio, Integer idEmpresa)
			throws SQLException, Exception;

	List<PagoServicio> listarPagosObligacion(Integer idObligacion,
			Integer idEmpresa) throws SQLException, Exception;

	BigDecimal consultarSaldoServicio(Integer idServicio, Integer idEmpresa)
			throws SQLException, Exception;

	List<DetalleServicioAgencia> consultarDetalleServicioComprobante(
			Integer idServicio, Integer idEmpresa) throws SQLException,
			Exception;

	List<DetalleServicioAgencia> consultarDetServComprobanteObligacion(
			Integer idServicio, Integer idEmpresa)
			throws ErrorConsultaDataException, SQLException, Exception;

	List<DocumentoAdicional> listarDocumentosAdicionales(Integer idServicio,
			Integer idEmpresa) throws SQLException;

	Comprobante consultarComprobante(Integer idComprobante, Integer idEmpresa)
			throws ErrorConsultaDataException;

	DetalleServicioAgencia consultaDetalleServicioDetalle(int idServicio,
			int idDetServicio, Integer idEmpresa) throws SQLException;

	List<CuentaBancaria> listarCuentasBancarias(Integer idEmpresa)
			throws SQLException;

	CuentaBancaria consultaCuentaBancaria(Integer idCuenta, Integer idEmpresa)
			throws SQLException;

	List<CuentaBancaria> listarCuentasBancariasCombo(Integer idEmpresa)
			throws SQLException;

	Comprobante consultarComprobanteObligacion(Integer idObligacion,
			Integer idEmpresa) throws SQLException;

	List<CuentaBancaria> listarCuentasBancariasProveedor(Integer idProveedor,
			Integer idEmpresa) throws SQLException;

	List<MovimientoCuenta> listarMovimientosXCuenta(Integer idCuenta,
			Integer idEmpresa) throws SQLException;

	List<TipoCambio> listarTipoCambio(Date fecha, Integer idEmpresa)
			throws SQLException;

	List<ImpresionArchivoCargado> consultaImpresionArchivoCargado(
			Integer idArchivoCargado, Integer idEmpresa) throws SQLException;

	List<Comprobante> consultarObligacionesPendientes(int idEmpresa)
			throws ErrorConsultaDataException;

	List<DocumentoAdicional> listarDocumentosAdicionales(Persona persona)
			throws ErrorConsultaDataException;

	Pasajero consultaClientePasajero(Pasajero pasajero)
			throws ErrorConsultaDataException;

	Pasajero consultaContactoPasajero(Pasajero pasajero) throws ErrorConsultaDataException;

	TipoCambio consultarTipoCambio(Integer idEmpresa)
			throws ErrorConsultaDataException;

	List<DetalleServicioAgencia> consultarDescripcionServicioDC(
			Integer idEmpresa, Integer idServicio)
			throws ErrorConsultaDataException;
}
