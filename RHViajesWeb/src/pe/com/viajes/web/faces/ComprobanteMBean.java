/**
 * 
 */
package pe.com.viajes.web.faces;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Properties;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;
import javax.naming.NamingException;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletResponse;

import net.sf.jasperreports.engine.JRException;
import net.sf.jasperreports.engine.JasperFillManager;
import net.sf.jasperreports.engine.JasperPrint;
import net.sf.jasperreports.engine.data.JRBeanCollectionDataSource;
import net.sf.jasperreports.engine.export.JRPdfExporter;
import net.sf.jasperreports.export.SimpleExporterInput;
import net.sf.jasperreports.export.SimpleOutputStreamExporterOutput;
import net.sf.jasperreports.export.SimplePdfExporterConfiguration;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import pe.com.viajes.bean.negocio.Cliente;
import pe.com.viajes.bean.negocio.Comprobante;
import pe.com.viajes.bean.negocio.ComprobanteBusqueda;
import pe.com.viajes.bean.negocio.DetalleComprobante;
import pe.com.viajes.bean.negocio.Direccion;
import pe.com.viajes.bean.negocio.Pasajero;
import pe.com.viajes.bean.negocio.Proveedor;
import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.bean.util.UtilProperties;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;
import pe.com.viajes.web.servicio.ConsultaNegocioServicio;
import pe.com.viajes.web.servicio.UtilNegocioServicio;
import pe.com.viajes.web.servicio.impl.ConsultaNegocioServicioImpl;
import pe.com.viajes.web.servicio.impl.UtilNegocioServicioImpl;
import pe.com.viajes.web.util.UtilConvertirNumeroLetras;
import pe.com.viajes.web.util.UtilWeb;

/**
 * @author EDWREB
 *
 */
@ManagedBean(name = "comprobanteMBean")
@SessionScoped()
public class ComprobanteMBean extends BaseMBean implements ComprobanteInterface {

	private final static Logger logger = Logger
			.getLogger(ComprobanteMBean.class);

	private static final long serialVersionUID = 3796481899238208609L;

	private ComprobanteBusqueda comprobanteBusqueda;
	private Comprobante comprobanteDetalle;

	private Proveedor proveedor;

	private List<Comprobante> listaComprobantes;
	private List<Proveedor> listadoProveedores;
	
	private boolean documentoCobranza;
	private boolean factura;
	private boolean boleta;

	// private NegocioServicio negocioServicio;
	private ConsultaNegocioServicio consultaNegocioServicio;
	private UtilNegocioServicio utilNegocioServicio;
	
	private static String TIPO_EXPORTA_IMPRESION = "I";
	private static String TIPO_EXPORTA_DIGITAL   = "D";

	/**
	 * 
	 */
	public ComprobanteMBean() {
		try {
			ServletContext servletContext = (ServletContext) FacesContext
					.getCurrentInstance().getExternalContext().getContext();
			// negocioServicio = new NegocioServicioImpl(servletContext);
			consultaNegocioServicio = new ConsultaNegocioServicioImpl(
					servletContext);
			utilNegocioServicio = new UtilNegocioServicioImpl(servletContext);
		} catch (NamingException e) {
			logger.error(e.getMessage(), e);
		}
	}

	public void buscar() {
		try {
			getComprobanteBusqueda().setEmpresa(this.obtenerEmpresa());
			this.setListaComprobantes(this.consultaNegocioServicio
					.consultarComprobantesGenerados(getComprobanteBusqueda()));
			this.setDocumentoCobranza(false);
			this.setFactura(false);
			this.setBoleta(false);
		} catch (ErrorConsultaDataException e) {
			logger.error(e.getMessage(), e);
		}
	}

	public void buscarProveedor() {

	}

	public void seleccionarProveedor() {
		for (Proveedor proveedor : this.listadoProveedores) {
			if (proveedor.getCodigoEntero().equals(
					proveedor.getCodigoSeleccionado())) {
				this.getComprobanteBusqueda().setProveedor(proveedor);
				break;
			}
		}
	}

	public void consultarComprobante(Integer idComprobante) {
		try {
			this.setComprobanteDetalle(null);
			this.setComprobanteDetalle(this.consultaNegocioServicio
					.consultarComprobanteGenerado(idComprobante,
							this.obtenerIdEmpresa()));
			
			this.setDocumentoCobranza(this.getComprobanteDetalle().getTipoComprobante()
					.getCodigoEntero().intValue() == UtilWeb
					.obtenerEnteroPropertieMaestro(
							"comprobanteDocumentoCobranza", "aplicacionDatos"));
			this.setFactura(this.getComprobanteDetalle().getTipoComprobante()
					.getCodigoEntero().intValue() == UtilWeb
					.obtenerEnteroPropertieMaestro("comprobanteFactura",
							"aplicacionDatos"));
			this.setBoleta(this.getComprobanteDetalle().getTipoComprobante()
					.getCodigoEntero().intValue() == UtilWeb
					.obtenerEnteroPropertieMaestro("comprobanteBoleta",
							"aplicacionDatos"));
		} catch (ErrorConsultaDataException e) {
			e.printStackTrace();
		}
	}

	public void generarComprobante() {
		Connection conn = null;
		try {
			Properties prop = UtilProperties
					.cargaArchivo("aplicacionConfiguracion.properties");
			String ruta = prop.getProperty("ruta.formatos.excel.comprobantes");
			Usuario usuario = this.obtenerUsuarioSession();
			String nombreDominio = usuario.getNombreDominioEmpresa();
			ruta = ruta + nombreDominio;
			
			conn = UtilWeb.obtenerConexion();

			// FACTURA
			if (this.isFactura()) {
				String plantilla = ruta + File.separator
						+ "fc-plantilla.jasper";
				File archivo = new File(plantilla);
				InputStream streamJasper = new FileInputStream(archivo);

				/**
				 * Inicio data de factura
				 */
				HttpServletResponse response = obtenerResponse();
				response.setHeader("Content-Type", "application/pdf");
				response.setHeader("Content-Transfer-Encoding", "binary");
				response.setHeader("Content-disposition","attachment;filename=factura.pdf");
				OutputStream stream = response.getOutputStream();
				imprimirPDFFactura(this.enviarParametrosFactura(), stream, streamJasper);
				/* this.dataFactura(hoja1, archivoExcel); */
				/**
				 * Fin data de factura
				 */
			}
			// BOLETA
			else if (this.isBoleta()) {
				String plantilla = ruta + File.separator
						+ "bl-plantilla.jasper";
				File archivo = new File(plantilla);
				InputStream streamJasper = new FileInputStream(archivo);

				/**
				 * Inicio data de documento de cobranza
				 */
				HttpServletResponse response = obtenerResponse();
				response.setHeader("Content-Type", "application/pdf");
				response.setHeader("Content-Transfer-Encoding", "binary");
				response.setHeader("Content-disposition","attachment;filename=documentoCobranza.pdf");
				OutputStream stream = response.getOutputStream();
				//imprimirPDFDocumentoCobranza(this.enviarParametrosDocumentoCobranza(), stream, streamJasper);
				/**
				 * Fin data documento de cobranza
				 */
			}
			// DOCUMENTO DE COBRANZA
			else if (this.isDocumentoCobranza()) {
				String plantilla = ruta + File.separator
						+ "dc-plantilla.jasper";
				File archivo = new File(plantilla);
				InputStream streamJasper = new FileInputStream(archivo);

				/**
				 * Inicio data de documento de cobranza
				 */
				HttpServletResponse response = obtenerResponse();
				response.setHeader("Content-Type", "application/pdf");
				response.setHeader("Content-Transfer-Encoding", "binary");
				response.setHeader("Content-disposition","attachment;filename=documentoCobranza.pdf");
				OutputStream stream = response.getOutputStream();
				imprimirPDFDocumentoCobranza(this.enviarParametrosDocumentoCobranza(ruta,this.TIPO_EXPORTA_IMPRESION,conn), stream, streamJasper);
				/**
				 * Fin data documento de cobranza
				 */
			}

			/**
			 * Inicio datos de excel
			 */
		} catch (IOException e) {
			// TODO Auto-generated catch block
			logger.error(e.getMessage(), e);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			logger.error(e.getMessage(), e);
		} finally{
			if (conn != null){
				try {
					conn.close();
				} catch (SQLException e) {
					logger.error(e.getMessage(), e);
				}
			}
		}
	}
	
	public void generarComprobanteDigital(){
		Connection conn = null;
		try {
			Properties prop = UtilProperties
					.cargaArchivo("aplicacionConfiguracion.properties");
			String ruta = prop.getProperty("ruta.formatos.excel.comprobantes");
			Usuario usuario = this.obtenerUsuarioSession();
			String nombreDominio = usuario.getNombreDominioEmpresa();
			ruta = ruta + nombreDominio;
			
			conn = UtilWeb.obtenerConexion();

			// FACTURA
			if (this.isFactura()) {
				String plantilla = ruta + File.separator
						+ "fc-plantilla.jasper";
				File archivo = new File(plantilla);
				InputStream streamJasper = new FileInputStream(archivo);

				/**
				 * Inicio data de factura
				 */
				HttpServletResponse response = obtenerResponse();
				response.setHeader("Content-Type", "application/pdf");
				response.setHeader("Content-Transfer-Encoding", "binary");
				response.setHeader("Content-disposition","attachment;filename=factura.pdf");
				OutputStream stream = response.getOutputStream();
				imprimirPDFFactura(this.enviarParametrosFactura(), stream, streamJasper);
				/* this.dataFactura(hoja1, archivoExcel); */
				/**
				 * Fin data de factura
				 */
			}
			// BOLETA
			else if (this.isBoleta()) {
				String plantilla = ruta + File.separator
						+ "bl-plantilla.jasper";
				File archivo = new File(plantilla);
				InputStream streamJasper = new FileInputStream(archivo);

				/**
				 * Inicio data de documento de cobranza
				 */
				HttpServletResponse response = obtenerResponse();
				response.setHeader("Content-Type", "application/pdf");
				response.setHeader("Content-Transfer-Encoding", "binary");
				response.setHeader("Content-disposition","attachment;filename=documentoCobranza.pdf");
				OutputStream stream = response.getOutputStream();
				//imprimirPDFDocumentoCobranza(this.enviarParametrosDocumentoCobranza(), stream, streamJasper);
				/**
				 * Fin data documento de cobranza
				 */
			}
			// DOCUMENTO DE COBRANZA
			else if (this.isDocumentoCobranza()) {
				String plantilla = ruta + File.separator
						+ "dc-digital.jasper";
				File archivo = new File(plantilla);
				InputStream streamJasper = new FileInputStream(archivo);

				/**
				 * Inicio data de documento de cobranza
				 */
				HttpServletResponse response = obtenerResponse();
				response.setHeader("Content-Type", "application/pdf");
				response.setHeader("Content-Transfer-Encoding", "binary");
				response.setHeader("Content-disposition","attachment;filename=documentoCobranzaDigital.pdf");
				OutputStream stream = response.getOutputStream();
				imprimirPDFDocumentoCobranza(this.enviarParametrosDocumentoCobranza(ruta,this.TIPO_EXPORTA_DIGITAL, conn), stream, streamJasper);
				/**
				 * Fin data documento de cobranza
				 */
			}

			/**
			 * Inicio datos de excel
			 */
		} catch (IOException e) {
			// TODO Auto-generated catch block
			logger.error(e.getMessage(), e);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			logger.error(e.getMessage(), e);
		} finally{
			if (conn != null){
				try {
					conn.close();
				} catch (SQLException e) {
					logger.error(e.getMessage(), e);
				}
			}
		}
		
		
	}

	private HSSFSheet configuracionDocumentoCobranza(HSSFSheet hoja1) {
		HSSFRow fila = null;
		for (int i = 0; i < 30; i++) {
			fila = hoja1.createRow(i);
			fila.createCell(0);
			if (i == 0) {
				for (int j = 0; j < 10; j++) {
					fila.createCell(j);
				}
			}
		}

		hoja1.setColumnWidth(0, 2800);
		hoja1.setColumnWidth(1, 2500);
		hoja1.setColumnWidth(2, 2940);
		hoja1.setColumnWidth(3, 2940);
		hoja1.setColumnWidth(4, 2940);
		hoja1.setColumnWidth(5, 2050);
		hoja1.setColumnWidth(6, 1975);
		hoja1.setColumnWidth(7, 2940);
		hoja1.setColumnWidth(8, 2940);
		hoja1.setColumnWidth(9, 2940);
		hoja1.setColumnWidth(10, 2940);
		hoja1.setColumnWidth(11, 2940);

		fila = hoja1.getRow(0);
		fila.setHeightInPoints((float) 15.00);
		fila = hoja1.getRow(1);
		fila.setHeightInPoints((float) 15.00);
		fila = hoja1.getRow(2);
		fila.setHeightInPoints((float) 15.00);
		fila = hoja1.getRow(3);
		fila.setHeightInPoints((float) 15.00);
		fila = hoja1.getRow(4);
		fila.setHeightInPoints((float) 18.75);
		fila = hoja1.getRow(5);
		fila.setHeightInPoints((float) 18.75);
		fila = hoja1.getRow(6);
		fila.setHeightInPoints((float) 15.00);
		fila = hoja1.getRow(7);
		fila.setHeightInPoints((float) 13.50);
		fila = hoja1.getRow(8);
		fila.setHeightInPoints((float) 10.50);
		for (int i = 9; i <= 22; i++) {
			fila = hoja1.getRow(i);
			fila.setHeightInPoints((float) 15.00);
		}
		fila = hoja1.getRow(19);
		fila.setHeightInPoints((float) 10.50);

		CellRangeAddress region = new CellRangeAddress(6, 6, 0, 1);
		hoja1.addMergedRegion(region);
		CellRangeAddress region2 = new CellRangeAddress(6, 6, 2, 5);
		hoja1.addMergedRegion(region2);
		CellRangeAddress region3 = new CellRangeAddress(7, 7, 2, 6);
		hoja1.addMergedRegion(region3);

		for (int i = 12; i <= 18; i++) {
			hoja1.addMergedRegion(new CellRangeAddress(i, i, 1, 6));
		}
		hoja1.addMergedRegion(new CellRangeAddress(21, 21, 0, 6));

		return hoja1;
	}

	private HSSFSheet configuracionBoletaVenta(HSSFSheet hoja1) {
		HSSFRow fila = null;
		for (int i = 0; i < 30; i++) {
			fila = hoja1.createRow(i);
			fila.createCell(0);
			if (i == 0) {
				for (int j = 0; j < 10; j++) {
					fila.createCell(j);
				}
			}
		}

		/**
		 * Configuracion de columnas
		 */
		hoja1.setColumnWidth(0, 2800);
		hoja1.setColumnWidth(1, 1825);
		hoja1.setColumnWidth(2, 2940);
		hoja1.setColumnWidth(3, 2940);
		hoja1.setColumnWidth(4, 2940);
		hoja1.setColumnWidth(5, 2940);
		hoja1.setColumnWidth(6, 3875);
		hoja1.setColumnWidth(7, 2940);
		hoja1.setColumnWidth(8, 2940);
		hoja1.setColumnWidth(9, 2940);
		hoja1.setColumnWidth(10, 2940);
		hoja1.setColumnWidth(11, 2940);
		/**
		 * Fin de configuracion de columnas
		 */

		/**
		 * Configuracion de filas
		 */
		fila = hoja1.getRow(0);
		fila.setHeightInPoints((float) 15.00);
		fila = hoja1.getRow(1);
		fila.setHeightInPoints((float) 15.00);
		fila = hoja1.getRow(2);
		fila.setHeightInPoints((float) 15.00);
		fila = hoja1.getRow(3);
		fila.setHeightInPoints((float) 15.00);
		fila = hoja1.getRow(4);
		fila.setHeightInPoints((float) 27.00);
		fila = hoja1.getRow(5);
		fila.setHeightInPoints((float) 15.00);
		fila = hoja1.getRow(6);
		fila.setHeightInPoints((float) 11.25);
		fila = hoja1.getRow(7);
		fila.setHeightInPoints((float) 15.00);
		fila = hoja1.getRow(8);
		fila.setHeightInPoints((float) 15.00);
		fila = hoja1.getRow(9);
		fila.setHeightInPoints((float) 19.50);
		for (int i = 10; i <= 15; i++) {
			fila = hoja1.getRow(i);
			fila.setHeightInPoints((float) 15.00);
		}
		fila = hoja1.getRow(16);
		fila.setHeightInPoints((float) 14.25);
		fila = hoja1.getRow(17);
		fila.setHeightInPoints((float) 15.00);
		fila = hoja1.getRow(18);
		fila.setHeightInPoints((float) 17.25);
		fila = hoja1.getRow(19);
		fila.setHeightInPoints((float) 18.00);
		fila = hoja1.getRow(20);
		fila.setHeightInPoints((float) 10.50);
		fila = hoja1.getRow(21);
		fila.setHeightInPoints((float) 15.00);
		fila = hoja1.getRow(22);
		fila.setHeightInPoints((float) 9.00);
		fila = hoja1.getRow(23);
		fila.setHeightInPoints((float) 15.00);
		/**
		 * Fin de configuracion de filas
		 */

		CellRangeAddress region = new CellRangeAddress(5, 5, 1, 3);
		hoja1.addMergedRegion(region);
		CellRangeAddress region2 = new CellRangeAddress(7, 7, 0, 4);
		hoja1.addMergedRegion(region2);
		CellRangeAddress region3 = new CellRangeAddress(9, 9, 6, 7);
		hoja1.addMergedRegion(region3);

		for (int i = 13; i <= 18; i++) {
			hoja1.addMergedRegion(new CellRangeAddress(i, i, 2, 6));
		}
		hoja1.addMergedRegion(new CellRangeAddress(19, 20, 1, 6));

		hoja1.addMergedRegion(new CellRangeAddress(22, 23, 1, 6));

		hoja1.addMergedRegion(new CellRangeAddress(21, 23, 7, 7));

		return hoja1;
	}

	private HSSFSheet configuracionFactura(HSSFSheet hoja1) {
		HSSFRow fila = null;
		for (int i = 0; i < 30; i++) {
			fila = hoja1.createRow(i);
			fila.createCell(0);
			if (i == 0) {
				for (int j = 0; j < 10; j++) {
					fila.createCell(j);
				}
			}
		}

		/**
		 * Configuracion de columnas
		 */
		hoja1.setColumnWidth(0, 2500);
		hoja1.setColumnWidth(1, 3125);
		hoja1.setColumnWidth(2, 3600);
		hoja1.setColumnWidth(3, 2950);
		hoja1.setColumnWidth(4, 1800);
		hoja1.setColumnWidth(5, 2950);
		hoja1.setColumnWidth(6, 2950);
		hoja1.setColumnWidth(7, 2950);
		hoja1.setColumnWidth(8, 2950);
		hoja1.setColumnWidth(9, 2950);
		hoja1.setColumnWidth(10, 2950);
		hoja1.setColumnWidth(11, 2950);
		/**
		 * Fin de configuracion de columnas
		 */

		/**
		 * Configuracion de filas
		 */
		fila = hoja1.getRow(0);
		fila.setHeightInPoints((float) 15.00);
		fila = hoja1.getRow(1);
		fila.setHeightInPoints((float) 15.00);
		fila = hoja1.getRow(2);
		fila.setHeightInPoints((float) 15.00);
		fila = hoja1.getRow(3);
		fila.setHeightInPoints((float) 15.00);
		fila = hoja1.getRow(4);
		fila.setHeightInPoints((float) 23.25);
		fila = hoja1.getRow(5);
		fila.setHeightInPoints((float) 15.00);
		fila = hoja1.getRow(6);
		fila.setHeightInPoints((float) 11.25);
		fila = hoja1.getRow(7);
		fila.setHeightInPoints((float) 15.00);
		fila = hoja1.getRow(8);
		fila.setHeightInPoints((float) 17.25);
		fila = hoja1.getRow(9);
		fila.setHeightInPoints((float) 19.50);
		for (int i = 10; i <= 19; i++) {
			fila = hoja1.getRow(i);
			fila.setHeightInPoints((float) 15.00);
		}
		fila = hoja1.getRow(20);
		fila.setHeightInPoints((float) 10.50);
		fila = hoja1.getRow(21);
		fila.setHeightInPoints((float) 15.00);
		fila = hoja1.getRow(22);
		fila.setHeightInPoints((float) 15.00);
		fila = hoja1.getRow(23);
		fila.setHeightInPoints((float) 15.00);
		fila = hoja1.getRow(24);
		fila.setHeightInPoints((float) 31.50);
		/**
		 * Fin de configuracion de filas
		 */

		CellRangeAddress region = new CellRangeAddress(5, 5, 1, 2);
		hoja1.addMergedRegion(region);
		CellRangeAddress region2 = new CellRangeAddress(7, 7, 0, 4);
		hoja1.addMergedRegion(region2);
		region2 = new CellRangeAddress(7, 7, 6, 7);
		hoja1.addMergedRegion(region2);
		CellRangeAddress region3 = new CellRangeAddress(9, 9, 0, 6);
		hoja1.addMergedRegion(region3);

		for (int i = 13; i <= 18; i++) {
			hoja1.addMergedRegion(new CellRangeAddress(i, i, 1, 6));
		}
		hoja1.addMergedRegion(new CellRangeAddress(23, 23, 1, 6));
		hoja1.addMergedRegion(new CellRangeAddress(24, 25, 5, 5));
		hoja1.addMergedRegion(new CellRangeAddress(24, 25, 6, 6));
		hoja1.addMergedRegion(new CellRangeAddress(24, 25, 7, 7));

		return hoja1;
	}

	private void dataDocumentoCobranza(XSSFSheet hoja1,
			XSSFWorkbook archivoExcel) throws SQLException, Exception {
		int ultimaFila = hoja1.getLastRowNum();
		Cliente cliente = this.consultaNegocioServicio.consultarCliente(this
				.getComprobanteDetalle().getTitular().getCodigoEntero(),
				this.obtenerIdEmpresa());
		for (int i = 0; i <= ultimaFila; i++) {
			XSSFRow fila = hoja1.getRow(i);
			if (fila != null) {
				Integer vfinal = Integer.valueOf(fila.getLastCellNum());
				for (int j = 0; j < vfinal.intValue(); j++) {
					XSSFCell celda = fila.getCell(j);
					if (celda != null) {
						String valor = celda.getStringCellValue();
						if (NOMBRE_CLIENTE.equals(valor)) {
							celda.setCellValue(cliente.getNombreCompleto());
						} else if (DIRECCION_CLIENTE.equals(valor)) {
							List<Direccion> listaDirecciones = cliente
									.getListaDirecciones();
							if (listaDirecciones != null
									&& !listaDirecciones.isEmpty()) {
								celda.setCellValue(listaDirecciones.get(0)
										.getDireccion());
							}
						} else if (DOC_IDENTIDAD.equals(valor)) {
							String docIdentidad = cliente
									.getDocumentoIdentidad().getTipoDocumento()
									.getNombre()
									+ " - "
									+ cliente.getDocumentoIdentidad()
											.getNumeroDocumento();
							celda.setCellValue(docIdentidad);
						} else if (NUM_VENTA.equals(valor)) {
							celda.setCellValue(this.getComprobanteDetalle()
									.getIdServicio());
						} else if (FECHA_COMPRA.equals(valor)) {
							Calendar cal = Calendar.getInstance();
							cal.setTime(this.getComprobanteDetalle()
									.getFechaComprobante());

							String fecha = UtilWeb.completarCerosIzquierda(
									String.valueOf(cal.get(Calendar.DATE)), 2)
									+ "  "
									+ UtilWeb.completarCerosIzquierda(
											String.valueOf(cal
													.get(Calendar.MONTH) + 1),
											2)
									+ "    "
									+ cal.get(Calendar.YEAR);
							celda.setCellValue(fecha);
						} else if (TOTAL_DC.equals(valor)) {
							DecimalFormat df = new DecimalFormat("#,##0.00",
									new DecimalFormatSymbols(Locale.US));
							celda.setCellValue(this.getComprobanteDetalle()
									.getMoneda().getAbreviatura()
									+ " "
									+ df.format(this.getComprobanteDetalle()
											.getTotalComprobante()
											.doubleValue()));
						} else if (DETALLE_DOCUMENTO_COBRANZA.equals(valor)) {
							List<DetalleComprobante> listaDetalle = this
									.getComprobanteDetalle()
									.getDetalleComprobante();
							List<String> detalleComprobante = utilNegocioServicio
									.generarDetalleComprobanteImpresionDocumentoCobranza(
											listaDetalle, this
													.getComprobanteDetalle()
													.getIdServicio(), this
													.obtenerIdEmpresa());
							int z = 1;
							celda.setCellValue("");
							for (int a = 0; a < detalleComprobante.size(); a++) {
								String detaComprobante = detalleComprobante
										.get(a);
								celda = fila.getCell(1);
								if (celda == null) {
									celda = fila.createCell(1);
								}
								celda.setCellValue(detaComprobante);
								fila = hoja1.getRow(i + z);
								z++;
							}
						}
					}
				}
			}
		}
	}

	private void dataBoletaVenta(XSSFSheet hoja1, XSSFWorkbook archivoExcel)
			throws SQLException, Exception {
		int ultimaFila = hoja1.getLastRowNum();
		Cliente cliente = this.consultaNegocioServicio.consultarCliente(this
				.getComprobanteDetalle().getTitular().getCodigoEntero(),
				this.obtenerIdEmpresa());
		for (int i = 0; i <= ultimaFila; i++) {
			XSSFRow fila = hoja1.getRow(i);
			if (fila != null) {
				Integer vfinal = Integer.valueOf(fila.getLastCellNum());
				for (int j = 0; j < vfinal.intValue(); j++) {
					XSSFCell celda = fila.getCell(j);
					if (celda != null) {
						String valor = celda.getStringCellValue();
						if (NOMBRE_CLIENTE.equals(valor)) {
							celda.setCellValue(cliente.getNombreCompleto());
						} else if (DIRECCION_CLIENTE.equals(valor)) {
							List<Direccion> listaDirecciones = cliente
									.getListaDirecciones();
							if (listaDirecciones != null
									&& !listaDirecciones.isEmpty()) {
								celda.setCellValue(listaDirecciones.get(0)
										.getDireccion());
							}
						} else if (DOC_IDENTIDAD.equals(valor)) {
							String docIdentidad = cliente
									.getDocumentoIdentidad().getTipoDocumento()
									.getNombre()
									+ " - "
									+ cliente.getDocumentoIdentidad()
											.getNumeroDocumento();
							celda.setCellValue(docIdentidad);
						} else if (NUM_VENTA.equals(valor)) {
							celda.setCellValue(this.getComprobanteDetalle()
									.getIdServicio());
						} else if (FECHA_COMPRA.equals(valor)) {
							Calendar cal = Calendar.getInstance();
							cal.setTime(this.getComprobanteDetalle()
									.getFechaComprobante());

							String fecha = UtilWeb.completarCerosIzquierda(
									String.valueOf(cal.get(Calendar.DATE)), 2)
									+ "  "
									+ UtilWeb.completarCerosIzquierda(
											String.valueOf(cal
													.get(Calendar.MONTH) + 1),
											2)
									+ "    "
									+ cal.get(Calendar.YEAR);
							celda.setCellValue(fecha);
						} else if (TOTAL_BL.equals(valor)) {
							DecimalFormat df = new DecimalFormat("#,##0.00",
									new DecimalFormatSymbols(Locale.US));
							celda.setCellValue(this.getComprobanteDetalle()
									.getMoneda().getAbreviatura()
									+ " "
									+ df.format(this.getComprobanteDetalle()
											.getTotalComprobante()
											.doubleValue()));
						} else if (DETALLE_BOLETA.equals(valor)) {
							List<DetalleComprobante> listaDetalle = this
									.getComprobanteDetalle()
									.getDetalleComprobante();
							List<String> detalleComprobante = utilNegocioServicio
									.generarDetalleComprobanteImpresionBoleta(
											listaDetalle, this
													.getComprobanteDetalle()
													.getIdServicio(), this
													.obtenerIdEmpresa());
							int z = 1;
							celda.setCellValue("");
							for (int a = 0; a < detalleComprobante.size(); a++) {
								String detaComprobante = detalleComprobante
										.get(a);
								celda = fila.getCell(1);
								if (celda == null) {
									celda = fila.createCell(1);
								}
								celda.setCellValue(detaComprobante);
								fila = hoja1.getRow(i + z);
								z++;
							}
						}
					}
				}
			}
		}
	}

	private Map<String,Object> enviarParametrosFactura() {
		Map<String,Object> mapeo = new HashMap<String,Object>();
		
		Cliente cliente = null;
		try {
			cliente = this.consultaNegocioServicio.consultarCliente(this
					.getComprobanteDetalle().getTitular().getCodigoEntero(),
					this.obtenerIdEmpresa());
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
		}
		mapeo.put("p_nombrecliente", cliente.getNombreCompleto());
		mapeo.put("p_direccion", "");
		List<Direccion> listaDirecciones = cliente
				.getListaDirecciones();
		if (listaDirecciones != null
				&& !listaDirecciones.isEmpty()) {
			mapeo.put("p_direccion",listaDirecciones.get(0)
					.getDireccion());
		}
		mapeo.put("p_numeroruc", cliente
				.getDocumentoIdentidad()
				.getNumeroDocumento());
		
		Calendar cal = Calendar.getInstance();
		mapeo.put("p_diafecha", UtilWeb
				.completarCerosIzquierda(
						String.valueOf(cal
								.get(Calendar.DATE)),
						2));
		mapeo.put("p_mesfecha", UtilWeb.completarCerosIzquierda(
				String.valueOf(cal
						.get(Calendar.MONTH) + 1),
				2));
		String anio = String.valueOf(cal.get(Calendar.YEAR));
		mapeo.put("p_aniofecha", anio.substring(2));
		String montoLetras = UtilConvertirNumeroLetras
				.convertirNumeroALetras(this
						.getComprobanteDetalle()
						.getTotalComprobante()
						.doubleValue())
				+ " "
				+ this.getComprobanteDetalle().getMoneda()
						.getNombre();
		mapeo.put("p_montoletras",montoLetras);
		
		DecimalFormat df = new DecimalFormat("#,##0.00",
				new DecimalFormatSymbols(Locale.US));
		mapeo.put("p_montosubtotal", this.getComprobanteDetalle()
				.getMoneda().getAbreviatura()
				+ " "
				+ df.format(this.getComprobanteDetalle()
						.getSubTotal().doubleValue()));
		mapeo.put("p_montoigv", this.getComprobanteDetalle()
				.getMoneda().getAbreviatura()
				+ " "
				+ df.format(this.getComprobanteDetalle()
						.getTotalIGV().doubleValue()));
		mapeo.put("p_montototal", this.getComprobanteDetalle()
				.getMoneda().getAbreviatura()
				+ " "
				+ df.format(this.getComprobanteDetalle()
						.getTotalComprobante()
						.doubleValue()));
		
		return mapeo;
	}
	
	private Map<String,Object> enviarParametrosDocumentoCobranza(String ruta, String tipo, Connection conn) throws ErrorConsultaDataException {
		Map<String,Object> mapeo = new HashMap<String,Object>();
		
		Cliente cliente = null;
		try {
			cliente = this.consultaNegocioServicio.consultarCliente(this
					.getComprobanteDetalle().getTitular().getCodigoEntero(),
					this.obtenerIdEmpresa());
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
		}
		mapeo.put("p_numserie", "001");
		mapeo.put("p_numdocumento", UtilWeb.completarCerosIzquierda(this.getComprobanteDetalle().getNumeroComprobante(), 6));
		mapeo.put("p_nombrecliente", cliente.getNombreCompleto());
		mapeo.put("p_direccion", "");
		List<Direccion> listaDirecciones = cliente
				.getListaDirecciones();
		if (listaDirecciones != null
				&& !listaDirecciones.isEmpty()) {
			mapeo.put("p_direccion",listaDirecciones.get(0)
					.getDireccion());
		}
		mapeo.put("p_docidentidad", cliente
				.getDocumentoIdentidad().getTipoDocumento().getAbreviatura()+" - "+cliente
				.getDocumentoIdentidad()
				.getNumeroDocumento());
		
		Calendar cal = Calendar.getInstance();
		mapeo.put("p_diafecha", UtilWeb
				.completarCerosIzquierda(
						String.valueOf(cal
								.get(Calendar.DATE)),
						2));
		mapeo.put("p_mesfecha", UtilWeb.completarCerosIzquierda(
				String.valueOf(cal
						.get(Calendar.MONTH) + 1),
				2));
		String anio = String.valueOf(cal.get(Calendar.YEAR));
		mapeo.put("p_aniofecha", anio);
		
		DecimalFormat df = new DecimalFormat("#,##0.00",
				new DecimalFormatSymbols(Locale.US));
		mapeo.put("p_montototal", this.getComprobanteDetalle()
				.getMoneda().getAbreviatura()
				+ " "	
				+ df.format(this.getComprobanteDetalle()
						.getTotalComprobante()
						.doubleValue()));
		
		mapeo.put("p_idempresa", this.obtenerIdEmpresa());
		mapeo.put("p_idservicio", this.getComprobanteDetalle().getIdServicio());
		mapeo.put("SUBREPORT_DIR", ruta + File.separator);
		mapeo.put("REPORT_CONNECTION", conn);
		
		return mapeo;
	}

	private void dataFactura(XSSFSheet hoja1, XSSFWorkbook archivoExcel)
			throws SQLException, Exception {
		int ultimaFila = hoja1.getLastRowNum();
		Cliente cliente = this.consultaNegocioServicio.consultarCliente(this
				.getComprobanteDetalle().getTitular().getCodigoEntero(),
				this.obtenerIdEmpresa());
		for (int i = 0; i <= ultimaFila; i++) {
			XSSFRow fila = hoja1.getRow(i);
			if (fila != null) {
				Integer vfinal = Integer.valueOf(fila.getLastCellNum());
				for (int j = 0; j < vfinal.intValue(); j++) {
					XSSFCell celda = fila.getCell(j);
					if (celda != null) {
						String valor = celda.getStringCellValue();
						if (RAZON_SOCIAL.equals(valor)) {
							celda.setCellValue(cliente.getNombreCompleto());
						} else if (DIRECCION_CLIENTE.equals(valor)) {
							List<Direccion> listaDirecciones = cliente
									.getListaDirecciones();
							if (listaDirecciones != null
									&& !listaDirecciones.isEmpty()) {
								celda.setCellValue(listaDirecciones.get(0)
										.getDireccion());
							} else {
								celda.setCellValue("");
							}
						} else if (RUC_CLIENTE.equals(valor)) {
							String docIdentidad = cliente
									.getDocumentoIdentidad()
									.getNumeroDocumento();
							celda.setCellValue(docIdentidad);
						} else if (NUM_VENTA.equals(valor)) {
							celda.setCellValue(this.getComprobanteDetalle()
									.getIdServicio());
						} else if (FECHA_COMPRA.equals(valor)) {
							Calendar cal = Calendar.getInstance();
							cal.setTime(this.getComprobanteDetalle()
									.getFechaComprobante());

							String fecha = "          "
									+ UtilWeb
											.completarCerosIzquierda(
													String.valueOf(cal
															.get(Calendar.DATE)),
													2)
									+ "      "
									+ UtilWeb.completarCerosIzquierda(
											String.valueOf(cal
													.get(Calendar.MONTH) + 1),
											2) + "    "
									+ cal.get(Calendar.YEAR);
							celda.setCellValue(fecha);
						} else if (TOTAL_FC.equals(valor)) {
							DecimalFormat df = new DecimalFormat("#,##0.00",
									new DecimalFormatSymbols(Locale.US));
							celda.setCellValue(this.getComprobanteDetalle()
									.getMoneda().getAbreviatura()
									+ " "
									+ df.format(this.getComprobanteDetalle()
											.getTotalComprobante()
											.doubleValue()));
						} else if (TOTAL_FC_IGV.equals(valor)) {
							DecimalFormat df = new DecimalFormat("#,##0.00",
									new DecimalFormatSymbols(Locale.US));
							celda.setCellValue(this.getComprobanteDetalle()
									.getMoneda().getAbreviatura()
									+ " "
									+ df.format(this.getComprobanteDetalle()
											.getTotalIGV().doubleValue()));
						} else if (SUBTOTAL_FC.equals(valor)) {
							DecimalFormat df = new DecimalFormat("#,##0.00",
									new DecimalFormatSymbols(Locale.US));
							celda.setCellValue(this.getComprobanteDetalle()
									.getMoneda().getAbreviatura()
									+ " "
									+ df.format(this.getComprobanteDetalle()
											.getSubTotal().doubleValue()));
						} else if (TOTAL_FC_LETRAS.equals(valor)) {
							String montoLetras = UtilConvertirNumeroLetras
									.convertirNumeroALetras(this
											.getComprobanteDetalle()
											.getTotalComprobante()
											.doubleValue())
									+ " "
									+ this.getComprobanteDetalle().getMoneda()
											.getNombre();
							celda.setCellValue(montoLetras);
						} else if (DETALLE_FACTURA.equals(valor)) {
							List<Pasajero> listaPasajeros = utilNegocioServicio
									.consultarPasajerosServicio(this
											.getComprobanteDetalle()
											.getIdServicio(), this
											.obtenerIdEmpresa());
							int z = 1;
							celda.setCellValue("");
							for (Pasajero pasajero : listaPasajeros) {
								fila = hoja1.getRow(i + z);
								celda = fila.getCell(1);
								if (celda == null) {
									celda = fila.createCell(1);
								}
								celda.setCellValue(pasajero.getNombreCompleto());
								z++;
								celda = fila.getCell(4);
								if (celda == null) {
									celda = fila.createCell(4);
								}
								if (StringUtils.isBlank(pasajero
										.getNumeroBoleto())) {
									celda.setCellValue("");
								} else {
									celda.setCellValue("Tkt: "
											+ pasajero.getNumeroBoleto());
								}

							}
						}
					}
				}
			}
		}
	}

	private void imprimirPDFFactura(Map<String, Object> map,
			OutputStream outputStream, InputStream jasperStream)
			throws JRException {
		List<JasperPrint> printList = new ArrayList<JasperPrint>();

		try {
			printList.add(JasperFillManager.fillReport(
					jasperStream,
					map,
					new JRBeanCollectionDataSource(this.utilNegocioServicio
							.consultarPasajerosServicio(this
									.getComprobanteDetalle().getIdServicio(),
									this.obtenerIdEmpresa()))));

			JRPdfExporter exporter = new JRPdfExporter();
			exporter.setExporterInput(SimpleExporterInput
					.getInstance(printList));
			exporter.setExporterOutput(new SimpleOutputStreamExporterOutput(
					outputStream));
			SimplePdfExporterConfiguration configuration = new SimplePdfExporterConfiguration();
			configuration.setCreatingBatchModeBookmarks(true);
			// exporter.setConfiguration(configuration);
			exporter.exportReport();
			
			this.obtenerContexto().responseComplete();
		} catch (ErrorConsultaDataException e) {
			logger.error(e.getMessage(), e);
		}
	}
	
	private void imprimirPDFDocumentoCobranza(Map<String, Object> map,
			OutputStream outputStream, InputStream jasperStream)
			throws JRException {
		List<JasperPrint> printList = new ArrayList<JasperPrint>();

		try {
			
			printList.add(JasperFillManager.fillReport(
					jasperStream,
					map,
					new JRBeanCollectionDataSource(this.consultaNegocioServicio.consultarDescripcionServicioDC(this.obtenerIdEmpresa(), this
									.getComprobanteDetalle().getIdServicio()))));

			JRPdfExporter exporter = new JRPdfExporter();
			exporter.setExporterInput(SimpleExporterInput
					.getInstance(printList));
			exporter.setExporterOutput(new SimpleOutputStreamExporterOutput(
					outputStream));
			SimplePdfExporterConfiguration configuration = new SimplePdfExporterConfiguration();
			configuration.setCreatingBatchModeBookmarks(true);
			// exporter.setConfiguration(configuration);
			exporter.exportReport();
			
			this.obtenerContexto().responseComplete();
		} catch (ErrorConsultaDataException e) {
			logger.error(e.getMessage(), e);
		}
	}

	/**
	 * ========================================================================
	 * ===============================================================
	 */

	/**
	 * @return the comprobanteBusqueda
	 */
	public ComprobanteBusqueda getComprobanteBusqueda() {
		if (comprobanteBusqueda == null) {
			comprobanteBusqueda = new ComprobanteBusqueda();

			Calendar cal = Calendar.getInstance();
			comprobanteBusqueda.setFechaHasta(cal.getTime());
			cal.add(Calendar.MONTH, -1);
			comprobanteBusqueda.setFechaDesde(cal.getTime());
		}
		return comprobanteBusqueda;
	}

	/**
	 * @param comprobanteBusqueda
	 *            the comprobanteBusqueda to set
	 */
	public void setComprobanteBusqueda(ComprobanteBusqueda comprobanteBusqueda) {
		this.comprobanteBusqueda = comprobanteBusqueda;
	}

	/**
	 * @return the listaComprobantes
	 */
	public List<Comprobante> getListaComprobantes() {
		if (listaComprobantes == null) {
			listaComprobantes = new ArrayList<Comprobante>();
		}
		return listaComprobantes;
	}

	/**
	 * @param listaComprobantes
	 *            the listaComprobantes to set
	 */
	public void setListaComprobantes(List<Comprobante> listaComprobantes) {
		this.listaComprobantes = listaComprobantes;
	}

	/**
	 * @return the proveedor
	 */
	public Proveedor getProveedor() {
		if (proveedor == null) {
			proveedor = new Proveedor();
		}
		return proveedor;
	}

	/**
	 * @param proveedor
	 *            the proveedor to set
	 */
	public void setProveedor(Proveedor proveedor) {
		this.proveedor = proveedor;
	}

	/**
	 * @return the listadoProveedores
	 */
	public List<Proveedor> getListadoProveedores() {
		if (listadoProveedores == null) {
			listadoProveedores = new ArrayList<Proveedor>();
		}
		return listadoProveedores;
	}

	/**
	 * @param listadoProveedores
	 *            the listadoProveedores to set
	 */
	public void setListadoProveedores(List<Proveedor> listadoProveedores) {
		this.listadoProveedores = listadoProveedores;
	}

	/**
	 * @return the comprobanteDetalle
	 */
	public Comprobante getComprobanteDetalle() {
		if (comprobanteDetalle == null) {
			comprobanteDetalle = new Comprobante();
		}
		return comprobanteDetalle;
	}

	/**
	 * @param comprobanteDetalle
	 *            the comprobanteDetalle to set
	 */
	public void setComprobanteDetalle(Comprobante comprobanteDetalle) {
		this.comprobanteDetalle = comprobanteDetalle;
	}

	/**
	 * @return the documentoCobranza
	 */
	public boolean isDocumentoCobranza() {
		return documentoCobranza;
	}

	/**
	 * @param documentoCobranza the documentoCobranza to set
	 */
	public void setDocumentoCobranza(boolean documentoCobranza) {
		this.documentoCobranza = documentoCobranza;
	}

	/**
	 * @return the factura
	 */
	public boolean isFactura() {
		return factura;
	}

	/**
	 * @param factura the factura to set
	 */
	public void setFactura(boolean factura) {
		this.factura = factura;
	}

	/**
	 * @return the boleta
	 */
	public boolean isBoleta() {
		return boleta;
	}

	/**
	 * @param boleta the boleta to set
	 */
	public void setBoleta(boolean boleta) {
		this.boleta = boleta;
	}

}
