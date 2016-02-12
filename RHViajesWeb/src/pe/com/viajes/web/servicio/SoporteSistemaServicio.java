/**
 * 
 */
package pe.com.viajes.web.servicio;

import java.util.List;

import pe.com.viajes.bean.administracion.SentenciaSQL;
import pe.com.viajes.bean.licencia.EmpresaAgenciaViajes;
import pe.com.viajes.bean.negocio.Maestro;
import pe.com.viajes.negocio.exception.EjecucionSQLException;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;
import pe.com.viajes.negocio.exception.ErrorRegistroDataException;
import pe.com.viajes.negocio.exception.RHViajesException;

/**
 * @author EDWREB
 *
 */
public interface SoporteSistemaServicio {

	public SentenciaSQL ejecutarSentenciaSQL(SentenciaSQL sentenciaSQL)
			throws EjecucionSQLException, RHViajesException;

	List<Maestro> listarMaestro(int idMaestro)
			throws ErrorConsultaDataException;

	boolean grabarEmpresa(EmpresaAgenciaViajes empresa)
			throws ErrorRegistroDataException;
}
