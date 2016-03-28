/**
 * 
 */
package pe.com.viajes.web.faces;

import java.io.IOException;
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

import org.apache.log4j.Logger;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFFont;
import org.apache.poi.hssf.usermodel.HSSFPalette;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hssf.util.HSSFColor;
import org.apache.poi.ss.usermodel.CreationHelper;
import org.apache.poi.ss.usermodel.DataFormat;
import org.apache.poi.ss.util.CellRangeAddress;

import pe.com.viajes.bean.negocio.DetalleServicioAgencia;
import pe.com.viajes.bean.reportes.ReporteVentas;
import pe.com.viajes.web.servicio.ReportesServicio;
import pe.com.viajes.web.servicio.SeguridadServicio;
import pe.com.viajes.web.servicio.impl.ReportesServicioImpl;
import pe.com.viajes.web.servicio.impl.SeguridadServicioImpl;

/**
 * @author Edwin
 *
 */
@ManagedBean(name = "reporteVentasMBean")
@SessionScoped()
public class ReporteVentasMBean extends BaseMBean {

	private final static Logger logger = Logger
			.getLogger(ReporteVentasMBean.class);

	private static final long serialVersionUID = -4496282062127472546L;

	private ReportesServicio reportesServicio;
	private SeguridadServicio seguridadServicio;

	private List<DetalleServicioAgencia> reporteGeneralVentas;

	private ReporteVentas reporteVentas;

	private String nombreVendedor;

	public ReporteVentasMBean() {
		try {
			ServletContext servletContext = (ServletContext) FacesContext
					.getCurrentInstance().getExternalContext().getContext();
			reportesServicio = new ReportesServicioImpl(servletContext);
			seguridadServicio = new SeguridadServicioImpl(servletContext);
		} catch (NamingException e) {
			logger.error(e.getMessage(), e);
		}
	}

	public void consultaReporteGeneralVentas() {
		try {
			this.setNombreVendedor(this.seguridadServicio.consultarUsuario(
					this.getReporteVentas().getVendedor().getCodigoEntero(), this.obtenerIdEmpresa())
					.getNombreCompleto());
			this.getReporteVentas().setEmpresa(this.obtenerEmpresa());
			this.setReporteGeneralVentas(this.reportesServicio
					.reporteGeneralVentas(this.getReporteVentas()));

		} catch (SQLException e) {
			this.mostrarMensajeError(e.getMessage());
			e.printStackTrace();
		}
	}

	public void exportarReporte() {

		HSSFWorkbook xls = new HSSFWorkbook();
		HSSFSheet hoja = xls.createSheet("Reporte");

		hoja.setColumnWidth(0, 20 * 256);
		hoja.setColumnWidth(1, 20 * 256);
		hoja.setColumnWidth(2, 20 * 256);
		hoja.setColumnWidth(3, 20 * 256);
		CellRangeAddress region = new CellRangeAddress(0, 0, 0, 3);
		hoja.addMergedRegion(region);

		HSSFRow fila = hoja.createRow(0);
		HSSFCell celda = fila.createCell(0);
		celda.setCellValue("Reporte General de Ventas");
		HSSFCellStyle estiloTitulo = xls.createCellStyle();
		HSSFFont fuenteNegrita = xls.createFont();
		fuenteNegrita.setBold(true);
		fuenteNegrita.setFontHeightInPoints((short) 15);
		fuenteNegrita.setFontName("Calibri");
		estiloTitulo.setFont(fuenteNegrita);
		estiloTitulo.setAlignment(HSSFCellStyle.ALIGN_LEFT);
		celda.setCellStyle(estiloTitulo);

		fila = hoja.createRow(1);
		celda = fila.createCell(0);
		celda.setCellValue("Desde");
		celda = fila.createCell(1);
		celda.setCellValue(reporteVentas.getFechaDesde());
		HSSFCellStyle estiloCelda = celda.getCellStyle();
		CreationHelper createHelper = xls.getCreationHelper();
		estiloCelda.setDataFormat(createHelper.createDataFormat().getFormat(
				"dd/MM/yyyy"));
		celda.setCellStyle(estiloCelda);
		celda = fila.createCell(2);
		celda.setCellValue("Hasta");
		celda = fila.createCell(3);
		celda.setCellValue(reporteVentas.getFechaHasta());
		celda.setCellStyle(estiloCelda);

		HSSFCellStyle estiloTituloTabla = xls.createCellStyle();
		estiloTituloTabla.setAlignment(HSSFCellStyle.ALIGN_CENTER);
		HSSFPalette palette = xls.getCustomPalette();
		short miIndice = HSSFColor.BLUE.index;
		byte b_rojo = (byte) 79;
		byte b_verde = (byte) 129;
		byte b_azul = (byte) 189;
		palette.setColorAtIndex(miIndice, b_rojo, b_verde, b_azul);
		estiloTituloTabla.setFillBackgroundColor(HSSFColor.BLUE.index);
		estiloTituloTabla.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
		estiloTituloTabla.setFillForegroundColor(HSSFColor.BLUE.index);
		HSSFFont fuenteTituloTabla = xls.createFont();
		fuenteTituloTabla.setBold(true);
		fuenteTituloTabla.setColor(HSSFColor.WHITE.index);
		estiloTituloTabla.setFont(fuenteTituloTabla);

		fila = hoja.createRow(3);
		celda = fila.createCell(0);
		celda.setCellValue("Tipo Servicio");
		celda.setCellStyle(estiloTituloTabla);
		celda = fila.createCell(1);
		celda.setCellValue("Cantidad");
		celda.setCellStyle(estiloTituloTabla);
		celda = fila.createCell(2);
		celda.setCellValue("Total Facturado");
		celda.setCellStyle(estiloTituloTabla);
		celda = fila.createCell(3);
		celda.setCellValue("Total Comision");
		celda.setCellStyle(estiloTituloTabla);

		HSSFCellStyle estiloDataTabla = xls.createCellStyle();
		HSSFCellStyle estiloDataTablaSimple = xls.createCellStyle();
		DataFormat format = xls.createDataFormat();
		if (reporteGeneralVentas != null) {
			for (int i = 0; i < reporteGeneralVentas.size(); i++) {
				DetalleServicioAgencia detalle = reporteGeneralVentas.get(i);

				fila = hoja.createRow(4 + i);
				celda = fila.createCell(0);
				celda.setCellValue(detalle.getTipoServicio().getNombre());
				celda.setCellStyle(estiloDataTablaSimple);
				celda = fila.createCell(1);
				celda.setCellValue(detalle.getCantidad());
				celda.setCellStyle(estiloDataTablaSimple);
				celda = fila.createCell(2);
				celda.setCellValue(detalle.getTotalAgrupados().doubleValue());
				estiloDataTabla.setDataFormat(format.getFormat("###,##0.00"));
				celda.setCellStyle(estiloDataTabla);
				celda = fila.createCell(3);
				celda.setCellValue(detalle.getMontoComision().doubleValue());
				estiloDataTabla.setDataFormat(format.getFormat("###,##0.00"));
				celda.setCellStyle(estiloDataTabla);
			}
		}

		try {
			HttpServletResponse response = obtenerResponse();
			response.setContentType("application/vnd.ms-excel");
			response.setHeader("Content-disposition", "attachment;filename="
					+ "reporte.xls");
			response.setHeader("Content-Transfer-Encoding", "binary");

			FacesContext facesContext = obtenerContexto();

			ServletOutputStream respuesta = response.getOutputStream();
			// respuesta.write(xls.getBytes());
			xls.write(respuesta);
			xls.close();

			respuesta.close();
			respuesta.flush();

			facesContext.responseComplete();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/**
	 * ========================================================================
	 * ======================
	 */
	/**
	 * @return the reporteVentas
	 */
	public ReporteVentas getReporteVentas() {
		if (reporteVentas == null) {
			reporteVentas = new ReporteVentas();
			Calendar cal = Calendar.getInstance();
			reporteVentas.setFechaHasta(cal.getTime());
			cal.add(Calendar.MONTH, -1);
			reporteVentas.setFechaDesde(cal.getTime());
		}
		return reporteVentas;
	}

	/**
	 * @param reporteVentas
	 *            the reporteVentas to set
	 */
	public void setReporteVentas(ReporteVentas reporteVentas) {
		this.reporteVentas = reporteVentas;
	}

	/**
	 * @return the reporteGeneralVentas
	 */
	public List<DetalleServicioAgencia> getReporteGeneralVentas() {
		if (reporteGeneralVentas == null) {
			reporteGeneralVentas = new ArrayList<DetalleServicioAgencia>();
		}
		return reporteGeneralVentas;
	}

	/**
	 * @param reporteGeneralVentas
	 *            the reporteGeneralVentas to set
	 */
	public void setReporteGeneralVentas(
			List<DetalleServicioAgencia> reporteGeneralVentas) {
		this.reporteGeneralVentas = reporteGeneralVentas;
	}

	/**
	 * @return the nombreVendedor
	 */
	public String getNombreVendedor() {
		return nombreVendedor;
	}

	/**
	 * @param nombreVendedor
	 *            the nombreVendedor to set
	 */
	public void setNombreVendedor(String nombreVendedor) {
		this.nombreVendedor = nombreVendedor;
	}

}
