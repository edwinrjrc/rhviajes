/**
 * 
 */
package pe.com.viajes.negocio.dao.impl;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Types;

import org.apache.commons.lang3.StringUtils;

import pe.com.viajes.bean.base.Persona;
import pe.com.viajes.negocio.dao.PersonaDao;
import pe.com.viajes.negocio.util.UtilJdbc;

/**
 * @author Edwin
 *
 */
public class PersonaDaoImpl implements PersonaDao {

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * pe.com.viajes.negocio.dao.ProveedorDao#registrarProveedor(pe.com.logistica
	 * .bean.negocio.Proveedor)
	 */
	@Override
	public int registrarPersona(Persona persona, Connection conexion)
			throws SQLException {
		int resultado = 0;
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_ingresarpersona(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) }";

		try {
			cs = conexion.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.INTEGER);
			cs.setInt(i++, persona.getEmpresa().getCodigoEntero().intValue());
			cs.setInt(i++, persona.getTipoPersona());
			if (StringUtils.isNotBlank(persona.getNombres())) {
				cs.setString(i++,
						UtilJdbc.convertirMayuscula(persona.getNombres()));
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (StringUtils.isNotBlank(persona.getApellidoPaterno())) {
				cs.setString(i++, UtilJdbc.convertirMayuscula(persona
						.getApellidoPaterno()));
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (StringUtils.isNotBlank(persona.getApellidoMaterno())) {
				cs.setString(i++, UtilJdbc.convertirMayuscula(persona
						.getApellidoMaterno()));
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (StringUtils.isNotBlank(persona.getGenero().getCodigoCadena())) {
				cs.setString(i++, persona.getGenero().getCodigoCadena());
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (persona.getEstadoCivil().getCodigoEntero() != null
					&& !Integer.valueOf(0).equals(
							persona.getEstadoCivil().getCodigoEntero())) {
				cs.setInt(i++, persona.getEstadoCivil().getCodigoEntero());
			} else {
				cs.setNull(i++, Types.INTEGER);
			}
			if (persona.getDocumentoIdentidad().getTipoDocumento()
					.getCodigoEntero() != null
					&& !Integer.valueOf(0).equals(
							persona.getDocumentoIdentidad().getTipoDocumento()
									.getCodigoEntero())) {
				cs.setInt(i++, persona.getDocumentoIdentidad()
						.getTipoDocumento().getCodigoEntero());
			} else {
				cs.setNull(i++, Types.INTEGER);
			}
			if (StringUtils.isNotBlank(persona.getDocumentoIdentidad()
					.getNumeroDocumento())) {
				cs.setString(i++, UtilJdbc.convertirMayuscula(persona
						.getDocumentoIdentidad().getNumeroDocumento()));
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (persona.getUsuarioCreacion() != null ) {
				cs.setInt(i++, persona.getUsuarioCreacion().getCodigoEntero().intValue());
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (StringUtils.isNotBlank(persona.getIpCreacion())) {
				cs.setString(i++, persona.getIpCreacion());
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (persona.getFechaNacimiento() != null) {
				cs.setDate(i++, UtilJdbc.convertirUtilDateSQLDate(persona
						.getFechaNacimiento()));
			} else {
				cs.setNull(i++, Types.DATE);
			}
			if (StringUtils.isNotBlank(persona.getNroPasaporte())) {
				cs.setString(i++, persona.getNroPasaporte());
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (persona.getFechaVctoPasaporte() != null) {
				cs.setDate(i++, UtilJdbc.convertirUtilDateSQLDate(persona
						.getFechaVctoPasaporte()));
			} else {
				cs.setNull(i++, Types.DATE);
			}
			if (persona.getNacionalidad().getCodigoEntero() != null && persona.getNacionalidad().getCodigoEntero().intValue()!=0){
				cs.setInt(i++, persona.getNacionalidad().getCodigoEntero().intValue());
			}
			else{
				cs.setNull(i++, Types.INTEGER);
			}

			cs.execute();
			resultado = cs.getInt(1);
		} catch (SQLException e) {
			resultado = 0;
			throw new SQLException(e);
		} finally {
			try {
				if (cs != null) {
					cs.close();
				}
			} catch (SQLException e) {
				throw new SQLException(e);
			}
		}

		return resultado;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * pe.com.viajes.negocio.dao.ProveedorDao#actualizarProveedor(pe.com.
	 * logistica.bean.negocio.Proveedor)
	 */
	@Override
	public int actualizarPersona(Persona persona, Connection conexion)
			throws SQLException {
		int resultado = 0;
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_actualizarpersona(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) }";

		try {
			cs = conexion.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.INTEGER);
			cs.setInt(i++, persona.getEmpresa().getCodigoEntero().intValue());
			cs.setInt(i++, persona.getCodigoEntero().intValue());
			cs.setInt(i++, persona.getTipoPersona());
			if (StringUtils.isNotBlank(persona.getNombres())) {
				cs.setString(i++,
						UtilJdbc.convertirMayuscula(persona.getNombres()));
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (StringUtils.isNotBlank(persona.getApellidoPaterno())) {
				cs.setString(i++, UtilJdbc.convertirMayuscula(persona
						.getApellidoPaterno()));
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (StringUtils.isNotBlank(persona.getApellidoMaterno())) {
				cs.setString(i++, UtilJdbc.convertirMayuscula(persona
						.getApellidoMaterno()));
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (StringUtils.isNotBlank(persona.getGenero().getCodigoCadena())) {
				cs.setString(i++, persona.getGenero().getCodigoCadena());
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (persona.getEstadoCivil().getCodigoEntero() != null
					&& !Integer.valueOf(0).equals(
							persona.getEstadoCivil().getCodigoEntero())) {
				cs.setInt(i++, persona.getEstadoCivil().getCodigoEntero());
			} else {
				cs.setNull(i++, Types.INTEGER);
			}
			if (persona.getDocumentoIdentidad().getTipoDocumento()
					.getCodigoEntero() != null
					&& !Integer.valueOf(0).equals(
							persona.getDocumentoIdentidad().getTipoDocumento()
									.getCodigoEntero())) {
				cs.setInt(i++, persona.getDocumentoIdentidad()
						.getTipoDocumento().getCodigoEntero());
			} else {
				cs.setNull(i++, Types.INTEGER);
			}
			if (StringUtils.isNotBlank(persona.getDocumentoIdentidad()
					.getNumeroDocumento())) {
				cs.setString(i++, UtilJdbc.convertirMayuscula(persona
						.getDocumentoIdentidad().getNumeroDocumento()));
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (persona.getUsuarioModificacion() != null) {
				cs.setInt(i++, persona
						.getUsuarioModificacion().getCodigoEntero().intValue());
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (StringUtils.isNotBlank(persona.getIpModificacion())) {
				cs.setString(i++, persona.getIpModificacion());
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (persona.getFechaNacimiento() != null) {
				cs.setDate(i++, UtilJdbc.convertirUtilDateSQLDate(persona
						.getFechaNacimiento()));
			} else {
				cs.setNull(i++, Types.DATE);
			}
			if (StringUtils.isNotBlank(persona.getNroPasaporte())) {
				cs.setString(i++, persona.getNroPasaporte());
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (persona.getFechaVctoPasaporte() != null) {
				cs.setDate(i++, UtilJdbc.convertirUtilDateSQLDate(persona
						.getFechaVctoPasaporte()));
			} else {
				cs.setNull(i++, Types.DATE);
			}
			cs.setInt(i++, persona.getNacionalidad().getCodigoEntero().intValue());

			cs.execute();
			resultado = cs.getInt(1);
		} catch (SQLException e) {
			resultado = 0;
			throw new SQLException(e);
		} finally {
			try {
				if (cs != null) {
					cs.close();
				}
			} catch (SQLException e) {
				throw new SQLException(e);
			}
		}

		return resultado;
	}

}
