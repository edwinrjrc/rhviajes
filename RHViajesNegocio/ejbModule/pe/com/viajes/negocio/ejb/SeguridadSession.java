package pe.com.viajes.negocio.ejb;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import javax.annotation.Resource;
import javax.ejb.EJB;
import javax.ejb.Stateless;
import javax.ejb.TransactionManagement;
import javax.ejb.TransactionManagementType;
import javax.transaction.HeuristicMixedException;
import javax.transaction.HeuristicRollbackException;
import javax.transaction.NotSupportedException;
import javax.transaction.RollbackException;
import javax.transaction.SystemException;
import javax.transaction.UserTransaction;

import org.apache.commons.lang3.StringUtils;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.negocio.dao.AuditoriaDao;
import pe.com.viajes.negocio.dao.CatalogoDao;
import pe.com.viajes.negocio.dao.EmpresaLicenciaDao;
import pe.com.viajes.negocio.dao.UsuarioDao;
import pe.com.viajes.negocio.dao.impl.AuditoriaDaoImpl;
import pe.com.viajes.negocio.dao.impl.CatalogoDaoImpl;
import pe.com.viajes.negocio.dao.impl.EmpresaLicenciaDaoImpl;
import pe.com.viajes.negocio.dao.impl.UsuarioDaoImpl;
import pe.com.viajes.negocio.exception.ConnectionException;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;
import pe.com.viajes.negocio.exception.ErrorEncriptacionException;
import pe.com.viajes.negocio.exception.ErrorRegistroDataException;
import pe.com.viajes.negocio.exception.InicioSesionException;
import pe.com.viajes.negocio.util.UtilConexion;

/**
 * Session Bean implementation class Seguridad
 */
@Stateless(name = "SeguridadSession")
@TransactionManagement(TransactionManagementType.BEAN)
public class SeguridadSession implements SeguridadRemote, SeguridadLocal {

	UsuarioDao usuarioDao = null;
	CatalogoDao catalogoDao = null;

	@EJB
	AuditoriaSessionLocal auditoriaSessionLocal;
	
	@Resource
	private UserTransaction userTransaction;

	@Override
	public boolean registrarUsuario(Usuario usuario) throws ErrorEncriptacionException, ErrorRegistroDataException {
		boolean resultado;
		try {
			Connection conn = null;
			resultado = false;
			userTransaction.begin();
			try{
				conn = UtilConexion.obtenerConexion();
				usuarioDao = new UsuarioDaoImpl(usuario.getEmpresa().getCodigoEntero());
				Integer idUsuario = usuarioDao.registrarUsuario(usuario, conn);
				usuarioDao.ingresarRolUsuario(usuario.getListaRoles(), idUsuario, conn);
				
				userTransaction.commit();
			}
			catch(SQLException e){
				userTransaction.rollback();
				throw new ErrorRegistroDataException(e);
			}
			finally{
				try {
					if (conn != null){
						conn.close();
					}
				} catch (SQLException e) {
					throw new ErrorRegistroDataException(e);
				}
			}
			
		} catch (NotSupportedException e) {
			throw new ErrorRegistroDataException(e);
		} catch (SystemException e) {
			throw new ErrorRegistroDataException(e);
		} catch (SecurityException e) {
			throw new ErrorRegistroDataException(e);
		} catch (IllegalStateException e) {
			throw new ErrorRegistroDataException(e);
		} catch (RollbackException e) {
			throw new ErrorRegistroDataException(e);
		} catch (HeuristicMixedException e) {
			throw new ErrorRegistroDataException(e);
		} catch (HeuristicRollbackException e) {
			throw new ErrorRegistroDataException(e);
		}
		
		return resultado;
	}

	@Override
	public List<Usuario> listarUsuarios(Integer idEmpresa) throws ErrorConsultaDataException {
		try {
			Connection conn = null;
			userTransaction.begin();
			
			try {
				usuarioDao = new UsuarioDaoImpl(idEmpresa);
				conn = UtilConexion.obtenerConexion();
				List<Usuario> listaUsuarios = usuarioDao.listarUsuarios(conn);
				userTransaction.commit();
				return listaUsuarios;
			} catch (SQLException e) {
				userTransaction.rollback();
				throw new ErrorConsultaDataException(e);
			} finally{
				try {
					if (conn != null){
						conn.close();
					}
				} catch (SQLException e) {
					throw new ErrorConsultaDataException(e);
				}
			}
		} catch (NotSupportedException e) {
			throw new ErrorConsultaDataException(e);
		} catch (SystemException e) {
			throw new ErrorConsultaDataException(e);
		} catch (SecurityException e) {
			throw new ErrorConsultaDataException(e);
		} catch (IllegalStateException e) {
			throw new ErrorConsultaDataException(e);
		} catch (RollbackException e) {
			throw new ErrorConsultaDataException(e);
		} catch (HeuristicMixedException e) {
			throw new ErrorConsultaDataException(e);
		} catch (HeuristicRollbackException e) {
			throw new ErrorConsultaDataException(e);
		}
	}

	@Override
	public List<BaseVO> listarRoles(Integer idEmpresa) throws ErrorConsultaDataException {
		List<BaseVO> listado;
		try {
			listado = null;
			Connection conn = null;
			userTransaction.begin();
			try {
				catalogoDao = new CatalogoDaoImpl();
				conn = UtilConexion.obtenerConexion();
				listado = catalogoDao.listarRoles(idEmpresa, conn);
				userTransaction.commit();
			} catch (ConnectionException e) {
				userTransaction.rollback();
				throw new ErrorConsultaDataException (e);
			} catch (SQLException e) {
				userTransaction.rollback();
				throw new ErrorConsultaDataException (e);
			} finally{
				try {
					if (conn != null){
						conn.close();
					}
				} catch (SQLException e) {
					throw new ErrorConsultaDataException(e);
				}
			}
		} catch (NotSupportedException e) {
			throw new ErrorConsultaDataException(e);
		} catch (SystemException e) {
			throw new ErrorConsultaDataException(e);
		} catch (SecurityException e) {
			throw new ErrorConsultaDataException(e);
		} catch (IllegalStateException e) {
			throw new ErrorConsultaDataException(e);
		} catch (RollbackException e) {
			throw new ErrorConsultaDataException(e);
		} catch (HeuristicMixedException e) {
			throw new ErrorConsultaDataException(e);
		} catch (HeuristicRollbackException e) {
			throw new ErrorConsultaDataException(e);
		}
		
		return listado;
	}

	@Override
	public Usuario consultarUsuario(int id, Integer idEmpresa) throws ErrorConsultaDataException {
		try {
			Connection conn = null;
			try {
				conn = UtilConexion.obtenerConexion();
				userTransaction.begin();
				Usuario usuario = null;
				usuarioDao = new UsuarioDaoImpl(idEmpresa);
				usuario = usuarioDao.consultarUsuario(id, conn);
				userTransaction.commit();
				return usuario;
			} catch (SQLException e) {
				userTransaction.rollback();
				throw new ErrorConsultaDataException(e);
			} finally{
				try {
					if (conn != null){
						conn.close();
					}
				} catch (SQLException e) {
					throw new ErrorConsultaDataException(e);
				}
			}
		} catch (NotSupportedException e) {
			throw new ErrorConsultaDataException(e);
		} catch (SystemException e) {
			throw new ErrorConsultaDataException(e);
		} catch (SecurityException e) {
			throw new ErrorConsultaDataException(e);
		} catch (IllegalStateException e) {
			throw new ErrorConsultaDataException(e);
		} catch (RollbackException e) {
			throw new ErrorConsultaDataException(e);
		} catch (HeuristicMixedException e) {
			throw new ErrorConsultaDataException(e);
		} catch (HeuristicRollbackException e) {
			throw new ErrorConsultaDataException(e);
		}
	}

	@Override
	public boolean actualizarUsuario(Usuario usuario) throws ErrorEncriptacionException, ErrorRegistroDataException {
		try {
			boolean resultado = false;
			Connection conn = null;
			userTransaction.begin();
			try {
				
				usuarioDao = new UsuarioDaoImpl(usuario.getEmpresa().getCodigoEntero());
				conn = UtilConexion.obtenerConexion();
				resultado = usuarioDao.actualizarUsuario(usuario, conn);
				userTransaction.commit();
				return resultado;
			} catch (SQLException e) {
				userTransaction.rollback();
				throw new ErrorRegistroDataException(e);
			} finally{
				try {
					if (conn != null){
						conn.close();
					}
				} catch (SQLException e) {
					throw new ErrorRegistroDataException(e);
				}
			}
		} catch (NotSupportedException e) {
			throw new ErrorRegistroDataException(e);
		} catch (SystemException e) {
			throw new ErrorRegistroDataException(e);
		} catch (SecurityException e) {
			throw new ErrorRegistroDataException(e);
		} catch (IllegalStateException e) {
			throw new ErrorRegistroDataException(e);
		} catch (RollbackException e) {
			throw new ErrorRegistroDataException(e);
		} catch (HeuristicMixedException e) {
			throw new ErrorRegistroDataException(e);
		} catch (HeuristicRollbackException e) {
			throw new ErrorRegistroDataException(e);
		}
	}

	@Override
	public Usuario inicioSesion(Usuario usuario) throws InicioSesionException {
		EmpresaLicenciaDao empresaLicenciaDao = new EmpresaLicenciaDaoImpl();
		String nombreDominio = StringUtils.trim(usuario.getUsuario());
		Connection conn = null;
		try {
			userTransaction.begin();
			if (StringUtils.contains(nombreDominio, "@")){
				try {
					conn = UtilConexion.obtenerConexion();
					nombreDominio = nombreDominio.split("@")[1];
					usuario.setEmpresa(empresaLicenciaDao.consultarEmpresaLicencia(nombreDominio, conn));
					
					usuarioDao = new UsuarioDaoImpl(usuario.getEmpresa().getCodigoEntero());
					usuario = usuarioDao.inicioSesion2(usuario, conn);
					usuario.setNombreDominioEmpresa(nombreDominio);
					
					if (!usuario.isEncontrado()) {
						throw new InicioSesionException(
								"El usuario y la contraseña son incorrectas");
					}
					
					usuario.setUsuarioCreacion(usuario);
					usuario.setUsuarioModificacion(usuario);
					AuditoriaDao auditoriaDao = new AuditoriaDaoImpl();
					auditoriaDao.registrarEventoSesion(usuario, 1, conn);
					
					userTransaction.commit();
				} catch (SQLException e) {
					userTransaction.rollback();
					throw new InicioSesionException("No se pudo iniciar session", e);
				} catch (SecurityException e) {
					userTransaction.rollback();
					throw new InicioSesionException("No se pudo iniciar session", e);
				} catch (IllegalStateException e) {
					userTransaction.rollback();
					throw new InicioSesionException("No se pudo iniciar session", e);
				} catch (RollbackException e) {
					userTransaction.rollback();
					throw new InicioSesionException("No se pudo iniciar session", e);
				} catch (HeuristicMixedException e) {
					userTransaction.rollback();
					throw new InicioSesionException("No se pudo iniciar session", e);
				} catch (HeuristicRollbackException e) {
					userTransaction.rollback();
					throw new InicioSesionException("No se pudo iniciar session", e);
				} catch (InicioSesionException e){
					userTransaction.rollback();
					throw new InicioSesionException(e);
				} finally{
					try {
						if (conn != null){
							conn.close();
						}
					} catch (SQLException e) {
						throw new InicioSesionException(e);
					}
				}
			}
			else{
				throw new InicioSesionException(
						"El usuario incorrecto");
			}
		} catch (ErrorEncriptacionException e) {
			throw new InicioSesionException("No se pudo iniciar session", e);
		} catch (NotSupportedException e) {
			throw new InicioSesionException("No se pudo iniciar session", e);
		} catch (SystemException e) {
			throw new InicioSesionException("No se pudo iniciar session", e);
		} catch (Exception e){
			throw new InicioSesionException("No se pudo iniciar session", e);
		}
				
		return usuario;
	}

	@Override
	public boolean cambiarClaveUsuario(Usuario usuario) throws ErrorConsultaDataException {
		usuarioDao = new UsuarioDaoImpl(usuario.getEmpresa().getCodigoEntero());
		boolean resultado = false;
		try {
			Connection conn = null;
			userTransaction.begin();
			
			try {
				conn = UtilConexion.obtenerConexion();
				Usuario usuario2 = usuarioDao.inicioSesion2(usuario, conn);
				usuario2.setCredencialNueva(usuario.getCredencialNueva());
				if (!usuario2.isEncontrado()) {
					throw new ErrorConsultaDataException("Informacion de usuario incorrecta");
				}

				resultado = usuarioDao.actualizarClaveUsuario(usuario2, conn);
				userTransaction.commit();
			} catch (SQLException e) {
				userTransaction.rollback();
				throw new ErrorConsultaDataException(e);
			} catch (ErrorEncriptacionException e) {
				userTransaction.rollback();
				throw new ErrorConsultaDataException(e);
			} finally{
				try {
					if (conn != null){
						conn.close();
					}
				} catch (SQLException e) {
					throw new ErrorConsultaDataException(e);
				}
			}
			
			return resultado;
		} catch (NotSupportedException e) {
			throw new ErrorConsultaDataException(e);
		} catch (SystemException e) {
			throw new ErrorConsultaDataException(e);
		} catch (SecurityException e) {
			throw new ErrorConsultaDataException(e);
		} catch (IllegalStateException e) {
			throw new ErrorConsultaDataException(e);
		} catch (RollbackException e) {
			throw new ErrorConsultaDataException(e);
		} catch (HeuristicMixedException e) {
			throw new ErrorConsultaDataException(e);
		} catch (HeuristicRollbackException e) {
			throw new ErrorConsultaDataException(e);
		}
	}

	@Override
	public boolean actualizarClaveUsuario(Usuario usuario) throws ErrorRegistroDataException {
		boolean resultado = false;
		
		try {
			Connection conn = null;
			userTransaction.begin();
			
			try {
				usuarioDao = new UsuarioDaoImpl(usuario.getEmpresa().getCodigoEntero());
				conn = UtilConexion.obtenerConexion();
				resultado = usuarioDao.actualizarClaveUsuario(usuario, conn);
				userTransaction.commit();
			} catch (SQLException e) {
				userTransaction.rollback();
				throw new ErrorRegistroDataException(e);
			} catch (ErrorEncriptacionException e) {
				userTransaction.rollback();
				throw new ErrorRegistroDataException(e);
			} finally{
				try {
					if (conn != null){
						conn.close();
					}
				} catch (SQLException e) {
					throw new ErrorRegistroDataException(e);
				}
			}

			return resultado;
		} catch (NotSupportedException e) {
			throw new ErrorRegistroDataException(e);
		} catch (SystemException e) {
			throw new ErrorRegistroDataException(e);
		} catch (SecurityException e) {
			throw new ErrorRegistroDataException(e);
		} catch (IllegalStateException e) {
			throw new ErrorRegistroDataException(e);
		} catch (RollbackException e) {
			throw new ErrorRegistroDataException(e);
		} catch (HeuristicMixedException e) {
			throw new ErrorRegistroDataException(e);
		} catch (HeuristicRollbackException e) {
			throw new ErrorRegistroDataException(e);
		}
	}

	@Override
	public List<Usuario> listarVendedores(Integer idEmpresa) throws ErrorConsultaDataException {
		try {
			List<Usuario> lista = null;
			Connection conn = null;
			userTransaction.begin();
			try {
				conn = UtilConexion.obtenerConexion();
				usuarioDao = new UsuarioDaoImpl(idEmpresa);
				lista = usuarioDao.listarVendedores(conn);
				userTransaction.commit();
			} catch (SQLException e) {
				userTransaction.rollback();
				throw new ErrorConsultaDataException(e);
			} finally{
				try {
					if (conn != null){
						conn.close();
					}
				} catch (SQLException e) {
					throw new ErrorConsultaDataException(e);
				}
			}
			
			return lista;
		} catch (NotSupportedException e) {
			throw new ErrorConsultaDataException(e);
		} catch (SystemException e) {
			throw new ErrorConsultaDataException(e);
		} catch (SecurityException e) {
			throw new ErrorConsultaDataException(e);
		} catch (IllegalStateException e) {
			throw new ErrorConsultaDataException(e);
		} catch (RollbackException e) {
			throw new ErrorConsultaDataException(e);
		} catch (HeuristicMixedException e) {
			throw new ErrorConsultaDataException(e);
		} catch (HeuristicRollbackException e) {
			throw new ErrorConsultaDataException(e);
		}
	}

	@Override
	public boolean actualizarCredencialVencida(Usuario usuario)
			throws ErrorRegistroDataException {
		try {
			boolean resultado = false;
			Connection conn = null;
			userTransaction.begin();
			
			try {
				conn = UtilConexion.obtenerConexion();
				usuarioDao = new UsuarioDaoImpl(usuario.getEmpresa().getCodigoEntero());
				usuarioDao.inicioSesion2(usuario, conn);

				resultado = usuarioDao.actualizarCredencialVencida(usuario);
				userTransaction.commit();
			} catch (SQLException e) {
				userTransaction.rollback();
				throw new ErrorRegistroDataException(e);
			} catch (ErrorEncriptacionException e) {
				userTransaction.rollback();
				throw new ErrorRegistroDataException(e);
			} finally{
				try {
					if (conn != null){
						conn.close();
					}
				} catch (SQLException e) {
					throw new ErrorRegistroDataException(e);
				}
			}
			
			return resultado;
		} catch (NotSupportedException e) {
			throw new ErrorRegistroDataException(e);
		} catch (SystemException e) {
			throw new ErrorRegistroDataException(e);
		} catch (SecurityException e) {
			throw new ErrorRegistroDataException(e);
		} catch (IllegalStateException e) {
			throw new ErrorRegistroDataException(e);
		} catch (RollbackException e) {
			throw new ErrorRegistroDataException(e);
		} catch (HeuristicMixedException e) {
			throw new ErrorRegistroDataException(e);
		} catch (HeuristicRollbackException e) {
			throw new ErrorRegistroDataException(e);
		}
	}
	
	@Override
	public boolean validaAgregarUsuario(int idEmpresa) throws ErrorConsultaDataException{
		boolean resultado = false;
		try {
			Connection conn = null;
			userTransaction.begin();
			try {
				usuarioDao = new UsuarioDaoImpl(idEmpresa);
				conn = UtilConexion.obtenerConexion();
				resultado = usuarioDao.validarAgregarUsuario(conn);
				userTransaction.commit();
			} catch (SQLException e) {
				userTransaction.rollback();
				throw new ErrorConsultaDataException("Error en validar para agregar usuario", e);
			} finally{
				try {
					if (conn != null){
						conn.close();
					}
				} catch (SQLException e) {
					throw new ErrorConsultaDataException(e);
				}
			}
			
			return resultado;
		} catch (NotSupportedException e) {
			throw new ErrorConsultaDataException(e);
		} catch (SystemException e) {
			throw new ErrorConsultaDataException(e);
		} catch (SecurityException e) {
			throw new ErrorConsultaDataException(e);
		} catch (IllegalStateException e) {
			throw new ErrorConsultaDataException(e);
		} catch (RollbackException e) {
			throw new ErrorConsultaDataException(e);
		} catch (HeuristicMixedException e) {
			throw new ErrorConsultaDataException(e);
		} catch (HeuristicRollbackException e) {
			throw new ErrorConsultaDataException(e);
		}
	}
}
