/**
 * 
 */
package pe.com.viajes.web.servicio;

import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.negocio.exception.ConnectionException;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;
import pe.com.viajes.negocio.exception.ErrorEncriptacionException;
import pe.com.viajes.negocio.exception.InicioSesionException;

/**
 * @author Edwin
 *
 */
public interface SeguridadServicio {

	public boolean registrarUsuario(Usuario usuario) throws SQLException,
			ErrorEncriptacionException;

	boolean actualizarUsuario(Usuario usuario) throws SQLException;

	Usuario inicioSesion(Usuario usuario) throws InicioSesionException,
			SQLException, Exception;

	boolean cambiarClaveUsuario(Usuario usuario) throws SQLException, Exception;

	boolean actualizarClaveUsuario(Usuario usuario) throws SQLException,
			Exception;

	boolean actualizarCredencialVencida(Usuario usuario) throws SQLException,
			Exception;

	List<Usuario> listarUsuarios(Integer idEmpresa) throws SQLException;

	List<BaseVO> listarRoles(Integer idEmpresa) throws ConnectionException,
			SQLException;

	Usuario consultarUsuario(int id, Integer idEmpresa) throws SQLException;

	List<Usuario> listarVendedores(Integer idEmpresa) throws SQLException;

	boolean validarAgregarUsuario(int idEmpresa)
			throws ErrorConsultaDataException;
}
