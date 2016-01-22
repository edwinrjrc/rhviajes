/**
 * 
 */
package pe.com.viajes.web.faces;

import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;
import javax.naming.NamingException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFFont;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.util.CellRangeAddress;
import org.richfaces.event.FileUploadEvent;
import org.richfaces.model.UploadedFile;

import pe.com.viajes.bean.cargaexcel.CeldaExcel;
import pe.com.viajes.bean.cargaexcel.ColumnasExcel;
import pe.com.viajes.bean.cargaexcel.ReporteArchivo;
import pe.com.viajes.bean.cargaexcel.ReporteArchivoBusqueda;
import pe.com.viajes.bean.negocio.ImpresionArchivoCargado;
import pe.com.viajes.bean.negocio.Proveedor;
import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;
import pe.com.viajes.negocio.exception.ErrorRegistroDataException;
import pe.com.viajes.web.servicio.ConsultaNegocioServicio;
import pe.com.viajes.web.servicio.NegocioServicio;
import pe.com.viajes.web.servicio.impl.ConsultaNegocioServicioImpl;
import pe.com.viajes.web.servicio.impl.NegocioServicioImpl;
import pe.com.viajes.web.util.UtilConvertirNumeroLetras;
import pe.com.viajes.web.util.UtilWeb;

/**
 * @author EDWREB
 *
 */
@ManagedBean(name = "cargaReporteProveedorMBean")
@SessionScoped()
public class CargaReporteProveedorMBean extends BaseMBean {

	private final static Logger logger = Logger
			.getLogger(CargaReporteProveedorMBean.class);
	/**
	 * 
	 */
	private static final long serialVersionUID = 6607933550231690113L;

	private Integer filaInicial;
	private Integer columnaInicial;
	private Integer nroColumnas;
	private ReporteArchivo reporteArchivo;
	private ReporteArchivoBusqueda reporteArchivoBusqueda;

	private List<CeldaExcel> tablaExcelCargada;
	private ColumnasExcel columnasExcel;
	private InputStream streamArchivo;

	private List<ColumnasExcel> dataExcel = null;
	private List<ReporteArchivoBusqueda> listaReporteBusqueda;

	private boolean tablaLlena;

	private NegocioServicio negocioServicio;
	private ConsultaNegocioServicio consultaNegocioServicio;

	public CargaReporteProveedorMBean() {
		try {
			ServletContext servletContext = (ServletContext) FacesContext
					.getCurrentInstance().getExternalContext().getContext();
			negocioServicio = new NegocioServicioImpl(servletContext);
			consultaNegocioServicio = new ConsultaNegocioServicioImpl(
					servletContext);
		} catch (NamingException e) {
			logger.error(e.getMessage(), e);
		}
	}

	public void buscarArchivoCargado() {
		try {
			this.setListaReporteBusqueda(this.consultaNegocioServicio
					.consultarArchivosCargados(getReporteArchivoBusqueda()));
		} catch (ErrorConsultaDataException e) {
			this.mostrarMensajeError(e.getMessage());
			logger.error(e.getMessage(), e);
		}
	}

	public void listenerExcel(FileUploadEvent event) {
		UploadedFile archivo = event.getUploadedFile();
		try {
			this.setTablaLlena(false);
			this.setDataExcel(null);
			this.setStreamArchivo(archivo.getInputStream());
			this.getReporteArchivo().setNombreArchivo(archivo.getName());

			this.setTablaLlena(true);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void cargarArchivoExcel() {
		HSSFWorkbook archivoExcel = null;
		try {
			if (this.getStreamArchivo() != null) {
				this.setDataExcel(null);
				archivoExcel = new HSSFWorkbook(this.getStreamArchivo());
				HSSFSheet hojaInicial = archivoExcel.getSheetAt(0);
				// int ultimaColumna = hojaInicial.getLastRowNum();
				// Iterator<Row> filas = hojaInicial.rowIterator();
				HSSFRow fila = null;
				HSSFCell celda = null;
				int iCelda = 0;
				List<String> cabecera = new ArrayList<String>();

				boolean registroCabecera = false;
				ColumnasExcel columna = null;
				Method method = null;
				Method method2 = null;
				Method method3 = null;
				String metodo = "getColumna";
				String metodo2 = "setValorCadena";
				String metodo3 = "setMostrar";
				Object ob1 = null;
				for (int i = (this.getFilaInicial() - 1); i < hojaInicial
						.getLastRowNum(); i++) {
					fila = hojaInicial.getRow(i);
					iCelda = this.getColumnaInicial()-1;
					celda = null;
					while (!registroCabecera
							&& iCelda <= (this.getNroColumnas())) {
						celda = fila.getCell(iCelda);
						String dato = UtilWeb.obtenerDato(celda);
						cabecera.add(dato);
						iCelda++;
					}
					if (cabecera.size() > 0) {
						columna = new ColumnasExcel();
						registroCabecera = true;
					}
					if (i > (this.getFilaInicial()-1)) {
						int j = 1;
						while (iCelda <= this.getNroColumnas()) {
							celda = fila.getCell(iCelda);
							String dato = UtilWeb.obtenerDato(celda);

							method = columna.getClass().getMethod(metodo + (j),
									null);
							ob1 = method.invoke(columna, null);
							method2 = ob1.getClass().getMethod(metodo2,
									String.class);
							method2.invoke(ob1, dato);
							method3 = ob1.getClass().getMethod(metodo3,
									boolean.class);
							method3.invoke(ob1, true);
							iCelda++;
							j++;
						}
						columna.getTipoComprobante().setCodigoEntero(
								this.getReporteArchivo().getTipoComprobante()
										.getCodigoEntero());
						columna.setNumeroComprobante(this.getReporteArchivo()
								.getNumeroComprobante());
						this.getDataExcel().add(columna);
					}
				}

				method = null;
				method2 = null;
				metodo = "getColumna";
				metodo2 = "setNombreColumna";
				ob1 = null;
				for (int i = 0; i < cabecera.size(); i++) {
					if (StringUtils.isNotBlank(cabecera.get(i))) {
						method = this.getColumnasExcel().getClass()
								.getMethod(metodo + (i + 1), null);
						ob1 = method.invoke(this.getColumnasExcel(), null);
						method2 = ob1.getClass().getMethod(metodo2,
								String.class);
						method2.invoke(ob1, cabecera.get(i));
						method3 = ob1.getClass().getMethod(metodo3,
								boolean.class);
						method3.invoke(ob1, true);
					}
				}

				this.getReporteArchivo().setNumeroFilas(
						this.getDataExcel().size());
				this.getReporteArchivo().setNumeroColumnas(
						this.getNroColumnas());
			}

		} catch (IOException e) {
			logger.error(e.getMessage(), e);
		} catch (IllegalAccessException e) {
			logger.error(e.getMessage(), e);
		} catch (IllegalArgumentException e) {
			logger.error(e.getMessage(), e);
		} catch (InvocationTargetException e) {
			logger.error(e.getMessage(), e);
		} catch (NoSuchMethodException e) {
			logger.error(e.getMessage(), e);
		} catch (SecurityException e) {
			logger.error(e.getMessage(), e);
		} finally {
			try {
				if (this.getStreamArchivo() != null) {
					this.getStreamArchivo().reset();
					this.getStreamArchivo().close();
				}
			} catch (IOException e) {
				logger.error(e.getMessage(), e);
			}
		}
	}

	public void grabarReporteProveedor() {
		try {
			HttpSession session = obtenerSession(false);
			Usuario usuario = (Usuario) session.getAttribute("usuarioSession");
			getReporteArchivo().setUsuarioCreacion(usuario);
			getReporteArchivo().setIpCreacion(obtenerRequest().getRemoteAddr());

			this.negocioServicio.grabarComprobantesReporte(getReporteArchivo(),
					getColumnasExcel(), getDataExcel());

			this.mostrarMensajeExito("Comprobantes guardados satisfactoriamente");
		} catch (ErrorRegistroDataException e) {
			this.mostrarMensajeError(e.getMessage());
			logger.error(e.getMessage(), e);
		} catch (SQLException e) {
			this.mostrarMensajeError(e.getMessage());
			logger.error(e.getMessage(), e);
		} catch (Exception e) {
			this.mostrarMensajeError(e.getMessage());
			logger.error(e.getMessage(), e);
		}
	}

	public void iniciarCargaArchivo() {
		this.setReporteArchivo(null);
		this.setColumnasExcel(null);
		this.setDataExcel(null);
		this.setColumnaInicial(null);
		this.setFilaInicial(null);
		this.setNroColumnas(null);
		this.getReporteArchivo().getMoneda().setCodigoEntero(2);
	}

	public void generarComprobante(ReporteArchivoBusqueda reporteCargado) {
		try {
			/**
			 * Informacion de prueba
			 */
			/*reporteCargado.getMoneda().setAbreviatura("$");
			reporteCargado.setMontoSubtotal(BigDecimal.valueOf(60.69));
			reporteCargado.setMontoIGV(BigDecimal.valueOf(10.92));
			reporteCargado.setMontoTotal(BigDecimal.valueOf(71.61));*/
			/**
			 * ==============================================================
			 */
			Proveedor proveedor = this.consultaNegocioServicio.consultarProveedor(reporteCargado.getProveedor().getCodigoEntero(), this.obtenerIdEmpresa());
			
			HSSFWorkbook archivoExcel = new HSSFWorkbook();

			HSSFFont fuenteDefecto = archivoExcel.createFont();
			fuenteDefecto.setFontName("Calibri");
			fuenteDefecto.setFontHeightInPoints((short) 11);

			String nombreHoja = "Comprobante";
			HSSFSheet hoja1 = archivoExcel.createSheet(nombreHoja);

			HSSFCellStyle estiloCalibri = archivoExcel.createCellStyle();
			HSSFFont fuente = archivoExcel.createFont();
			fuente.setFontName("Calibri");
			fuente.setFontHeightInPoints((short) 11);
			estiloCalibri.setFont(fuente);

			HSSFCellStyle estiloCalibriNegrita = archivoExcel.createCellStyle();
			fuente = archivoExcel.createFont();
			fuente.setFontName("Calibri");
			fuente.setFontHeightInPoints((short) 11);
			fuente.setBold(true);
			estiloCalibriNegrita.setFont(fuente);

			HSSFCellStyle sCalibriNegrita12 = archivoExcel.createCellStyle();
			fuente = archivoExcel.createFont();
			fuente.setFontName("Calibri");
			fuente.setFontHeightInPoints((short) 12);
			fuente.setBold(true);
			sCalibriNegrita12.setFont(fuente);

			HSSFCellStyle estiloCalibriCentro = archivoExcel.createCellStyle();
			fuente = archivoExcel.createFont();
			fuente.setFontName("Calibri");
			fuente.setFontHeightInPoints((short) 11);
			estiloCalibriCentro.setFont(fuente);
			estiloCalibriCentro.setAlignment(HSSFCellStyle.ALIGN_CENTER);

			HSSFCellStyle estiloCalibriDerecha = archivoExcel.createCellStyle();
			fuente = archivoExcel.createFont();
			fuente.setFontName("Calibri");
			fuente.setFontHeightInPoints((short) 11);
			estiloCalibriDerecha.setFont(fuente);
			estiloCalibriDerecha.setAlignment(HSSFCellStyle.ALIGN_RIGHT);

			HSSFRow fila = null;
			HSSFCell celda = null;
			for (int i = 0; i < 30; i++) {
				fila = hoja1.createRow(i);
				celda = fila.createCell(0);
				if (i == 0) {
					for (int j = 0; j < 10; j++) {
						celda = fila.createCell(j);
						celda.setCellStyle(estiloCalibri);
					}
				}

				celda.setCellStyle(estiloCalibri);
			}

			hoja1.setColumnWidth(0, 11 * 256);
			hoja1.setColumnWidth(1, 12 * 256);
			hoja1.setColumnWidth(2, 13 * 256);
			hoja1.setColumnWidth(3, 2940);
			hoja1.setColumnWidth(4, 2940);
			hoja1.setColumnWidth(5, 2940);
			hoja1.setColumnWidth(6, 2940);
			hoja1.setColumnWidth(7, 2940);
			hoja1.setColumnWidth(8, 2940);
			hoja1.setColumnWidth(9, 2940);
			hoja1.setColumnWidth(10, 2940);
			hoja1.setColumnWidth(11, 2940);

			fila = hoja1.getRow(1);
			fila.setHeightInPoints((float) 20.25);
			fila = hoja1.getRow(4);
			fila.setHeightInPoints((float) 20.25);
			fila = hoja1.getRow(5);
			celda = fila.createCell(1);
			
			celda.setCellValue(UtilWeb.fechaHoy("dd/MM/yyyy"));
			celda.setCellStyle(estiloCalibri);

			fila = hoja1.getRow(6);
			fila.setHeightInPoints((float) 25.5);
			fila = hoja1.getRow(7);
			celda = fila.getCell(0);
			
			String nombreProveedor = proveedor.getNombreCompleto();
			
			celda.setCellValue(nombreProveedor);
			celda.setCellStyle(estiloCalibriCentro);

			celda = fila.createCell(6);
			String rucProveedor = proveedor.getDocumentoIdentidad().getNumeroDocumento();
			celda.setCellValue(rucProveedor);
			celda.setCellStyle(estiloCalibriCentro);

			CellRangeAddress region = new CellRangeAddress(7, 7, 0, 4);
			hoja1.addMergedRegion(region);
			CellRangeAddress region2 = new CellRangeAddress(7, 7, 6, 7);
			hoja1.addMergedRegion(region2);

			fila = hoja1.createRow(9);
			fila.setHeightInPoints((float) 19.5);
			CellRangeAddress region3 = new CellRangeAddress(9, 9, 0, 6);
			hoja1.addMergedRegion(region3);
			celda = fila.createCell(0);
			String direccion = proveedor.getListaDirecciones().get(0).getDireccion();
			celda.setCellValue(direccion);
			celda.setCellStyle(estiloCalibriCentro);

			fila = hoja1.getRow(13);
			celda = fila.createCell(1);
			CellRangeAddress region4 = new CellRangeAddress(13, 13, 1, 6);
			hoja1.addMergedRegion(region4);
			celda.setCellValue("Por la comisión en la venta de tkt aéreo a favor de:");
			celda.setCellStyle(estiloCalibri);

			List<ImpresionArchivoCargado> listado = this.consultaNegocioServicio.consultaImpresionArchivoCargado(reporteCargado.getCodigoEntero(),obtenerIdEmpresa());
			if (listado != null){
				int i=14;
				for (ImpresionArchivoCargado impresionArchivoCargado : listado) {
					fila = hoja1.getRow(i);
					celda = fila.createCell(1);
					CellRangeAddress region5 = new CellRangeAddress(i, i, 1, 6);
					hoja1.addMergedRegion(region5);
					String v = "Pax: "+impresionArchivoCargado.getPaternoCliente()+"/"+impresionArchivoCargado.getNombresCliente()+" - Tkt: "+impresionArchivoCargado.getNumeroBoleto();
					celda.setCellValue(v);
					celda.setCellStyle(estiloCalibri);
				}
			}
			

			fila = hoja1.getRow(20);
			fila.setHeightInPoints((float) 10.50);

			fila = hoja1.getRow(22);
			fila.setHeightInPoints((float) 3.0);

			fila = hoja1.getRow(23);
			CellRangeAddress region11 = new CellRangeAddress(23, 23, 1, 6);
			hoja1.addMergedRegion(region11);
			fila.setHeightInPoints((float) 22.50);
			celda = fila.createCell(1);
			celda.setCellValue(UtilConvertirNumeroLetras.convertNumberToLetter(reporteCargado.getMontoTotal().doubleValue()));
			celda.setCellStyle(estiloCalibri);

			fila = hoja1.getRow(24);
			fila.setHeightInPoints((float) 31.5);
			celda = fila.getCell(0);
			celda.setCellValue(UtilWeb.diaFechaHoy());
			celda.setCellStyle(estiloCalibriDerecha);
			celda = fila.createCell(1);
			celda.setCellValue(UtilWeb.mesHoy());
			celda.setCellStyle(estiloCalibri);
			celda = fila.createCell(2);
			celda.setCellStyle(estiloCalibriDerecha);
			celda.setCellValue(UtilWeb.anioFechaHoy());

			celda = fila.createCell(5);
			celda.setCellStyle(sCalibriNegrita12);
			celda.setCellValue(reporteCargado.getMoneda().getAbreviatura()+" "+reporteCargado.getMontoSubtotal());
			
			celda = fila.createCell(6);
			celda.setCellStyle(sCalibriNegrita12);
			celda.setCellValue(reporteCargado.getMoneda().getAbreviatura()+" "+reporteCargado.getMontoIGV());
			
			celda = fila.createCell(7);
			celda.setCellValue(reporteCargado.getMoneda().getAbreviatura()+" "+reporteCargado.getMontoTotal());
			celda.setCellStyle(sCalibriNegrita12);

			HttpServletResponse response = obtenerResponse();
			response.setContentType("application/vnd.ms-excel");
			response.setHeader("Content-disposition", "attachment;filename="
					+ "reporte.xls");
			response.setHeader("Content-Transfer-Encoding", "binary");

			FacesContext facesContext = obtenerContexto();

			ServletOutputStream respuesta = response.getOutputStream();
			// respuesta.write(xls.getBytes());
			archivoExcel.write(respuesta);
			archivoExcel.close();

			respuesta.close();
			respuesta.flush();

			facesContext.responseComplete();
		} catch (IOException e1) {
			e1.printStackTrace();
		} catch (SQLException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * ========================================================================
	 * ===========
	 */

	/**
	 * @return the filaInicial
	 */
	public Integer getFilaInicial() {
		if (filaInicial == null) {
			filaInicial = 1;
		}
		return filaInicial;
	}

	/**
	 * @param filaInicial
	 *            the filaInicial to set
	 */
	public void setFilaInicial(Integer filaInicial) {
		this.filaInicial = filaInicial;
	}

	/**
	 * @return the columnaInicial
	 */
	public Integer getColumnaInicial() {
		if (columnaInicial == null) {
			columnaInicial = 1;
		}
		return columnaInicial;
	}

	/**
	 * @param columnaInicial
	 *            the columnaInicial to set
	 */
	public void setColumnaInicial(Integer columnaInicial) {
		this.columnaInicial = columnaInicial;
	}

	/**
	 * @return the nroColumnas
	 */
	public Integer getNroColumnas() {
		return nroColumnas;
	}

	/**
	 * @param nroColumnas
	 *            the nroColumnas to set
	 */
	public void setNroColumnas(Integer nroColumnas) {
		this.nroColumnas = nroColumnas;
	}

	/**
	 * @return the tablaExcelCargada
	 */
	public List<CeldaExcel> getTablaExcelCargada() {
		if (tablaExcelCargada == null) {
			tablaExcelCargada = new ArrayList<CeldaExcel>();
		}
		return tablaExcelCargada;
	}

	/**
	 * @param tablaExcelCargada
	 *            the tablaExcelCargada to set
	 */
	public void setTablaExcelCargada(List<CeldaExcel> tablaExcelCargada) {
		this.tablaExcelCargada = tablaExcelCargada;
	}

	/**
	 * @return the columnasExcel
	 */
	public ColumnasExcel getColumnasExcel() {
		if (columnasExcel == null) {
			columnasExcel = new ColumnasExcel();
		}
		return columnasExcel;
	}

	/**
	 * @param columnasExcel
	 *            the columnasExcel to set
	 */
	public void setColumnasExcel(ColumnasExcel columnasExcel) {
		this.columnasExcel = columnasExcel;
	}

	/**
	 * @return the streamArchivo
	 */
	public InputStream getStreamArchivo() {
		return streamArchivo;
	}

	/**
	 * @param streamArchivo
	 *            the streamArchivo to set
	 */
	public void setStreamArchivo(InputStream streamArchivo) {
		this.streamArchivo = streamArchivo;
	}

	/**
	 * @return the dataExcel
	 */
	public List<ColumnasExcel> getDataExcel() {
		if (dataExcel == null) {
			dataExcel = new ArrayList<ColumnasExcel>();
		}
		return dataExcel;
	}

	/**
	 * @param dataExcel
	 *            the dataExcel to set
	 */
	public void setDataExcel(List<ColumnasExcel> dataExcel) {
		this.dataExcel = dataExcel;
	}

	/**
	 * @return the tablaLlena
	 */
	public boolean isTablaLlena() {
		return tablaLlena;
	}

	/**
	 * @param tablaLlena
	 *            the tablaLlena to set
	 */
	public void setTablaLlena(boolean tablaLlena) {
		this.tablaLlena = tablaLlena;
	}

	/**
	 * @return the reporteArchivo
	 */
	public ReporteArchivo getReporteArchivo() {
		if (reporteArchivo == null) {
			reporteArchivo = new ReporteArchivo();
		}
		return reporteArchivo;
	}

	/**
	 * @param reporteArchivo
	 *            the reporteArchivo to set
	 */
	public void setReporteArchivo(ReporteArchivo reporteArchivo) {
		this.reporteArchivo = reporteArchivo;
	}

	/**
	 * @return the listaReporteBusqueda
	 */
	public List<ReporteArchivoBusqueda> getListaReporteBusqueda() {
		if (listaReporteBusqueda == null) {
			// listaReporteBusqueda = new ArrayList<ReporteArchivoBusqueda>();
			this.buscarArchivoCargado();
		}
		return listaReporteBusqueda;
	}

	/**
	 * @param listaReporteBusqueda
	 *            the listaReporteBusqueda to set
	 */
	public void setListaReporteBusqueda(
			List<ReporteArchivoBusqueda> listaReporteBusqueda) {
		this.listaReporteBusqueda = listaReporteBusqueda;
	}

	/**
	 * @return the reporteArchivoBusqueda
	 */
	public ReporteArchivoBusqueda getReporteArchivoBusqueda() {
		if (reporteArchivoBusqueda == null) {
			reporteArchivoBusqueda = new ReporteArchivoBusqueda();

			Calendar cal = Calendar.getInstance();
			reporteArchivoBusqueda.setFechaHasta(cal.getTime());
			cal.add(Calendar.MONTH, -1);
			reporteArchivoBusqueda.setFechaDesde(cal.getTime());
		}
		return reporteArchivoBusqueda;
	}

	/**
	 * @param reporteArchivoBusqueda
	 *            the reporteArchivoBusqueda to set
	 */
	public void setReporteArchivoBusqueda(
			ReporteArchivoBusqueda reporteArchivoBusqueda) {
		this.reporteArchivoBusqueda = reporteArchivoBusqueda;
	}
}
