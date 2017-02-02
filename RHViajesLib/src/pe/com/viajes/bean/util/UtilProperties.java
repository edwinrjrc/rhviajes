/**
 * 
 */
package pe.com.viajes.bean.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import org.apache.commons.lang3.StringUtils;

/**
 * @author edwreb
 *
 */
public class UtilProperties {

	public static Properties cargaArchivo(String archivoProperties)
			throws FileNotFoundException, IOException {
		
		String nombreOS = System.getProperty("os.name");
		String c = "";
		String d = "";
		if (StringUtils.contains(nombreOS, "Linux")){
			c = "/usr/local/share/aplicacion"
					+ File.separator + archivoProperties;
			d = "/usr/local/share/aplicacion"
					+ File.separator + archivoProperties;
		}
		else{
			c = "D:\\aplicacion"
					+ File.separator + archivoProperties;
			d = "D:\\aplicacion"
					+ File.separator + archivoProperties;
		}
		
		File fc = new File(c);

		Properties prop = new Properties();
		InputStream input = null;

		if (fc.exists()) {
			input = new FileInputStream(fc);
			prop.load(input);
		} else {
			fc = new File(d);
			if (fc.exists()) {
				input = new FileInputStream(fc);
				prop.load(input);
			}
		}

		return prop;
	}

}
