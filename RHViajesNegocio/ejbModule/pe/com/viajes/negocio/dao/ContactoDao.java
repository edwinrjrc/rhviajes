/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.base.CorreoElectronico;
import pe.com.viajes.bean.base.Persona;
import pe.com.viajes.bean.negocio.Cliente;
import pe.com.viajes.bean.negocio.Contacto;
import pe.com.viajes.bean.negocio.Pasajero;

/**
 * @author Edwin
 *
 */
public interface ContactoDao {

	void registrarContactoProveedor(int idproveedor, Contacto contacto,
			Connection conexion) throws SQLException;

	boolean eliminarTelefonoContacto(Contacto contacto, Connection conexion)
			throws SQLException;

	boolean eliminarContacto(Contacto contacto, Connection conexion)
			throws SQLException;

	boolean ingresarCorreoElectronico(Contacto contacto, Connection conexion)
			throws SQLException;

	boolean eliminarCorreosContacto(Contacto contacto, Connection conexion)
			throws SQLException;

	boolean eliminarContactoProveedor(Persona proveedor, Connection conexion)
			throws SQLException;

	List<Contacto> consultarContactoProveedor(int idproveedor, int idEmpresa)
			throws SQLException;

	List<CorreoElectronico> consultarCorreos(int idcontacto, int idEmpresa,
			Connection conn) throws SQLException;

	List<Contacto> listarContactosXPersona(int idpersona, int idEmpresa)
			throws SQLException;

	List<Contacto> listarContactosXPersona(int idpersona, int idEmpresa,
			Connection conn) throws SQLException;

	List<Contacto> consultarContactoPasajero(Pasajero pasajero)
			throws SQLException;
}
