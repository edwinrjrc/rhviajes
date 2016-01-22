/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.negocio.exception.ErrorEncriptacionException;

/**
 * @author Edwin
 *
 */
public interface UsuarioDao {

	public boolean registrarUsuario(Usuario usuario) throws SQLException,
			ErrorEncriptacionException;

	public List<Usuario> listarUsuarios() throws SQLException;

	Usuario consultarUsuario(int id) throws SQLException;

	boolean actualizarUsuario(Usuario usuario) throws SQLException;

	boolean inicioSesion(Usuario usuario) throws SQLException,
			ErrorEncriptacionException;

	Usuario inicioSesion2(Usuario usuario) throws SQLException,
			ErrorEncriptacionException;

	boolean cambiarClaveUsuario(Usuario usuario) throws SQLException,
			ErrorEncriptacionException;

	boolean actualizarClaveUsuario(Usuario usuario) throws SQLException,
			ErrorEncriptacionException;

	List<Usuario> listarVendedores() throws SQLException;

	boolean actualizarCredencialVencida(Usuario usuario) throws SQLException,
			ErrorEncriptacionException;

}
