package pe.com.viajes.negocio.ejb;

import java.sql.SQLException;
import java.util.List;

import javax.ejb.Stateless;

import pe.com.viajes.bean.negocio.Parametro;
import pe.com.viajes.negocio.dao.ParametroDao;
import pe.com.viajes.negocio.dao.impl.ParametroDaoImpl;

/**
 * Session Bean implementation class Parametro
 */
@Stateless(name = "ParametroSession")
public class ParametroSession implements ParametroRemote, ParametroLocal {

	ParametroDao parametroDao = null;

	/**
	 * Default constructor.
	 */
	public ParametroSession() {
		// TODO Auto-generated constructor stub
	}

	@Override
	public List<pe.com.viajes.bean.negocio.Parametro> listarParametros(Integer idEmpresa)
			throws SQLException {
		parametroDao = new ParametroDaoImpl();
		return parametroDao.listarParametros(idEmpresa);
	}

	@Override
	public void registrarParametro(
			pe.com.viajes.bean.negocio.Parametro parametro)
			throws SQLException {
		parametroDao = new ParametroDaoImpl();
		parametroDao.registrarParametro(parametro);
	}

	@Override
	public void actualizarParametro(
			pe.com.viajes.bean.negocio.Parametro parametro)
			throws SQLException {
		parametroDao = new ParametroDaoImpl();
		parametroDao.actualizarParametro(parametro);
	}

	@Override
	public Parametro consultarParametro(int id, Integer idEmpresa) throws SQLException {
		parametroDao = new ParametroDaoImpl();
		return parametroDao.consultarParametro(id, idEmpresa);
	}
}
