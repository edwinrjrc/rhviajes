package pe.com.viajes.negocio.ejb;

import java.sql.SQLException;
import java.util.List;

import javax.ejb.Local;

import pe.com.viajes.bean.negocio.Parametro;

@Local
public interface ParametroLocal {

	List<Parametro> listarParametros(Integer idEmpresa) throws SQLException;

	void registrarParametro(Parametro parametro) throws SQLException;

	void actualizarParametro(Parametro parametro) throws SQLException;

	Parametro consultarParametro(int id, Integer idEmpresa) throws SQLException;
}
