package pe.com.viajes.negocio.ejb;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import javax.ejb.EJB;
import javax.ejb.Stateless;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.base.CorreoElectronico;
import pe.com.viajes.bean.base.Persona;
import pe.com.viajes.bean.cargaexcel.ReporteArchivoBusqueda;
import pe.com.viajes.bean.negocio.Cliente;
import pe.com.viajes.bean.negocio.Comprobante;
import pe.com.viajes.bean.negocio.ComprobanteBusqueda;
import pe.com.viajes.bean.negocio.Consolidador;
import pe.com.viajes.bean.negocio.Contacto;
import pe.com.viajes.bean.negocio.CorreoClienteMasivo;
import pe.com.viajes.bean.negocio.CuentaBancaria;
import pe.com.viajes.bean.negocio.CuotaPago;
import pe.com.viajes.bean.negocio.DetalleServicioAgencia;
import pe.com.viajes.bean.negocio.Direccion;
import pe.com.viajes.bean.negocio.DocumentoAdicional;
import pe.com.viajes.bean.negocio.ImpresionArchivoCargado;
import pe.com.viajes.bean.negocio.Maestro;
import pe.com.viajes.bean.negocio.MaestroServicio;
import pe.com.viajes.bean.negocio.MovimientoCuenta;
import pe.com.viajes.bean.negocio.PagoServicio;
import pe.com.viajes.bean.negocio.Pasajero;
import pe.com.viajes.bean.negocio.ProgramaNovios;
import pe.com.viajes.bean.negocio.Proveedor;
import pe.com.viajes.bean.negocio.ServicioAgencia;
import pe.com.viajes.bean.negocio.ServicioAgenciaBusqueda;
import pe.com.viajes.bean.negocio.ServicioProveedor;
import pe.com.viajes.bean.negocio.Telefono;
import pe.com.viajes.bean.negocio.TipoCambio;
import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.bean.reportes.CheckIn;
import pe.com.viajes.negocio.dao.ArchivoReporteDao;
import pe.com.viajes.negocio.dao.ClienteDao;
import pe.com.viajes.negocio.dao.ComprobanteNovaViajesDao;
import pe.com.viajes.negocio.dao.ConsolidadorDao;
import pe.com.viajes.negocio.dao.ContactoDao;
import pe.com.viajes.negocio.dao.CorreoMasivoDao;
import pe.com.viajes.negocio.dao.CuentaBancariaDao;
import pe.com.viajes.negocio.dao.DireccionDao;
import pe.com.viajes.negocio.dao.MaestroDao;
import pe.com.viajes.negocio.dao.MaestroServicioDao;
import pe.com.viajes.negocio.dao.ParametroDao;
import pe.com.viajes.negocio.dao.ProveedorDao;
import pe.com.viajes.negocio.dao.ServicioNegocioDao;
import pe.com.viajes.negocio.dao.ServicioNovaViajesDao;
import pe.com.viajes.negocio.dao.ServicioNoviosDao;
import pe.com.viajes.negocio.dao.TelefonoDao;
import pe.com.viajes.negocio.dao.TipoCambioDao;
import pe.com.viajes.negocio.dao.impl.ArchivoReporteDaoImpl;
import pe.com.viajes.negocio.dao.impl.ClienteDaoImpl;
import pe.com.viajes.negocio.dao.impl.ComprobanteNovaViajesDaoImpl;
import pe.com.viajes.negocio.dao.impl.ConsolidadorDaoImpl;
import pe.com.viajes.negocio.dao.impl.ContactoDaoImpl;
import pe.com.viajes.negocio.dao.impl.CorreoMasivoDaoImpl;
import pe.com.viajes.negocio.dao.impl.CuentaBancariaDaoImpl;
import pe.com.viajes.negocio.dao.impl.DireccionDaoImpl;
import pe.com.viajes.negocio.dao.impl.MaestroDaoImpl;
import pe.com.viajes.negocio.dao.impl.MaestroServicioDaoImpl;
import pe.com.viajes.negocio.dao.impl.ParametroDaoImpl;
import pe.com.viajes.negocio.dao.impl.ProveedorDaoImpl;
import pe.com.viajes.negocio.dao.impl.ServicioNegocioDaoImpl;
import pe.com.viajes.negocio.dao.impl.ServicioNovaViajesDaoImpl;
import pe.com.viajes.negocio.dao.impl.ServicioNoviosDaoImpl;
import pe.com.viajes.negocio.dao.impl.TelefonoDaoImpl;
import pe.com.viajes.negocio.dao.impl.TipoCambioDaoImpl;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;
import pe.com.viajes.negocio.exception.ValidacionException;
import pe.com.viajes.negocio.util.UtilConexion;
import pe.com.viajes.negocio.util.UtilDatos;
import pe.com.viajes.negocio.util.UtilEjb;
import pe.com.viajes.negocio.util.UtilJdbc;

/**
 * Session Bean implementation class ConsultaNegocioSession
 */
@Stateless(name = "ConsultaNegocioSession")
public class ConsultaNegocioSession implements ConsultaNegocioSessionRemote,
		ConsultaNegocioSessionLocal {

	@EJB
	UtilNegocioSessionLocal utilNegocioSessionLocal;

	@Override
	public List<Proveedor> listarProveedor(Proveedor proveedor)
			throws SQLException {
		ProveedorDao proveedorDao = new ProveedorDaoImpl();
		List<Proveedor> listaProveedores = proveedorDao
				.listarProveedor(proveedor);

		MaestroDao maestroDao = new MaestroDaoImpl();

		for (Proveedor proveedor2 : listaProveedores) {
			Maestro hijoMaestro = new Maestro();
			int valorMaestro = UtilEjb.obtenerEnteroPropertieMaestro("maestroVias", "aplicacionDatosEjb");
			hijoMaestro.setCodigoMaestro(valorMaestro);
			hijoMaestro.setCodigoEntero(proveedor2.getDireccion().getVia()
					.getCodigoEntero());
			hijoMaestro.setEmpresa(proveedor.getEmpresa());
			hijoMaestro = maestroDao.consultarHijoMaestro(hijoMaestro);
			proveedor2.getDireccion().setDireccion(
					UtilDatos.obtenerDireccionCompleta(
							proveedor2.getDireccion(), hijoMaestro));

		}

		return listaProveedores;
	}

	@Override
	public Proveedor consultarProveedor(int codigoProveedor, Integer idEmpresa)
			throws SQLException, Exception {
		DireccionDao direccionDao = new DireccionDaoImpl();
		ProveedorDao proveedorDao = new ProveedorDaoImpl();
		ContactoDao contactoDao = new ContactoDaoImpl();

		Proveedor proveedor = proveedorDao.consultarProveedor(codigoProveedor,idEmpresa);
		List<Direccion> listaDirecciones = direccionDao
				.consultarDireccionProveedor(codigoProveedor,idEmpresa);

		for (Direccion direccion : listaDirecciones) {
			direccion.setDireccion(utilNegocioSessionLocal
					.obtenerDireccionCompleta(direccion));
		}
		proveedor.setListaDirecciones(listaDirecciones);
		proveedor.setListaContactos(contactoDao
				.consultarContactoProveedor(codigoProveedor,idEmpresa));
		proveedor.setListaServicioProveedor(proveedorDao
				.consultarServicioProveedor(codigoProveedor,idEmpresa));

		return proveedor;
	}

	@Override
	public List<Proveedor> buscarProveedor(Proveedor proveedor)
			throws SQLException {
		ProveedorDao proveedorDao = new ProveedorDaoImpl();
		List<Proveedor> listaProveedores = proveedorDao
				.buscarProveedor(proveedor);

		MaestroDao maestroDao = new MaestroDaoImpl();

		for (Proveedor proveedor2 : listaProveedores) {
			Maestro hijoMaestro = new Maestro();
			int valorMaestro = UtilEjb.obtenerEnteroPropertieMaestro("maestroVias", "aplicacionDatosEjb");
			hijoMaestro.setCodigoMaestro(valorMaestro);
			hijoMaestro.setCodigoEntero(proveedor2.getDireccion().getVia()
					.getCodigoEntero());
			hijoMaestro.setEmpresa(proveedor.getEmpresa());
			hijoMaestro = maestroDao.consultarHijoMaestro(hijoMaestro);
			proveedor2.getDireccion().setDireccion(
					UtilDatos.obtenerDireccionCompleta(
							proveedor2.getDireccion(), hijoMaestro));

		}

		return listaProveedores;
	}

	@Override
	public List<Cliente> listarCliente(Cliente cliente) throws SQLException {
		ClienteDao clienteDao = new ClienteDaoImpl();
		List<Cliente> listaClientes = clienteDao.consultarPersona(cliente);

		MaestroDao maestroDao = new MaestroDaoImpl();

		for (Cliente cliente2 : listaClientes) {
			Maestro hijoMaestro = new Maestro();
			int valorMaestro = UtilEjb.obtenerEnteroPropertieMaestro("maestroVias", "aplicacionDatosEjb");
			hijoMaestro.setCodigoMaestro(valorMaestro);
			hijoMaestro.setCodigoEntero(cliente2.getDireccion().getVia()
					.getCodigoEntero());
			hijoMaestro.setEmpresa(cliente.getEmpresa());
			hijoMaestro = maestroDao.consultarHijoMaestro(hijoMaestro);
			cliente2.getDireccion().setDireccion(
					UtilDatos.obtenerDireccionCompleta(cliente2.getDireccion(),
							hijoMaestro));

		}

		return listaClientes;
	}

	@Override
	public List<Cliente> buscarCliente(Cliente cliente) throws SQLException {
		ClienteDao clienteDao = new ClienteDaoImpl();
		List<Cliente> listaClientes = clienteDao.buscarPersona(cliente);

		MaestroDao maestroDao = new MaestroDaoImpl();

		for (Cliente cliente2 : listaClientes) {
			Maestro hijoMaestro = new Maestro();
			int valorMaestro = UtilEjb.obtenerEnteroPropertieMaestro("maestroVias", "aplicacionDatosEjb");
			hijoMaestro.setCodigoMaestro(valorMaestro);
			hijoMaestro.setCodigoEntero(cliente2.getDireccion().getVia()
					.getCodigoEntero());
			hijoMaestro.setEmpresa(cliente.getEmpresa());
			hijoMaestro = maestroDao.consultarHijoMaestro(hijoMaestro);
			cliente2.getDireccion().setDireccion(
					UtilDatos.obtenerDireccionCompleta(cliente2.getDireccion(),
							hijoMaestro));

		}

		return listaClientes;
	}

	@Override
	public Cliente consultarCliente(int idcliente, Integer idEmpresa) throws SQLException,
			Exception {
		DireccionDao direccionDao = new DireccionDaoImpl();
		ClienteDao clienteDao = new ClienteDaoImpl();
		ContactoDao contactoDao = new ContactoDaoImpl();

		Cliente cliente = clienteDao.consultarCliente(idcliente,idEmpresa);
		List<Direccion> listaDirecciones = direccionDao
				.consultarDireccionProveedor(idcliente,idEmpresa);

		for (Direccion direccion : listaDirecciones) {
			direccion.setDireccion(utilNegocioSessionLocal
					.obtenerDireccionCompleta(direccion));
			if (direccion.isPrincipal()){
				cliente.setDireccion(direccion);
			}
		}
		cliente.setListaDirecciones(listaDirecciones);
		cliente.setListaContactos(contactoDao
				.consultarContactoProveedor(idcliente,idEmpresa));
		
		try {
			cliente.setListaAdjuntos(clienteDao.listarAdjuntosPersona(cliente));
		} catch (Exception e) {
			e.printStackTrace();
		}

		return cliente;
	}

	@Override
	public List<Cliente> listarClientesNovios(String genero, Integer idEmpresa)
			throws SQLException, Exception {
		ClienteDao clienteDao = new ClienteDaoImpl();
		return clienteDao.listarClientesNovios(genero,idEmpresa);
	}

	@Override
	public List<Cliente> consultarClientesNovios(Cliente cliente, Integer idEmpresa)
			throws SQLException, Exception {
		ClienteDao clienteDao = new ClienteDaoImpl();
		return clienteDao.consultarClientesNovios(cliente);
	}

	@Override
	public List<ProgramaNovios> consultarNovios(ProgramaNovios programaNovios)
			throws SQLException, Exception {
		ServicioNoviosDao servicioNovios = new ServicioNoviosDaoImpl(programaNovios.getEmpresa().getCodigoEntero());
		return servicioNovios.consultarNovios(programaNovios);
	}

	@Override
	public List<CuotaPago> consultarCronograma(ServicioAgencia servicioAgencia)
			throws SQLException, Exception {
		ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(servicioAgencia.getEmpresa().getCodigoEntero());
		return servicioNovaViajesDao.consultarCronogramaPago(servicioAgencia);
	}

	@Override
	public ServicioAgencia consultarServicioVenta(int idServicio, Integer idEmpresa)
			throws SQLException, Exception {
		ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(idEmpresa);
		ServicioNegocioDao servicioNegocioDao = new ServicioNegocioDaoImpl();

		Connection conn = null;

		ServicioAgencia servicioAgencia;
		try {
			conn = UtilConexion.obtenerConexion();

			servicioAgencia = servicioNovaViajesDao.consultarServiciosVenta2(
					idServicio, conn);

			List<DetalleServicioAgencia> listaServiciosPadre = servicioNovaViajesDao
					.consultaServicioDetallePadre(
							servicioAgencia.getCodigoEntero(), conn);

			List<DetalleServicioAgencia> listaHijos = null;
			DetalleServicioAgencia detalleServicioAgencia = null;
			List<DetalleServicioAgencia> listaServiciosPadreNueva = new ArrayList<DetalleServicioAgencia>();
			for (int i = 0; i < listaServiciosPadre.size(); i++) {
				detalleServicioAgencia = (DetalleServicioAgencia) listaServiciosPadre
						.get(i);
				detalleServicioAgencia
						.setDescripcionServicio(detalleServicioAgencia
								.getDescripcionServicio());
				listaHijos = new ArrayList<DetalleServicioAgencia>();
				listaHijos.add(detalleServicioAgencia);
				listaHijos
						.addAll(servicioNovaViajesDao
								.consultaServicioDetalleHijo(servicioAgencia
										.getCodigoEntero(),
										detalleServicioAgencia
												.getCodigoEntero(), conn));
				detalleServicioAgencia.setServiciosHijos(listaHijos);
				listaHijos = null;
				
				detalleServicioAgencia.setListaPasajeros(servicioNegocioDao.consultarPasajeros(detalleServicioAgencia.getCodigoEntero(),idEmpresa, conn));
				
				listaServiciosPadreNueva.add(detalleServicioAgencia);
			}
			servicioAgencia.setListaDetalleServicio(listaServiciosPadreNueva);

			if (servicioAgencia.getFormaPago().getCodigoEntero() != null
					&& servicioAgencia.getFormaPago().getCodigoEntero()
							.intValue() == 2) {
				servicioAgencia.setCronogramaPago(servicioNovaViajesDao
						.consultarCronogramaPago(servicioAgencia));
			}

		} catch (SQLException e) {
			throw new SQLException(e);
		} catch (Exception e) {
			throw new Exception(e);
		} finally {
			if (conn != null) {
				conn.close();
			}
		}

		return servicioAgencia;
	}

	@Override
	public List<ServicioAgencia> listarServicioVenta(
			ServicioAgenciaBusqueda servicioAgencia) throws SQLException,
			Exception {
		ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(servicioAgencia.getEmpresa().getCodigoEntero());
		return servicioNovaViajesDao.consultarServiciosVenta(servicioAgencia);
	}

	@Override
	public List<Cliente> consultarCliente2(Cliente cliente)
			throws SQLException, Exception {
		ClienteDao clienteDao = new ClienteDaoImpl();
		DireccionDao direccionDao = new DireccionDaoImpl();
		TelefonoDao telefonoDao = new TelefonoDaoImpl(cliente.getEmpresa().getCodigoEntero());
		ContactoDao contactoDao = new ContactoDaoImpl();

		Connection conn = null;

		List<Cliente> listarCliente;
		try {
			conn = UtilConexion.obtenerConexion();
			cliente.setTipoPersona(1);
			listarCliente = clienteDao.listarClientes(cliente, conn);
			int info = 0;
			for (Cliente cliente2 : listarCliente) {
				info = 1;
				cliente2.setInfoCliente(info);
				List<Direccion> listaDireccion = direccionDao
						.consultarDireccionPersona(cliente2.getCodigoEntero(), cliente2.getEmpresa().getCodigoEntero(),
								conn);
				if (listaDireccion != null && listaDireccion.size() > 0) {
					info++;
					cliente2.setInfoCliente(info);
					cliente2.setDireccion(listaDireccion.get(0));
					cliente2.getDireccion().setDireccion(
							utilNegocioSessionLocal
									.obtenerDireccionCompleta(cliente2
											.getDireccion()));
					for (Direccion direccion : listaDireccion) {
						List<Telefono> listaTelefono = telefonoDao
								.consultarTelefonosDireccion(
										direccion.getCodigoEntero(), conn);
						if (listaTelefono != null && listaTelefono.size() > 0) {
							info++;
							cliente2.setInfoCliente(info);
						}
					}
				}

				List<Contacto> listaContacto = contactoDao
						.listarContactosXPersona(cliente2.getCodigoEntero(), cliente2.getEmpresa().getCodigoEntero(),
								conn);
				if (listaContacto != null && listaContacto.size() > 0) {
					info++;
					cliente2.setInfoCliente(info);
					for (Contacto contacto : listaContacto) {
						List<Telefono> listaTelefono = telefonoDao
								.consultarTelefonosXPersona(
										contacto.getCodigoEntero(), conn);
						if (listaTelefono != null && listaTelefono.size() > 0) {
							info++;
							cliente2.setInfoCliente(info);
							cliente2.setTelefonoMovil(listaTelefono.get(0));
						}
					}
				}
			}

		} catch (SQLException e) {
			throw new SQLException(e);
		} catch (Exception e) {
			throw new Exception(e);
		} finally {
			if (conn != null) {
				conn.close();
			}
		}

		return listarCliente;
	}

	@Override
	public List<ServicioProveedor> proveedoresXServicio(BaseVO servicio)
			throws SQLException, Exception {
		ServicioNegocioDao servicioNegocioDao = new ServicioNegocioDaoImpl();

		return servicioNegocioDao.proveedoresXServicio(servicio);
	}

	@Override
	public ProgramaNovios consultarProgramaNovios(int idProgramaNovios, Integer idEmpresa)
			throws ValidacionException, SQLException, Exception {
		ServicioNoviosDao servicioNoviosDao = new ServicioNoviosDaoImpl(idEmpresa);

		ProgramaNovios programa = new ProgramaNovios();
		programa.setCodigoEntero(idProgramaNovios);

		Connection conn = null;

		try {
			conn = UtilConexion.obtenerConexion();

			List<ProgramaNovios> listaProgramaNovios = servicioNoviosDao
					.consultarNovios(programa, conn);
			if (listaProgramaNovios != null && !listaProgramaNovios.isEmpty()) {
				if (listaProgramaNovios.size() > 1) {
					throw new ValidacionException(
							"Se encontro mas de un Programa de novios");
				}
			}
			programa = listaProgramaNovios.get(0);

			programa.setListaInvitados(servicioNoviosDao
					.consultarInvitasosNovios(idProgramaNovios, conn));

		} catch (SQLException e) {
			throw new SQLException(e);
		} catch (Exception e) {
			throw new Exception(e);
		} finally {
			if (conn != null) {
				conn.close();
			}
		}

		return programa;
	}

	@Override
	public List<MaestroServicio> listarMaestroServicio(Integer idEmpresa) throws SQLException,
			Exception {
		MaestroServicioDao maestroServicioDao = new MaestroServicioDaoImpl();

		return maestroServicioDao.listarMaestroServicios(idEmpresa);
	}
	
	@Override
	public List<MaestroServicio> listarMaestroServicioPadre(Integer idEmpresa) throws SQLException,
			Exception {
		MaestroServicioDao maestroServicioDao = new MaestroServicioDaoImpl();

		return maestroServicioDao.listarMaestroServiciosPadre(idEmpresa);
	}

	@Override
	public List<MaestroServicio> listarMaestroServicioAdm(Integer idEmpresa)
			throws SQLException, Exception {
		MaestroServicioDao maestroServicioDao = new MaestroServicioDaoImpl();

		return maestroServicioDao.listarMaestroServiciosAdm(idEmpresa);
	}

	@Override
	public List<MaestroServicio> listarMaestroServicioFee(Integer idEmpresa)
			throws SQLException, Exception {
		MaestroServicioDao maestroServicioDao = new MaestroServicioDaoImpl();

		return maestroServicioDao.listarMaestroServiciosFee(idEmpresa);
	}

	@Override
	public List<MaestroServicio> listarMaestroServicioIgv(Integer idEmpresa)
			throws SQLException, Exception {
		MaestroServicioDao maestroServicioDao = new MaestroServicioDaoImpl();

		return maestroServicioDao.listarMaestroServiciosIgv(idEmpresa);
	}

	@Override
	public List<MaestroServicio> listarMaestroServicioImpto(Integer idEmpresa)
			throws SQLException, Exception {
		MaestroServicioDao maestroServicioDao = new MaestroServicioDaoImpl();

		return maestroServicioDao.listarMaestroServiciosImpto(idEmpresa);
	}

	@Override
	public MaestroServicio consultarMaestroServicio(int idMaestroServicio, Integer idEmpresa)
			throws SQLException, Exception {
		MaestroServicioDao maestroServicioDao = new MaestroServicioDaoImpl();

		MaestroServicio maestroServicio = maestroServicioDao
				.consultarMaestroServicio(idMaestroServicio,idEmpresa);

		List<BaseVO> listaDependientes = maestroServicioDao
				.consultarServicioDependientes(maestroServicio
						.getCodigoEntero(),idEmpresa);

		maestroServicio.setListaServicioDepende(listaDependientes);

		return maestroServicio;
	}
	

	@Override
	public List<CorreoClienteMasivo> listarClientesCorreo(Integer idEmpresa)
			throws SQLException, Exception {
		CorreoMasivoDao correoMasivoDao = new CorreoMasivoDaoImpl();

		return correoMasivoDao.listarClientesCorreo(idEmpresa);
	}

	@Override
	public List<Cliente> listarClientesCumples(Integer idEmpresa) throws SQLException, Exception {
		ClienteDao clienteDao = new ClienteDaoImpl();
		return clienteDao.listarClienteCumpleanieros(idEmpresa);
	}

	@Override
	public List<BaseVO> consultaServiciosDependientes(Integer idServicio, Integer idEmpresa)
			throws SQLException, Exception {
		MaestroServicioDao maestroServicioDao = new MaestroServicioDaoImpl();

		return maestroServicioDao.consultarServicioDependientes(idServicio,idEmpresa);
	}

	@Override
	public List<Consolidador> listarConsolidador() throws SQLException,
			Exception {
		ConsolidadorDao consolidadorDao = new ConsolidadorDaoImpl();

		return consolidadorDao.listarConsolidador();
	}

	@Override
	public Consolidador consultarConsolidador(Consolidador consolidador)
			throws SQLException, Exception {
		ConsolidadorDao consolidadorDao = new ConsolidadorDaoImpl();

		return consolidadorDao.consultarConsolidador(consolidador);
	}

	@Override
	public List<PagoServicio> listarPagosServicio(Integer idServicio, Integer idEmpresa)
			throws SQLException, Exception {
		ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(idEmpresa);

		return servicioNovaViajesDao.listarPagosServicio(idServicio);
	}

	@Override
	public List<PagoServicio> listarPagosObligacion(Integer idObligacion, Integer idEmpresa)
			throws SQLException, Exception {
		ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(idEmpresa);

		return servicioNovaViajesDao.listarPagosObligacion(idObligacion);
	}

	@Override
	public BigDecimal consultarSaldoServicio(Integer idServicio, Integer idEmpresa)
			throws SQLException, Exception {
		ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(idEmpresa);

		return servicioNovaViajesDao.consultarSaldoServicio(idServicio);
	}

	@Override
	public List<DetalleServicioAgencia> consultarDetalleServicioComprobante(
			Integer idServicio, Integer idEmpresa) throws SQLException, Exception {
		ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(idEmpresa);

		List<DetalleServicioAgencia> lista = servicioNovaViajesDao
				.consultaServicioDetalleComprobante(idServicio);

		for (DetalleServicioAgencia detalleServicioAgencia : lista) {
			detalleServicioAgencia.getServiciosHijos().add(
					detalleServicioAgencia);
			List<DetalleServicioAgencia> lista2 = servicioNovaViajesDao
					.consultaServicioDetalleComprobanteHijo(idServicio,
							detalleServicioAgencia.getCodigoEntero());
			detalleServicioAgencia.getServiciosHijos().addAll(lista2);
		}

		return lista;
	}

	@Override
	public List<DetalleServicioAgencia> consultarDetServComprobanteObligacion(
			Integer idServicio, Integer idEmpresa) throws ErrorConsultaDataException,
			SQLException, Exception {
		ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(idEmpresa);
		List<DetalleServicioAgencia> lista = null;
		Connection conn = null;

		try {
			conn = UtilConexion.obtenerConexion();
			lista = servicioNovaViajesDao.consultaServDetComprobanteObligacion(
					idServicio, conn);
			for (DetalleServicioAgencia detalleServicioAgencia : lista) {
				detalleServicioAgencia.getServiciosHijos().add(
						detalleServicioAgencia);
				detalleServicioAgencia.getServiciosHijos().addAll(
						servicioNovaViajesDao
								.consultaServDetComprobanteObligacionHijo(
										idServicio, detalleServicioAgencia
												.getCodigoEntero(), conn));
			}

			return lista;
		} catch (SQLException e) {
			throw new ErrorConsultaDataException(e);
		} catch (Exception e) {
			throw new ErrorConsultaDataException(e);
		} finally {
			if (conn != null) {
				conn.close();
			}
		}
	}

	@Override
	public List<Comprobante> listarObligacionXPagar(Comprobante comprobante)
			throws SQLException, Exception {
		ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(comprobante.getEmpresa().getCodigoEntero());
		return servicioNovaViajesDao.consultaObligacionXPagar(comprobante);
	}

	@Override
	public List<DocumentoAdicional> listarDocumentosAdicionales(
			Integer idServicio, Integer idEmpresa) throws SQLException {
		ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(idEmpresa);
		return servicioNovaViajesDao.listarDocumentosAdicionales(idServicio);
	}

	@Override
	public List<Comprobante> consultarComprobantesGenerados(
			ComprobanteBusqueda comprobanteBusqueda)
			throws ErrorConsultaDataException {
		try {
			ComprobanteNovaViajesDao comprobanteNovaViajesDao = new ComprobanteNovaViajesDaoImpl();
			return comprobanteNovaViajesDao
					.consultarComprobantes(comprobanteBusqueda);
		} catch (SQLException e) {
			throw new ErrorConsultaDataException(e);
		} catch (Exception e) {
			throw new ErrorConsultaDataException(e);
		}
	}

	@Override
	public Comprobante consultarComprobante(Integer idComprobante, Integer idEmpresa)
			throws ErrorConsultaDataException {
		try {
			ComprobanteNovaViajesDao comprobanteNovaViajesDao = new ComprobanteNovaViajesDaoImpl();

			ComprobanteBusqueda comprobanteBusqueda = new ComprobanteBusqueda();
			comprobanteBusqueda.setCodigoEntero(idComprobante);
			comprobanteBusqueda.getEmpresa().setCodigoEntero(idEmpresa);

			List<Comprobante> comprobantes = comprobanteNovaViajesDao
					.consultarComprobantes(comprobanteBusqueda);

			Comprobante comprobante = comprobantes.get(0);
			comprobante.setDetalleComprobante(comprobanteNovaViajesDao
					.consultarDetalleComprobante(idComprobante, idEmpresa));

			return comprobante;
		} catch (SQLException e) {
			throw new ErrorConsultaDataException(e);
		} catch (Exception e) {
			throw new ErrorConsultaDataException(e);
		}
	}

	@Override
	public List<ReporteArchivoBusqueda> consultarArchivosCargados(
			ReporteArchivoBusqueda reporteArchivoBusqueda)
			throws ErrorConsultaDataException {
		try {
			ArchivoReporteDao archivoReporteDao = new ArchivoReporteDaoImpl();
			return archivoReporteDao
					.consultarArchivosCargados(reporteArchivoBusqueda);
		} catch (SQLException e) {
			throw new ErrorConsultaDataException(e);
		} catch (Exception e) {
			throw new ErrorConsultaDataException(e);
		}
	}

	@Override
	public DetalleServicioAgencia consultaDetalleServicioDetalle(
			int idServicio, int idDetServicio, Integer idEmpresa)  throws SQLException {
		Connection conn = null;
		try{
			conn = UtilConexion.obtenerConexion();
			
			ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(idEmpresa);

			DetalleServicioAgencia detalle = servicioNovaViajesDao
					.consultaDetalleServicioDetalle(idServicio, idDetServicio, conn);
			ServicioNegocioDao servicioNegocioDao = new ServicioNegocioDaoImpl();
			
			List<Pasajero> pasajeros = servicioNegocioDao.consultarPasajeros(idDetServicio, idEmpresa, conn);
			
			detalle.setListaPasajeros(pasajeros);
			int idTipoServicio = detalle.getTipoServicio().getCodigoEntero().intValue();
			if (idTipoServicio == UtilEjb.obtenerEnteroPropertieMaestro("servicioBoletoAereo", "aplicacionDatosEjb")){
				detalle.getRuta().setTramos(
						servicioNovaViajesDao.consultarTramos(detalle.getRuta()
								.getCodigoEntero(), conn));
				
				detalle.setAerolinea(detalle.getRuta().getTramos().get(0).getAerolinea());
			}
			return detalle;
		}
		catch (SQLException e){
			throw new SQLException(e);
		}
		finally{
			if ( conn != null){
				conn.close();
			}
		}
	}

	@Override
	public List<CuentaBancaria> listarCuentasBancarias(Integer idEmpresa) throws SQLException {
		CuentaBancariaDao cuentaBancariaDao = new CuentaBancariaDaoImpl();

		return cuentaBancariaDao.listarCuentasBancarias(idEmpresa);
	}

	@Override
	public CuentaBancaria consultaCuentaBancaria(Integer idCuenta, Integer idEmpresa)
			throws SQLException {
		CuentaBancariaDao cuentaBancariaDao = new CuentaBancariaDaoImpl();

		return cuentaBancariaDao.consultaCuentaBancaria(idCuenta, idEmpresa);
	}

	@Override
	public List<CuentaBancaria> listarCuentasBancariasCombo(Integer idEmpresa)
			throws SQLException {
		CuentaBancariaDao cuentaBancariaDao = new CuentaBancariaDaoImpl();

		return cuentaBancariaDao.listarCuentasBancariasCombo(idEmpresa);
	}

	@Override
	public Comprobante consultarComprobanteObligacion(Integer idObligacion, Integer idEmpresa)
			throws SQLException {
		ComprobanteNovaViajesDao comprobanteDao = new ComprobanteNovaViajesDaoImpl();

		return comprobanteDao.consultarObligacion(idObligacion, idEmpresa);
	}

	@Override
	public List<CuentaBancaria> listarCuentasBancariasProveedor(
			Integer idProveedor, Integer idEmpresa) throws SQLException {
		ProveedorDao proveedorDao = new ProveedorDaoImpl();

		return proveedorDao.listarCuentasBancarias(idProveedor, idEmpresa);
	}

	@Override
	public List<MovimientoCuenta> listarMovimientosXCuenta(Integer idCuenta, Integer idEmpresa)
			throws SQLException {
		CuentaBancariaDao cuentaBancariaDao = new CuentaBancariaDaoImpl();

		return cuentaBancariaDao.listarMovimientoCuentaBancaria(idCuenta, idEmpresa);
	}

	@Override
	public List<TipoCambio> listarTipoCambio(Date fecha, Integer idEmpresa) throws SQLException {
		TipoCambioDao tipoCambioDao = new TipoCambioDaoImpl(idEmpresa);
		return tipoCambioDao.listarTipoCambio(fecha);
	}
	
	@Override
	public List<CheckIn> consultarCheckInPendientes(Usuario usuario) throws SQLException{
		ServicioNegocioDao servicioNegocioDao = new ServicioNegocioDaoImpl();
		ParametroDao parametroDao = new ParametroDaoImpl();
		Calendar cal = Calendar.getInstance();
		int numeroHoras = 100;
		numeroHoras = UtilEjb.convertirCadenaEntero(parametroDao.consultarParametro(UtilEjb.obtenerEnteroPropertieMaestro("codigoParametroCheckIn", "aplicacionDatosEjb"), usuario.getEmpresa().getCodigoEntero()).getValor());
		cal.add(Calendar.HOUR, numeroHoras);
		
		if (UtilEjb.validarPermisoRoles(usuario.getListaRoles(), UtilEjb.obtenerEnteroPropertieMaestro("rolSupervisorVen", "aplicacionDatosEjb"))){
			return servicioNegocioDao.consultarcheckinpendientes(cal.getTime(), null, usuario.getEmpresa().getCodigoEntero());
		}
		else{
			return servicioNegocioDao.consultarcheckinpendientes(cal.getTime(), usuario.getCodigoEntero(), usuario.getEmpresa().getCodigoEntero());
		}
	}
	
	@Override
	public List<ImpresionArchivoCargado> consultaImpresionArchivoCargado(Integer idArchivoCargado, Integer idEmpresa) throws SQLException{
		ArchivoReporteDao archivoReporteDao = new ArchivoReporteDaoImpl();
		return archivoReporteDao.consultaImpresionArchivoCargado(idArchivoCargado, idEmpresa);
	}
	
	@Override
	public List<Pasajero> consultarPasajeroHistorico(Pasajero pasajero) throws ErrorConsultaDataException{
		try {
			ServicioNegocioDao servicioNegocioDao = new ServicioNegocioDaoImpl();
			List<Pasajero> listaPasajeros = servicioNegocioDao.consultarPasajeroHistorico(pasajero);
			return listaPasajeros;
		} catch (SQLException e) {
			throw new ErrorConsultaDataException(e.getMessage());
		}
	}
	
	@Override
	public List<Comprobante> consultarObligacionesPendientes(int idEmpresa) throws ErrorConsultaDataException {
		try {
			ServicioNegocioDao servicioNegocioDao = new ServicioNegocioDaoImpl();
			
			Date fechaHasta = new Date();
			
			return servicioNegocioDao.consultarObligacionesPendientes(idEmpresa,fechaHasta);
		} catch (SQLException e) {
			throw new ErrorConsultaDataException(e.getMessage(),e);
		} catch (Exception e){
			throw new ErrorConsultaDataException("Ha ocurrido un error al realizar la consulta");
		}
		
	}
	
	@Override
	public List<DocumentoAdicional> listarDocumentosAdicionales(Persona persona) throws ErrorConsultaDataException{
		List documentosAdicionales = null;
		try {
			ClienteDao clienteDao = new ClienteDaoImpl();
			documentosAdicionales = clienteDao.listarAdjuntosPersona(persona);
		} catch (SQLException e) {
			throw new ErrorConsultaDataException(e.getMessage(),e);
		} catch (Exception e){
			throw new ErrorConsultaDataException("Ha ocurrido un error al realizar la consulta");
		}
		
		return documentosAdicionales;
	}
	
	@Override
	public Pasajero consultaClientePasajero(Pasajero pasajero) throws ErrorConsultaDataException{
		try {
			ClienteDao clienteDao = new ClienteDaoImpl();
			List<Cliente> listaClientes = clienteDao.listarClientes(pasajero);
			
			if (listaClientes != null && !listaClientes.isEmpty()){
				Cliente cliente = this.consultarCliente(listaClientes.get(0).getCodigoEntero().intValue(), pasajero.getEmpresa().getCodigoEntero().intValue());
				
				pasajero.setNombres(cliente.getNombres());
				pasajero.setApellidoPaterno(cliente.getApellidoPaterno());
				pasajero.setApellidoMaterno(cliente.getApellidoMaterno());
				pasajero.setFechaNacimiento(cliente.getFechaNacimiento());
				pasajero.setFechaVctoPasaporte(cliente.getFechaVctoPasaporte());
				pasajero.setNroPasaporte(cliente.getNroPasaporte());
				pasajero.setTelefono1(obtenerTelefonoCliente(cliente.getListaContactos()));
				pasajero.setTelefono2(obtenerTelefonoFijoCliente(cliente.getListaDirecciones()));
				pasajero.setCorreoElectronico(obtenerCorreoElectronico(cliente.getListaContactos()));
			}
			
			return pasajero;
		} catch (SQLException e) {
			throw new ErrorConsultaDataException(e.getMessage(),e);
		} catch (Exception e) {
			throw new ErrorConsultaDataException("Ha ocurrido un error al realizar la consulta",e);
		}
		
	}

	private String obtenerCorreoElectronico(List<Contacto> listaContactos) {
		if (listaContactos.size()>0){
			Contacto contacto = listaContactos.get(0);
			List<CorreoElectronico> correos = contacto.getListaCorreos();
			if (correos.size()>0){
				CorreoElectronico correo = correos.get(0);
				return correo.getDireccion();
			}
		}
		
		return "";
	}

	private String obtenerTelefonoCliente(List<Contacto> listaContactos) {
		if (listaContactos.size()>0){
			Contacto contacto = listaContactos.get(0);
			List<Telefono> telefonos = contacto.getListaTelefonos();
			if (telefonos.size()>0){
				Telefono telefono = telefonos.get(0);
				return UtilJdbc.quitaEspaciosInternos(telefono.getNumeroTelefono());
			}
		}
		
		return "";
	}
	
	private String obtenerTelefonoFijoCliente(List<Direccion> listaDireccion) {
		if (listaDireccion.size()>0){
			Direccion direccion = listaDireccion.get(0);
			List<Telefono> telefonos = direccion.getTelefonos();
			if (telefonos.size()>0){
				Telefono telefono = telefonos.get(0);
				return UtilJdbc.quitaEspaciosInternos(telefono.getNumeroTelefono());
			}
		}
		
		return "";
	}

	@Override
	public Pasajero consultaContactoPasajero(Pasajero pasajero) throws ErrorConsultaDataException {
		try {
			ContactoDao contactoDao = new ContactoDaoImpl();
			List<Contacto> listaClientes = contactoDao.consultarContactoPasajero(pasajero);
			
			if (listaClientes != null && !listaClientes.isEmpty()){
				Contacto cliente = listaClientes.get(0);
				
				pasajero.setNombres(cliente.getNombres());
				pasajero.setApellidoPaterno(cliente.getApellidoPaterno());
				pasajero.setApellidoMaterno(cliente.getApellidoMaterno());
				if (!cliente.getListaTelefonos().isEmpty()){
					pasajero.setTelefono1(UtilJdbc.quitaEspaciosInternos(cliente.getListaTelefonos().get(0).getNumeroTelefono()));
				}
				if (!cliente.getListaCorreos().isEmpty()){
					pasajero.setCorreoElectronico(cliente.getListaCorreos().get(0).getDireccion());
				}
			}
			
			return pasajero;
		} catch (SQLException e) {
			throw new ErrorConsultaDataException(e.getMessage(),e);
		} catch (Exception e) {
			throw new ErrorConsultaDataException("Ha ocurrido un error al realizar la consulta",e);
		}
	}
	
	@Override
	public TipoCambio consultarTipoCambio (Integer idEmpresa) throws ErrorConsultaDataException{
		try {
			TipoCambioDao tipoCambioDao = new TipoCambioDaoImpl(idEmpresa);
			Integer idMonedaOrigen = 2;
			Integer idMonedaDestino = 1;
			return tipoCambioDao.consultarTipoCambio(idMonedaOrigen, idMonedaDestino);
		} catch (SQLException e) {
			throw new ErrorConsultaDataException("No se pudo completar la consulta de tipo de cambio", e);
		}
	}
	@Override
	public List<DetalleServicioAgencia> consultarDescripcionServicioDC(Integer idEmpresa, Integer idServicio) throws ErrorConsultaDataException{
		try {
			ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(idEmpresa);
			List<DetalleServicioAgencia> lista = servicioNovaViajesDao.consultarDescripcionServicioDC(idEmpresa, idServicio);
			for (DetalleServicioAgencia detalleServicioAgencia : lista) {
				detalleServicioAgencia.setPasajeros(UtilEjb.listaPasajerosString(detalleServicioAgencia.getListaPasajeros()));
			}
			
			return lista;
		} catch (SQLException e) {
			throw new ErrorConsultaDataException(e);
		}
	}
	
}
