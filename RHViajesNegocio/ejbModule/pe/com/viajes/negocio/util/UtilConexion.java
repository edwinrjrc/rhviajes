/**
 * 
 */
package pe.com.viajes.negocio.util;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;

import pe.com.viajes.bean.util.UtilProperties;
import pe.com.viajes.negocio.exception.ConnectionException;

/**
 * @author Edwin
 *
 */
public class UtilConexion {

	private final static Logger logger = Logger.getLogger(UtilConexion.class);

	private static String JNDI = "java:/jboss/jdbc/rhviajesDS";

	/**
	 * 
	 * @return Connection
	 * @throws ConnectionException
	 */
	public static Connection obtenerConexion() {

		try {
			Context ic = new InitialContext();
			DataSource dataSource = null;

			String jndiProperties = getJndiProperties();

			if (StringUtils.isNotBlank(jndiProperties)) {
				dataSource = (DataSource) ic.lookup(jndiProperties);
			} else {
				dataSource = (DataSource) ic.lookup(JNDI);
			}

			return dataSource.getConnection();
		} catch (NamingException e) {
			logger.error(e.getMessage(), e);
			// throw new ConnectionException(e);
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
			// throw new ConnectionException(e);
		} catch (FileNotFoundException e) {
			logger.error(e.getMessage(), e);
			// throw new ConnectionException(e);
		} catch (IOException e) {
			logger.error(e.getMessage(), e);
			// throw new ConnectionException(e);
		}
		return null;
	}

	/**
	 * 
	 * @param jndi
	 * @return Connection
	 * @throws ConnectionException
	 */
	public static Connection obtenerConexion(String jndi) {
		try {

			jndi = (StringUtils.isBlank(jndi) ? JNDI : jndi);

			Context ic = new InitialContext();
			DataSource dataSource = (DataSource) ic.lookup(jndi);

			return dataSource.getConnection();
		} catch (NamingException e) {
			logger.error(e.getMessage(), e);
			// throw new ConnectionException(e);
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
			// throw new ConnectionException(e);
		}
		return null;
	}

	/**
	 * 
	 * @return String
	 * @throws FileNotFoundException
	 * @throws IOException
	 */
	public static String getJndiProperties() throws FileNotFoundException,
			IOException {
		Properties prop = UtilProperties
				.cargaArchivo("aplicacionConfiguracion.properties");

		String jndiProperties = prop.getProperty("jndi_ds");

		return jndiProperties;
	}

}
