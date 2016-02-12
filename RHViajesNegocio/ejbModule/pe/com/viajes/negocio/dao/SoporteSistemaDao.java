/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.licencia.EmpresaAgenciaViajes;
import pe.com.viajes.bean.negocio.Maestro;

/**
 * @author EDWREB
 *
 */
public interface SoporteSistemaDao {

	public List<Maestro> listarMaestro(int idMaestro) throws SQLException;
	
	public boolean grabarEmpresa(EmpresaAgenciaViajes empresa) throws SQLException;
}
