package pe.com.viajes.negocio.ejb;

import javax.ejb.Remote;

import pe.com.viajes.bean.administracion.SentenciaSQL;
import pe.com.viajes.negocio.exception.EjecucionSQLException;
import pe.com.viajes.negocio.exception.RHViajesException;

@Remote
public interface SoporteSistemaSessionRemote {

	SentenciaSQL ejecutarSentenciaSQL(SentenciaSQL sentenciaSQL) throws EjecucionSQLException, RHViajesException;

}
