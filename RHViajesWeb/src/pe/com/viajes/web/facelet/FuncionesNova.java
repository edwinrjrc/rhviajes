/**
 * 
 */
package pe.com.viajes.web.facelet;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.List;
import java.util.Locale;
import java.util.StringTokenizer;

import org.apache.commons.lang3.StringUtils;

import pe.com.viajes.bean.base.BaseVO;

/**
 * @author Edwin
 *
 */
public class FuncionesNova {

	/**
	 * 
	 * @param codigoOpcion
	 * @param codigoRol
	 * @return
	 */
	public static boolean tienePermiso(String codigoOpcion, String codigoRol) {
		return (StringUtils.equals(codigoOpcion, codigoRol));
	}

	/**
	 * 
	 * @param codigoOpcion
	 * @param codigoRol
	 * @return
	 */
	public static boolean mostrarBotonesVenta1(List<BaseVO> roles,
			Integer estadoServicio, Integer tienePagos,
			boolean guardoComprobantes, String codigoRoles) {
		if (roles != null) {
			boolean resultado = validarPermisoRol(roles, codigoRoles);

			resultado = (resultado && !guardoComprobantes);

			return resultado;
		}
		return false;
	}

	/**
	 * 
	 * @param simboloMoneda
	 * @param monto
	 * @return
	 */
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

	/**
	 * 
	 * @param simboloMoneda
	 * @param monto
	 * @param montoAlternativo
	 * @return
	 */
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

	/**
	 * 
	 * @param roles
	 * @param codigoRoles
	 * @return
	 */
	public static boolean validarPermisoRol(List<BaseVO> roles,
			String codigoRoles) {
		StringTokenizer stk = new StringTokenizer(codigoRoles, ",");
		if (roles != null) {
			while (stk.hasMoreTokens()) {
				String c= (String) stk.nextElement();
				for (BaseVO rol : roles) {
					if (rol.getCodigoEntero().toString()
							.equals(c)) {
						return true;
					}
				}

			}
		}
		return false;
	}
}
