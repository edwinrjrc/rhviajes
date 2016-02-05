/**
 * 
 */
package pe.com.viajes.web.servicio;

import pe.com.viajes.bean.administracion.SentenciaSQL;
import pe.com.viajes.negocio.exception.EjecucionSQLException;
import pe.com.viajes.negocio.exception.RHViajesException;

/**
 * @author EDWREB
 *
 */
public interface SoporteSistemaServicio {

	public SentenciaSQL ejecutarSentenciaSQL(SentenciaSQL sentenciaSQL) throws EjecucionSQLException, RHViajesException;
}
