/**
 * 
 */
package pe.com.viajes.negocio.util;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.ResourceBundle;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.negocio.Comprobante;
import pe.com.viajes.bean.negocio.DetalleComprobante;
import pe.com.viajes.bean.negocio.DetalleServicioAgencia;
import pe.com.viajes.bean.negocio.Parametro;
import pe.com.viajes.bean.negocio.Pasajero;
import pe.com.viajes.bean.negocio.ServicioAgencia;
import pe.com.viajes.bean.util.UtilApp;
import pe.com.viajes.negocio.dao.ParametroDao;
import pe.com.viajes.negocio.dao.impl.ParametroDaoImpl;

/**
 * @author Edwin
 *
 */
public class UtilEjb extends UtilApp {

	private final static Logger logger = Logger.getLogger(UtilEjb.class);

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
			e.printStackTrace();
		}
		return 0;
	}

	public static String obtenerCadenaBlanco(String cadena) {
		if (StringUtils.isNotBlank(cadena)) {
			return StringUtils.trimToEmpty(cadena);
		}
		return "";
	}

	public static int convertirCadenaEntero(String cadena) {
		try {
			if (StringUtils.isNotBlank(cadena)) {
				return Integer.parseInt(cadena);
			}
		} catch (NumberFormatException e) {
			e.printStackTrace();
		}
		return 0;
	}

	public static BigDecimal convertirCadenaDecimal(String numero) {
		if (StringUtils.isNotBlank(numero)) {
			return BigDecimal.valueOf(Double.valueOf(numero));
		}
		return BigDecimal.ZERO;
	}

	public static List<Comprobante> obtenerNumeroComprobante(
			List<DetalleServicioAgencia> listaDetalle) {
		List<Comprobante> lista = new ArrayList<Comprobante>();
		Comprobante comprobante = new Comprobante();
		comprobante.setNumeroComprobante(listaDetalle.get(0)
				.getServiciosHijos().get(0).getNroComprobante());
		comprobante.setTipoComprobante(listaDetalle.get(0).getServiciosHijos()
				.get(0).getTipoComprobante());
		comprobante.setTieneDetraccion(listaDetalle.get(0).getServiciosHijos()
				.get(0).isTieneDetraccion());
		comprobante.setTieneRetencion(listaDetalle.get(0).getServiciosHijos()
				.get(0).isTieneRetencion());
		comprobante.setMoneda(listaDetalle.get(0).getMoneda());
		lista.add(comprobante);
		for (int s = 0; s < listaDetalle.size(); s++) {
			for (int i = 0; i < listaDetalle.get(s).getServiciosHijos().size(); i++) {
				DetalleServicioAgencia bean = listaDetalle.get(s)
						.getServiciosHijos().get(i);
				for (int r = 0; r < listaDetalle.size(); r++) {
					for (int j = 0; j < listaDetalle.get(r).getServiciosHijos()
							.size(); j++) {
						DetalleServicioAgencia bean2 = listaDetalle.get(r)
								.getServiciosHijos().get(j);
						if (!bean.getNroComprobante().equals(
								bean2.getNroComprobante())
								&& !estaEnListado(bean2.getNroComprobante(),
										lista)) {
							comprobante = new Comprobante();
							comprobante.setNumeroComprobante(bean2
									.getNroComprobante());
							comprobante.setTipoComprobante(bean2
									.getTipoComprobante());
							comprobante.setTieneDetraccion(bean2
									.isTieneDetraccion());
							comprobante.setTieneRetencion(bean2
									.isTieneRetencion());
							comprobante.setMoneda(bean2.getMoneda());
							lista.add(comprobante);
							comprobante = null;
						}
					}
				}
			}
		}

		return lista;
	}

	private static boolean estaEnListado(String numero, List<Comprobante> lista) {
		for (Comprobante comprobante : lista) {
			if (comprobante.getNumeroComprobante().equals(numero)) {
				return true;
			}
		}
		return false;
	}

	public static Comprobante obtenerDetalleComprobante(Comprobante comp,
			ServicioAgencia servicioAgencia) {
		try {
			BigDecimal total = BigDecimal.ZERO;
			BigDecimal totalIGV = BigDecimal.ZERO;
			ParametroDao parametroDao = new ParametroDaoImpl();
			Parametro param = parametroDao.consultarParametro(UtilEjb
					.obtenerEnteroPropertieMaestro("codigoParametroIGV",
							"aplicacionDatosEjb"), servicioAgencia.getEmpresa().getCodigoEntero());
			BaseVO tipoComprobante = null;
			DetalleComprobante detalle = null;
			DetalleServicioAgencia bean = null;
			for (int s = 0; s < servicioAgencia.getListaDetalleServicio()
					.size(); s++) {
				for (int i = 0; i < servicioAgencia
						.getListaDetalleServicioAgrupado().get(s)
						.getServiciosHijos().size(); i++) {
					bean = servicioAgencia.getListaDetalleServicioAgrupado()
							.get(s).getServiciosHijos().get(i);
					if (bean.getNroComprobante().equals(
							comp.getNumeroComprobante())) {
						detalle = new DetalleComprobante();
						if (bean.isAgrupado()) {
							for (Integer id : bean.getCodigoEnteroAgrupados()) {
								DetalleServicioAgencia beanAgrupado = obtenerDetalleIdAgrupado(
										id,
										servicioAgencia
												.getListaDetalleServicio());
								if (beanAgrupado == null) {
									continue;
								}
								total = total.add(bean.getTotalServicio());
								tipoComprobante = bean.getTipoComprobante();
								detalle = null;
								detalle = new DetalleComprobante();
								detalle.setIdServicioDetalle(id);
								detalle.setCantidad(beanAgrupado.getCantidad());
								detalle.setPrecioUnitario(beanAgrupado
										.getPrecioUnitario());
								detalle.setTotalDetalle(beanAgrupado
										.getTotalServicio());
								detalle.setConcepto(obtenerDescripcionServicio(
										id, servicioAgencia
												.getListaDetalleServicio()));
								detalle.setUsuarioCreacion(servicioAgencia
										.getUsuarioCreacion());
								detalle.setIpCreacion(servicioAgencia
										.getIpCreacion());
								comp.getDetalleComprobante().add(detalle);
							}
							if (bean.getTipoServicio().getCodigoEntero()
									.intValue() == UtilEjb
									.convertirCadenaEntero(param.getValor())) {
								totalIGV = totalIGV.add(bean
										.getPrecioUnitario());
							}
						} else {
							total = total.add(bean.getTotalServicio());
							tipoComprobante = bean.getTipoComprobante();
							detalle.setIdServicioDetalle(bean.getCodigoEntero());
							detalle.setCantidad(bean.getCantidad());
							detalle.setPrecioUnitario(bean.getPrecioUnitario());
							detalle.setTotalDetalle(bean.getTotalServicio());
							detalle.setConcepto(bean.getDescripcionServicio());
							detalle.setUsuarioCreacion(servicioAgencia
									.getUsuarioCreacion());
							detalle.setIpCreacion(servicioAgencia
									.getIpCreacion());
							comp.getDetalleComprobante().add(detalle);
							if (bean.getTipoServicio().getCodigoEntero()
									.intValue() == UtilEjb
									.convertirCadenaEntero(param.getValor())) {
								totalIGV = totalIGV.add(bean
										.getPrecioUnitario());
							}
						}
					}
				}
			}

			comp.setTitular(servicioAgencia.getCliente());
			comp.setFechaComprobante(servicioAgencia.getFechaServicio());
			comp.setTipoComprobante(tipoComprobante);
			comp.setTotalComprobante(total);
			comp.setTotalIGV(totalIGV);
			comp.setUsuarioCreacion(servicioAgencia.getUsuarioCreacion());
			comp.setIpCreacion(servicioAgencia.getIpCreacion());
			comp.setIdServicio(servicioAgencia.getCodigoEntero());
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return comp;
	}

	private static DetalleServicioAgencia obtenerDetalleIdAgrupado(
			Integer idAgrupado, List<DetalleServicioAgencia> listaDetalleTotal) {
		if (listaDetalleTotal != null && !listaDetalleTotal.isEmpty()) {
			for (DetalleServicioAgencia detalleServicioAgencia : listaDetalleTotal) {
				if (detalleServicioAgencia.getServiciosHijos() != null
						&& !detalleServicioAgencia.getServiciosHijos()
								.isEmpty()) {
					for (DetalleServicioAgencia detalleServicioHijo : detalleServicioAgencia
							.getServiciosHijos()) {
						if (detalleServicioHijo.getCodigoEntero().intValue() == idAgrupado
								.intValue()) {
							return detalleServicioHijo;
						}
					}
				}
			}
		}
		return null;
	}

	private static String obtenerDescripcionServicio(Integer id,
			List<DetalleServicioAgencia> lista) {

		if (lista != null && !lista.isEmpty() && id != null) {
			for (DetalleServicioAgencia detalleServicioAgencia : lista) {
				if (detalleServicioAgencia.getServiciosHijos() != null
						&& !detalleServicioAgencia.getServiciosHijos()
								.isEmpty()) {
					for (DetalleServicioAgencia detalleServicioHijo : detalleServicioAgencia
							.getServiciosHijos()) {
						if (detalleServicioHijo.getCodigoEntero().intValue() == id
								.intValue()) {
							return detalleServicioHijo.getDescripcionServicio();
						}
					}
				}
			}
		}

		return "";
	}

	public static boolean correoValido(String correo) {
		try {
			String patternEmail = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@"
					+ "[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";
			Pattern pattern = Pattern.compile(patternEmail);
			Matcher matcher = pattern.matcher(correo);

			boolean resultado = matcher.matches();

			return resultado;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	public static List<DetalleServicioAgencia> ordenarServiciosVenta(
			List<DetalleServicioAgencia> listaServicio) throws SQLException,
			Exception {

		Collections.sort(listaServicio,
				new Comparator<DetalleServicioAgencia>() {
					@Override
					public int compare(DetalleServicioAgencia s1,
							DetalleServicioAgencia s2) {

						if (s1.getFechaIda().before(s2.getFechaIda())) {
							return -1;
						}
						if (s1.getFechaIda().after(s2.getFechaIda())) {
							return 1;
						}
						return 0;
					}
				});

		return listaServicio;
	}

	public static String generaSentenciaFuncion(String nombreFuncion,
			int numeroParametros) {
		String sql = "";

		sql = "{ ? = call ";
		sql = sql + nombreFuncion + "(";
		sql = sql + completarParametrosSQL(numeroParametros);
		sql = sql + ")}";

		logger.info(sql);

		return sql;
	}

	public static String completarParametrosSQL(int numeroParametros) {
		String parametros = "";

		parametros = completarCaracter(parametros, "?,", numeroParametros, "D");
		parametros = parametros.substring(0, (parametros.length() - 1));

		return parametros;
	}

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
	
	public static InputStream convertirByteArrayAInputStream(byte[] arreglo){
		ByteArrayInputStream bis = new ByteArrayInputStream(arreglo);
		
		return (InputStream)bis;
	}
	
	public static String listaPasajerosString(List<Pasajero> lista){
		String pasajeros = "";
		for (Pasajero pasajero : lista) {
			pasajeros = pasajeros + pasajero.getNombreCompleto() + "("+pasajero.getNumeroBoleto()+")\n";
		}
		return pasajeros;
	}
}
