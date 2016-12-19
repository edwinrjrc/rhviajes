package pe.com.viajes.negocio.ejb;

import java.sql.SQLException;
import java.util.List;

import javax.ejb.Local;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;
import pe.com.viajes.negocio.exception.ErrorEncriptacionException;
import pe.com.viajes.negocio.exception.ErrorRegistroDataException;
import pe.com.viajes.negocio.exception.InicioSesionException;

@Local
public interface SeguridadLocal {

	boolean registrarUsuario(Usuario usuario) throws SQLException,
	ErrorEncriptacionException, ErrorRegistroDataException;

	List<Usuario> listarUsuarios(Integer idEmpresa) throws ErrorConsultaDataException;

	public List<BaseVO> listarRoles(Integer idEmpresa) throws ErrorConsultaDataException;

	public Usuario consultarUsuario(int id, Integer idEmpresa) throws ErrorConsultaDataException;

	boolean actualizarUsuario(Usuario usuario) throws ErrorEncriptacionException, ErrorRegistroDataException;

	Usuario inicioSesion(Usuario usuario) throws InicioSesionException;

	boolean cambiarClaveUsuario(Usuario usuario) throws SQLException, Exception;

	boolean actualizarClaveUsuario(Usuario usuario) throws SQLException,
			Exception;

	public List<Usuario> listarVendedores(Integer idEmpresa) throws ErrorConsultaDataException;

	boolean actualizarCredencialVencida(Usuario usuario) throws SQLException,
			Exception;
}
