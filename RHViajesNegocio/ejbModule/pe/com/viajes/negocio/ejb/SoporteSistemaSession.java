package pe.com.viajes.negocio.ejb;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.ejb.Stateless;
import javax.ejb.TransactionManagement;
import javax.ejb.TransactionManagementType;
import javax.transaction.HeuristicMixedException;
import javax.transaction.HeuristicRollbackException;
import javax.transaction.NotSupportedException;
import javax.transaction.RollbackException;
import javax.transaction.SystemException;
import javax.transaction.UserTransaction;

import org.apache.commons.lang3.StringUtils;

import pe.com.viajes.bean.administracion.SentenciaSQL;
import pe.com.viajes.negocio.dao.EjecutaSentenciaSQLDao;
import pe.com.viajes.negocio.dao.impl.EjecutaSentenciaSQLDaoImpl;
import pe.com.viajes.negocio.ejb.SoporteSistemaSessionLocal;
import pe.com.viajes.negocio.ejb.SoporteSistemaSessionRemote;
import pe.com.viajes.negocio.exception.EjecucionSQLException;
import pe.com.viajes.negocio.exception.RHViajesException;
import pe.com.viajes.negocio.util.UtilConexion;

/**
 * Session Bean implementation class SoporteSistemaSession
 */
@Stateless(name = "SoporteSistemaSession")
@TransactionManagement(TransactionManagementType.BEAN)
public class SoporteSistemaSession implements SoporteSistemaSessionRemote, SoporteSistemaSessionLocal {

	@Resource
	private UserTransaction userTransaction;
	
    public SoporteSistemaSession() {
        // TODO Auto-generated constructor stub
    }
    
    @Override
    public SentenciaSQL ejecutarSentenciaSQL(SentenciaSQL sentenciaSQL) throws EjecucionSQLException, RHViajesException{
    	try {
			String sql = sentenciaSQL.getScript();
			sql = StringUtils.trimToEmpty(sql);
			if (StringUtils.isNotBlank(sql)){
				sql = StringUtils.normalizeSpace(sql);
				int i = StringUtils.indexOf(sql, " ");
				String sql_1 = StringUtils.substring(sql, 0, i);
				sql_1 = StringUtils.trim(sql_1);
				sentenciaSQL.setConsulta("SELECT".equals(StringUtils.upperCase(sql_1)));
				sentenciaSQL.setEliminacion("DELETE".equals(StringUtils.upperCase(sql_1)));
				sentenciaSQL.setInsercion("INSERT".equals(StringUtils.upperCase(sql_1)));
				sentenciaSQL.setActualizacion("UPDATE".equals(StringUtils.upperCase(sql_1)));
			}
			
			Connection conn = null;
			
			try {
				userTransaction.begin();
				conn = UtilConexion.obtenerConexion();
				
				EjecutaSentenciaSQLDao ejecutaSentenciaSQLDao = new EjecutaSentenciaSQLDaoImpl();
				if (sentenciaSQL.isConsulta()){
					Map<String, Object> resultado = ejecutaSentenciaSQLDao.ejecutarConsulta(sql, conn);
					
					sentenciaSQL.setResultadoConsulta(resultado);
				}
				else if (sentenciaSQL.isActualizacion() || sentenciaSQL.isEliminacion() || sentenciaSQL.isInsercion()) {
					sentenciaSQL.setMsjeTransaccion(ejecutaSentenciaSQLDao.ejecutarSentencia(sql, conn));
				}
				else{
					sentenciaSQL.setMsjeTransaccion("Sentencia SQL incorrecta");
				}
				
				userTransaction.commit();
			} catch (SQLException e) {
				userTransaction.rollback();
				throw new EjecucionSQLException("Error en ejecucion de sentencia SQL", e);
			} catch (NotSupportedException e) {
				userTransaction.rollback();
				throw new EjecucionSQLException("Error en ejecucion de sentencia SQL", e);
			} catch (SystemException e) {
				userTransaction.rollback();
				throw new EjecucionSQLException("Error en ejecucion de sentencia SQL", e);
			} catch (RollbackException e) {
				userTransaction.rollback();
				throw new EjecucionSQLException("Error en ejecucion de sentencia SQL", e);
			} catch (HeuristicMixedException e) {
				userTransaction.rollback();
				throw new EjecucionSQLException("Error en ejecucion de sentencia SQL", e);
			} catch (HeuristicRollbackException e) {
				userTransaction.rollback();
				throw new EjecucionSQLException("Error en ejecucion de sentencia SQL", e);
			} finally{
				if ( conn != null ){
					conn.close();
				}
			}
		} catch (IllegalStateException e) {
			throw new RHViajesException(e);
		} catch (SecurityException e) {
			throw new RHViajesException(e);
		} catch (SystemException e) {
			throw new RHViajesException(e);
		} catch (SQLException e){
			throw new RHViajesException(e);
		}
    	
    	
    	return sentenciaSQL;
    }

}
