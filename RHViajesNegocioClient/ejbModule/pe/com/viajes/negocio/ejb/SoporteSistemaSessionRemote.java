package pe.com.viajes.negocio.ejb;

import java.util.List;

import javax.ejb.Remote;

import pe.com.viajes.bean.administracion.SentenciaSQL;
import pe.com.viajes.bean.licencia.EmpresaAgenciaViajes;
import pe.com.viajes.bean.negocio.Maestro;
import pe.com.viajes.negocio.exception.EjecucionSQLException;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;
import pe.com.viajes.negocio.exception.ErrorRegistroDataException;
import pe.com.viajes.negocio.exception.RHViajesException;

@Remote
public interface SoporteSistemaSessionRemote {

	/**
	 * 
	 * @param sentenciaSQL
	 * @return
	 * @throws EjecucionSQLException
	 * @throws RHViajesException
	 */
	SentenciaSQL ejecutarSentenciaSQL(SentenciaSQL sentenciaSQL)
			throws EjecucionSQLException, RHViajesException;

	/**
	 * 
	 * @param idMaestro
	 * @return
	 * @throws ErrorConsultaDataException
	 * @throws RHViajesException
	 */
	List<Maestro> listarMaestro(int idMaestro)
			throws ErrorConsultaDataException, RHViajesException;

	/**
	 * 
	 * @param empresa
	 * @return
	 * @throws ErrorRegistroDataException
	 * @throws RHViajesException
	 */
	boolean grabarEmpresa(EmpresaAgenciaViajes empresa)
			throws ErrorRegistroDataException, RHViajesException;

	/**
	 * 
	 * @return
	 * @throws ErrorConsultaDataException
	 * @throws RHViajesException
	 */
	List<EmpresaAgenciaViajes> listarEmpresas()
			throws ErrorConsultaDataException, RHViajesException;

}
