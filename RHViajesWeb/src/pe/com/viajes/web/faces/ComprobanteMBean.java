/**
 * 
 */
package pe.com.viajes.web.faces;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Locale;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;
import javax.naming.NamingException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFFont;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import pe.com.viajes.bean.negocio.Cliente;
import pe.com.viajes.bean.negocio.Comprobante;
import pe.com.viajes.bean.negocio.ComprobanteBusqueda;
import pe.com.viajes.bean.negocio.DetalleComprobante;
import pe.com.viajes.bean.negocio.DetalleServicioAgencia;
import pe.com.viajes.bean.negocio.Direccion;
import pe.com.viajes.bean.negocio.Pasajero;
import pe.com.viajes.bean.negocio.Proveedor;
import pe.com.viajes.bean.negocio.ServicioAgencia;
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

	/**
	 * 
	 */
	private static final long serialVersionUID = 3796481899238208609L;

	private ComprobanteBusqueda comprobanteBusqueda;
	private Comprobante comprobanteDetalle;

	private Proveedor proveedor;

	private List<Comprobante> listaComprobantes;
	private List<Proveedor> listadoProveedores;

	//private NegocioServicio negocioServicio;
	private ConsultaNegocioServicio consultaNegocioServicio;
	private UtilNegocioServicio utilNegocioServicio; 

	/**
	 * 
	 */
	public ComprobanteMBean() {
		try {
			ServletContext servletContext = (ServletContext) FacesContext
					.getCurrentInstance().getExternalContext().getContext();
			//negocioServicio = new NegocioServicioImpl(servletContext);
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
					.consultarComprobanteGenerado(idComprobante, this.obtenerIdEmpresa()));
		} catch (ErrorConsultaDataException e) {
			e.printStackTrace();
		}
	}
	
	public void generarComprobante(){
		try {
			
			String plantilla = "D:\\dc-plantilla.xlsx";
			File archivo = new File(plantilla);
			XSSFWorkbook archivoExcel = new XSSFWorkbook(new FileInputStream(archivo));
			
			XSSFSheet hoja1 = null;
			
			// FACTURA
			if (this.getComprobanteDetalle().getTipoComprobante().getCodigoEntero().intValue() == UtilWeb.obtenerEnteroPropertieMaestro("comprobanteFactura", "aplicacionDatos")){
				//hoja1 = archivoExcel.createSheet("Factura");
				/**
				 * Inicio de configuracion de hoja excel
				 */
				//hoja1 = this.configuracionFactura(hoja1);
				/**
				 * Fin configuracion hoja excel
				 */
				/**
				 * Inicio data de factura
				 */
				//	this.dataFactura(hoja1, archivoExcel);
				/**
				 * Fin data de factura
				 */
			}
			// BOLETA
			else if (this.getComprobanteDetalle().getTipoComprobante().getCodigoEntero().intValue() == UtilWeb.obtenerEnteroPropertieMaestro("comprobanteBoleta", "aplicacionDatos")){
				//hoja1 = archivoExcel.createSheet("Boleta");
				/**
				 * Inicio de configuracion de hoja excel
				 */
				//hoja1 = this.configuracionBoletaVenta(hoja1);
				/**
				 * Fin configuracion hoja excel
				 */
				/**
				 * Inicio data documento de cobranza
				 */
				//this.dataBoletaVenta(hoja1, archivoExcel);
				/**
				 * Fin data documento de cobranza
				 */
			}
			// DOCUMENTO DE COBRANZA
			else if (this.getComprobanteDetalle().getTipoComprobante().getCodigoEntero().intValue() == UtilWeb.obtenerEnteroPropertieMaestro("comprobanteDocumentoCobranza", "aplicacionDatos")){
				hoja1 = archivoExcel.getSheetAt(0);
				/**
				 * Inicio de configuracion de hoja excel
				 */
				//hoja1 = this.configuracionDocumentoCobranza(hoja1);
				/**
				 * Fin configuracion hoja excel
				 */
				/**
				 * Inicio data documento de cobranza
				 */
				this.dataDocumentoCobranza(hoja1, archivoExcel);
				/**
				 * Fin data documento de cobranza
				 */
			}
			
			/**
			 * Inicio datos de excel
			 */
			

			HttpServletResponse response = obtenerResponse();
			response.setContentType("application/vnd.ms-excel");
			response.setHeader("Content-disposition", "attachment;filename="
					+ "comprobante.xlsx");
			response.setHeader("Content-Transfer-Encoding", "binary");

			FacesContext facesContext = obtenerContexto();

			ServletOutputStream respuesta = response.getOutputStream();
			// respuesta.write(xls.getBytes());
			archivoExcel.write(respuesta);
			archivoExcel.close();

			respuesta.close();
			respuesta.flush();

			facesContext.responseComplete();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			logger.error(e.getMessage(), e);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			logger.error(e.getMessage(), e);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			logger.error(e.getMessage(), e);
		}
	}
	
	private HSSFSheet configuracionDocumentoCobranza(HSSFSheet hoja1){
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
		for (int i=9; i<=22; i++){
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
		
		for (int i=12; i<=18; i++){
			hoja1.addMergedRegion(new CellRangeAddress(i, i, 1, 6));
		}
		hoja1.addMergedRegion(new CellRangeAddress(21, 21, 0, 6));
		
		return hoja1;
	}

	private HSSFSheet configuracionBoletaVenta(HSSFSheet hoja1){
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
		for (int i=10; i<=15; i++){
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
		
		for (int i=13; i<=18; i++){
			hoja1.addMergedRegion(new CellRangeAddress(i, i, 2, 6));
		}
		hoja1.addMergedRegion(new CellRangeAddress(19, 20, 1, 6));
		
		hoja1.addMergedRegion(new CellRangeAddress(22, 23, 1, 6));
		
		hoja1.addMergedRegion(new CellRangeAddress(21, 23, 7, 7));
		
		return hoja1;
	}
	
	private HSSFSheet configuracionFactura(HSSFSheet hoja1){
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
		for (int i=10; i<=19; i++){
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
		
		for (int i=13; i<=18; i++){
			hoja1.addMergedRegion(new CellRangeAddress(i, i, 1, 6));
		}
		hoja1.addMergedRegion(new CellRangeAddress(23, 23, 1, 6));
		hoja1.addMergedRegion(new CellRangeAddress(24, 25, 5, 5));
		hoja1.addMergedRegion(new CellRangeAddress(24, 25, 6, 6));
		hoja1.addMergedRegion(new CellRangeAddress(24, 25, 7, 7));
		
		return hoja1;
	}
	
	private void dataDocumentoCobranza(XSSFSheet hoja1, XSSFWorkbook archivoExcel) throws SQLException, Exception{
		int ultimaFila = hoja1.getLastRowNum();
		Cliente cliente = this.consultaNegocioServicio.consultarCliente(this.getComprobanteDetalle().getTitular().getCodigoEntero(), this.obtenerIdEmpresa());
		for (int i=0; i<=ultimaFila; i++){
			XSSFRow fila = hoja1.getRow(i);
			if (fila != null){
				Integer vfinal = Integer.valueOf(fila.getLastCellNum());
				for (int j=0; j<vfinal.intValue(); j++){
					XSSFCell celda = fila.getCell(j);
					if (celda != null){
						String valor = celda.getStringCellValue();
						if (NOMBRE_CLIENTE.equals(valor)){
							celda.setCellValue(cliente.getNombreCompleto());
						}
						else if (DIRECCION_CLIENTE.equals(valor)){
							List<Direccion> listaDirecciones = cliente.getListaDirecciones();
							if (listaDirecciones != null && !listaDirecciones.isEmpty()){
								celda.setCellValue(listaDirecciones.get(0).getDireccion());
							}
						}
						else if (DOC_IDENTIDAD.equals(valor)){
							String docIdentidad = cliente.getDocumentoIdentidad().getTipoDocumento().getNombre() + " - " + cliente.getDocumentoIdentidad().getNumeroDocumento();
							celda.setCellValue(docIdentidad);
						}
						else if (NUM_VENTA.equals(valor)){
							celda.setCellValue(this.getComprobanteDetalle().getIdServicio());
						}
						else if (FECHA_COMPRA.equals(valor)){
							Calendar cal = Calendar.getInstance();
							cal.setTime(this.getComprobanteDetalle().getFechaComprobante());
							
							String fecha = UtilWeb.completarCerosIzquierda(String.valueOf(cal.get(Calendar.DATE)),2)+"  "+UtilWeb.completarCerosIzquierda(String.valueOf(cal.get(Calendar.MONTH)),2)+ "    "+cal.get(Calendar.YEAR);
							celda.setCellValue(fecha);
						}
						else if (TOTAL_DC.equals(valor)){
							DecimalFormat df = new DecimalFormat("#,##0.00", new DecimalFormatSymbols(Locale.US));
							celda.setCellValue(df.format(this.getComprobanteDetalle().getTotalComprobante().doubleValue()));
						}
						else if (DETALLE_DOCUMENTO_COBRANZA.equals(valor)){
							List<DetalleComprobante> listaDetalle = this.getComprobanteDetalle().getDetalleComprobante();
							utilNegocioServicio.analizarDetalleComprobante(listaDetalle, this.getComprobanteDetalle().getIdServicio(), this.obtenerIdEmpresa());
							int z=1;
							for (int a=0; a<listaDetalle.size(); a++){
								DetalleComprobante detaComprobante = listaDetalle.get(a);
								if (detaComprobante.isImpresion()){
									celda.setCellValue(detaComprobante.getConcepto());
									fila = hoja1.getRow(i+z);
									celda = fila.getCell(1);
									z++;
								}
							}
						}
					}
				}
			}
		}
		
	}
	
	private void dataBoletaVenta(HSSFSheet hoja1, HSSFWorkbook archivoExcel) throws SQLException, Exception{
		HSSFFont fuenteDefecto = archivoExcel.createFont();
		fuenteDefecto.setFontName("Calibri");
		fuenteDefecto.setFontHeightInPoints((short) 10);

		/**
		 * Creacion de estilos
		 */
		HSSFCellStyle estiloCalibri = archivoExcel.createCellStyle();
		HSSFFont fuente = archivoExcel.createFont();
		fuente.setFontName("Calibri");
		fuente.setFontHeightInPoints((short) 10);
		estiloCalibri.setFont(fuente);

		HSSFCellStyle estiloCalibriNegrita = archivoExcel.createCellStyle();
		fuente = archivoExcel.createFont();
		fuente.setFontName("Calibri");
		fuente.setFontHeightInPoints((short) 10);
		fuente.setBold(true);
		estiloCalibriNegrita.setFont(fuente);

		HSSFCellStyle sCalibriNegrita12 = archivoExcel.createCellStyle();
		fuente = archivoExcel.createFont();
		fuente.setFontName("Calibri");
		fuente.setFontHeightInPoints((short) 10);
		fuente.setBold(true);
		sCalibriNegrita12.setFont(fuente);
		
		HSSFCellStyle sCalibriNegrita11Centro = archivoExcel.createCellStyle();
		fuente = archivoExcel.createFont();
		fuente.setFontName("Calibri");
		fuente.setFontHeightInPoints((short) 11);
		fuente.setBold(true);
		sCalibriNegrita11Centro.setFont(fuente);
		sCalibriNegrita11Centro.setAlignment(HSSFCellStyle.ALIGN_CENTER);

		HSSFCellStyle estiloCalibriCentro = archivoExcel.createCellStyle();
		fuente = archivoExcel.createFont();
		fuente.setFontName("Calibri");
		fuente.setFontHeightInPoints((short) 10);
		estiloCalibriCentro.setFont(fuente);
		estiloCalibriCentro.setAlignment(HSSFCellStyle.ALIGN_CENTER);

		HSSFCellStyle estiloCalibriDerecha = archivoExcel.createCellStyle();
		fuente = archivoExcel.createFont();
		fuente.setFontName("Calibri");
		fuente.setFontHeightInPoints((short) 10);
		estiloCalibriDerecha.setFont(fuente);
		estiloCalibriDerecha.setAlignment(HSSFCellStyle.ALIGN_RIGHT);
		
		HSSFCellStyle estiloCalibriIzquierda = archivoExcel.createCellStyle();
		fuente = archivoExcel.createFont();
		fuente.setFontName("Calibri");
		fuente.setFontHeightInPoints((short) 10);
		estiloCalibriIzquierda.setFont(fuente);
		estiloCalibriIzquierda.setAlignment(HSSFCellStyle.ALIGN_LEFT);

		/**
		 * Fin de estilos
		 */
		
		Pasajero pasajero = null;
		ServicioAgencia servicio = this.consultaNegocioServicio.consultarVentaServicio(this.getComprobanteDetalle().getIdServicio(), this.obtenerIdEmpresa());
		for (DetalleServicioAgencia detalleServicio : servicio.getListaDetalleServicio()){
			if (!detalleServicio.getListaPasajeros().isEmpty()){
				pasajero = detalleServicio.getListaPasajeros().get(0);
				break;
			}
		}
		
		String linea1 = "Referencia: Pax "+pasajero.getApellidoPaterno()+" "+pasajero.getApellidoMaterno()+" "+pasajero.getNombres();
		String linea2 = "";
		String linea3 = "";
		String linea4 = "";
		String linea5 = "";
		String linea6 = "";
		String linea7 = "";
		for (int i=0; i<this.getComprobanteDetalle().getDetalleComprobante().size(); i++){
			DetalleComprobante detaComprobante = this.getComprobanteDetalle().getDetalleComprobante().get(i);
			if (i==0){
				linea2 = detaComprobante.getConcepto();
			}
			else if (i==1){
				linea3 = detaComprobante.getConcepto();
			}
			else if (i==2){
				linea4 = detaComprobante.getConcepto();
			}
			else if (i==3){
				linea5 = detaComprobante.getConcepto();
			}
			else if (i==4){
				linea6 = detaComprobante.getConcepto();
			}
			else if (i==5){
				linea7 = detaComprobante.getConcepto();
			}
		}
		
		String monto = this.getComprobanteDetalle().getTotalComprobante().toEngineeringString();
		String moneda = this.getComprobanteDetalle().getMoneda().getNombre();
		String simboloMoneda = this.getComprobanteDetalle().getMoneda().getAbreviatura();
				
		HSSFRow fila = hoja1.getRow(5);
		HSSFCell celda = fila.createCell(1);
		celda.setCellStyle(estiloCalibriIzquierda);
		celda.setCellValue(UtilWeb.fechaHoy("dd/MM/yyyy"));
		
		Cliente cliente = this.consultaNegocioServicio.consultarCliente(this.getComprobanteDetalle().getTitular().getCodigoEntero(), this.obtenerIdEmpresa());
		
		fila = hoja1.getRow(7);
		celda = fila.getCell(0);
		celda.setCellValue(cliente.getNombreCompleto());
		celda.setCellStyle(estiloCalibriCentro);
		
		fila = hoja1.getRow(9);
		celda = fila.createCell(6);
		celda.setCellValue(cliente.getDocumentoIdentidad().getNumeroDocumento());
		celda.setCellStyle(estiloCalibriCentro);
			
		fila = hoja1.getRow(13);
		celda = fila.getCell(2);
		if (celda == null){
			celda = fila.createCell(2);
		}
		celda.setCellValue(linea1);
		celda.setCellStyle(estiloCalibri);
		
		fila = hoja1.getRow(14);
		celda = fila.getCell(2);
		if (celda == null){
			celda = fila.createCell(2);
		}
		celda.setCellValue(linea2);
		celda.setCellStyle(estiloCalibri);
		
		fila = hoja1.getRow(15);
		celda = fila.getCell(2);
		if (celda == null){
			celda = fila.createCell(2);
		}
		celda.setCellValue(linea3);
		celda.setCellStyle(estiloCalibri);
		
		fila = hoja1.getRow(16);
		celda = fila.getCell(2);
		if (celda == null){
			celda = fila.createCell(2);
		}
		celda.setCellValue(linea5);
		celda.setCellStyle(estiloCalibri);
		
		fila = hoja1.getRow(17);
		celda = fila.getCell(2);
		if (celda == null){
			celda = fila.createCell(2);
		}
		celda.setCellValue(linea6);
		celda.setCellStyle(estiloCalibri);
		
		fila = hoja1.getRow(18);
		celda = fila.getCell(2);
		if (celda == null){
			celda = fila.createCell(2);
		}
		
		fila = hoja1.getRow(19);
		celda = fila.getCell(1);
		if (celda == null){
			celda = fila.createCell(1);
		}
		celda.setCellValue(UtilConvertirNumeroLetras.convertNumberToLetter(monto)+" "+moneda);
		celda.setCellStyle(estiloCalibri);
		
		fila = hoja1.getRow(21);
		celda = fila.getCell(7);
		if (celda == null){
			celda = fila.createCell(7);
		}
		celda.setCellValue(simboloMoneda+monto);
		celda.setCellStyle(sCalibriNegrita11Centro);
		
		fila = hoja1.getRow(22);
		celda = fila.getCell(1);
		if (celda == null){
			celda = fila.createCell(1);
		}
		String fechaComprobanteLetras = "";
		fechaComprobanteLetras = UtilWeb.diaFechaHoy()+"     "+UtilWeb.mesHoy()+"   "+UtilWeb.anioFechaHoy();
		fechaComprobanteLetras = "                            "+fechaComprobanteLetras;
		celda.setCellValue(fechaComprobanteLetras);
		celda.setCellStyle(estiloCalibri);
	}
	
	private void dataFactura(HSSFSheet hoja1, HSSFWorkbook archivoExcel) throws SQLException, Exception{
		HSSFFont fuenteDefecto = archivoExcel.createFont();
		fuenteDefecto.setFontName("Calibri");
		fuenteDefecto.setFontHeightInPoints((short) 10);

		/**
		 * Creacion de estilos
		 */
		HSSFCellStyle estiloCalibri = archivoExcel.createCellStyle();
		HSSFFont fuente = archivoExcel.createFont();
		fuente.setFontName("Calibri");
		fuente.setFontHeightInPoints((short) 10);
		estiloCalibri.setFont(fuente);

		HSSFCellStyle estiloCalibriNegrita = archivoExcel.createCellStyle();
		fuente = archivoExcel.createFont();
		fuente.setFontName("Calibri");
		fuente.setFontHeightInPoints((short) 10);
		fuente.setBold(true);
		estiloCalibriNegrita.setFont(fuente);

		HSSFCellStyle sCalibriNegrita12 = archivoExcel.createCellStyle();
		fuente = archivoExcel.createFont();
		fuente.setFontName("Calibri");
		fuente.setFontHeightInPoints((short) 10);
		fuente.setBold(true);
		sCalibriNegrita12.setFont(fuente);
		
		HSSFCellStyle sCalibriNegrita11Centro = archivoExcel.createCellStyle();
		fuente = archivoExcel.createFont();
		fuente.setFontName("Calibri");
		fuente.setFontHeightInPoints((short) 11);
		fuente.setBold(true);
		sCalibriNegrita11Centro.setFont(fuente);
		sCalibriNegrita11Centro.setAlignment(HSSFCellStyle.ALIGN_CENTER);

		HSSFCellStyle estiloCalibriCentro = archivoExcel.createCellStyle();
		fuente = archivoExcel.createFont();
		fuente.setFontName("Calibri");
		fuente.setFontHeightInPoints((short) 10);
		estiloCalibriCentro.setFont(fuente);
		estiloCalibriCentro.setAlignment(HSSFCellStyle.ALIGN_CENTER);

		HSSFCellStyle estiloCalibriDerecha = archivoExcel.createCellStyle();
		fuente = archivoExcel.createFont();
		fuente.setFontName("Calibri");
		fuente.setFontHeightInPoints((short) 10);
		estiloCalibriDerecha.setFont(fuente);
		estiloCalibriDerecha.setAlignment(HSSFCellStyle.ALIGN_RIGHT);
		
		HSSFCellStyle estiloCalibriIzquierda = archivoExcel.createCellStyle();
		fuente = archivoExcel.createFont();
		fuente.setFontName("Calibri");
		fuente.setFontHeightInPoints((short) 10);
		estiloCalibriIzquierda.setFont(fuente);
		estiloCalibriIzquierda.setAlignment(HSSFCellStyle.ALIGN_LEFT);

		/**
		 * Fin de estilos
		 */
		Pasajero pasajero = null;
		ServicioAgencia servicio = this.consultaNegocioServicio.consultarVentaServicio(this.getComprobanteDetalle().getIdServicio(), this.obtenerIdEmpresa());
		for (DetalleServicioAgencia detalleServicio : servicio.getListaDetalleServicio()){
			if (!detalleServicio.getListaPasajeros().isEmpty()){
				pasajero = detalleServicio.getListaPasajeros().get(0);
				break;
			}
		}
		
		String linea1 = "Referencia: Pax "+pasajero.getApellidoPaterno()+" "+pasajero.getApellidoMaterno()+" "+pasajero.getNombres();
		String linea2 = "";
		String linea3 = "";
		String linea4 = "";
		String linea5 = "";
		String linea6 = "";
		String linea7 = "";
		for (int i=0; i<this.getComprobanteDetalle().getDetalleComprobante().size(); i++){
			DetalleComprobante detaComprobante = this.getComprobanteDetalle().getDetalleComprobante().get(i);
			if (i==0){
				linea2 = detaComprobante.getConcepto();
			}
			else if (i==1){
				linea3 = detaComprobante.getConcepto();
			}
			else if (i==2){
				linea4 = detaComprobante.getConcepto();
			}
			else if (i==3){
				linea5 = detaComprobante.getConcepto();
			}
			else if (i==4){
				linea6 = detaComprobante.getConcepto();
			}
			else if (i==5){
				linea7 = detaComprobante.getConcepto();
			}
		}
		
		String montoSinIGV = this.getComprobanteDetalle().getSubTotal().toEngineeringString();
		String montoIGV = this.getComprobanteDetalle().getTotalIGV().toEngineeringString();
		String monto = this.getComprobanteDetalle().getTotalComprobante().toEngineeringString();
		String moneda = this.getComprobanteDetalle().getMoneda().getNombre();
		String simboloMoneda = this.getComprobanteDetalle().getMoneda().getAbreviatura();
		
		HSSFRow fila = hoja1.getRow(5);
		HSSFCell celda = fila.createCell(1);
		celda.setCellStyle(estiloCalibriIzquierda);
		celda.setCellValue(UtilWeb.fechaHoy("dd/MM/yyyy"));
		
		Cliente cliente = this.consultaNegocioServicio.consultarCliente(this.getComprobanteDetalle().getTitular().getCodigoEntero(), this.obtenerIdEmpresa());
		
		fila = hoja1.getRow(7);
		celda = fila.getCell(0);
		celda.setCellValue(cliente.getNombreCompleto());
		celda.setCellStyle(estiloCalibriCentro);
		
		celda = fila.createCell(6);
		celda.setCellValue(cliente.getDocumentoIdentidad().getNumeroDocumento());
		celda.setCellStyle(estiloCalibriCentro);
		
		fila = hoja1.getRow(9);
		celda = fila.getCell(0);
		celda.setCellValue(cliente.getListaDirecciones().get(0).getDireccion());
		celda.setCellStyle(estiloCalibriCentro);
			
		fila = hoja1.getRow(13);
		celda = fila.getCell(1);
		if (celda == null){
			celda = fila.createCell(1);
		}
		celda.setCellValue(linea1);
		celda.setCellStyle(estiloCalibri);
		
		fila = hoja1.getRow(14);
		celda = fila.getCell(1);
		if (celda == null){
			celda = fila.createCell(1);
		}
		celda.setCellValue(linea2);
		celda.setCellStyle(estiloCalibri);
		
		fila = hoja1.getRow(15);
		celda = fila.getCell(1);
		if (celda == null){
			celda = fila.createCell(1);
		}
		celda.setCellValue(linea3);
		celda.setCellStyle(estiloCalibri);
		
		fila = hoja1.getRow(16);
		celda = fila.getCell(1);
		if (celda == null){
			celda = fila.createCell(1);
		}
		celda.setCellValue(linea5);
		celda.setCellStyle(estiloCalibri);
		
		fila = hoja1.getRow(17);
		celda = fila.getCell(1);
		if (celda == null){
			celda = fila.createCell(1);
		}
		celda.setCellValue(linea6);
		celda.setCellStyle(estiloCalibri);
		
		fila = hoja1.getRow(18);
		celda = fila.getCell(1);
		if (celda == null){
			celda = fila.createCell(1);
		}
		celda.setCellValue(linea7);
		celda.setCellStyle(estiloCalibri);
		
		fila = hoja1.getRow(23);
		celda = fila.getCell(1);
		if (celda == null){
			celda = fila.createCell(1);
		}
		celda.setCellValue(UtilConvertirNumeroLetras.convertirNumeroALetras(Double.parseDouble(monto))+" "+moneda);
		celda.setCellStyle(estiloCalibri);
		
		fila = hoja1.getRow(24);
		celda = fila.getCell(0);
		if (celda == null){
			celda = fila.createCell(0);
		}
		celda.setCellValue(UtilWeb.diaFechaHoy());
		celda.setCellStyle(estiloCalibri);
		
		celda = fila.getCell(1);
		if (celda == null){
			celda = fila.createCell(1);
		}
		celda.setCellValue(UtilWeb.mesHoy());
		celda.setCellStyle(estiloCalibri);
		
		celda = fila.getCell(1);
		if (celda == null){
			celda = fila.createCell(1);
		}
		celda.setCellValue(UtilWeb.mesHoy());
		celda.setCellStyle(estiloCalibri);
		
		celda = fila.getCell(2);
		if (celda == null){
			celda = fila.createCell(2);
		}
		celda.setCellValue(UtilWeb.anioFechaHoy());
		celda.setCellStyle(estiloCalibri);
		
		celda = fila.getCell(5);
		if (celda == null){
			celda = fila.createCell(5);
		}
		celda.setCellValue(simboloMoneda+" "+montoSinIGV);
		celda.setCellStyle(estiloCalibriNegrita);
		
		celda = fila.getCell(6);
		if (celda == null){
			celda = fila.createCell(6);
		}
		celda.setCellValue(simboloMoneda+" "+montoIGV);
		celda.setCellStyle(estiloCalibriNegrita);
		
		celda = fila.getCell(7);
		if (celda == null){
			celda = fila.createCell(7);
		}
		celda.setCellValue(simboloMoneda+" "+monto);
		celda.setCellStyle(estiloCalibriNegrita);
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

}
