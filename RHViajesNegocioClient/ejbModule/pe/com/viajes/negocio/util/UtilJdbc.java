/**
 * 
 */
package pe.com.viajes.negocio.util;

import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Date;

import org.apache.commons.lang3.StringUtils;

/**
 * @author Edwin
 * 
 */
public class UtilJdbc {

	public static String obtenerCadena(ResultSet rs, String campo)
			throws SQLException {
		if (rs != null && StringUtils.isNotBlank(campo)) {
			return parseaCadena(rs.getString(campo));
		}
		return "";
	}

	public static int obtenerNumero(ResultSet rs, String campo)
			throws SQLException {
		if (rs != null && StringUtils.isNotBlank(campo)) {
			return rs.getInt(campo);
		}
		return 0;
	}

	public static Date obtenerFecha(ResultSet rs, String campo)
			throws SQLException {
		if (rs != null && StringUtils.isNotBlank(campo)) {
			return rs.getDate(campo);
		}
		return null;
	}

	public static Date obtenerFechaTimestamp(ResultSet rs, String campo)
			throws SQLException {
		if (rs != null && StringUtils.isNotBlank(campo)) {
			Timestamp fechaTimeStamp = rs.getTimestamp(campo);
			return new Date(fechaTimeStamp.getTime());
		}
		return null;
	}

	public static BigDecimal obtenerBigDecimal(ResultSet rs, String campo)
			throws SQLException {
		if (rs != null && StringUtils.isNotBlank(campo)) {
			return rs.getBigDecimal(campo);
		}
		return BigDecimal.ZERO;
	}

	public static boolean obtenerBoolean(ResultSet rs, String campo)
			throws SQLException {
		if (rs != null && StringUtils.isNotBlank(campo)) {
			return rs.getBoolean(campo);
		}
		return false;
	}

	public static boolean convertirBooleanSiNo(ResultSet rs, String campo)
			throws SQLException {
		String dato = obtenerCadena(rs, campo);
		return ("S".equals(dato));
	}

	public static String parseaCadena(String cadena) {
		if (StringUtils.isNotBlank(cadena)) {
			return cadena;
		}
		return "";
	}

	public static Integer parseCadenaEntero(String cadena) {
		if (StringUtils.isNotBlank(cadena)) {
			return Integer.valueOf(cadena);
		}
		return Integer.valueOf(0);
	}

	public static int obtenerNumero(Integer numero) {
		if (numero == null) {
			return 0;
		}
		return numero.intValue();
	}

	public static String convertirMayuscula(String cadena) {
		return StringUtils.upperCase(parseaCadena(cadena));
	}

	public static java.sql.Date convertirUtilDateSQLDate(java.util.Date fecha) {
		return new java.sql.Date(fecha.getTime());
	}

	public static Timestamp convertirUtilDateTimeStamp(java.util.Date fecha) {
		return new Timestamp(fecha.getTime());
	}

	public static boolean enteroNoNuloNoCero(Integer numero) {
		return (numero != null && numero.intValue() != 0);
	}

	public static String borrarEspacioMayusculas(String cadena) {
		cadena = StringUtils.normalizeSpace(cadena);
		cadena = cadena.replaceAll(" ", "");
		cadena = StringUtils.upperCase(cadena);

		return cadena;
	}

	public static boolean comparaNumero(Integer numero1, Integer numero2) {
		try {
			return (numero1.intValue() == numero2.intValue());
		} catch (NullPointerException e) {
			e.printStackTrace();
		}
		return false;
	}
}
