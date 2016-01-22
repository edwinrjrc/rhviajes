/**
 * 
 */
package pe.com.viajes.web.facelet;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.Locale;

import org.apache.commons.lang3.StringUtils;

/**
 * @author Edwin
 *
 */
public class FuncionesNova {

	public static boolean tienePermiso(String codigoOpcion, String codigoRol) {
		return (StringUtils.equals(codigoOpcion, codigoRol));
	}

	/**
	 * 
	 * @param codigoOpcion
	 * @param codigoRol
	 * @return
	 */
	public static boolean mostrarBotonesVenta1(Integer codigoRol,
			Integer estadoServicio, Integer tienePagos,
			boolean guardoComprobantes) {
		// boolean resultado = (codigoRol.intValue() == 3 &&
		// estadoServicio.intValue() ==2 && tienePagos.intValue()==0);
		boolean resultado = (codigoRol.intValue() == 3 && estadoServicio
				.intValue() == 2);

		resultado = (resultado && !guardoComprobantes);

		return resultado;
	}

	public static String formatearMonto(String simboloMoneda, Object monto) {
		String formateado = "";
		DecimalFormat formateador = new DecimalFormat("###,###,##0.00",
				new DecimalFormatSymbols(Locale.ENGLISH));
		if (monto instanceof BigDecimal) {
			formateado = formateador.format(((BigDecimal) monto).doubleValue());
			formateado = simboloMoneda + " " + formateado;
		}

		return formateado;
	}

	public static String formatearMonto2(String simboloMoneda, Object monto,
			Object montoAlternativo) {
		String formateado = "";
		BigDecimal montoFormateado = (BigDecimal) monto;
		if (montoAlternativo != null) {
			montoFormateado = (BigDecimal) montoAlternativo;
		}
		DecimalFormat formateador = new DecimalFormat("###,###,##0.00",
				new DecimalFormatSymbols(Locale.ENGLISH));
		formateado = formateador.format(((BigDecimal) montoFormateado)
				.doubleValue());
		formateado = simboloMoneda + " " + formateado;

		return formateado;
	}
}
