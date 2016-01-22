package pe.com.viajes.negocio.ejb;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import javax.ejb.Stateless;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.negocio.ConfiguracionTipoServicio;
import pe.com.viajes.bean.negocio.Destino;
import pe.com.viajes.bean.negocio.Maestro;
import pe.com.viajes.bean.negocio.Pais;
import pe.com.viajes.bean.negocio.Proveedor;
import pe.com.viajes.negocio.dao.CatalogoDao;
import pe.com.viajes.negocio.dao.ConfiguracionServicioDao;
import pe.com.viajes.negocio.dao.DestinoDao;
import pe.com.viajes.negocio.dao.MaestroDao;
import pe.com.viajes.negocio.dao.ProveedorDao;
import pe.com.viajes.negocio.dao.impl.CatalogoDaoImpl;
import pe.com.viajes.negocio.dao.impl.ConfiguracionServicioDaoImpl;
import pe.com.viajes.negocio.dao.impl.DestinoDaoImpl;
import pe.com.viajes.negocio.dao.impl.MaestroDaoImpl;
import pe.com.viajes.negocio.dao.impl.ProveedorDaoImpl;
import pe.com.viajes.negocio.exception.ConnectionException;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;
import pe.com.viajes.negocio.util.UtilConexion;

/**
 * Session Bean implementation class SoporteSession
 */
@Stateless(name = "SoporteSession")
public class SoporteSession implements SoporteRemote, SoporteLocal {

	MaestroDao maestroDao = null;
	CatalogoDao catalogoDao = null;
	DestinoDao destinoDao = null;

	/**
	 * Default constructor.
	 */
	public SoporteSession() {

	}

	@Override
	public List<Maestro> listarMaestros(Integer idEmpresa) throws SQLException {
		maestroDao = new MaestroDaoImpl();
		return maestroDao.listarMaestros(idEmpresa);
	}

	@Override
	public List<Maestro> listarHijosMaestro(int idmaestro, Integer idEmpresa) throws SQLException {
		maestroDao = new MaestroDaoImpl();
		return maestroDao.listarHijosMaestro(idmaestro, idEmpresa);
	}

	@Override
	public boolean ingresarMaestro(Maestro maestro) throws SQLException {
		maestroDao = new MaestroDaoImpl();
		return maestroDao.ingresarMaestro(maestro);
	}

	@Override
	public boolean ingresarHijoMaestro(Maestro maestro) throws SQLException {
		maestroDao = new MaestroDaoImpl();
		return maestroDao.ingresarHijoMaestro(maestro);
	}

	@Override
	public Maestro consultarMaestro(int id, Integer idEmpresa) throws SQLException {
		maestroDao = new MaestroDaoImpl();
		return maestroDao.consultarMaestro(id, idEmpresa);
	}

	@Override
	public Maestro consultarHijoMaestro(Maestro hijo) throws SQLException {
		maestroDao = new MaestroDaoImpl();
		return maestroDao.consultarHijoMaestro(hijo);
	}

	@Override
	public boolean actualizarMaestro(Maestro maestro) throws SQLException {
		maestroDao = new MaestroDaoImpl();
		return maestroDao.actualizarMaestro(maestro);
	}

	@Override
	public List<BaseVO> listarCatalogoMaestro(int maestro, Integer idEmpresa) throws SQLException,
			ConnectionException {
		catalogoDao = new CatalogoDaoImpl();
		return catalogoDao.listarCatalogoMaestro(maestro, idEmpresa);
	}

	@Override
	public List<BaseVO> listarCatalogoDepartamento(Integer idEmpresa) throws SQLException,
			ConnectionException {
		catalogoDao = new CatalogoDaoImpl();
		return catalogoDao.listaDepartamento(idEmpresa);
	}

	@Override
	public List<BaseVO> listarCatalogoProvincia(String idDepartamento, Integer idEmpresa)
			throws SQLException, ConnectionException {
		catalogoDao = new CatalogoDaoImpl();
		return catalogoDao.listaProvincia(idDepartamento, idEmpresa);
	}

	@Override
	public List<BaseVO> listarCatalogoDistrito(String idDepartamento,
			String idProvincia, Integer idEmpresa) throws SQLException, ConnectionException {
		catalogoDao = new CatalogoDaoImpl();
		return catalogoDao.listaDistrito(idDepartamento, idProvincia, idEmpresa);
	}

	@Override
	public List<BaseVO> listarContinentes(Integer idEmpresa) throws SQLException {
		maestroDao = new MaestroDaoImpl();
		List<BaseVO> lista = new ArrayList<BaseVO>();
		int idmaestro = 10;
		List<Maestro> listaContinentes = maestroDao
				.listarHijosMaestro(idmaestro, idEmpresa);
		for (Maestro maestro : listaContinentes) {
			lista.add((BaseVO) maestro);
		}

		return lista;
	}

	@Override
	public List<BaseVO> consultarPaisesContinente(int idcontinente, Integer idEmpresa)
			throws SQLException, Exception {
		maestroDao = new MaestroDaoImpl();
		return maestroDao.listarPaises(idcontinente, idEmpresa);
	}

	@Override
	public boolean ingresarPais(Pais pais) throws SQLException, Exception {
		maestroDao = new MaestroDaoImpl();
		return maestroDao.ingresarPais(pais);
	}

	@Override
	public boolean ingresarDestino(Destino destino) throws SQLException,
			Exception {
		destinoDao = new DestinoDaoImpl();
		return destinoDao.ingresarDestino(destino);
	}

	@Override
	public boolean actualizarDestino(Destino destino) throws SQLException,
			Exception {
		destinoDao = new DestinoDaoImpl();
		return destinoDao.actualizarDestino(destino);
	}

	@Override
	public List<Destino> listarDestinos(Integer idEmpresa) throws SQLException, Exception {
		destinoDao = new DestinoDaoImpl();
		return destinoDao.listarDestinos(idEmpresa);
	}

	@Override
	public ConfiguracionTipoServicio consultarConfiguracionServicio(
			int idTipoServicio, Integer idEmpresa) throws SQLException, Exception {
		ConfiguracionServicioDao configuracionServicioDao = new ConfiguracionServicioDaoImpl();

		return configuracionServicioDao
				.consultarConfiguracionServicio(idTipoServicio, idEmpresa);
	}

	@Override
	public List<Proveedor> listarProveedorTipo(BaseVO tipoProveedor)
			throws SQLException, Exception {
		ProveedorDao proveedorDao = new ProveedorDaoImpl();

		return proveedorDao.listarComboProveedorTipo(tipoProveedor, tipoProveedor.getEmpresa().getCodigoEntero());
	}

	@Override
	public boolean esDestinoNacional(Integer destino, Integer idEmpresa)
			throws ErrorConsultaDataException, SQLException, Exception {
		DestinoDao destinoDao = new DestinoDaoImpl();

		try {
			Destino destinoConsultado = destinoDao.consultarDestino(destino, idEmpresa);

			Locale localidad = Locale.getDefault();

			return localidad.getCountry().equals(
					destinoConsultado.getPais().getAbreviado());
		} catch (SQLException e) {
			throw new ErrorConsultaDataException(
					"Error al determinar la nacionalidad del destino");
		} catch (Exception e) {
			throw new ErrorConsultaDataException(
					"Error al determinar la nacionalidad del destino");
		}
	}

	@Override
	public List<ConfiguracionTipoServicio> listarConfiguracionServicios(Integer idEmpresa)
			throws SQLException, Exception {
		ConfiguracionServicioDao configuracionServicioDao = new ConfiguracionServicioDaoImpl();

		return configuracionServicioDao.listarConfiguracionServicios(idEmpresa);
	}

	@Override
	public List<BaseVO> listarTipoServicios(Integer idEmpresa) throws SQLException, Exception {
		ConfiguracionServicioDao configuracionServicioDao = new ConfiguracionServicioDaoImpl();

		return configuracionServicioDao.listarTipoServicios(idEmpresa);
	}

	@Override
	public boolean guardarConfiguracionServicio(
			List<ConfiguracionTipoServicio> listaConfigServicios)
			throws ErrorConsultaDataException, SQLException, Exception {
		ConfiguracionServicioDao configuracionServicioDao = new ConfiguracionServicioDaoImpl();

		Connection conn = null;

		try {
			conn = UtilConexion.obtenerConexion();

			configuracionServicioDao.eliminarConfiguracion(
					listaConfigServicios.get(0), conn);

			for (ConfiguracionTipoServicio configuracion : listaConfigServicios) {
				configuracionServicioDao.registrarConfiguracionServicio(
						configuracion, conn);
			}

			return true;
		} catch (SQLException e) {
			e.printStackTrace();
			throw new ErrorConsultaDataException(
					"Error al grabar configuracion");
		} catch (Exception e) {
			throw new ErrorConsultaDataException(
					"Error al grabar configuracion");
		} finally {
			if (conn != null) {
				conn.close();
			}
		}

	}

	@Override
	public List<Destino> buscarDestinos(String descripcion, Integer idEmpresa)
			throws SQLException, Exception {

		destinoDao = new DestinoDaoImpl();

		return destinoDao.buscarDestinos(descripcion, idEmpresa);
	}

	@Override
	public Destino consultaDestinoIATA(String codigoIATA, Integer idEmpresa) throws SQLException {
		destinoDao = new DestinoDaoImpl();

		return destinoDao.consultarDestinoIATA(codigoIATA, idEmpresa);
	}
}
