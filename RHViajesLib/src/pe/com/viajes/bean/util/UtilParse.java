/**
 * 
 */
package pe.com.viajes.bean.util;

import java.math.BigDecimal;

import org.apache.commons.lang3.StringUtils;

/**
 * @author Edwin
 *
 */
public class UtilParse {

	public static String parseCadena(String cadena) {
		if (StringUtils.isBlank(cadena)) {
			return "";
		}
		return cadena;
	}

	public static BigDecimal parseIntABigDecimal(int numero) {
		return BigDecimal.valueOf(numero);
	}

	public static BigDecimal parseStringABigDecimal(String numero) {
		Double val = Double.valueOf(numero);

		return BigDecimal.valueOf(val.doubleValue());
	}
}
