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

/**
 * @author edwreb
 *
 */
public class UtilProperties {

	public static Properties cargaArchivo(String archivoProperties)
			throws FileNotFoundException, IOException {
		String c = "/var/lib/openshift/55fcc5c37628e1e6b2000124/jbossas/aplicacion/"
				+ archivoProperties;
		String d = "/var/lib/openshift/55fcc5c37628e1e6b2000124/jbossas/aplicacion/"
				+ archivoProperties;
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
