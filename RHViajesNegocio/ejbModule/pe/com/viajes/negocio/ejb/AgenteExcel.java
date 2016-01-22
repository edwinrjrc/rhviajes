package pe.com.viajes.negocio.ejb;

import java.io.InputStream;

import javax.ejb.Stateless;

/**
 * Session Bean implementation class AgenteExcel
 */
@Stateless(name = "AgenteExcel")
public class AgenteExcel implements AgenteExcelRemote, AgenteExcelLocal {

	/**
	 * Default constructor.
	 */
	public AgenteExcel() {
		// TODO Auto-generated constructor stub
	}

	public void enviarCorreoMasivo(InputStream is) {
		/*
		 * try { HSSFWorkbook libro = new HSSFWorkbook(is); HSSFSheet hoja =
		 * libro.getSheetAt(0); Iterator rowIterator = hoja.rowIterator();
		 * rowIterator.next();
		 * 
		 * List<ClienteCorreo> correosExternos = new ArrayList<ClienteCorreo>();
		 * ClienteCorreo clienteCorreo = null; while (rowIterator.hasNext()) {
		 * HSSFRow fila = (HSSFRow) rowIterator.next();
		 * 
		 * HSSFCell celdaNombre = fila.getCell(0); HSSFCell celdaApellidos =
		 * fila.getCell(1); HSSFCell celdaCorreo = fila.getCell(2);
		 * clienteCorreo = new ClienteCorreo();
		 * clienteCorreo.setNombres(celdaNombre.getStringCellValue());
		 * clienteCorreo.setApellidos(celdaApellidos.getStringCellValue());
		 * clienteCorreo.setCorreo(celdaCorreo.getStringCellValue());
		 * correosExternos.add(clienteCorreo); }
		 * 
		 * 
		 * } catch (IOException e) { e.printStackTrace(); }
		 */

	}

}
