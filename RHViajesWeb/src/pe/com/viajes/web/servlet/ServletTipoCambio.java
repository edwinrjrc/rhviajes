package pe.com.viajes.web.servlet;

import java.io.FileInputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

import javax.naming.NamingException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import pe.com.viajes.bean.negocio.TipoCambio;
import pe.com.viajes.negocio.exception.ValidacionException;
import pe.com.viajes.web.servicio.NegocioServicio;
import pe.com.viajes.web.servicio.impl.NegocioServicioImpl;

/**
 * Servlet implementation class ServletTipoCambio
 */
@WebServlet("/ServletTipoCambio")
public class ServletTipoCambio extends HttpServlet {
	private static final long serialVersionUID = 1L;
    
	private NegocioServicio negocioServicio;
    /**
     * @see HttpServlet#HttpServlet()
     */
    public ServletTipoCambio() {
        super();
    }
	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		try {
			negocioServicio = new NegocioServicioImpl(getServletContext());
			TipoCambio tipoCambio = null;
			//negocioServicio.registrarTipoCambio(tipoCambio);
			XSSFWorkbook archivoExcel = new XSSFWorkbook(new FileInputStream("D:\\TCSUNAT.xlsx"));
			XSSFSheet hoja = archivoExcel.getSheetAt(0);
			String ip = request.getRemoteAddr();
			for (int i=0; i<hoja.getLastRowNum(); i++){
				XSSFRow fila = hoja.getRow(i);
				XSSFCell celda1 = fila.getCell(0);
				XSSFCell celda2 = fila.getCell(1);
				System.out.println("Celda 1 ::"+obtenerValor(celda1));
				System.out.println("Celda 2 ::"+obtenerValor(celda2));
				tipoCambio = new TipoCambio();
				tipoCambio.getEmpresa().setCodigoEntero(1);
				tipoCambio.getMonedaOrigen().setCodigoEntero(2);
				tipoCambio.getMonedaDestino().setCodigoEntero(1);
				tipoCambio.setFechaTipoCambio(obtenerFecha(obtenerValor(celda1)));
				tipoCambio.getUsuarioCreacion().setCodigoEntero(1);
				tipoCambio.setIpCreacion(ip);
				tipoCambio.getUsuarioModificacion().setCodigoEntero(1);
				tipoCambio.setIpModificacion(ip);
				double montotipoCambio = Double.parseDouble(obtenerValor(celda2));
				tipoCambio.setMontoCambio(BigDecimal.valueOf(montotipoCambio));
				negocioServicio.registrarTipoCambioSunat(tipoCambio);
			}
		} catch (NamingException | ParseException | ValidacionException e) {
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
	
	String obtenerValor (XSSFCell celda){
		CellType tipo = celda.getCellTypeEnum();
		
		if (tipo == tipo.NUMERIC){
			return String.valueOf(celda.getNumericCellValue());
		}
		else if (tipo == tipo.STRING) {
			return celda.getStringCellValue();
		}
		return "";
	}

	Date obtenerFecha(String fecha) throws ParseException{
		SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
		return sdf.parse(fecha);
	}
}
