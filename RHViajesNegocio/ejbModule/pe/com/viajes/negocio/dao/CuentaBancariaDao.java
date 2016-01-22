/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.negocio.CuentaBancaria;
import pe.com.viajes.bean.negocio.MovimientoCuenta;

/**
 * @author EDWREB
 *
 */
public interface CuentaBancariaDao {

	public boolean registrarCuentaBancaria(CuentaBancaria cuentaBancaria)
			throws SQLException;

	public boolean actualizarCuentaBancaria(CuentaBancaria cuentaBancaria)
			throws SQLException;

	List<CuentaBancaria> listarCuentasBancarias(int idEmpresa)
			throws SQLException;

	CuentaBancaria consultaCuentaBancaria(Integer idCuenta, int idEmpresa)
			throws SQLException;

	List<CuentaBancaria> listarCuentasBancariasCombo(int idEmpresa)
			throws SQLException;

	List<MovimientoCuenta> listarMovimientoCuentaBancaria(Integer idCuenta,
			int idEmpresa) throws SQLException;
}
