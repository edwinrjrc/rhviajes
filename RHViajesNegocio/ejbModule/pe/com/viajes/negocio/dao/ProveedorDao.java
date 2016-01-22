/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.negocio.Contacto;
import pe.com.viajes.bean.negocio.CuentaBancaria;
import pe.com.viajes.bean.negocio.Proveedor;
import pe.com.viajes.bean.negocio.ServicioProveedor;

/**
 * @author Edwin
 *
 */
public interface ProveedorDao {

	void registroProveedor(Proveedor proveedor, Connection conexion)
			throws SQLException;

	List<Proveedor> listarProveedor(Proveedor proveedor) throws SQLException;

	Contacto consultarContacto(int idPersona) throws SQLException;

	void actualizarProveedor(Proveedor proveedor, Connection conexion)
			throws SQLException;

	List<Proveedor> buscarProveedor(Proveedor proveedor) throws SQLException;

	boolean ingresarServicioProveedor(Integer idproveedor,
			ServicioProveedor servicio, Connection conn) throws SQLException;

	boolean actualizarServicioProveedor(Integer idproveedor,
			ServicioProveedor servicio, Connection conn) throws SQLException;

	void registroProveedorTipo(Proveedor proveedor, Connection conexion)
			throws SQLException;

	void actualizarProveedorTipo(Proveedor proveedor, Connection conexion)
			throws SQLException;

	boolean ingresarCuentaBancaria(Integer idProveedor, CuentaBancaria cuenta,
			Connection conexion) throws SQLException;

	boolean eliminarCuentasBancarias(Proveedor proveedor, Connection conn)
			throws SQLException;

	boolean actualizarCuentaBancaria(Integer idProveedor,
			CuentaBancaria cuenta, Connection conn) throws SQLException;

	boolean eliminarTipoServicioProveedor(Proveedor proveedor, Connection conn)
			throws SQLException;

	Proveedor consultarProveedor(int idProveedor, int idEmpresa)
			throws SQLException;

	Proveedor consultarProveedor(int idProveedor, int idEmpresa, Connection conn)
			throws SQLException;

	List<ServicioProveedor> consultarServicioProveedor(int idProveedor,
			int idEmpresa) throws SQLException;

	List<ServicioProveedor> consultarServicioProveedor(int idProveedor,
			int idEmpresa, Connection conn) throws SQLException;

	List<Proveedor> listarComboProveedorTipo(BaseVO tipoProveedor, int idEmpresa)
			throws SQLException;

	boolean validarEliminarCuentaBancaria(Integer idCuenta,
			Integer idProveedor, int idEmpresa, Connection conn)
			throws SQLException;

	List<CuentaBancaria> listarCuentasBancarias(Integer idProveedor,
			int idEmpresa) throws SQLException;
}
