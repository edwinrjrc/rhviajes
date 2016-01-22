/**
 * 
 */
package pe.com.viajes.web.util;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.ResourceBundle;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.faces.model.SelectItem;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.apache.poi.hssf.usermodel.HSSFCell;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.negocio.Ruta;
import pe.com.viajes.bean.negocio.Tramo;

/**
 * @author Edwin
 *
 */
public class UtilWeb {

	private final static Logger logger = Logger.getLogger(UtilWeb.class);

	public static List<SelectItem> convertirSelectItem(List<BaseVO> lista) {
		List<SelectItem> listaCombo = new ArrayList<SelectItem>();
		SelectItem si = null;
		if (lista != null) {
			for (BaseVO baseVO : lista) {
				si = new SelectItem(obtenerObjetoCadena(baseVO),
						baseVO.getNombre());
				listaCombo.add(si);
			}
		}

		return listaCombo;
	}

	public static String obtenerObjetoCadena(BaseVO baseVO) {
		if (baseVO.getCodigoEntero() != null) {
			return baseVO.getCodigoEntero().toString();
		} else {
			return baseVO.getCodigoCadena();
		}
	}

	public static int convertirCadenaEntero(String cadena) {
		try {
			if (StringUtils.isNotBlank(cadena)) {
				return Integer.parseInt(cadena);
			}
		} catch (NumberFormatException e) {
			logger.error(e.getMessage(), e);
		}
		return 0;
	}

	public static String obtenerCadenaPropertieMaestro(String llave,
			String maestroPropertie) {
		try {
			ResourceBundle resourceMaestros = ResourceBundle
					.getBundle(maestroPropertie);

			return resourceMaestros.getString(llave);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return "";
	}

	public static int obtenerEnteroPropertieMaestro(String llave,
			String maestroPropertie) {
		try {
			ResourceBundle resourceMaestros = ResourceBundle
					.getBundle(maestroPropertie);

			return convertirCadenaEntero(resourceMaestros.getString(llave));
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
		}
		return 0;
	}

	public static String obtenerCadenaBlanco(String cadena) {
		if (StringUtils.isNotBlank(cadena)) {
			return StringUtils.trimToEmpty(cadena);
		}
		return "";
	}

	public static int obtenerLongitud(String cadena) {
		if (StringUtils.isNotBlank(cadena)) {
			return cadena.length();
		}
		return 0;
	}

	/**
	 * Nombre de la semana de la fecha de hoy
	 * @return
	 */
	public static String diaHoy() {
		Calendar cal = Calendar.getInstance();

		switch (cal.get(Calendar.DAY_OF_WEEK)) {
		case 2:
			return "Lunes";
		case 3:
			return "Martes";
		case 4:
			return "Miercoles";
		case 5:
			return "Jueves";
		case 6:
			return "Viernes";
		case 7:
			return "Sabado";
		case 1:
			return "Domingo";
		}

		return "";
	}
	
	/**
	 * Devuelve el valor de dia de la fecha de hoy
	 * @return
	 */
	public static String diaFechaHoy() {
		Calendar cal = Calendar.getInstance();

		String valor = Integer.valueOf(cal.get(Calendar.DATE)).toString();
		
		return completarCaracter(valor, "0", 2, "I");
	}
	
	public static String anioFechaHoy() {
		Calendar cal = Calendar.getInstance();

		String valor = Integer.valueOf(cal.get(Calendar.YEAR)).toString();
		
		return valor;
	}
	
	public static String anioFechaHoyYY() {
		Date fecha = new Date();
		SimpleDateFormat sdf = new SimpleDateFormat("yy");
		
		return sdf.format(fecha);
	}

	/**
	 * Nombre del mes de la fecha de hoy
	 * @return
	 */
	public static String mesHoy() {
		Calendar cal = Calendar.getInstance();

		switch (cal.get(Calendar.MONTH) + 1) {
		case 1:
			return "Enero";
		case 2:
			return "Febrero";
		case 3:
			return "Marzo";
		case 4:
			return "Abril";
		case 5:
			return "Mayo";
		case 6:
			return "Junio";
		case 7:
			return "Julio";
		case 8:
			return "Agosto";
		case 9:
			return "Septiembre";
		case 10:
			return "Octubre";
		case 11:
			return "Noviembre";
		case 12:
			return "Diciembre";
		}

		return "";
	}
	
	/**
	 * Numero del mes completo, ejm. 01, 03, 10, 12
	 * @return
	 */
	public static String mesHoyNumero() {
		Calendar cal = Calendar.getInstance();

		String mes = "";
		mes = Integer.valueOf(cal.get(Calendar.MONTH) + 1).toString();
		mes = completarCaracter(mes,"0",2,"I");
		
		return mes;
	}
	
	/**
	 * Completa caracteres segun la cantidad y la direccion
	 * 
	 * @param cadena
	 * @param caracter
	 * @param cantidad
	 * @param direccion
	 * @return
	 */
	public static String completarCaracter(String cadena, String caracter,
			int cantidad, String direccion) {
		if ("D".equals(direccion)) {
			String cadenaNueva = cadena;
			int i = 0;
			while ((cadena.length() + i) < cantidad) {
				cadenaNueva = cadenaNueva + caracter;
				i++;
			}
			return cadenaNueva;
		} else if ("I".equals(direccion)) {
			String cadenaNueva = cadena;
			int i = 0;
			while ((cadena.length() + i) < cantidad) {
				cadenaNueva = caracter + cadenaNueva;
				i++;
			}
			return cadenaNueva;
		}
		return cadena;
	}

	public static boolean validaEnteroEsNuloOCero(Integer numero) {
		try {
			return (numero == null || numero.intValue() == 0);

		} catch (Exception e) {
			logger.error("Error validacion numero cero o nullo ::"
					+ e.getMessage());
		}

		return false;
	}

	public static boolean validarCorreo(String email) {
		try {
			String patternEmail = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@"
					+ "[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";
			Pattern pattern = Pattern.compile(patternEmail);
			Matcher matcher = pattern.matcher(email);

			boolean resultado = matcher.matches();

			return resultado;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	public static boolean fecha1EsMayorIgualFecha2(Date fecha1, Date fecha2) {
		SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/YYYY");
		if (sdf.format(fecha1).equals(sdf.format(fecha2))) {
			return true;
		} else {
			if (fecha1.after(fecha2)) {
				return true;
			}
		}

		return false;
	}

	public static Date fechaHoy() {
		try {
			SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
			String fecha = "";

			Calendar cal = Calendar.getInstance();
			fecha = cal.get(Calendar.DATE) + "/"
					+ (cal.get(Calendar.MONTH) + 1) + "/"
					+ cal.get(Calendar.YEAR);

			return sdf.parse(fecha);
		} catch (ParseException e) {
			e.printStackTrace();
		}
		return null;
	}
	
	public static String fechaHoy(String pattern) {
		SimpleDateFormat sdf = new SimpleDateFormat(pattern);

		return sdf.format(new Date());
	}

	public static String obtenerDato(HSSFCell celda) {
		if (celda != null) {
			/*
			 * 
			 * switch (celda.getCellType()) { case HSSFCell.CELL_TYPE_BLANK:
			 * return ""; case HSSFCell.CELL_TYPE_NUMERIC: return
			 * String.valueOf(celda.getNumericCellValue()); case
			 * HSSFCell.CELL_TYPE_STRING: return celda.getStringCellValue();
			 * default: return ""; }
			 */
			return celda.toString();
		}
		return "";
	}

	public static int calculaTamanioExcel(int pixeles) {
		BigDecimal tamanio = BigDecimal.ZERO;

		tamanio = BigDecimal.valueOf(pixeles).divide(BigDecimal.valueOf(7.0),
				0, RoundingMode.HALF_UP);

		tamanio = tamanio.multiply(BigDecimal.valueOf(256.0));

		return tamanio.intValue();
	}
	
	public static String rutaCorta(Ruta ruta){
		String rutaCorta = "";
		int i=0;
		if (ruta != null && !ruta.getTramos().isEmpty()){
			for (Tramo tramo : ruta.getTramos()) {
				if (i == 0){
					rutaCorta = tramo.getOrigen().getDescripcion() +"/" + tramo.getDestino().getDescripcion();
				}
				else{
					rutaCorta = rutaCorta + tramo.getDestino().getDescripcion() + "/";
				}
				i++;
			}
		}
		
		return rutaCorta;
	}
	
	public static String nvl(String valor1, String valor2){
		if (StringUtils.isNotBlank(valor1)){
			return valor1;
		}
		return valor2;
	}
}
