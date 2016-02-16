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

import org.apache.commons.lang3.StringUtils;

import pe.com.viajes.bean.base.Persona;
import pe.com.viajes.bean.negocio.Direccion;
import pe.com.viajes.negocio.dao.DireccionDao;
import pe.com.viajes.negocio.dao.TelefonoDao;
import pe.com.viajes.negocio.util.UtilConexion;
import pe.com.viajes.negocio.util.UtilJdbc;

/**
 * @author Edwin
 *
 */
public class DireccionDaoImpl implements DireccionDao {

	@Override
	public int registrarDireccion(Direccion direccion, Connection conexion)
			throws SQLException {
		int resultado = 0;
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_ingresardireccion(?,?,?,?,?,?,?,?,?,?,?,?,?,?) }";

		try {
			cs = conexion.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.INTEGER);
			cs.setInt(i++, direccion.getEmpresa().getCodigoEntero().intValue());
			cs.setInt(i++, direccion.getVia().getCodigoEntero());
			if (StringUtils.isNotBlank(direccion.getNombreVia())) {
				cs.setString(i++,
						UtilJdbc.convertirMayuscula(direccion.getNombreVia()));
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (StringUtils.isNotBlank(direccion.getNumero())) {
				cs.setString(i++, direccion.getNumero());
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (StringUtils.isNotBlank(direccion.getInterior())) {
				cs.setString(i++, direccion.getInterior());
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (StringUtils.isNotBlank(direccion.getManzana())) {
				cs.setString(i++,
						UtilJdbc.convertirMayuscula(direccion.getManzana()));
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (StringUtils.isNotBlank(direccion.getLote())) {
				cs.setString(i++,
						UtilJdbc.convertirMayuscula(direccion.getLote()));
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			cs.setString(i++, direccion.isPrincipal() ? "S" : "N");
			if (StringUtils.isNotBlank(direccion.getUbigeo().getCodigoCadena())) {
				cs.setString(i++, direccion.getUbigeo().getCodigoCadena());
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (direccion.getUsuarioCreacion().getCodigoEntero() != null) {
				cs.setInt(i++, direccion
						.getUsuarioCreacion().getCodigoEntero().intValue());
			} else {
				cs.setNull(i++, Types.INTEGER);
			}
			if (StringUtils.isNotBlank(direccion.getIpCreacion())) {
				cs.setString(i++, direccion.getIpCreacion());
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (StringUtils.isNotBlank(direccion.getObservaciones())) {
				cs.setString(i++, UtilJdbc.convertirMayuscula(direccion
						.getObservaciones()));
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (StringUtils.isNotBlank(direccion.getReferencia())) {
				cs.setString(i++,
						UtilJdbc.convertirMayuscula(direccion.getReferencia()));
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (direccion.getPais().getCodigoEntero() != null && direccion.getPais().getCodigoEntero().intValue() !=0){
				cs.setInt(i++, direccion.getPais().getCodigoEntero().intValue());
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

	@Override
	public void registrarPersonaDireccion(Persona persona,
			Direccion direccion, Connection conexion) throws SQLException {
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_ingresarpersonadireccion(?,?,?,?,?,?) }";

		try {
			cs = conexion.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.BOOLEAN);
			cs.setInt(i++, persona.getEmpresa().getCodigoEntero().intValue());
			cs.setInt(i++, persona.getCodigoEntero().intValue());
			cs.setInt(i++, persona.getTipoPersona());
			cs.setInt(i++, direccion.getCodigoEntero().intValue());
			cs.setInt(i++, persona.getUsuarioCreacion().getCodigoEntero().intValue());
			cs.setString(i++, persona.getIpCreacion());

			cs.execute();
		} catch (SQLException e) {
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
	}

	@Override
	public List<Direccion> consultarDireccionProveedor(int idProveedor, int idEmpresa)
			throws SQLException {
		List<Direccion> resultado = null;
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "select * "
				+ " from negocio.vw_consultadireccionproveedor where idpersona = ? and idempresa = ?";

		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			cs.setInt(1, idProveedor);
			cs.setInt(2, idEmpresa);
			rs = cs.executeQuery();

			resultado = new ArrayList<Direccion>();
			Direccion direccion = null;
			TelefonoDao telefonoDao = new TelefonoDaoImpl(idEmpresa);
			while (rs.next()) {
				direccion = new Direccion();
				direccion.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				direccion.getVia().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idvia"));
				direccion.setNombreVia(UtilJdbc.obtenerCadena(rs, "nombrevia"));
				direccion.setNumero(UtilJdbc.obtenerCadena(rs, "numero"));
				direccion.setInterior(UtilJdbc.obtenerCadena(rs, "interior"));
				direccion.setManzana(UtilJdbc.obtenerCadena(rs, "manzana"));
				direccion.setLote(UtilJdbc.obtenerCadena(rs, "lote"));
				direccion.setPrincipal(UtilJdbc.convertirBooleanSiNo(rs,
						"principal"));
				direccion.getUbigeo().setCodigoCadena(
						UtilJdbc.obtenerCadena(rs, "idubigeo"));
				direccion.getPais().setCodigoEntero(UtilJdbc.obtenerNumero(rs, "idpais"));
				direccion
						.getUbigeo()
						.getDepartamento()
						.setCodigoCadena(
								UtilJdbc.obtenerCadena(rs, "iddepartamento"));
				direccion.getUbigeo().getDepartamento()
						.setNombre(UtilJdbc.obtenerCadena(rs, "departamento"));
				direccion
						.getUbigeo()
						.getProvincia()
						.setCodigoCadena(
								UtilJdbc.obtenerCadena(rs, "idprovincia"));
				direccion.getUbigeo().getProvincia()
						.setNombre(UtilJdbc.obtenerCadena(rs, "provincia"));
				direccion
						.getUbigeo()
						.getDistrito()
						.setCodigoCadena(
								UtilJdbc.obtenerCadena(rs, "iddistrito"));
				direccion.getUbigeo().getDistrito()
						.setNombre(UtilJdbc.obtenerCadena(rs, "distrito"));
				direccion.getUsuarioCreacion().setCodigoEntero(UtilJdbc.obtenerNumero(rs,
						"idusuariocreacion"));
				direccion.setFechaCreacion(UtilJdbc.obtenerFecha(rs,
						"fechacreacion"));
				direccion.setIpCreacion(UtilJdbc
						.obtenerCadena(rs, "ipcreacion"));
				direccion.setObservaciones(UtilJdbc.obtenerCadena(rs,
						"observacion"));
				direccion.setReferencia(UtilJdbc
						.obtenerCadena(rs, "referencia"));
				direccion.setTelefonos(telefonoDao.consultarTelefonoDireccion(
						direccion.getCodigoEntero().intValue(), conn));
				direccion.getEmpresa().setCodigoEntero(idEmpresa);
				resultado.add(direccion);
			}

		} catch (SQLException e) {
			resultado = null;
			throw new SQLException(e);
		} finally {
			try {
				if (rs != null) {
					rs.close();
				}
				if (cs != null) {
					cs.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch (SQLException e) {
				try {
					if (conn != null) {
						conn.close();
					}
					throw new SQLException(e);
				} catch (SQLException e1) {
					throw new SQLException(e);
				}
			}
		}

		return resultado;
	}

	@Override
	public int actualizarDireccion(Direccion direccion, Connection conexion)
			throws SQLException {
		int resultado = 0;
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_actualizardireccion(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) }";

		try {
			cs = conexion.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.INTEGER);
			cs.setInt(i++, direccion.getEmpresa().getCodigoEntero().intValue());
			cs.setInt(i++, UtilJdbc.obtenerNumero(direccion.getCodigoEntero()));
			cs.setInt(i++, direccion.getVia().getCodigoEntero());
			if (StringUtils.isNotBlank(direccion.getNombreVia())) {
				cs.setString(i++,
						UtilJdbc.convertirMayuscula(direccion.getNombreVia()));
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (StringUtils.isNotBlank(direccion.getNumero())) {
				cs.setString(i++, direccion.getNumero());
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (StringUtils.isNotBlank(direccion.getInterior())) {
				cs.setString(i++, direccion.getInterior());
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (StringUtils.isNotBlank(direccion.getManzana())) {
				cs.setString(i++,
						UtilJdbc.convertirMayuscula(direccion.getManzana()));
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (StringUtils.isNotBlank(direccion.getLote())) {
				cs.setString(i++, direccion.getLote());
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			cs.setString(i++, direccion.isPrincipal() ? "S" : "N");
			if (StringUtils.isNotBlank(direccion.getUbigeo().getCodigoCadena())) {
				cs.setString(i++, direccion.getUbigeo().getCodigoCadena());
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (direccion.getUsuarioModificacion() != null) {
				cs.setInt(i++, direccion
						.getUsuarioModificacion().getCodigoEntero().intValue());
			} else {
				cs.setNull(i++, Types.INTEGER);
			}
			if (StringUtils.isNotBlank(direccion.getIpModificacion())) {
				cs.setString(i++, direccion.getIpModificacion());
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (StringUtils.isNotBlank(direccion.getObservaciones())) {
				cs.setString(i++, UtilJdbc.convertirMayuscula(direccion
						.getObservaciones()));
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (StringUtils.isNotBlank(direccion.getReferencia())) {
				cs.setString(i++,
						UtilJdbc.convertirMayuscula(direccion.getReferencia()));
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (direccion.getPais().getCodigoEntero() != null && direccion.getPais().getCodigoEntero().intValue() !=0){
				cs.setInt(i++, direccion.getPais().getCodigoEntero().intValue());
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

	@Override
	public boolean eliminarTelefonoDireccion(Direccion direccion,
			Connection conexion) throws SQLException {
		boolean resultado = false;
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_eliminartelefonosdireccion(?,?,?,?) }";

		try {
			cs = conexion.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.BOOLEAN);
			cs.setInt(i++, direccion.getEmpresa().getCodigoEntero().intValue());
			cs.setInt(i++, UtilJdbc.obtenerNumero(direccion.getCodigoEntero()));
			cs.setInt(i++, direccion
					.getUsuarioModificacion().getCodigoEntero().intValue());
			cs.setString(i++, direccion.getIpModificacion());

			cs.execute();
			resultado = cs.getBoolean(1);
		} catch (SQLException e) {
			resultado = false;
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

	@Override
	public boolean eliminarDireccionPersona(Persona persona, Connection conexion)
			throws SQLException {
		boolean resultado = false;
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_eliminardirecciones(?,?,?,?) }";

		try {
			cs = conexion.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.BOOLEAN);
			cs.setInt(i++, persona.getEmpresa().getCodigoEntero().intValue());
			cs.setInt(i++, persona.getCodigoEntero().intValue());
			cs.setInt(i++, persona
					.getUsuarioModificacion().getCodigoEntero().intValue());
			cs.setString(i++, persona.getIpModificacion());

			cs.execute();
			resultado = cs.getBoolean(1);
		} catch (SQLException e) {
			resultado = false;
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

	@Override
	public List<Direccion> consultarDireccionPersona(int idPersona, int idEmpresa)
			throws SQLException {
		List<Direccion> resultado = null;
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "{ ? = call negocio.fn_direccionesxpersona(?) }";

		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.OTHER);
			cs.setInt(2, idEmpresa);
			cs.setInt(3, idPersona);
			cs.execute();

			rs = (ResultSet) cs.getObject(1);
			resultado = new ArrayList<Direccion>();
			Direccion direccion = null;
			TelefonoDao telefonoDao = new TelefonoDaoImpl(idEmpresa);
			while (rs.next()) {
				direccion = new Direccion();
				direccion.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				direccion.getVia().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idvia"));
				direccion.setNombreVia(UtilJdbc.obtenerCadena(rs, "nombrevia"));
				direccion.setNumero(UtilJdbc.obtenerCadena(rs, "numero"));
				direccion.setInterior(UtilJdbc.obtenerCadena(rs, "interior"));
				direccion.setManzana(UtilJdbc.obtenerCadena(rs, "manzana"));
				direccion.setLote(UtilJdbc.obtenerCadena(rs, "lote"));
				direccion.setPrincipal(UtilJdbc.convertirBooleanSiNo(rs,
						"principal"));
				direccion.getUbigeo().setCodigoCadena(
						UtilJdbc.obtenerCadena(rs, "idubigeo"));
				direccion
						.getUbigeo()
						.getDepartamento()
						.setCodigoCadena(
								UtilJdbc.obtenerCadena(rs, "iddepartamento"));
				direccion.getUbigeo().getDepartamento()
						.setNombre(UtilJdbc.obtenerCadena(rs, "departamento"));
				direccion
						.getUbigeo()
						.getProvincia()
						.setCodigoCadena(
								UtilJdbc.obtenerCadena(rs, "idprovincia"));
				direccion.getUbigeo().getProvincia()
						.setNombre(UtilJdbc.obtenerCadena(rs, "provincia"));
				direccion
						.getUbigeo()
						.getDistrito()
						.setCodigoCadena(
								UtilJdbc.obtenerCadena(rs, "iddistrito"));
				direccion.getUbigeo().getDistrito()
						.setNombre(UtilJdbc.obtenerCadena(rs, "distrito"));
				direccion.getUsuarioCreacion().setCodigoEntero(UtilJdbc.obtenerNumero(rs,
						"usuariocreacion"));
				direccion.setFechaCreacion(UtilJdbc.obtenerFecha(rs,
						"fechacreacion"));
				direccion.setIpCreacion(UtilJdbc
						.obtenerCadena(rs, "ipcreacion"));
				direccion.setObservaciones(UtilJdbc.obtenerCadena(rs,
						"observacion"));
				direccion.setReferencia(UtilJdbc
						.obtenerCadena(rs, "referencia"));
				direccion.setTelefonos(telefonoDao.consultarTelefonoDireccion(
						direccion.getCodigoEntero().intValue(), conn));
				resultado.add(direccion);
			}

		} catch (SQLException e) {
			resultado = null;
			throw new SQLException(e);
		} finally {
			try {
				if (rs != null) {
					rs.close();
				}
				if (cs != null) {
					cs.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch (SQLException e) {
				try {
					if (conn != null) {
						conn.close();
					}
					throw new SQLException(e);
				} catch (SQLException e1) {
					throw new SQLException(e);
				}
			}
		}

		return resultado;
	}

	@Override
	public List<Direccion> consultarDireccionPersona(int idPersona, int idEmpresa, 
			Connection conn) throws SQLException {
		List<Direccion> resultado = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "{ ? = call negocio.fn_direccionesxpersona(?,?) }";

		try {
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.OTHER);
			cs.setInt(2, idEmpresa);
			cs.setInt(3, idPersona);
			cs.execute();

			rs = (ResultSet) cs.getObject(1);
			resultado = new ArrayList<Direccion>();
			Direccion direccion = null;
			TelefonoDao telefonoDao = new TelefonoDaoImpl(idEmpresa);
			while (rs.next()) {
				direccion = new Direccion();
				direccion.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				direccion.getVia().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idvia"));
				direccion.setNombreVia(UtilJdbc.obtenerCadena(rs, "nombrevia"));
				direccion.setNumero(UtilJdbc.obtenerCadena(rs, "numero"));
				direccion.setInterior(UtilJdbc.obtenerCadena(rs, "interior"));
				direccion.setManzana(UtilJdbc.obtenerCadena(rs, "manzana"));
				direccion.setLote(UtilJdbc.obtenerCadena(rs, "lote"));
				direccion.setPrincipal(UtilJdbc.convertirBooleanSiNo(rs,
						"principal"));
				direccion.getUbigeo().setCodigoCadena(
						UtilJdbc.obtenerCadena(rs, "idubigeo"));
				direccion
						.getUbigeo()
						.getDepartamento()
						.setCodigoCadena(
								UtilJdbc.obtenerCadena(rs, "iddepartamento"));
				direccion.getUbigeo().getDepartamento()
						.setNombre(UtilJdbc.obtenerCadena(rs, "departamento"));
				direccion
						.getUbigeo()
						.getProvincia()
						.setCodigoCadena(
								UtilJdbc.obtenerCadena(rs, "idprovincia"));
				direccion.getUbigeo().getProvincia()
						.setNombre(UtilJdbc.obtenerCadena(rs, "provincia"));
				direccion
						.getUbigeo()
						.getDistrito()
						.setCodigoCadena(
								UtilJdbc.obtenerCadena(rs, "iddistrito"));
				direccion.getUbigeo().getDistrito()
						.setNombre(UtilJdbc.obtenerCadena(rs, "distrito"));
				direccion.setObservaciones(UtilJdbc.obtenerCadena(rs,
						"observacion"));
				direccion.setReferencia(UtilJdbc
						.obtenerCadena(rs, "referencia"));
				direccion.setTelefonos(telefonoDao.consultarTelefonoDireccion(
						direccion.getCodigoEntero().intValue(), conn));
				direccion.getEmpresa().setCodigoEntero(idEmpresa);
				resultado.add(direccion);
			}

		} catch (SQLException e) {
			resultado = null;
			throw new SQLException(e);
		} finally {
			try {
				if (rs != null) {
					rs.close();
				}
				if (cs != null) {
					cs.close();
				}

			} catch (SQLException e) {
				throw new SQLException(e);

			}
		}

		return resultado;
	}

	@Override
	public boolean eliminarPersonaDirecciones(Persona persona, Connection conn)
			throws SQLException {
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_eliminarpersonadirecciones(?,?,?,?) }";

		try {
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.BOOLEAN);
			cs.setInt(2, persona.getEmpresa().getCodigoEntero().intValue());
			cs.setInt(3, persona.getCodigoEntero().intValue());
			cs.setInt(4, persona.getUsuarioModificacion().getCodigoEntero().intValue());
			cs.setString(5, persona.getIpModificacion());

			cs.execute();
			return cs.getBoolean(1);
		} catch (SQLException e) {
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
	}
}
