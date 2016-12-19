/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.Date;
import java.util.List;

import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.bean.recursoshumanos.UsuarioAsistencia;

/**
 * @author Edwin
 *
 */
public interface AuditoriaDao {

	/**
	 * Metodo que registrar el evento de sesion del sistema
	 * 
	 * @param usuario
	 * @param tipoEvento
	 * @return
	 * @throws SQLException
	 */
	public boolean registrarEventoSesion(Usuario usuario, Integer tipoEvento)
			throws SQLException;
	
	/**
	 * Metodo que registrar el evento de sesion del sistema
	 * 
	 * @param usuario
	 * @param tipoEvento
	 * @return
	 * @throws SQLException
	 */
	public boolean registrarEventoSesion(Usuario usuario, Integer tipoEvento, Connection conn)
			throws SQLException;

	/**
	 * 
	 * @param fecha
	 * @param idEmpresa
	 * @return
	 * @throws SQLException
	 */
	List<UsuarioAsistencia> listarHoraEntradaXDia(Date fecha, Integer idEmpresa)
			throws SQLException;
}
