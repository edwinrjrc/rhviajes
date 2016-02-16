/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.licencia.ContratoLicencia;
import pe.com.viajes.bean.licencia.EmpresaAgenciaViajes;
import pe.com.viajes.bean.negocio.Maestro;

/**
 * @author EDWREB
 *
 */
public interface SoporteSistemaDao {

	/**
	 * 
	 * @param idMaestro
	 * @return
	 * @throws SQLException
	 */
	public List<Maestro> listarMaestro(int idMaestro) throws SQLException;

	/**
	 * 
	 * @param empresa
	 * @return
	 * @throws SQLException
	 */
	public boolean grabarEmpresa(EmpresaAgenciaViajes empresa)
			throws SQLException;

	/**
	 * 
	 * @return
	 * @throws SQLException
	 */
	List<EmpresaAgenciaViajes> listarEmpresas() throws SQLException;

	/**
	 * 
	 * @return
	 * @throws SQLException
	 */
	List<ContratoLicencia> listarContratos() throws SQLException;

	/**
	 * 
	 * @param contrato
	 * @return
	 * @throws SQLException
	 */
	boolean grabarContrato(ContratoLicencia contrato) throws SQLException;
}
