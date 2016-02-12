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

	@Override
	public boolean grabarEmpresa(EmpresaAgenciaViajes empresa)
			throws SQLException {
		Connection conn = null;
		CallableStatement cs = null;
		String sql = "";
		
		try{
			sql = "{ ? = call licencia.fn_ingresarempresa (?,?,?,?,?,?)}";
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.INTEGER);
			cs.setString(2, empresa.getRazonSocial());
			cs.setString(3, empresa.getNombreComercial());
			cs.setString(4, empresa.getNombreDominio());
			cs.setInt(5, empresa.getDocumentoIdentidad().getTipoDocumento().getCodigoEntero().intValue());
			cs.setString(6, empresa.getDocumentoIdentidad().getNumeroDocumento());
			cs.setString(7, empresa.getNombreContacto());
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
