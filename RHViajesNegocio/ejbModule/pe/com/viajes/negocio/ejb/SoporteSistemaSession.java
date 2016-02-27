package pe.com.viajes.negocio.ejb;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.sql.Connection;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.ejb.Stateless;
import javax.ejb.TransactionManagement;
import javax.ejb.TransactionManagementType;
import javax.mail.MessagingException;
import javax.mail.NoSuchProviderException;
import javax.mail.internet.AddressException;
import javax.transaction.HeuristicMixedException;
import javax.transaction.HeuristicRollbackException;
import javax.transaction.NotSupportedException;
import javax.transaction.RollbackException;
import javax.transaction.SystemException;
import javax.transaction.UserTransaction;

import org.apache.commons.lang3.StringUtils;

import pe.com.viajes.bean.administracion.SentenciaSQL;
import pe.com.viajes.bean.licencia.ContratoLicencia;
import pe.com.viajes.bean.licencia.EmpresaAgenciaViajes;
import pe.com.viajes.bean.negocio.Maestro;
import pe.com.viajes.negocio.dao.EjecutaSentenciaSQLDao;
import pe.com.viajes.negocio.dao.SoporteSistemaDao;
import pe.com.viajes.negocio.dao.impl.EjecutaSentenciaSQLDaoImpl;
import pe.com.viajes.negocio.dao.impl.SoporteSistemaDaoImpl;
import pe.com.viajes.negocio.exception.EjecucionSQLException;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;
import pe.com.viajes.negocio.exception.ErrorEncriptacionException;
import pe.com.viajes.negocio.exception.ErrorRegistroDataException;
import pe.com.viajes.negocio.exception.RHViajesException;
import pe.com.viajes.negocio.util.UtilConexion;
import pe.com.viajes.negocio.util.UtilCorreo;
import pe.com.viajes.negocio.util.UtilEncripta;

/**
 * Session Bean implementation class SoporteSistemaSession
 */
@Stateless(name = "SoporteSistemaSession")
@TransactionManagement(TransactionManagementType.BEAN)
public class SoporteSistemaSession implements SoporteSistemaSessionRemote, SoporteSistemaSessionLocal {

	@Resource
	private UserTransaction userTransaction;
	
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
				sentenciaSQL.setInsercion("CREATE".equals(StringUtils.upperCase(sql_1)));
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
    
    @Override
    public List<Maestro> listarMaestro(int idMaestro) throws ErrorConsultaDataException, RHViajesException{
    	List<Maestro> lista = null;
    	try {
			try {
				userTransaction.begin();
				SoporteSistemaDao soporteSistema = new SoporteSistemaDaoImpl();
				
				lista = soporteSistema.listarMaestro(idMaestro);
				userTransaction.commit();
			} catch (SQLException e) {
				userTransaction.rollback();
				throw new ErrorConsultaDataException("Error al consultar maestro", e);
			}
		} catch (SecurityException e) {
			throw new RHViajesException("Error al consultar maestro", e);
		} catch (IllegalStateException e) {
			throw new RHViajesException("Error al consultar maestro", e);
		} catch (NotSupportedException e) {
			throw new RHViajesException("Error al consultar maestro", e);
		} catch (SystemException e) {
			throw new RHViajesException("Error al consultar maestro", e);
		} catch (RollbackException e) {
			throw new RHViajesException("Error al consultar maestro", e);
		} catch (HeuristicMixedException e) {
			throw new RHViajesException("Error al consultar maestro", e);
		} catch (HeuristicRollbackException e) {
			throw new RHViajesException("Error al consultar maestro", e);
		}
    	
    	return lista;
    }
    
    @Override
    public boolean grabarEmpresa(EmpresaAgenciaViajes empresa) throws ErrorRegistroDataException, RHViajesException{
    	boolean resultado = false;
    		
    	try {
			try {
				userTransaction.begin();
				SoporteSistemaDao soporteSistema = new SoporteSistemaDaoImpl();
				
				resultado = soporteSistema.grabarEmpresa(empresa);
				userTransaction.commit();
			} catch (SQLException e) {
				userTransaction.rollback();
				throw new ErrorRegistroDataException("Error en registro de empresa", e);
			}
		} catch (SecurityException e) {
			throw new RHViajesException("Error en transaccion", e);
		} catch (IllegalStateException e) {
			throw new RHViajesException("Error en transaccion", e);
		} catch (NotSupportedException e) {
			throw new RHViajesException("Error en transaccion", e);
		} catch (SystemException e) {
			throw new RHViajesException("Error en transaccion", e);
		} catch (RollbackException e) {
			throw new RHViajesException("Error en transaccion", e);
		} catch (HeuristicMixedException e) {
			throw new RHViajesException("Error en transaccion", e);
		} catch (HeuristicRollbackException e) {
			throw new RHViajesException("Error en transaccion", e);
		}
    	
    	return resultado;
    }
    
    
    @Override
    public List<EmpresaAgenciaViajes> listarEmpresas() throws ErrorConsultaDataException, RHViajesException {
    	List<EmpresaAgenciaViajes> lista = null;
    	try {
			try {
				userTransaction.begin();
				SoporteSistemaDao soporteSistema = new SoporteSistemaDaoImpl();
				
				lista = soporteSistema.listarEmpresas();
				userTransaction.commit();
			} catch (SQLException e) {
				userTransaction.rollback();
				throw new ErrorConsultaDataException("Error al consultar empresas", e);
			}
		} catch (SecurityException e) {
			throw new RHViajesException("Error al consultar empresas", e);
		} catch (IllegalStateException e) {
			throw new RHViajesException("Error al consultar empresas", e);
		} catch (NotSupportedException e) {
			throw new RHViajesException("Error al consultar empresas", e);
		} catch (SystemException e) {
			throw new RHViajesException("Error al consultar empresas", e);
		} catch (RollbackException e) {
			throw new RHViajesException("Error al consultar empresas", e);
		} catch (HeuristicMixedException e) {
			throw new RHViajesException("Error al consultar empresas", e);
		} catch (HeuristicRollbackException e) {
			throw new RHViajesException("Error al consultar empresas", e);
		}
    	
    	return lista;
    }

    @Override
    public List<ContratoLicencia> listarContratos() throws ErrorConsultaDataException, RHViajesException {
    	List<ContratoLicencia> lista = null;
    	try {
			try {
				userTransaction.begin();
				SoporteSistemaDao soporteSistema = new SoporteSistemaDaoImpl();
				
				lista = soporteSistema.listarContratos();
				userTransaction.commit();
			} catch (SQLException e) {
				userTransaction.rollback();
				throw new ErrorConsultaDataException("Error al consultar empresas", e);
			}
		} catch (SecurityException e) {
			throw new RHViajesException("Error al consultar empresas", e);
		} catch (IllegalStateException e) {
			throw new RHViajesException("Error al consultar empresas", e);
		} catch (NotSupportedException e) {
			throw new RHViajesException("Error al consultar empresas", e);
		} catch (SystemException e) {
			throw new RHViajesException("Error al consultar empresas", e);
		} catch (RollbackException e) {
			throw new RHViajesException("Error al consultar empresas", e);
		} catch (HeuristicMixedException e) {
			throw new RHViajesException("Error al consultar empresas", e);
		} catch (HeuristicRollbackException e) {
			throw new RHViajesException("Error al consultar empresas", e);
		}
    	
    	return lista;
    }
    
    
    @Override
    public boolean grabarContrato(ContratoLicencia contrato) throws ErrorRegistroDataException, RHViajesException{
    	boolean resultado = false;
    		
    	try {
			try {
				userTransaction.begin();
				SoporteSistemaDao soporteSistema = new SoporteSistemaDaoImpl();
				
				contrato.getEstado().setCodigoEntero(1);
				resultado = soporteSistema.grabarContrato(contrato);
				
				EmpresaAgenciaViajes empresa = null;
				String serial = this.generaSerialContrato(contrato);
				String mensaje = "";
				enviarCorreoSerialContrato(empresa, mensaje);
				
				userTransaction.commit();
			} catch (SQLException e) {
				userTransaction.rollback();
				throw new ErrorRegistroDataException("Error en registro de empresa", e);
			}
		} catch (SecurityException e) {
			throw new RHViajesException("Error en transaccion", e);
		} catch (IllegalStateException e) {
			throw new RHViajesException("Error en transaccion", e);
		} catch (NotSupportedException e) {
			throw new RHViajesException("Error en transaccion", e);
		} catch (SystemException e) {
			throw new RHViajesException("Error en transaccion", e);
		} catch (RollbackException e) {
			throw new RHViajesException("Error en transaccion", e);
		} catch (HeuristicMixedException e) {
			throw new RHViajesException("Error en transaccion", e);
		} catch (HeuristicRollbackException e) {
			throw new RHViajesException("Error en transaccion", e);
		}
    	
    	return resultado;
    }
    
    private void enviarCorreoSerialContrato(EmpresaAgenciaViajes empresa, String mensaje) throws RHViajesException {
		try {
			UtilCorreo utilCorreo = new UtilCorreo();
			utilCorreo.enviarCorreo(empresa.getCorreoContacto(), "Clave Serial de contrato", mensaje);
		} catch (AddressException e) {
			throw new RHViajesException(e);
		} catch (FileNotFoundException e) {
			throw new RHViajesException(e);
		} catch (ErrorEncriptacionException e) {
			throw new RHViajesException(e);
		} catch (NoSuchProviderException e) {
			throw new RHViajesException(e);
		} catch (UnsupportedEncodingException e) {
			throw new RHViajesException(e);
		} catch (IOException e) {
			throw new RHViajesException(e);
		} catch (MessagingException e) {
			throw new RHViajesException(e);
		}
	}

	@Override
    public String generaSerialContrato(ContratoLicencia contrato) throws ErrorEncriptacionException, RHViajesException {
    	try {
			String llave = "";
			
			SimpleDateFormat sdf = new SimpleDateFormat("ddMMyyyy");
			llave = llave + "|"+contrato.getEmpresaAgencia().getDocumentoIdentidad().getNumeroDocumento();
			llave = llave + "|" + contrato.getEmpresaAgencia().getRazonSocial();
			llave = llave + "|" + contrato.getNumeroUsuarios();
			llave = llave + "|" + sdf.format(contrato.getFechaInicio());
			llave = llave + "|" + sdf.format(contrato.getFechaFin()) + "|";
			
			return UtilEncripta.encriptaCadena(llave);
		} catch (ErrorEncriptacionException e) {
			throw new ErrorEncriptacionException(e);
		} catch (Exception e){
			throw new RHViajesException(e);
		}
    }
}
