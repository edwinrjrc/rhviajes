package pe.com.viajes.negocio.ejb;

import java.sql.SQLException;
import java.util.List;

import javax.ejb.Local;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.negocio.ConfiguracionTipoServicio;
import pe.com.viajes.bean.negocio.Destino;
import pe.com.viajes.bean.negocio.Maestro;
import pe.com.viajes.bean.negocio.Pais;
import pe.com.viajes.bean.negocio.Proveedor;
import pe.com.viajes.negocio.exception.ConnectionException;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;

@Local
public interface SoporteLocal {

	public List<Maestro> listarMaestros(Integer idEmpresa) throws SQLException;

	public List<Maestro> listarHijosMaestro(int idmaestro, Integer idEmpresa) throws SQLException;

	public boolean ingresarMaestro(Maestro maestro) throws SQLException;

	public boolean ingresarHijoMaestro(Maestro maestro) throws SQLException;

	public Maestro consultarHijoMaestro(Maestro hijo) throws SQLException;

	public boolean actualizarMaestro(Maestro maestro) throws SQLException;

	boolean ingresarPais(Pais pais) throws SQLException, Exception;

	public boolean ingresarDestino(Destino destino) throws SQLException,
			Exception;

	public boolean actualizarDestino(Destino destino) throws SQLException,
			Exception;

	public List<Proveedor> listarProveedorTipo(BaseVO tipoProveedor)
			throws SQLException, Exception;

	public boolean guardarConfiguracionServicio(
			List<ConfiguracionTipoServicio> listaConfigServicios)
			throws SQLException, Exception;

	Maestro consultarMaestro(int id, Integer idEmpresa) throws SQLException;

	List<BaseVO> listarCatalogoMaestro(int maestro, Integer idEmpresa)
			throws SQLException, ConnectionException;

	List<BaseVO> listarCatalogoDepartamento(Integer idEmpresa)
			throws SQLException, ConnectionException;

	List<BaseVO> listarCatalogoProvincia(String idDepartamento,
			Integer idEmpresa) throws SQLException, ConnectionException;

	List<BaseVO> listarCatalogoDistrito(String idDepartamento,
			String idProvincia, Integer idEmpresa) throws SQLException,
			ConnectionException;

	List<BaseVO> listarContinentes(Integer idEmpresa) throws SQLException;

	List<BaseVO> consultarPaisesContinente(int idcontinente, Integer idEmpresa)
			throws SQLException, Exception;

	List<Destino> listarDestinos(Integer idEmpresa) throws SQLException,
			Exception;

	ConfiguracionTipoServicio consultarConfiguracionServicio(
			int idTipoServicio, Integer idEmpresa) throws SQLException,
			Exception;

	boolean esDestinoNacional(Integer destino, Integer idEmpresa)
			throws ErrorConsultaDataException, SQLException, Exception;

	List<ConfiguracionTipoServicio> listarConfiguracionServicios(
			Integer idEmpresa) throws SQLException, Exception;

	List<BaseVO> listarTipoServicios(Integer idEmpresa) throws SQLException,
			Exception;

	List<Destino> buscarDestinos(String descripcion, Integer idEmpresa)
			throws SQLException, Exception;

	Destino consultaDestinoIATA(String codigoIATA, Integer idEmpresa)
			throws SQLException;
}
