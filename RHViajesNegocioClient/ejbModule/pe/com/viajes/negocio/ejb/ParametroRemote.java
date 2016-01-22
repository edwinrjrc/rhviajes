package pe.com.viajes.negocio.ejb;

import java.sql.SQLException;
import java.util.List;

import javax.ejb.Remote;

import pe.com.viajes.bean.negocio.Parametro;

@Remote
public interface ParametroRemote {

	void registrarParametro(Parametro parametro) throws SQLException;

	void actualizarParametro(Parametro parametro) throws SQLException;

	List<Parametro> listarParametros(Integer idEmpresa) throws SQLException;

	Parametro consultarParametro(int id, Integer idEmpresa) throws SQLException;
}
