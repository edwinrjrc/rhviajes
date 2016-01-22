package pe.com.viajes.negocio.ejb;

import java.sql.SQLException;
import java.util.List;

import javax.ejb.Remote;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.negocio.exception.ConnectionException;
import pe.com.viajes.negocio.exception.ErrorEncriptacionException;
import pe.com.viajes.negocio.exception.InicioSesionException;

@Remote
public interface SeguridadRemote {

	boolean registrarUsuario(Usuario usuario) throws SQLException,
			ErrorEncriptacionException;

	public List<BaseVO> listarRoles(Integer idEmpresa) throws ConnectionException, SQLException;

	public Usuario consultarUsuario(int id, Integer idEmpresa) throws SQLException;

	boolean actualizarUsuario(Usuario usuario) throws SQLException;

	Usuario inicioSesion(Usuario usuario) throws InicioSesionException,
			SQLException, Exception;

	boolean cambiarClaveUsuario(Usuario usuario) throws SQLException, Exception;

	public boolean actualizarClaveUsuario(Usuario usuario) throws SQLException,
			Exception;

	public List<Usuario> listarVendedores(Integer idEmpresa) throws SQLException;

	boolean actualizarCredencialVencida(Usuario usuario) throws SQLException,
			Exception;

	List<Usuario> listarUsuarios(Integer idEmpresa) throws SQLException;
}
