/**
 * 
 */
package pe.com.viajes.negocio.dao.impl;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import pe.com.viajes.bean.licencia.ContratoLicencia;
import pe.com.viajes.bean.licencia.EmpresaAgenciaViajes;
import pe.com.viajes.bean.negocio.Maestro;
import pe.com.viajes.negocio.dao.SoporteSistemaDao;
import pe.com.viajes.negocio.util.UtilConexion;
import pe.com.viajes.negocio.util.UtilJdbc;

/**
 * @author EDWREB
 *
 */
public class SoporteSistemaDaoImpl implements SoporteSistemaDao {

	/* (non-Javadoc)
	 * @see pe.com.viajes.negocio.dao.SoporteSistemaDao#listarMaestro(int)
	 */
	@Override
	public List<Maestro> listarMaestro(int idMaestro) throws SQLException {
		List<Maestro> resultado = new ArrayList<Maestro>();
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "";
		
		try{
			sql = "{ ? = call licencia.fn_listarmaestro(?) }";
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.OTHER);
			cs.setInt(2, idMaestro);
			cs.execute();
			
			rs = (ResultSet) cs.getObject(1);
			
			Maestro bean = null;
			while (rs.next()){
				bean = new Maestro();
				bean.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				bean.setNombre(UtilJdbc.obtenerCadena(rs, "nombre"));
				bean.setDescripcion(UtilJdbc.obtenerCadena(rs, "descripcion"));
				bean.setOrden(UtilJdbc.obtenerNumero(rs, "orden"));
				bean.getEstado().setCodigoCadena(UtilJdbc.obtenerCadena(rs, "estado"));
				bean.setAbreviatura(UtilJdbc.obtenerCadena(rs, "abreviatura"));
				resultado.add(bean);
			}
		}
		finally{
			if (rs != null){
				rs.close();
			}
			if (cs != null){
				cs.close();
			}
			if (conn != null){
				conn.close();
			}
		}
		
		return resultado;
	}

	/*
	 * (non-Javadoc)
	 * @see pe.com.viajes.negocio.dao.SoporteSistemaDao#grabarEmpresa(pe.com.viajes.bean.licencia.EmpresaAgenciaViajes)
	 */
	@Override
	public boolean grabarEmpresa(EmpresaAgenciaViajes empresa)
			throws SQLException {
		Connection conn = null;
		CallableStatement cs = null;
		String sql = "";
		
		try{
			sql = "{ ? = call licencia.fn_ingresarempresa (?,?,?,?,?,?,?)}";
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.INTEGER);
			cs.setString(2, empresa.getRazonSocial());
			cs.setString(3, empresa.getNombreComercial());
			cs.setString(4, empresa.getNombreDominio());
			cs.setInt(5, empresa.getDocumentoIdentidad().getTipoDocumento().getCodigoEntero().intValue());
			cs.setString(6, empresa.getDocumentoIdentidad().getNumeroDocumento());
			cs.setString(7, empresa.getNombreContacto());
			cs.setString(8, empresa.getCorreoContacto());
			cs.execute();
			
			int r = cs.getInt(1);
			
			return (r != 0);
		}
		finally{
			if (cs != null){
				cs.close();
			}
			if (conn != null){
				conn.close();
			}
		}
	}
	
	/*
	 * (non-Javadoc)
	 * @see pe.com.viajes.negocio.dao.SoporteSistemaDao#listarEmpresas()
	 */
	@Override
	public List<EmpresaAgenciaViajes> listarEmpresas() throws SQLException {
		List<EmpresaAgenciaViajes> resultado = new ArrayList<EmpresaAgenciaViajes>();
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "";
		
		try{
			sql = "{ ? = call licencia.fn_listarempresas() }";
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.OTHER);
			cs.execute();
			
			rs = (ResultSet) cs.getObject(1);
			
			EmpresaAgenciaViajes bean = null;
			while (rs.next()){
				bean = new EmpresaAgenciaViajes();
				bean.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				bean.setRazonSocial(UtilJdbc.obtenerCadena(rs, "razonsocial"));
				bean.setNombreComercial(UtilJdbc.obtenerCadena(rs, "nombrecomercial"));
				bean.setNombreDominio(UtilJdbc.obtenerCadena(rs, "nombredominio"));
				bean.getDocumentoIdentidad().getTipoDocumento().setCodigoEntero(UtilJdbc.obtenerNumero(rs, "idtipodocumento"));
				bean.getDocumentoIdentidad().getTipoDocumento().setNombre(UtilJdbc.obtenerCadena(rs, "nombre"));
				bean.getDocumentoIdentidad().getTipoDocumento().setAbreviatura(UtilJdbc.obtenerCadena(rs, "abreviatura"));
				bean.getDocumentoIdentidad().setNumeroDocumento(UtilJdbc.obtenerCadena(rs, "numerodocumento"));
				bean.setNombreContacto(UtilJdbc.obtenerCadena(rs, "nombrecontacto"));
				bean.setCorreoContacto(UtilJdbc.obtenerCadena(rs, "correocontacto"));
				resultado.add(bean);
			}
			
			return resultado;
		}
		finally{
			if (rs != null){
				rs.close();
			}
			if (cs != null){
				cs.close();
			}
			if (conn != null){
				conn.close();
			}
		}
		
	}

	
	@Override
	public List<ContratoLicencia> listarContratos() throws SQLException {
		List<ContratoLicencia> resultado = new ArrayList<ContratoLicencia>();
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "";
		
		try{
			sql = "{ ? = call licencia.fn_listarcontratos() }";
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.OTHER);
			cs.execute();
			
			rs = (ResultSet) cs.getObject(1);
			
			ContratoLicencia bean = null;
			while (rs.next()){
				bean = new ContratoLicencia();
				bean.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				bean.setFechaInicio(UtilJdbc.obtenerFecha(rs, "fechainicio"));
				bean.setFechaFin(UtilJdbc.obtenerFecha(rs, "fechafin"));
				bean.setPrecioUsuario(UtilJdbc.obtenerBigDecimal(rs, "precioxusuario"));
				bean.setNumeroUsuarios(UtilJdbc.obtenerNumero(rs, "nrousuarios"));
				bean.getEmpresa().setCodigoEntero(UtilJdbc.obtenerNumero(rs, "idempresa"));
				bean.getEmpresa().setNombre(UtilJdbc.obtenerCadena(rs, "nombrecomercial"));
				bean.getEstado().setCodigoEntero(UtilJdbc.obtenerNumero(rs, "idestado"));
				bean.getEstado().setNombre(UtilJdbc.obtenerCadena(rs, "estadocontrato"));
				resultado.add(bean);
			}
			
			return resultado;
		}
		finally{
			if (rs != null){
				rs.close();
			}
			if (cs != null){
				cs.close();
			}
			if (conn != null){
				conn.close();
			}
		}
		
	}
	
	
	@Override
	public boolean grabarContrato(ContratoLicencia contrato)
			throws SQLException {
		Connection conn = null;
		CallableStatement cs = null;
		String sql = "";
		
		try{
			sql = "{ ? = call licencia.fn_ingresarcontrato (?,?,?,?,?,?,?)}";
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.INTEGER);
			cs.setDate(2, UtilJdbc.convertirUtilDateSQLDate(contrato.getFechaInicio()));
			cs.setDate(3, UtilJdbc.convertirUtilDateSQLDate(contrato.getFechaFin()));
			cs.setBigDecimal(4, contrato.getPrecioUsuario());
			cs.setInt(5, contrato.getNumeroUsuarios());
			cs.setInt(6, contrato.getEmpresa().getCodigoEntero().intValue());
			cs.setInt(7, contrato.getEstado().getCodigoEntero().intValue());
			cs.execute();
			
			int r = cs.getInt(1);
			
			return (r != 0);
		}
		finally{
			if (cs != null){
				cs.close();
			}
			if (conn != null){
				conn.close();
			}
		}
	}
}
