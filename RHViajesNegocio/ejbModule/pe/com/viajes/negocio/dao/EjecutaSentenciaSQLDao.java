package pe.com.viajes.negocio.dao;

import java.sql.Connection;
import java.sql.SQLException;

public interface EjecutaSentenciaSQLDao {

	public abstract void ejecutarSentencia(String sql, Connection conn) throws SQLException;

	public abstract Object ejecutarConsulta(String sql, Connection conn) throws SQLException;

}