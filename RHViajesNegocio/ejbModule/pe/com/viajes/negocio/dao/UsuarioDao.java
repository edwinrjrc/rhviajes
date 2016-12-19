/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.negocio.exception.ErrorEncriptacionException;

/**
 * @author Edwin
 *
 */
public interface UsuarioDao {

	public Integer registrarUsuario(Usuario usuario, Connection conn) throws SQLException,
			ErrorEncriptacionException;

	public List<Usuario> listarUsuarios(Connection conn) throws SQLException;

	Usuario consultarUsuario(int id, Connection conn) throws SQLException;

	boolean actualizarUsuario(Usuario usuario, Connection conn) throws SQLException;

	boolean inicioSesion(Usuario usuario) throws SQLException,
			ErrorEncriptacionException;

	boolean cambiarClaveUsuario(Usuario usuario) throws SQLException,
			ErrorEncriptacionException;

	boolean actualizarClaveUsuario(Usuario usuario, Connection conn) throws SQLException,
			ErrorEncriptacionException;

	List<Usuario> listarVendedores(Connection conn) throws SQLException;

	boolean actualizarCredencialVencida(Usuario usuario) throws SQLException,
			ErrorEncriptacionException;

	boolean validarAgregarUsuario(Connection conn) throws SQLException;

	List<BaseVO> listarRolesUsuario(Integer idUsuario, Connection conn)
			throws SQLException;

	boolean ingresarRolUsuario(List<BaseVO> roles, Integer idUsuario,
			Connection conn) throws SQLException;

	Usuario inicioSesion2(Usuario usuario, Connection conn)
			throws SQLException, ErrorEncriptacionException;

}
