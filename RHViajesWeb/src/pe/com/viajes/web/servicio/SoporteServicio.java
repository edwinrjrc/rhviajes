/**
 * 
 */
package pe.com.viajes.web.servicio;

import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.negocio.ConfiguracionTipoServicio;
import pe.com.viajes.bean.negocio.Destino;
import pe.com.viajes.bean.negocio.Maestro;
import pe.com.viajes.bean.negocio.Pais;
import pe.com.viajes.bean.negocio.Proveedor;
import pe.com.viajes.negocio.exception.ConnectionException;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;

/**
 * @author Edwin
 * 
 */
public interface SoporteServicio {

	public boolean ingresarMaestro(Maestro maestro) throws SQLException;

	public boolean ingresarHijoMaestro(Maestro maestro) throws SQLException;

	public Maestro consultarHijoMaestro(Maestro hijo) throws SQLException;

	public boolean actualizarMaestro(Maestro hijo) throws SQLException;

	boolean ingresarPais(Pais pais) throws SQLException, Exception;

	boolean ingresarDestino(Destino destino) throws SQLException, Exception;

	boolean actualizarDestino(Destino destino) throws SQLException, Exception;

	public List<Proveedor> listarComboProveedorTipo(BaseVO proveedor)
			throws SQLException, Exception;

	public boolean guardarConfiguracionServicio(
			List<ConfiguracionTipoServicio> listaConfigServicios)
			throws SQLException, Exception;

	List<Maestro> listarMaestros(Integer idEmpresa) throws SQLException;

	List<Maestro> listarHijosMaestro(int idmaestro, Integer idEmpresa)
			throws SQLException;

	Maestro consultarMaestro(int idmaestro, Integer idEmpresa)
			throws SQLException;

	List<BaseVO> listarCatalogoMaestro(int idmaestro, Integer idEmpresa)
			throws SQLException, ConnectionException;

	List<BaseVO> listarCatalogoDepartamento(Integer idEmpresa)
			throws SQLException, ConnectionException;

	List<BaseVO> listarCatalogoProvincia(String idProvincia, Integer idEmpresa)
			throws SQLException, ConnectionException;

	List<BaseVO> listarCatalogoDistrito(String idDepartamento,
			String idProvincia, Integer idEmpresa) throws SQLException,
			ConnectionException;

	List<BaseVO> listarContinentes(Integer idEmpresa) throws SQLException,
			ConnectionException;

	List<BaseVO> consultarPaises(int idcontinente, Integer idEmpresa)
			throws SQLException, Exception;

	List<Destino> listarDestinos(Integer idEmpresa) throws SQLException,
			Exception;

	ConfiguracionTipoServicio consultarConfiguracionServicio(
			int convertirCadenaEntero, Integer idEmpresa);

	boolean esDestinoNacional(Integer destino, Integer idEmpresa)
			throws ErrorConsultaDataException, SQLException, Exception;

	List<ConfiguracionTipoServicio> listarConfiguracionServicios(
			Integer idEmpresa) throws SQLException, Exception;

	List<BaseVO> listarTiposServicios(Integer idEmpresa) throws SQLException,
			Exception;

	List<Destino> consultarOrigen(String descripcion, Integer idEmpresa)
			throws SQLException, Exception;

	List<Destino> consultarDestino(String descripcion, Integer idEmpresa)
			throws SQLException, Exception;

	Destino consultaDestinoIATA(String codigoIATA, Integer idEmpresa)
			throws SQLException;
}
