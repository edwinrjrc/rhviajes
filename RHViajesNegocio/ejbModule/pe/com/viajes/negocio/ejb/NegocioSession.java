package pe.com.viajes.negocio.ejb;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.annotation.Resource;
import javax.ejb.EJB;
import javax.ejb.Stateless;
import javax.ejb.TransactionManagement;
import javax.ejb.TransactionManagementType;
import javax.mail.MessagingException;
import javax.mail.NoSuchProviderException;
import javax.mail.internet.AddressException;
import javax.transaction.SystemException;
import javax.transaction.UserTransaction;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.cargaexcel.ColumnasExcel;
import pe.com.viajes.bean.cargaexcel.ReporteArchivo;
import pe.com.viajes.bean.negocio.Cliente;
import pe.com.viajes.bean.negocio.Comprobante;
import pe.com.viajes.bean.negocio.Consolidador;
import pe.com.viajes.bean.negocio.Contacto;
import pe.com.viajes.bean.negocio.CorreoClienteMasivo;
import pe.com.viajes.bean.negocio.CorreoMasivo;
import pe.com.viajes.bean.negocio.CuentaBancaria;
import pe.com.viajes.bean.negocio.DetalleServicioAgencia;
import pe.com.viajes.bean.negocio.Direccion;
import pe.com.viajes.bean.negocio.DocumentoAdicional;
import pe.com.viajes.bean.negocio.EventoObsAnu;
import pe.com.viajes.bean.negocio.MaestroServicio;
import pe.com.viajes.bean.negocio.PagoServicio;
import pe.com.viajes.bean.negocio.Parametro;
import pe.com.viajes.bean.negocio.Pasajero;
import pe.com.viajes.bean.negocio.ProgramaNovios;
import pe.com.viajes.bean.negocio.Proveedor;
import pe.com.viajes.bean.negocio.ServicioAgencia;
import pe.com.viajes.bean.negocio.ServicioProveedor;
import pe.com.viajes.bean.negocio.Telefono;
import pe.com.viajes.bean.negocio.TipoCambio;
import pe.com.viajes.bean.negocio.Tramo;
import pe.com.viajes.negocio.dao.ArchivoReporteDao;
import pe.com.viajes.negocio.dao.ClienteDao;
import pe.com.viajes.negocio.dao.ComprobanteNovaViajesDao;
import pe.com.viajes.negocio.dao.ConsolidadorDao;
import pe.com.viajes.negocio.dao.ContactoDao;
import pe.com.viajes.negocio.dao.CuentaBancariaDao;
import pe.com.viajes.negocio.dao.DestinoDao;
import pe.com.viajes.negocio.dao.DireccionDao;
import pe.com.viajes.negocio.dao.MaestroServicioDao;
import pe.com.viajes.negocio.dao.ParametroDao;
import pe.com.viajes.negocio.dao.PersonaDao;
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
import pe.com.viajes.negocio.dao.impl.CuentaBancariaDaoImpl;
import pe.com.viajes.negocio.dao.impl.DestinoDaoImpl;
import pe.com.viajes.negocio.dao.impl.DireccionDaoImpl;
import pe.com.viajes.negocio.dao.impl.MaestroServicioDaoImpl;
import pe.com.viajes.negocio.dao.impl.ParametroDaoImpl;
import pe.com.viajes.negocio.dao.impl.PersonaDaoImpl;
import pe.com.viajes.negocio.dao.impl.ProveedorDaoImpl;
import pe.com.viajes.negocio.dao.impl.ServicioNegocioDaoImpl;
import pe.com.viajes.negocio.dao.impl.ServicioNovaViajesDaoImpl;
import pe.com.viajes.negocio.dao.impl.ServicioNoviosDaoImpl;
import pe.com.viajes.negocio.dao.impl.TelefonoDaoImpl;
import pe.com.viajes.negocio.dao.impl.TipoCambioDaoImpl;
import pe.com.viajes.negocio.exception.EnvioCorreoException;
import pe.com.viajes.negocio.exception.ErrorRegistroDataException;
import pe.com.viajes.negocio.exception.ResultadoCeroDaoException;
import pe.com.viajes.negocio.exception.ValidacionException;
import pe.com.viajes.negocio.util.UtilConexion;
import pe.com.viajes.negocio.util.UtilCorreo;
import pe.com.viajes.negocio.util.UtilEjb;

/**
 * Session Bean implementation class NegocioSession
 */
@Stateless(name = "NegocioSession")
@TransactionManagement(TransactionManagementType.BEAN)
public class NegocioSession implements NegocioSessionRemote,
		NegocioSessionLocal {
	
	private final static Logger logger = Logger
			.getLogger(NegocioSession.class);

	@Resource
	private UserTransaction userTransaction;

	@EJB
	UtilNegocioSessionLocal utilNegocioSessionLocal;

	@EJB
	ConsultaNegocioSessionLocal consultaNegocioSessionLocal;

	@Override
	public boolean registrarProveedor(Proveedor proveedor)
			throws ResultadoCeroDaoException, SQLException, Exception {
		PersonaDao personaDao = new PersonaDaoImpl();
		DireccionDao direccionDao = new DireccionDaoImpl();
		TelefonoDao telefonoDao = new TelefonoDaoImpl(proveedor.getEmpresa().getCodigoEntero());
		ProveedorDao proveedorDao = new ProveedorDaoImpl();
		ContactoDao contactoDao = new ContactoDaoImpl();

		userTransaction.begin();
		Connection conexion = null;
		try {
			conexion = UtilConexion.obtenerConexion();

			proveedor.setTipoPersona(2);
			int idPersona = personaDao.registrarPersona(proveedor, conexion);
			if (idPersona == 0) {
				throw new ResultadoCeroDaoException(
						"No se pudo completar el registro de la persona");
			}
			proveedor.setCodigoEntero(idPersona);
			if (proveedor.getListaDirecciones() != null) {
				int idDireccion = 0;
				for (Direccion direccion : proveedor.getListaDirecciones()) {
					idDireccion = direccionDao.registrarDireccion(direccion,
							conexion);
					if (idDireccion == 0) {
						throw new ResultadoCeroDaoException(
								"No se pudo completar el registro de la direccion");
					}
					direccion.setCodigoEntero(idDireccion);
					int idTelefono = 0;
					if (!direccion.getTelefonos().isEmpty()) {
						for (Telefono telefono : direccion.getTelefonos()) {
							telefono.getEmpresaOperadora().setCodigoEntero(0);
							idTelefono = telefonoDao.registrarTelefono(
									telefono, conexion);
							if (idTelefono == 0) {
								throw new ResultadoCeroDaoException(
										"No se pudo completar el registro del telefono");
							}
							telefono.setCodigoEntero(idTelefono);
							telefonoDao.registrarTelefonoDireccion(telefono,
									direccion, conexion);
						}
					}

					direccion.setCodigoEntero(idDireccion);
					direccionDao.registrarPersonaDireccion(proveedor, direccion, conexion);
				}
			}

			if (proveedor.getListaContactos() != null) {
				int idContacto = 0;
				for (Contacto contacto : proveedor.getListaContactos()) {
					contacto.setTipoPersona(3);
					idContacto = personaDao
							.registrarPersona(contacto, conexion);
					contacto.setCodigoEntero(idContacto);
					if (!contacto.getListaTelefonos().isEmpty()) {
						for (Telefono telefono : contacto.getListaTelefonos()) {
							int idTelefono = telefonoDao.registrarTelefono(
									telefono, conexion);
							if (idTelefono == 0) {
								throw new ResultadoCeroDaoException(
										"No se pudo completar el registro del telefono");
							}
							telefono.setCodigoEntero(idTelefono);
							telefonoDao.registrarTelefonoPersona(telefono,
									contacto, conexion);
						}
					}
					contactoDao.registrarContactoProveedor(idPersona, contacto,
							conexion);

					contactoDao.ingresarCorreoElectronico(contacto, conexion);
				}
			}
			
			if (proveedor.getListaServicioProveedor() != null) {
				for (ServicioProveedor servicio : proveedor
						.getListaServicioProveedor()) {
					boolean resultado = proveedorDao.ingresarServicioProveedor(
							idPersona, servicio, conexion);
					if (!resultado) {
						throw new ResultadoCeroDaoException(
								"No se pudo completar el registro del servicios");
					}
				}
			}

			if (proveedor.getListaCuentas() != null) {
				for (CuentaBancaria cuenta : proveedor.getListaCuentas()) {
					if (!proveedorDao.ingresarCuentaBancaria(idPersona, cuenta,
							conexion)) {
						throw new ResultadoCeroDaoException(
								"No se pudo completar el registro del proveedor");
					}
				}
			}

			proveedorDao.registroProveedor(proveedor, conexion);
			proveedorDao.registroProveedorTipo(proveedor, conexion);

			userTransaction.commit();
			return true;
		} catch (ResultadoCeroDaoException e) {
			userTransaction.rollback();
			throw new ResultadoCeroDaoException(e.getMensajeError(), e);
		} catch (SQLException e) {
			userTransaction.rollback();
			throw new SQLException(e);
		} finally {
			if (conexion != null) {
				conexion.close();
			}
		}
	}

	@Override
	public boolean actualizarProveedor(Proveedor proveedor)
			throws SQLException, ResultadoCeroDaoException, Exception {
		PersonaDao personaDao = new PersonaDaoImpl();
		DireccionDao direccionDao = new DireccionDaoImpl();
		TelefonoDao telefonoDao = new TelefonoDaoImpl(proveedor.getEmpresa().getCodigoEntero());
		ProveedorDao proveedorDao = new ProveedorDaoImpl();
		ContactoDao contactoDao = new ContactoDaoImpl();

		userTransaction.begin();
		Connection conexion = null;
		try {
			conexion = UtilConexion.obtenerConexion();

			proveedor.setTipoPersona(2);

			Integer idPersona = personaDao.actualizarPersona(proveedor,
					conexion);
			if (idPersona == 0) {
				throw new ResultadoCeroDaoException(
						"No se pudo completar la actualización de la persona");
			}
			proveedor.setCodigoEntero(idPersona);
			direccionDao.eliminarDireccionPersona(proveedor, conexion);
			if (proveedor.getListaDirecciones() != null) {
				int idDireccion = 0;
				for (Direccion direccion : proveedor.getListaDirecciones()) {
					direccion.setUsuarioModificacion(proveedor.getUsuarioModificacion());
					direccion.setIpModificacion(proveedor.getIpModificacion());
					idDireccion = direccionDao.actualizarDireccion(direccion,
							conexion);
					int idTelefono = 0;
					if (idDireccion == 0) {
						throw new ResultadoCeroDaoException(
								"No se pudo completar la actualización de la dirección");
					} else {
						direccionDao.eliminarTelefonoDireccion(direccion,
								conexion);
						List<Telefono> listTelefonos = direccion.getTelefonos();
						if (!listTelefonos.isEmpty()) {
							for (Telefono telefono : listTelefonos) {
								telefono.getEmpresaOperadora().setCodigoEntero(
										0);
								telefono.setUsuarioCreacion(proveedor.getUsuarioCreacion());
								telefono.setIpCreacion(proveedor.getIpCreacion());
								telefono.setUsuarioModificacion(proveedor.getUsuarioModificacion());
								telefono.setIpModificacion(proveedor.getIpModificacion());
								idTelefono = telefonoDao.registrarTelefono(
										telefono, conexion);
								if (idTelefono == 0) {
									throw new ResultadoCeroDaoException(
											"No se pudo completar el registro del teléfono de direccion");
								}
								telefono.setCodigoEntero(idTelefono);
								telefonoDao.registrarTelefonoDireccion(
										telefono, direccion, conexion);
							}
						}
					}

					direccion.setCodigoEntero(idDireccion);
					direccionDao.registrarPersonaDireccion(proveedor, direccion, conexion);
				}
			}

			contactoDao.eliminarContactoProveedor(proveedor, conexion);
			if (proveedor.getListaContactos() != null) {
				int idContacto = 0;
				for (Contacto contacto : proveedor.getListaContactos()) {
					contacto.setTipoPersona(3);
					contacto.setUsuarioModificacion(proveedor.getUsuarioModificacion());
					contacto.setIpModificacion(proveedor.getIpModificacion());
					contacto.setEmpresa(proveedor.getEmpresa());
					idContacto = personaDao
							.registrarPersona(contacto, conexion);
					contacto.setCodigoEntero(idContacto);

					if (!contacto.getListaTelefonos().isEmpty()) {
						for (Telefono telefono : contacto.getListaTelefonos()) {
							telefono.setUsuarioCreacion(proveedor.getUsuarioModificacion());
							telefono.setIpModificacion(proveedor.getIpModificacion());
							int idTelefono = telefonoDao.registrarTelefono(
									telefono, conexion);
							if (idTelefono == 0) {
								throw new ResultadoCeroDaoException(
										"No se pudo completar el registro del teléfono de contacto");
							}
							telefono.setCodigoEntero(idTelefono);
							telefonoDao.registrarTelefonoPersona(telefono,
									contacto, conexion);
						}
					}
					contactoDao.registrarContactoProveedor(idPersona, contacto,
							conexion);

					contactoDao.eliminarCorreosContacto(contacto, conexion);

					contactoDao.ingresarCorreoElectronico(contacto, conexion);
				}
			}
			if (!proveedorDao.eliminarTipoServicioProveedor(proveedor, conexion)){
				throw new ResultadoCeroDaoException(
						"No se pudo eliminar el registro de servicio");
			}
			if (proveedor.getListaServicioProveedor() != null) {
				for (ServicioProveedor servicio : proveedor
						.getListaServicioProveedor()) {
					servicio.setEmpresa(proveedor.getEmpresa());
					boolean resultado = proveedorDao
							.actualizarServicioProveedor(idPersona, servicio,
									conexion);
					if (!resultado) {
						throw new ResultadoCeroDaoException(
								"No se pudo completar la actualizacion del servicio");
					}
				}
			}
			proveedorDao.actualizarProveedor(proveedor, conexion);

			proveedorDao.actualizarProveedorTipo(proveedor, conexion);

			if (proveedor.getListaCuentas() != null
					&& !proveedor.getListaCuentas().isEmpty()) {
				if (StringUtils.isNotBlank(proveedor.getCuentasEliminadas())) {
					for (int i = 0; i < proveedor.getCuentasEliminadas().split(
							",").length; i++) {
						Integer idCuenta = UtilEjb
								.convertirCadenaEntero(proveedor
										.getCuentasEliminadas().split(",")[i]);
						proveedorDao.validarEliminarCuentaBancaria(idCuenta,
								idPersona, proveedor.getEmpresa().getCodigoEntero(), conexion);
					}
				}
				if (proveedorDao.eliminarCuentasBancarias(proveedor, conexion)) {
					for (CuentaBancaria cuentaBancaria : proveedor
							.getListaCuentas()) {
						if (!proveedorDao.ingresarCuentaBancaria(idPersona,
								cuentaBancaria, conexion)) {
							throw new ResultadoCeroDaoException(
									"No se pudo completar el registro de cuentas bancarias");
						}
					}
				} else {
					throw new ResultadoCeroDaoException(
							"No se pudo completar la actualizacion de cuentas bancarias");
				}
			}
			userTransaction.commit();
			return true;
		} catch (ResultadoCeroDaoException e) {
			userTransaction.rollback();
			throw new ResultadoCeroDaoException(e.getMensajeError(), e);
		} catch (SQLException e) {
			userTransaction.rollback();
			throw new SQLException(e);
		} finally {
			if (conexion != null) {
				conexion.close();
			}
		}
	}

	@Override
	public boolean registrarCliente(Cliente cliente)
			throws ResultadoCeroDaoException, SQLException, Exception {
		PersonaDao personaDao = new PersonaDaoImpl();
		DireccionDao direccionDao = new DireccionDaoImpl();
		TelefonoDao telefonoDao = new TelefonoDaoImpl(cliente.getEmpresa().getCodigoEntero());
		ContactoDao contactoDao = new ContactoDaoImpl();
		userTransaction.begin();
		Connection conexion = null;
		try {
			conexion = UtilConexion.obtenerConexion();

			cliente.setTipoPersona(1);
			int idPersona = personaDao.registrarPersona(cliente, conexion);
			if (idPersona == 0) {
				throw new ResultadoCeroDaoException(
						"No se pudo completar el registro de la persona");
			}
			cliente.setCodigoEntero(idPersona);
			if (cliente.getListaDirecciones() != null) {
				int idDireccion = 0;
				for (Direccion direccion : cliente.getListaDirecciones()) {
					idDireccion = direccionDao.registrarDireccion(direccion,
							conexion);
					if (idDireccion == 0) {
						throw new ResultadoCeroDaoException(
								"No se pudo completar el registro de la direccion");
					}
					direccion.setCodigoEntero(idDireccion);
					int idTelefono = 0;
					if (!direccion.getTelefonos().isEmpty()) {
						for (Telefono telefono : direccion.getTelefonos()) {
							telefono.getEmpresaOperadora().setCodigoEntero(0);
							idTelefono = telefonoDao.registrarTelefono(
									telefono, conexion);
							if (idTelefono == 0) {
								throw new ResultadoCeroDaoException(
										"No se pudo completar el registro del telefono");
							}
							telefono.setCodigoEntero(idTelefono);
							telefonoDao.registrarTelefonoDireccion(telefono,
									direccion, conexion);
						}
					}

					
					direccionDao.registrarPersonaDireccion(cliente, direccion, conexion);
				}
			}

			if (cliente.getListaContactos() != null) {
				int idContacto = 0;
				for (Contacto contacto : cliente.getListaContactos()) {
					contacto.setTipoPersona(3);
					idContacto = personaDao
							.registrarPersona(contacto, conexion);
					contacto.setCodigoEntero(idContacto);
					if (!contacto.getListaTelefonos().isEmpty()) {
						for (Telefono telefono : contacto.getListaTelefonos()) {
							int idTelefono = telefonoDao.registrarTelefono(
									telefono, conexion);
							if (idTelefono == 0) {
								throw new ResultadoCeroDaoException(
										"No se pudo completar el registro del telefono");
							}
							telefono.setCodigoEntero(idTelefono);
							telefonoDao.registrarTelefonoPersona(telefono,
									contacto, conexion);
						}
					}
					contactoDao.registrarContactoProveedor(idPersona, contacto,
							conexion);

					contactoDao.ingresarCorreoElectronico(contacto, conexion);
				}
			}
			ClienteDao clienteDao = new ClienteDaoImpl();
			clienteDao.registroCliente(cliente, conexion);
			
			for (DocumentoAdicional documento : cliente.getListaAdjuntos()){
				boolean resultado = clienteDao.ingresarArchivosAdjuntos(documento, cliente, conexion);
				if (!resultado){
					throw new ErrorRegistroDataException("Error registro documento adjunto");
				}
			}
			
			userTransaction.commit();
			return true;
		} catch (ErrorRegistroDataException e){
			userTransaction.rollback();
			throw new ResultadoCeroDaoException(e.getMensajeError(), e);
		} catch (ResultadoCeroDaoException e) {
			userTransaction.rollback();
			throw new ResultadoCeroDaoException(e.getMensajeError(), e);
		} catch (SQLException e) {
			userTransaction.rollback();
			throw new SQLException(e);
		} finally {
			if (conexion != null) {
				conexion.close();
			}
		}
	}

	@Override
	public boolean actualizarCliente(Cliente cliente) throws SQLException,
			ResultadoCeroDaoException, Exception {
		PersonaDao personaDao = new PersonaDaoImpl();
		DireccionDao direccionDao = new DireccionDaoImpl();
		TelefonoDao telefonoDao = new TelefonoDaoImpl(cliente.getEmpresa().getCodigoEntero());
		ContactoDao contactoDao = new ContactoDaoImpl();

		Connection conexion = null;
		userTransaction.begin();
		try {
			conexion = UtilConexion.obtenerConexion();
			cliente.setTipoPersona(1);
			Integer idPersona = personaDao.actualizarPersona(cliente, conexion);
			if (idPersona == 0) {
				throw new ResultadoCeroDaoException(
						"No se pudo completar la actualización de la persona");
			}
			direccionDao.eliminarDireccionPersona(cliente, conexion);
			if (cliente.getListaDirecciones() != null) {
				int idDireccion = 0;
				if (!direccionDao.eliminarPersonaDirecciones(cliente, conexion)) {
					throw new ResultadoCeroDaoException(
							"No se pudo completar la actualización de direcciones de la persona");
				}
				for (Direccion direccion : cliente.getListaDirecciones()) {
					direccion.setUsuarioModificacion(cliente.getUsuarioModificacion());
					direccion.setIpModificacion(cliente.getIpModificacion());
					idDireccion = direccionDao.actualizarDireccion(direccion,
							conexion);
					int idTelefono = 0;
					if (idDireccion == 0) {
						throw new ResultadoCeroDaoException(
								"No se pudo completar la actualización de la dirección");
					} else {
						direccionDao.eliminarTelefonoDireccion(direccion,
								conexion);
						List<Telefono> listTelefonos = direccion.getTelefonos();
						if (!listTelefonos.isEmpty()) {
							for (Telefono telefono : listTelefonos) {
								telefono.getEmpresaOperadora().setCodigoEntero(
										0);
								telefono.setUsuarioCreacion(cliente.getUsuarioCreacion());
								telefono.setIpCreacion(cliente.getIpCreacion());
								telefono.setUsuarioModificacion(cliente.getUsuarioModificacion());
								telefono.setIpModificacion(cliente.getIpModificacion());
								idTelefono = telefonoDao.registrarTelefono(
										telefono, conexion);
								if (idTelefono == 0) {
									throw new ResultadoCeroDaoException(
											"No se pudo completar el registro del teléfono de direccion");
								}
								telefono.setCodigoEntero(idTelefono);
								direccion.setCodigoEntero(idDireccion);
								telefonoDao.registrarTelefonoDireccion(
										telefono, direccion, conexion);
							}
						}
					}
					
					direccion.setCodigoEntero(idDireccion);
					direccionDao.registrarPersonaDireccion(cliente, direccion, conexion);
				}
			}

			contactoDao.eliminarContactoProveedor(cliente, conexion);
			if (cliente.getListaContactos() != null) {
				int idContacto = 0;
				for (Contacto contacto : cliente.getListaContactos()) {
					contacto.setTipoPersona(3);
					contacto.setEmpresa(cliente.getEmpresa());
					idContacto = personaDao
							.registrarPersona(contacto, conexion);
					contacto.setCodigoEntero(idContacto);

					if (!contacto.getListaTelefonos().isEmpty()) {
						for (Telefono telefono : contacto.getListaTelefonos()) {
							telefono.setUsuarioCreacion(cliente.getUsuarioCreacion());
							telefono.setIpCreacion(cliente.getIpCreacion());
							telefono.setUsuarioModificacion(cliente.getUsuarioModificacion());
							telefono.setIpModificacion(cliente.getIpModificacion());
							int idTelefono = telefonoDao.registrarTelefono(
									telefono, conexion);
							if (idTelefono == 0) {
								throw new ResultadoCeroDaoException(
										"No se pudo completar el registro del teléfono de contacto");
							}
							telefono.setCodigoEntero(idTelefono);
							telefonoDao.registrarTelefonoPersona(telefono,
									contacto, conexion);
						}
					}
					contacto.setUsuarioCreacion(cliente.getUsuarioCreacion());
					contacto.setIpCreacion(cliente.getIpCreacion());
					contacto.setUsuarioModificacion(cliente.getUsuarioModificacion());
					contacto.setIpModificacion(cliente.getIpModificacion());
					contactoDao.registrarContactoProveedor(idPersona, contacto,
							conexion);
					contactoDao.eliminarCorreosContacto(contacto, conexion);

					contactoDao.ingresarCorreoElectronico(contacto, conexion);
				}
			}
			ClienteDao clienteDao = new ClienteDaoImpl();
			clienteDao.actualizarPersonaAdicional(cliente, conexion);
			clienteDao.eliminarArchivoAdjunto1(cliente, conexion);
			for (DocumentoAdicional documento : cliente.getListaAdjuntos()){
				boolean resultado = false;
				if (documento.getCodigoEntero() == null || documento.getCodigoEntero().intValue() == 0){
					resultado = clienteDao.ingresarArchivosAdjuntos(documento, cliente, conexion);
				}
				else{
					resultado = clienteDao.actualizarArchivoAdjunto(documento, cliente, conexion);
				}
				if (!resultado){
					throw new ErrorRegistroDataException("Error actualizar documento adjunto");
				}
			}	
			//clienteDao.eliminarArchivoAdjunto2(cliente, conexion);
			
			userTransaction.commit();
			return true;
		} catch (ResultadoCeroDaoException e) {
			userTransaction.rollback();
			throw new ResultadoCeroDaoException(e.getMensajeError(), e);
		} catch (SQLException e) {
			userTransaction.rollback();
			throw new SQLException(e);
		} finally {
			if (conexion != null) {
				conexion.close();
			}
		}
	}

	@Override
	public Integer registrarNovios(ProgramaNovios programaNovios)
			throws ErrorRegistroDataException, SQLException, Exception {
		ServicioNoviosDao servicioNoviosDao = new ServicioNoviosDaoImpl(programaNovios.getEmpresa().getCodigoEntero());
		Connection conexion = null;
		try {
			userTransaction.begin();
			conexion = UtilConexion.obtenerConexion();
			Integer idnovios = servicioNoviosDao.registrarNovios(
					programaNovios, conexion);

			if (programaNovios.getListaInvitados() != null
					&& !programaNovios.getListaInvitados().isEmpty()) {
				for (Cliente invitado : programaNovios.getListaInvitados()) {
					boolean exitoRegistro = servicioNoviosDao
							.registrarInvitado(invitado, idnovios, conexion);
					if (!exitoRegistro) {
						throw new ErrorRegistroDataException(
								"No se pudo registrar los invitados de los novios");
					}
				}
			}
			userTransaction.commit();
			return idnovios;
		} catch (ErrorRegistroDataException e) {
			userTransaction.rollback();
			throw new ErrorRegistroDataException(e.getMensajeError(), e);
		} catch (SQLException e) {
			userTransaction.rollback();
			throw new SQLException(e);
		} finally {
			if (conexion != null) {
				conexion.close();
			}
		}
	}

	@Override
	public Integer registrarVentaServicio(ServicioAgencia servicioAgencia)
			throws ErrorRegistroDataException, SQLException, Exception {
		ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(servicioAgencia.getEmpresa().getCodigoEntero());
		ServicioNegocioDao servicioNegocioDao = new ServicioNegocioDaoImpl();
		
		userTransaction.begin();
		Connection conexion = null;
		Integer idServicio = 0;
		try {
			conexion = UtilConexion.obtenerConexion();

			if (servicioAgencia.getFechaServicio() == null) {
				Date fechaSer = servicioAgencia.getListaDetalleServicio()
						.get(0).getFechaIda();
				servicioAgencia.setFechaServicio(fechaSer);
			}

			if (!servicioAgencia.getListaDetalleServicio().isEmpty()) {
				servicioAgencia.setCantidadServicios(servicioAgencia
						.getListaDetalleServicio().size());
			}

			servicioAgencia.getEstadoServicio().setCodigoEntero(
					ServicioAgencia.ESTADO_CERRADO);
			idServicio = servicioNovaViajesDao.ingresarCabeceraServicio(
					servicioAgencia, conexion);

			servicioAgencia.setCodigoEntero(idServicio);

			if (idServicio == 0) {
				throw new ErrorRegistroDataException(
						"No se pudo registrar los servicios de los novios");
			}
			if (servicioAgencia.getListaDetalleServicio() != null
					&& !servicioAgencia.getListaDetalleServicio().isEmpty()) {

				for (DetalleServicioAgencia detalleServicio : servicioAgencia
						.getListaDetalleServicio()) {
					if (detalleServicio.getTipoServicio().isServicioPadre()) {
						Integer idRuta = null;
						for (Tramo tramo : detalleServicio.getRuta()
								.getTramos()) {
							tramo = servicioNovaViajesDao.registrarTramo(tramo,
									conexion);
							if (tramo.getCodigoEntero() == null
									|| tramo.getCodigoEntero().intValue() == 0) {
								throw new ErrorRegistroDataException(
										"No se pudo registrar los servicios de la venta");
							}
							detalleServicio.getRuta().setTramo(tramo);
							if (idRuta == null) {
								idRuta = servicioNovaViajesDao
										.obtenerSiguienteRuta(conexion);
							}
							detalleServicio.getRuta().setCodigoEntero(idRuta);
							if (!servicioNovaViajesDao.registrarRuta(
									detalleServicio.getRuta(), conexion)) {
								throw new ErrorRegistroDataException(
										"No se pudo registrar los servicios de la venta");
							}
						}
						
						// INGRESO DE DETALLE DE SERVICIO PADRE
						Integer idSerDetaPadre = servicioNovaViajesDao
								.ingresarDetalleServicio(detalleServicio,
										idServicio, conexion);
						// INGRESO DE DETALLE DE SERVICIO HIJOS DEL PADRE
						if (idSerDetaPadre == null
								|| idSerDetaPadre.intValue() == 0) {
							throw new ErrorRegistroDataException(
									"No se pudo registrar los servicios de la venta");
						} else {
							for (DetalleServicioAgencia detalleServicio2 : servicioAgencia
									.getListaDetalleServicio()) {
								if (!detalleServicio2.getTipoServicio()
										.isServicioPadre()) {
									if (detalleServicio2.getServicioPadre()
											.getCodigoEntero().intValue() == detalleServicio
											.getCodigoEntero().intValue()) {
										detalleServicio2
												.getServicioPadre()
												.setCodigoEntero(idSerDetaPadre);
										Integer resultado = servicioNovaViajesDao
												.ingresarDetalleServicio(
														detalleServicio2,
														idServicio, conexion);
										if (resultado == null
												|| resultado.intValue() == 0) {
											throw new ErrorRegistroDataException(
													"No se pudo registrar los servicios de la venta");
										}
									}
								}
							}
						}
						
						// INGRESO DE LOS PASAJEROS DEL SERVICIO
						for (Pasajero pasajero : detalleServicio.getListaPasajeros()){
							pasajero.setIdServicio(idServicio);
							pasajero.setIdServicioDetalle(idSerDetaPadre);
							servicioNegocioDao.ingresarPasajero(pasajero, conexion);
						}
					}
				}
			} else {
				throw new ErrorRegistroDataException(
						"No se agregaron servicios a la venta");
			}

			servicioNovaViajesDao.registrarSaldosServicio(servicioAgencia,
					conexion);
			userTransaction.commit();
			return idServicio;
		} catch (SQLException e) {
			userTransaction.rollback();
			throw new ErrorRegistroDataException(e.getMessage(), e);
		} catch (ErrorRegistroDataException e) {
			userTransaction.rollback();
			throw new ErrorRegistroDataException(e.getMensajeError(), e);
		} finally {
			if (conexion != null) {
				conexion.close();
			}
		}
	}

	@Override
	public Integer actualizarVentaServicio(ServicioAgencia servicioAgencia)
			throws ErrorRegistroDataException, SQLException, Exception {
		ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(servicioAgencia.getEmpresa().getCodigoEntero());

		Connection conexion = null;
		Integer idServicio = 0;
		userTransaction.begin();
		try {
			conexion = UtilConexion.obtenerConexion();

			if (servicioAgencia.getFechaServicio() == null) {
				Date fechaSer = servicioAgencia.getListaDetalleServicio()
						.get(0).getFechaIda();
				servicioAgencia.setFechaServicio(fechaSer);
			}

			if (servicioAgencia.getValorCuota() == null
					&& servicioAgencia.getFormaPago().getCodigoEntero()
							.intValue() == 2) {
				ServicioNegocioDao servicioNegocioDao = new ServicioNegocioDaoImpl();
				servicioAgencia.setValorCuota(servicioNegocioDao
						.calcularCuota(servicioAgencia));
			}

			if (!servicioAgencia.getListaDetalleServicio().isEmpty()) {
				servicioAgencia.setCantidadServicios(servicioAgencia
						.getListaDetalleServicio().size());
			}

			servicioAgencia.getEstadoServicio().setCodigoEntero(2);
			idServicio = servicioNovaViajesDao.actualizarCabeceraServicio(
					servicioAgencia, conexion);

			servicioAgencia.setCodigoEntero(idServicio);

			if (idServicio == 0) {
				throw new ErrorRegistroDataException(
						"No se pudo registrar los servicios de los novios");
			}
			if (servicioAgencia.getListaDetalleServicio() != null
					&& !servicioAgencia.getListaDetalleServicio().isEmpty()) {

				servicioNovaViajesDao.eliminarDetalleServicio(servicioAgencia,
						conexion);

				for (DetalleServicioAgencia detalleServicio : servicioAgencia
						.getListaDetalleServicio()) {
					Integer resultado = servicioNovaViajesDao
							.ingresarDetalleServicio(detalleServicio,
									idServicio, conexion);
					if (resultado == null || resultado.intValue() == 0) {
						throw new ErrorRegistroDataException(
								"No se pudo registrar los servicios de la venta");
					} else {
						for (DetalleServicioAgencia detalleServicio2 : detalleServicio
								.getServiciosHijos()) {
							detalleServicio2.getServicioPadre()
									.setCodigoEntero(resultado);
							resultado = servicioNovaViajesDao
									.ingresarDetalleServicio(detalleServicio2,
											idServicio, conexion);
							if (resultado == null || resultado.intValue() == 0) {
								throw new ErrorRegistroDataException(
										"No se pudo registrar los servicios de la venta");
							}
						}
					}
				}
			}

			if (servicioAgencia.getFormaPago().getCodigoEntero().intValue() == 2) {
				servicioNovaViajesDao.eliminarCronogramaServicio(
						servicioAgencia, conexion);
				boolean resultado = servicioNovaViajesDao
						.generarCronogramaPago(servicioAgencia, conexion);
				if (!resultado) {
					throw new ErrorRegistroDataException(
							"No se pudo generar el cronograma de pagos");
				}
			}
			userTransaction.commit();
			return idServicio;
		} catch (ErrorRegistroDataException e) {
			userTransaction.rollback();
			throw new ErrorRegistroDataException(e.getMensajeError(), e);
		} finally {
			if (conexion != null) {
				conexion.close();
			}
		}
	}

	public int enviarCorreoMasivo(CorreoMasivo correoMasivo)
			throws EnvioCorreoException, Exception {
		int respuesta = 0;
		try {
			UtilCorreo utilCorreo = new UtilCorreo();
			for (CorreoClienteMasivo envio : correoMasivo
					.getListaCorreoMasivo()) {
				try {
					if (envio.isEnviarCorreo()
							&& UtilEjb.correoValido(envio
									.getCorreoElectronico().getDireccion())) {
						if (!correoMasivo.isArchivoCargado()) {
							utilCorreo.enviarCorreo(envio
									.getCorreoElectronico().getDireccion(),
									correoMasivo.getAsunto(), correoMasivo
											.getContenidoCorreo());
						} else {
							utilCorreo.enviarCorreo(envio
									.getCorreoElectronico().getDireccion(),
									correoMasivo.getAsunto(), correoMasivo
											.getContenidoCorreo(), correoMasivo
											.getArchivoAdjunto());
						}
					}
				} catch (AddressException e) {
					respuesta = 1;
					logger.error("ERROR EN ENVIO DE CORREO ::"
							+ envio.getCorreoElectronico().getDireccion(), e);
				} catch (FileNotFoundException e) {
					respuesta = 2;
					logger.error("ERROR EN ENVIO DE CORREO ::"
							+ envio.getCorreoElectronico().getDireccion(), e);
				} catch (NoSuchProviderException e) {
					respuesta = 3;
					logger.error("ERROR EN ENVIO DE CORREO ::"
							+ envio.getCorreoElectronico().getDireccion(), e);
				} catch (IOException e) {
					respuesta = 4;
					logger.error("ERROR EN ENVIO DE CORREO ::"
							+ envio.getCorreoElectronico().getDireccion(), e);
				} catch (MessagingException e) {
					respuesta = 5;
					logger.error("ERROR EN ENVIO DE CORREO ::"
							+ envio.getCorreoElectronico().getDireccion(), e);
				}
			}
			logger.debug("respuesta de envio de correo ::" + respuesta);

			return respuesta;
		} catch (Exception e) {
			e.printStackTrace();
			throw new EnvioCorreoException("0001",
					"Error en envio de correo masivo", e.getMessage(), e);
		}

	}

	@Override
	public boolean ingresarMaestroServicio(MaestroServicio servicio)
			throws ErrorRegistroDataException, SQLException, Exception {
		Connection conn = null;
		try {
			userTransaction.begin();
			conn = UtilConexion.obtenerConexion();
			MaestroServicioDao maestroServicioDao = new MaestroServicioDaoImpl();

			Integer idMaestroServicio = maestroServicioDao
					.ingresarMaestroServicio(servicio, conn);

			if (idMaestroServicio == null || idMaestroServicio.intValue() == 0) {
				throw new ErrorRegistroDataException(
						"No se pudo completar el registro de servicio");
			}
						
			userTransaction.commit();
			return true;
		} catch (Exception e) {
			userTransaction.rollback();
			throw new ErrorRegistroDataException(e);
		} finally{
			if (conn != null){
				conn.close();
			}
		}
	}

	@Override
	public boolean actualizarMaestroServicio(MaestroServicio servicio)
			throws SQLException, Exception {
		MaestroServicioDao maestroServicioDao = new MaestroServicioDaoImpl();
		Connection conn = null;
		try {
			userTransaction.begin();
			conn = UtilConexion.obtenerConexion();
			
			if (!maestroServicioDao.actualizarMaestroServicio(servicio)) {
				throw new ErrorRegistroDataException(
						"No se pudo completar la actualizacion de servicio");
			}

			if (servicio.getListaServicioDepende() != null
					&& !servicio.getListaServicioDepende().isEmpty()) {
				maestroServicioDao.ingresarServicioMaestroServicio(servicio, conn);
			}
			userTransaction.commit();
			return true;
		} catch (Exception e) {
			userTransaction.rollback();
			throw new ErrorRegistroDataException(e);
		} finally{
			if (conn != null){
				conn.close();
			}
		}
	}

	@Override
	public Integer actualizarNovios(ProgramaNovios programaNovios)
			throws SQLException, Exception {
		ServicioNoviosDao servicioNoviosDao = new ServicioNoviosDaoImpl(programaNovios.getEmpresa().getCodigoEntero());
		ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(programaNovios.getEmpresa().getCodigoEntero());
		DestinoDao destinoDao = new DestinoDaoImpl();
		userTransaction.begin();
		Connection conexion = null;
		try {
			conexion = UtilConexion.obtenerConexion();

			int idServicio = 0;

			ServicioAgencia servicioAgencia = new ServicioAgencia();
			servicioAgencia.setCodigoEntero(programaNovios.getIdServicio());
			servicioAgencia.setCliente(programaNovios.getNovia());
			servicioAgencia.setCliente2(programaNovios.getNovio());
			servicioAgencia.setFechaServicio(new Date());
			servicioAgencia.setCantidadServicios(0);
			if (programaNovios.getListaServicios() != null
					&& !programaNovios.getListaServicios().isEmpty()) {
				servicioAgencia.setCantidadServicios(programaNovios
						.getListaServicios().size());
			}

			servicioAgencia.setDestino(destinoDao.consultarDestino(
					programaNovios.getDestino().getCodigoEntero(), programaNovios.getEmpresa().getCodigoEntero(), conexion));
			servicioAgencia.getFormaPago().setCodigoEntero(1);
			servicioAgencia.getEstadoPago().setCodigoEntero(1);
			servicioAgencia.setVendedor(programaNovios.getVendedor());
			servicioAgencia.setMontoTotalComision(programaNovios
					.getMontoTotalComision());
			servicioAgencia.setMontoTotalServicios(programaNovios
					.getMontoTotalServiciosPrograma());
			servicioAgencia.setMontoTotalFee(programaNovios.getMontoTotalFee());
			servicioAgencia.setUsuarioCreacion(programaNovios
					.getUsuarioCreacion());
			servicioAgencia.setIpCreacion(programaNovios.getIpCreacion());
			servicioAgencia.setUsuarioModificacion(programaNovios
					.getUsuarioModificacion());
			servicioAgencia.setIpModificacion(programaNovios
					.getIpModificacion());
			servicioAgencia.getEstadoServicio().setCodigoEntero(1);
			servicioAgencia.setListaDetalleServicio(programaNovios
					.getListaServicios());

			idServicio = servicioNovaViajesDao.actualizarCabeceraServicio(
					servicioAgencia, conexion);
			if (idServicio == 0) {
				throw new ErrorRegistroDataException(
						"No se pudo actualizar los servicios de los novios");
			}
			if (programaNovios.getListaServicios() != null
					&& !programaNovios.getListaServicios().isEmpty()) {
				servicioNovaViajesDao.eliminarDetalleServicio(servicioAgencia,
						conexion);
				for (DetalleServicioAgencia servicioNovios : programaNovios
						.getListaServicios()) {
					Integer exitoRegistro = servicioNovaViajesDao
							.ingresarDetalleServicio(servicioNovios,
									idServicio, conexion);
					;
					if (exitoRegistro == null || exitoRegistro.intValue() == 0) {
						throw new ErrorRegistroDataException(
								"No se pudo actualizar los servicios de los novios");
					}
				}
			} else {
				throw new ErrorRegistroDataException(
						"No se enviaron los servicios de los novios");
			}
			programaNovios.setIdServicio(idServicio);

			Integer idnovios = servicioNoviosDao.actualizarNovios(
					programaNovios, conexion);

			if (!servicioNoviosDao.eliminarInvitadosNovios(programaNovios,
					conexion)) {
				throw new ErrorRegistroDataException(
						"No se pudo eliminar los invitados de los novios");
			}

			if (programaNovios.getListaInvitados() != null
					&& !programaNovios.getListaInvitados().isEmpty()) {
				for (Cliente invitado : programaNovios.getListaInvitados()) {
					boolean exitoRegistro = servicioNoviosDao
							.registrarInvitado(invitado, idnovios, conexion);
					if (!exitoRegistro) {
						throw new ErrorRegistroDataException(
								"No se pudo registrar los invitados de los novios");
					}
				}
			}
			userTransaction.commit();
			return idnovios;
		} catch (ErrorRegistroDataException e) {
			userTransaction.rollback();
			throw new ErrorRegistroDataException(e.getMensajeError(), e);
		} catch (SQLException e) {
			userTransaction.rollback();
			throw new SQLException(e);
		} finally {
			if (conexion != null) {
				conexion.close();
			}
		}
	}

	@Override
	public boolean ingresarConsolidador(Consolidador consolidador)
			throws SQLException, Exception {
		ConsolidadorDao consolidadorDao = new ConsolidadorDaoImpl();

		return consolidadorDao.ingresarConsolidador(consolidador);
	}

	@Override
	public boolean actualizarConsolidador(Consolidador consolidador)
			throws SQLException, Exception {
		ConsolidadorDao consolidadorDao = new ConsolidadorDaoImpl();

		return consolidadorDao.actualizarConsolidador(consolidador);
	}

	@Override
	public void registrarPago(PagoServicio pago) throws ErrorRegistroDataException, Exception {
		try {
			userTransaction.begin();
			ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(pago.getEmpresa().getCodigoEntero());

			servicioNovaViajesDao.registrarPagoServicio(pago);
			
			userTransaction.commit();
		} catch (SQLException e){
			userTransaction.rollback();
			throw new ErrorRegistroDataException("No se pudo registrar el pago", e);
		} catch (Exception e) {
			userTransaction.rollback();
			throw new ErrorRegistroDataException("No se pudo registrar el pago", e);
		}
	}

	@Override
	public void cerrarVenta(ServicioAgencia servicioAgencia)
			throws SQLException, Exception {
		ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(servicioAgencia.getEmpresa().getCodigoEntero());

		servicioAgencia.getEstadoServicio().setCodigoEntero(
				ServicioAgencia.ESTADO_CERRADO);

		servicioNovaViajesDao.actualizarServicioVenta(servicioAgencia);
	}

	@Override
	public void anularVenta(ServicioAgencia servicioAgencia)
			throws SQLException, Exception {
		try {
			userTransaction.begin();
			ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(servicioAgencia.getEmpresa().getCodigoEntero());

			servicioAgencia.getEstadoServicio().setCodigoEntero(
					ServicioAgencia.ESTADO_ANULADO);

			servicioNovaViajesDao.actualizarServicioVenta(servicioAgencia);
			
			userTransaction.commit();
		} catch (Exception e) {
			userTransaction.rollback();
			e.printStackTrace();
		}
	}

	@Override
	public void registrarEventoObservacion(EventoObsAnu evento)
			throws SQLException, Exception {
		try {
			userTransaction.begin();
			ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(evento.getEmpresa().getCodigoEntero());

			evento.getTipoEvento().setCodigoEntero(EventoObsAnu.EVENTO_OBS);

			servicioNovaViajesDao.registrarEventoObsAnu(evento);
			userTransaction.commit();
		} catch (Exception e) {
			userTransaction.rollback();
			e.printStackTrace();
		}
	}

	@Override
	public void registrarEventoAnulacion(EventoObsAnu evento)
			throws ErrorRegistroDataException {
		try {
			try {
				userTransaction.begin();
				ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(evento.getEmpresa().getCodigoEntero());

				evento.getTipoEvento().setCodigoEntero(EventoObsAnu.EVENTO_ANU);

				servicioNovaViajesDao.registrarEventoObsAnu(evento);
				userTransaction.commit();
			} catch (Exception e) {
				userTransaction.rollback();
				throw new ErrorRegistroDataException(e);
			}
		} catch (IllegalStateException e) {
			throw new ErrorRegistroDataException(e);
		} catch (SecurityException e) {
			throw new ErrorRegistroDataException(e);
		} catch (SystemException e) {
			throw new ErrorRegistroDataException(e);
		}
	}

	@Override
	public boolean registrarComprobantes(ServicioAgencia servicioAgencia)
			throws ValidacionException, SQLException, Exception {
		try {
			List<Comprobante> listaComprobantes = UtilEjb
					.obtenerNumeroComprobante(servicioAgencia
							.getListaDetalleServicioAgrupado());
			for (Comprobante comprobante : listaComprobantes) {
				for (DetalleServicioAgencia detallePadre : servicioAgencia
						.getListaDetalleServicioAgrupado()) {
					for (DetalleServicioAgencia detalle : detallePadre
							.getServiciosHijos()) {
						if (comprobante.getTipoComprobante().getCodigoEntero()
								.intValue() != detalle.getTipoComprobante()
								.getCodigoEntero().intValue()
								&& comprobante.getNumeroComprobante().equals(
										detalle.getNroComprobante())) {
							throw new ValidacionException(
									"Tipo y numero de comprobante diferente");
						}
					}
				}
			}

			List<Comprobante> listaComprobantes2 = new ArrayList<Comprobante>();
			for (Comprobante comprobante : listaComprobantes) {
				comprobante = UtilEjb.obtenerDetalleComprobante(comprobante,
						servicioAgencia);
				listaComprobantes2.add(comprobante);
			}
			ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(servicioAgencia.getEmpresa().getCodigoEntero());
			Connection conn = null;

			try {
				userTransaction.begin();
				conn = UtilConexion.obtenerConexion();
				for (Comprobante comprobante : listaComprobantes2) {
					if (comprobante.getTipoComprobante().getCodigoEntero().intValue() == UtilEjb.obtenerEnteroPropertieMaestro("comprobanteFactura", "aplicacionDatosEjb")){
						comprobante.setTotalIGV(this.utilNegocioSessionLocal.obtenerMontoIGV(comprobante.getTotalComprobante(), servicioAgencia.getEmpresa().getCodigoEntero()));
					}
					Integer idComprobante = servicioNovaViajesDao
							.registrarComprobante(comprobante, conn);
					servicioNovaViajesDao.registrarDetalleComprobante(
							comprobante.getDetalleComprobante(), idComprobante,
							conn);
				}

				servicioNovaViajesDao.actualizarComprobantesServicio(true,
						servicioAgencia, conn);
				
				userTransaction.commit();
			} catch (SQLException e) {
				userTransaction.rollback();
				throw new ValidacionException(e);
			} catch (Exception e) {
				userTransaction.rollback();
				throw new ValidacionException("Excepcion no controlada", e);
			} finally {
				if (conn != null) {
					conn.close();
				}
			}

			return true;
		} catch (ValidacionException e) {
			throw new ValidacionException(e.getMessage(), e);
		} catch (Exception e) {
			throw new ValidacionException("Excepcion no controlada", e);
		}
	}

	@Override
	public boolean registrarObligacionXPagar(Comprobante comprobante)
			throws SQLException, Exception {
		ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(comprobante.getEmpresa().getCodigoEntero());
		return servicioNovaViajesDao.registrarObligacionXPagar(comprobante);
	}

	@Override
	public void registrarPagoObligacion(PagoServicio pago) throws SQLException,
			Exception {
		ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(pago.getEmpresa().getCodigoEntero());

		servicioNovaViajesDao.registrarPagoObligacion(pago);
	}

	@Override
	public void registrarRelacionComproObligacion(
			ServicioAgencia servicioAgencia) throws SQLException, Exception {
		Connection conn = null;
		ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(servicioAgencia.getEmpresa().getCodigoEntero());

		try {
			userTransaction.begin();
			conn = UtilConexion.obtenerConexion();
			for (DetalleServicioAgencia detalleServicioAgencia : servicioAgencia
					.getListaDetalleServicioAgrupado()) {
				for (DetalleServicioAgencia detalleHijo : detalleServicioAgencia
						.getServiciosHijos()) {
					if (detalleHijo.getIdComprobanteGenerado() != null
							&& detalleHijo.getComprobanteAsociado()
									.getCodigoEntero() != null
							&& detalleHijo.getCodigoEntero() != null
							&& detalleHijo.getServicioPadre().getCodigoEntero() != null) {

						if (detalleHijo.isAgrupado()) {
							for (Integer id : detalleHijo
									.getCodigoEnteroAgrupados()) {
								detalleHijo.setCodigoEntero(id);
								servicioNovaViajesDao
										.guardarRelacionComproObligacion(
												detalleHijo, conn);
							}
						} else {
							servicioNovaViajesDao
									.guardarRelacionComproObligacion(
											detalleHijo, conn);
						}

					}
				}
			}
			servicioNovaViajesDao.actualizarRelacionComprobantes(true,
					servicioAgencia, conn);
			
			userTransaction.commit();
		} catch (SQLException e) {
			userTransaction.rollback();
			throw new SQLException(e);
		} catch (Exception e) {
			userTransaction.rollback();
			throw new Exception(e);
		} finally {
			if (conn != null) {
				conn.close();
			}
		}
	}

	@Override
	public boolean grabarDocumentosAdicionales(
			List<DocumentoAdicional> listaDocumentos, Integer idEmpresa)
			throws ErrorRegistroDataException, SQLException, Exception {

		Connection conn = null;
		ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(idEmpresa);
		try {
			userTransaction.begin();
			conn = UtilConexion.obtenerConexion();

			if (listaDocumentos != null && !listaDocumentos.isEmpty()) {
				DocumentoAdicional documento = listaDocumentos.get(0);
				if (documento.getIdServicio() != null
						&& !servicioNovaViajesDao.eliminarDocumentoAdicional(
								documento, conn)) {
					throw new ErrorRegistroDataException(
							"No se pudo eliminar los documentos adicionales");
				}

				for (DocumentoAdicional documentoAdicional : listaDocumentos) {
					if (documentoAdicional.getCodigoEntero() == null
							|| documentoAdicional.getCodigoEntero().intValue() == 0) {
						boolean resultado = servicioNovaViajesDao
								.grabarDocumentoAdicional(documentoAdicional,
										conn);
						if (!resultado) {
							throw new ErrorRegistroDataException(
									"No se pudo completar el registro de documentos adicionales");
						}
					}
				}
				userTransaction.commit();
				return true;
			}
			
		} catch (ErrorRegistroDataException e) {
			userTransaction.rollback();
			throw new ErrorRegistroDataException(e);
		} catch (SQLException e) {
			userTransaction.rollback();
			throw new SQLException(e);
		} catch (Exception e) {
			userTransaction.rollback();
			throw new Exception(e);
		} finally {
			if (conn != null) {
				conn.close();
			}
		}
		return false;
	}

	@Override
	public void registrarComprobantesAdicionales(
			List<Comprobante> listaComprobantesAdicionales)
			throws ErrorRegistroDataException, SQLException, Exception {

		Connection conn = null;

		try {
			userTransaction.begin();
			conn = UtilConexion.obtenerConexion();

			ComprobanteNovaViajesDao comprobanteNovaViajesDao = new ComprobanteNovaViajesDaoImpl();

			for (Comprobante comprobante : listaComprobantesAdicionales) {
				comprobanteNovaViajesDao.registrarComprobanteAdicional(
						comprobante, conn);
			}
			userTransaction.commit();
		} catch (SQLException e) {
			userTransaction.rollback();
			throw new ErrorRegistroDataException(e);
		} catch (Exception e) {
			userTransaction.rollback();
			throw new ErrorRegistroDataException(e);
		} finally {
			if (conn != null) {
				conn.close();
			}
		}
	}

	@Override
	public boolean grabarComprobantesReporte(ReporteArchivo reporteArchivo,
			ColumnasExcel columnasExcel, List<ColumnasExcel> dataExcel)
			throws ErrorRegistroDataException, SQLException, Exception {
		ArchivoReporteDao archivoReporteDao = new ArchivoReporteDaoImpl();
		Connection conn = null;

		try {
			BigDecimal monto = BigDecimal.ZERO;
			if (dataExcel != null){
				for (ColumnasExcel columnaExcel : dataExcel){
					if (columnaExcel.isSeleccionar()){
						monto = monto.add(UtilEjb.convertirCadenaDecimal(columnaExcel.getColumna9().getValorCadena()));
					}
				}
			}
			
			{
				ParametroDao parametroDao = new ParametroDaoImpl();
				Parametro param = parametroDao
						.consultarParametro(UtilEjb
								.obtenerEnteroPropertieMaestro(
										"codigoParametroImptoIGV",
										"aplicacionDatosEjb"), reporteArchivo.getEmpresa().getCodigoEntero());
				
				reporteArchivo.setMontoTotal(monto);
				BigDecimal igv = UtilEjb.convertirCadenaDecimal(param.getValor());
				BigDecimal subtotal = reporteArchivo.getMontoTotal().divide(igv.add(BigDecimal.ONE), RoundingMode.HALF_UP);
				reporteArchivo.setMontoSubtotal(subtotal);
				reporteArchivo.setMontoIGV( reporteArchivo.getMontoTotal().subtract(reporteArchivo.getMontoSubtotal()) );
			}
			
			userTransaction.begin();
			conn = UtilConexion.obtenerConexion();
			
			int idArchivo = archivoReporteDao.registrarArchivoReporteCabecera(
					reporteArchivo, conn);
			columnasExcel.setIdArchivo(idArchivo);
			columnasExcel.setUsuarioCreacion(reporteArchivo
					.getUsuarioCreacion());
			columnasExcel.setIpCreacion(reporteArchivo.getIpCreacion());
			columnasExcel.getColumna1().setValorCadena(
					columnasExcel.getColumna1().getNombreColumna());
			columnasExcel.getColumna2().setValorCadena(
					columnasExcel.getColumna2().getNombreColumna());
			columnasExcel.getColumna3().setValorCadena(
					columnasExcel.getColumna3().getNombreColumna());
			columnasExcel.getColumna4().setValorCadena(
					columnasExcel.getColumna4().getNombreColumna());
			columnasExcel.getColumna5().setValorCadena(
					columnasExcel.getColumna5().getNombreColumna());
			columnasExcel.getColumna6().setValorCadena(
					columnasExcel.getColumna6().getNombreColumna());
			columnasExcel.getColumna7().setValorCadena(
					columnasExcel.getColumna7().getNombreColumna());
			columnasExcel.getColumna8().setValorCadena(
					columnasExcel.getColumna8().getNombreColumna());
			columnasExcel.getColumna9().setValorCadena(
					columnasExcel.getColumna9().getNombreColumna());
			columnasExcel.getColumna10().setValorCadena(
					columnasExcel.getColumna10().getNombreColumna());
			columnasExcel.getColumna11().setValorCadena(
					columnasExcel.getColumna11().getNombreColumna());
			columnasExcel.getColumna12().setValorCadena(
					columnasExcel.getColumna12().getNombreColumna());
			columnasExcel.getColumna13().setValorCadena(
					columnasExcel.getColumna13().getNombreColumna());
			columnasExcel.getColumna14().setValorCadena(
					columnasExcel.getColumna14().getNombreColumna());
			columnasExcel.getColumna15().setValorCadena(
					columnasExcel.getColumna15().getNombreColumna());
			columnasExcel.getColumna16().setValorCadena(
					columnasExcel.getColumna16().getNombreColumna());
			columnasExcel.getColumna17().setValorCadena(
					columnasExcel.getColumna17().getNombreColumna());
			columnasExcel.getColumna18().setValorCadena(
					columnasExcel.getColumna18().getNombreColumna());
			columnasExcel.getColumna19().setValorCadena(
					columnasExcel.getColumna19().getNombreColumna());
			columnasExcel.getColumna20().setValorCadena(
					columnasExcel.getColumna20().getNombreColumna());

			archivoReporteDao.registrarDetalleArchivoReporte(columnasExcel,
					conn);

			for (ColumnasExcel columnasExcel2 : dataExcel) {
				columnasExcel2.setIdArchivo(idArchivo);
				columnasExcel2.setUsuarioCreacion(reporteArchivo
						.getUsuarioCreacion());
				columnasExcel2.setIpCreacion(reporteArchivo.getIpCreacion());
				archivoReporteDao.registrarDetalleArchivoReporte(
						columnasExcel2, conn);
			}
			userTransaction.commit();
			return true;
		} catch (SQLException e) {
			e.printStackTrace();
			userTransaction.rollback();
			throw new ErrorRegistroDataException(e);
		} catch (Exception e) {
			e.printStackTrace();
			userTransaction.rollback();
			throw new ErrorRegistroDataException(e);
		} finally {
			if (conn != null) {
				conn.close();
			}
		}
	}

	@Override
	public boolean registrarCuentaBancaria(CuentaBancaria cuentaBancaria)
			throws ErrorRegistroDataException {
		try {
			CuentaBancariaDao cuentaBancariaDao = new CuentaBancariaDaoImpl();

			return cuentaBancariaDao.registrarCuentaBancaria(cuentaBancaria);
		} catch (Exception e) {
			throw new ErrorRegistroDataException(e);
		}
	}

	@Override
	public boolean actualizarCuentaBancaria(CuentaBancaria cuentaBancaria)
			throws ErrorRegistroDataException {
		try {
			CuentaBancariaDao cuentaBancariaDao = new CuentaBancariaDaoImpl();

			return cuentaBancariaDao.actualizarCuentaBancaria(cuentaBancaria);
		} catch (SQLException e) {
			throw new ErrorRegistroDataException(e);
		}
	}

	@Override
	public boolean registrarTipoCambio(TipoCambio tipoCambio)
			throws SQLException {
		TipoCambioDao tipoCambioDao = new TipoCambioDaoImpl(tipoCambio.getEmpresa().getCodigoEntero());

		tipoCambioDao.registrarTipoCambio(tipoCambio);

		BigDecimal tipoCambioReversa = BigDecimal.ONE.divide(
				tipoCambio.getMontoCambio(), 6, RoundingMode.HALF_UP);

		BaseVO monedaOrigen = new BaseVO(tipoCambio.getMonedaDestino()
				.getCodigoEntero());
		tipoCambio.setMontoCambio(tipoCambioReversa);
		tipoCambio.setMonedaDestino(tipoCambio.getMonedaOrigen());
		tipoCambio.setMonedaOrigen(monedaOrigen);

		return tipoCambioDao.registrarTipoCambio(tipoCambio);
	}

}
