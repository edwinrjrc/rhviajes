package pe.com.viajes.web.servlet;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import javax.naming.NamingException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import pe.com.viajes.bean.negocio.Comprobante;
import pe.com.viajes.bean.negocio.DetalleComprobante;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;
import pe.com.viajes.web.servicio.ReportesServicio;
import pe.com.viajes.web.servicio.impl.ReportesServicioImpl;

/**
 * Servlet implementation class ServletGeneraReporteComprobantes
 */
@WebServlet("/ServletGeneraReporteComprobantes")
public class ServletGeneraReporteComprobantes extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
	private ReportesServicio reportesServicio;
	private final int CODIGO_FACTURA = 1;
	private final int CODIGO_BOLETA = 2;
	private final int CODIGO_DOCUMENTOCOBRANZA = 3;
	
    /**
     * @see HttpServlet#HttpServlet()
     */
    public ServletGeneraReporteComprobantes() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		try {
			reportesServicio = new ReportesServicioImpl(getServletContext());
			String fecha1 = "01/01/2016";
			String fecha2 = "31/12/2016";
			SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
			Date fechaDesde = sdf.parse(fecha1);
			Date fechaHasta = sdf.parse(fecha2);
			List<Comprobante> lista = reportesServicio.generarReporteContable(fechaDesde, fechaHasta, 1);
			File carpetaExcelComprobantes = new File("D:\\ReportesComprobantes");
			if (!carpetaExcelComprobantes.exists()){
				carpetaExcelComprobantes.mkdirs();
			}
			File archivoExcelComprobantes = new File("D:\\ReportesComprobantes\\archivoComprobantes.xlsx");
			
			XSSFWorkbook libro = new XSSFWorkbook();
			XSSFSheet hoja = libro.createSheet("Comprobantes");
			XSSFRow fila = hoja.createRow(0);
			XSSFCell celda = fila.createCell(0);
			celda.setCellValue("ID");
			celda = fila.createCell(1);
			celda.setCellValue("Tipo Comprobante");
			celda = fila.createCell(2);
			celda.setCellValue("Numero Serie");
			celda = fila.createCell(3);
			celda.setCellValue("Numero Comprobante");
			celda = fila.createCell(4);
			celda.setCellValue("Titular");
			celda = fila.createCell(5);
			celda.setCellValue("Fecha comprobante");
			celda = fila.createCell(6);
			celda.setCellValue("Detalle Comprobante");
			celda = fila.createCell(7);
			celda.setCellValue("Total IGV");
			celda = fila.createCell(8);
			celda.setCellValue("Total Compronbante");
			String conceptosTotal = "";
			for (int i=1; i<lista.size(); i++) {
				Comprobante comprobante = lista.get(i);
				fila = hoja.createRow(i);
				celda = fila.createCell(0);
				celda.setCellValue(comprobante.getCodigoEntero().intValue());
				celda = fila.createCell(1);
				celda.setCellValue(comprobante.getTipoComprobante().getNombre());
				celda = fila.createCell(2);
				celda.setCellValue(comprobante.getNumeroSerie());
				celda = fila.createCell(3);
				celda.setCellValue(comprobante.getNumeroComprobante());
				celda = fila.createCell(4);
				celda.setCellValue(comprobante.getTitular().getNombres());
				celda = fila.createCell(5);
				celda.setCellValue(sdf.format(comprobante.getFechaComprobante()));
				conceptosTotal = "";
				for (int j=0; j<comprobante.getDetalleComprobante().size(); j++){
					DetalleComprobante detalle = comprobante.getDetalleComprobante().get(j);
					conceptosTotal = conceptosTotal + "- " + detalle.getConcepto() + "\n";
				}
				celda = fila.createCell(6);
				celda.setCellValue(conceptosTotal);
				celda = fila.createCell(7);
				celda.setCellValue(comprobante.getTotalIGV().toPlainString());
				celda = fila.createCell(8);
				celda.setCellValue(comprobante.getTotalComprobante().toPlainString());
			}
			/**
			 * FACTURAS
			 */
			hoja = libro.createSheet("Facturas");
			fila = hoja.createRow(0);
			celda = fila.createCell(0);
			celda.setCellValue("ID");
			celda = fila.createCell(1);
			celda.setCellValue("Tipo Comprobante");
			celda = fila.createCell(2);
			celda.setCellValue("Numero Serie");
			celda = fila.createCell(3);
			celda.setCellValue("Numero Comprobante");
			celda = fila.createCell(4);
			celda.setCellValue("Titular");
			celda = fila.createCell(5);
			celda.setCellValue("Fecha comprobante");
			celda = fila.createCell(6);
			celda.setCellValue("Detalle Comprobante");
			celda = fila.createCell(7);
			celda.setCellValue("Total IGV");
			celda = fila.createCell(8);
			celda.setCellValue("Total Compronbante");
			conceptosTotal = "";
			int i=1;
			int k=1;
			while (i<lista.size()) {
				Comprobante comprobante = lista.get(i);
				if (comprobante.getTipoComprobante().getCodigoEntero().intValue() == this.CODIGO_FACTURA){
					fila = hoja.createRow(k);
					celda = fila.createCell(0);
					celda.setCellValue(comprobante.getCodigoEntero().intValue());
					celda = fila.createCell(1);
					celda.setCellValue(comprobante.getTipoComprobante().getNombre());
					celda = fila.createCell(2);
					celda.setCellValue(comprobante.getNumeroSerie());
					celda = fila.createCell(3);
					celda.setCellValue(comprobante.getNumeroComprobante());
					celda = fila.createCell(4);
					celda.setCellValue(comprobante.getTitular().getNombres());
					celda = fila.createCell(5);
					celda.setCellValue(sdf.format(comprobante.getFechaComprobante()));
					conceptosTotal = "";
					for (int j=0; j<comprobante.getDetalleComprobante().size(); j++){
						DetalleComprobante detalle = comprobante.getDetalleComprobante().get(j);
						conceptosTotal = conceptosTotal + "- " + detalle.getConcepto() + "\n";
					}
					celda = fila.createCell(6);
					celda.setCellValue(conceptosTotal);
					celda = fila.createCell(7);
					celda.setCellValue(comprobante.getTotalIGV().toPlainString());
					celda = fila.createCell(8);
					celda.setCellValue(comprobante.getTotalComprobante().toPlainString());
					k++;
				}
				i++;
				
			}
			/**
			 * BOLETAS
			 */
			hoja = libro.createSheet("Boletas");
			fila = hoja.createRow(0);
			celda = fila.createCell(0);
			celda.setCellValue("ID");
			celda = fila.createCell(1);
			celda.setCellValue("Tipo Comprobante");
			celda = fila.createCell(2);
			celda.setCellValue("Numero Serie");
			celda = fila.createCell(3);
			celda.setCellValue("Numero Comprobante");
			celda = fila.createCell(4);
			celda.setCellValue("Titular");
			celda = fila.createCell(5);
			celda.setCellValue("Fecha comprobante");
			celda = fila.createCell(6);
			celda.setCellValue("Detalle Comprobante");
			celda = fila.createCell(7);
			celda.setCellValue("Total IGV");
			celda = fila.createCell(8);
			celda.setCellValue("Total Compronbante");
			conceptosTotal = "";
			i=1;
			k=1;
			while (i<lista.size()) {
				Comprobante comprobante = lista.get(i);
				if (comprobante.getTipoComprobante().getCodigoEntero().intValue() == this.CODIGO_BOLETA){
					fila = hoja.createRow(k);
					celda = fila.createCell(0);
					celda.setCellValue(comprobante.getCodigoEntero().intValue());
					celda = fila.createCell(1);
					celda.setCellValue(comprobante.getTipoComprobante().getNombre());
					celda = fila.createCell(2);
					celda.setCellValue(comprobante.getNumeroSerie());
					celda = fila.createCell(3);
					celda.setCellValue(comprobante.getNumeroComprobante());
					celda = fila.createCell(4);
					celda.setCellValue(comprobante.getTitular().getNombres());
					celda = fila.createCell(5);
					celda.setCellValue(sdf.format(comprobante.getFechaComprobante()));
					conceptosTotal = "";
					for (int j=0; j<comprobante.getDetalleComprobante().size(); j++){
						DetalleComprobante detalle = comprobante.getDetalleComprobante().get(j);
						conceptosTotal = conceptosTotal + "- " + detalle.getConcepto() + "\n";
					}
					celda = fila.createCell(6);
					celda.setCellValue(conceptosTotal);
					celda = fila.createCell(7);
					celda.setCellValue(comprobante.getTotalIGV().toPlainString());
					celda = fila.createCell(8);
					celda.setCellValue(comprobante.getTotalComprobante().toPlainString());
					k++;
				}
				i++;
			}
			
			/**
			 * DOCUMENTO DE COBRANZA
			 */
			hoja = libro.createSheet("Documento Cobranza");
			fila = hoja.createRow(0);
			celda = fila.createCell(0);
			celda.setCellValue("ID");
			celda = fila.createCell(1);
			celda.setCellValue("Tipo Comprobante");
			celda = fila.createCell(2);
			celda.setCellValue("Numero Serie");
			celda = fila.createCell(3);
			celda.setCellValue("Numero Comprobante");
			celda = fila.createCell(4);
			celda.setCellValue("Titular");
			celda = fila.createCell(5);
			celda.setCellValue("Fecha comprobante");
			celda = fila.createCell(6);
			celda.setCellValue("Detalle Comprobante");
			celda = fila.createCell(7);
			celda.setCellValue("Total IGV");
			celda = fila.createCell(8);
			celda.setCellValue("Total Compronbante");
			conceptosTotal = "";
			i = 1;
			k=1;
			while (i<lista.size()) {
				Comprobante comprobante = lista.get(i);
				if (comprobante.getTipoComprobante().getCodigoEntero().intValue() == this.CODIGO_DOCUMENTOCOBRANZA){
					fila = hoja.createRow(k);
					celda = fila.createCell(0);
					celda.setCellValue(comprobante.getCodigoEntero().intValue());
					celda = fila.createCell(1);
					celda.setCellValue(comprobante.getTipoComprobante().getNombre());
					celda = fila.createCell(2);
					celda.setCellValue(comprobante.getNumeroSerie());
					celda = fila.createCell(3);
					celda.setCellValue(comprobante.getNumeroComprobante());
					celda = fila.createCell(4);
					celda.setCellValue(comprobante.getTitular().getNombres());
					celda = fila.createCell(5);
					celda.setCellValue(sdf.format(comprobante.getFechaComprobante()));
					conceptosTotal = "";
					for (int j=0; j<comprobante.getDetalleComprobante().size(); j++){
						DetalleComprobante detalle = comprobante.getDetalleComprobante().get(j);
						conceptosTotal = conceptosTotal + "- " + detalle.getConcepto() + "\n";
					}
					celda = fila.createCell(6);
					celda.setCellValue(conceptosTotal);
					celda = fila.createCell(7);
					celda.setCellValue(comprobante.getTotalIGV().toPlainString());
					celda = fila.createCell(8);
					celda.setCellValue(comprobante.getTotalComprobante().toPlainString());
					k++;
				}
				i++;
			}
			
			FileOutputStream outputArchivo = new FileOutputStream(archivoExcelComprobantes);
			libro.write(outputArchivo);
			libro.close();
			outputArchivo.flush();
			outputArchivo.close();
		} catch (NamingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (ErrorConsultaDataException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
