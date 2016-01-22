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

import pe.com.viajes.bean.negocio.Cliente;
import pe.com.viajes.bean.negocio.ProgramaNovios;
import pe.com.viajes.bean.negocio.ServicioNovios;
import pe.com.viajes.negocio.dao.ServicioNoviosDao;
import pe.com.viajes.negocio.util.UtilConexion;
import pe.com.viajes.negocio.util.UtilJdbc;

/**
 * @author Edwin
 *
 */
public class ServicioNoviosDaoImpl implements ServicioNoviosDao {
	
	
	private int idEmpresa = 0;

	/**
	 * 
	 */
	public ServicioNoviosDaoImpl(int idEmpresa) {
		this.idEmpresa = idEmpresa;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * pe.com.viajes.negocio.dao.ServicioNoviosDao#registrarNovios(pe.com
	 * .logistica.bean.negocio.ProgramaNovios)
	 */
	@Override
	public Integer registrarNovios(ProgramaNovios programaNovios)
			throws SQLException {
		Integer codigoNovios = 0;
		Connection conn = null;
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_ingresarprogramanovios(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) }";
		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.INTEGER);
			cs.setInt(i++, idEmpresa);
			cs.setInt(i++, programaNovios.getNovia().getCodigoEntero());
			cs.setInt(i++, programaNovios.getNovio().getCodigoEntero());
			cs.setInt(i++, programaNovios.getDestino().getCodigoEntero());
			cs.setDate(i++, UtilJdbc.convertirUtilDateSQLDate(programaNovios
					.getFechaBoda()));
			cs.setDate(i++, UtilJdbc.convertirUtilDateSQLDate(programaNovios
					.getFechaViaje()));
			cs.setInt(i++, programaNovios.getMoneda().getCodigoEntero());
			cs.setBigDecimal(i++, programaNovios.getCuotaInicial());
			cs.setInt(i++, programaNovios.getNroDias());
			cs.setInt(i++, programaNovios.getNroNoches());
			cs.setDate(i++, UtilJdbc.convertirUtilDateSQLDate(programaNovios
					.getFechaShower()));
			if (StringUtils.isNotBlank(programaNovios.getObservaciones())) {
				cs.setString(i++, programaNovios.getObservaciones());
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			cs.setBigDecimal(i++,
					programaNovios.getMontoTotalServiciosPrograma());
			cs.setInt(i++, programaNovios.getIdServicio());
			cs.setInt(i++, programaNovios.getUsuarioCreacion().getCodigoEntero().intValue());
			cs.setString(i++, programaNovios.getIpCreacion());
			cs.execute();

			codigoNovios = cs.getInt(1);
		} catch (SQLException e) {
			codigoNovios = 0;
			throw new SQLException(e);
		} finally {
			try {
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

		return codigoNovios;
	}

	@Override
	public Integer registrarNovios(ProgramaNovios programaNovios,
			Connection conn) throws SQLException, Exception {
		Integer codigoNovios = 0;
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_ingresarprogramanovios(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) }";
		try {
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.INTEGER);
			cs.setInt(i++, idEmpresa);
			cs.setInt(i++, programaNovios.getNovia().getCodigoEntero());
			cs.setInt(i++, programaNovios.getNovio().getCodigoEntero());
			cs.setInt(i++, programaNovios.getDestino().getCodigoEntero());
			cs.setDate(i++, UtilJdbc.convertirUtilDateSQLDate(programaNovios
					.getFechaBoda()));
			cs.setDate(i++, UtilJdbc.convertirUtilDateSQLDate(programaNovios
					.getFechaViaje()));
			cs.setInt(i++, programaNovios.getMoneda().getCodigoEntero());
			cs.setBigDecimal(i++, programaNovios.getCuotaInicial());
			cs.setInt(i++, programaNovios.getNroDias());
			cs.setInt(i++, programaNovios.getNroNoches());
			cs.setDate(i++, UtilJdbc.convertirUtilDateSQLDate(programaNovios
					.getFechaShower()));
			if (StringUtils.isNotBlank(programaNovios.getObservaciones())) {
				cs.setString(i++, programaNovios.getObservaciones());
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			cs.setBigDecimal(i++,
					programaNovios.getMontoTotalServiciosPrograma());
			cs.setInt(i++, programaNovios.getIdServicio());
			cs.setInt(i++, programaNovios.getUsuarioCreacion().getCodigoEntero().intValue());
			cs.setString(i++, programaNovios.getIpCreacion());
			cs.execute();

			codigoNovios = cs.getInt(1);
		} catch (SQLException e) {
			codigoNovios = 0;
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

		return codigoNovios;
	}

	@Override
	public boolean registrarInvitado(Cliente invitado, Integer idnovios,
			Connection conn) throws SQLException, Exception {
		boolean resultado = false;
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_ingresainvitado(?,?,?,?,?,?,?,?,?,?) }";
		try {
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.BOOLEAN);
			cs.setInt(i++, idEmpresa);
			cs.setString(i++, invitado.getNombres());
			cs.setString(i++, invitado.getApellidoPaterno());
			cs.setString(i++, invitado.getApellidoMaterno());
			if (invitado.getFechaNacimiento() != null) {
				cs.setDate(i++, UtilJdbc.convertirUtilDateSQLDate(invitado
						.getFechaNacimiento()));
			} else {
				cs.setNull(i++, Types.DATE);
			}
			cs.setString(i++, invitado.getTelefonoInvitadoNovios());
			cs.setString(i++, invitado.getCorreoElectronico());
			cs.setInt(i++, idnovios);
			cs.setInt(i++, invitado.getUsuarioCreacion().getCodigoEntero().intValue());
			cs.setString(i++, invitado.getIpCreacion());
			cs.execute();

			resultado = true;
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
	public List<ProgramaNovios> consultarNovios(ProgramaNovios programaNovios)
			throws SQLException {
		List<ProgramaNovios> resultado = null;
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "{ ? = call negocio.fn_consultarnovios(?,?,?,?,?)}";

		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.OTHER);
			cs.setInt(i++, idEmpresa);
			if (programaNovios.getCodigoEntero() != null
					&& programaNovios.getCodigoEntero().intValue() != 0) {
				cs.setInt(i++, programaNovios.getCodigoEntero().intValue());
			} else {
				cs.setNull(i++, Types.INTEGER);
			}
			if (StringUtils.isNotBlank(programaNovios.getCodigoNovios())) {
				cs.setString(i++, programaNovios.getCodigoNovios());
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (programaNovios.getNovia().getCodigoEntero() != null
					&& programaNovios.getNovia().getCodigoEntero().intValue() != 0) {
				cs.setInt(i++, programaNovios.getNovia().getCodigoEntero()
						.intValue());
			} else {
				cs.setNull(i++, Types.INTEGER);
			}
			if (programaNovios.getNovio().getCodigoEntero() != null
					&& programaNovios.getNovio().getCodigoEntero().intValue() != 0) {
				cs.setInt(i++, programaNovios.getNovio().getCodigoEntero()
						.intValue());
			} else {
				cs.setNull(i++, Types.INTEGER);
			}

			cs.execute();
			rs = (ResultSet) cs.getObject(1);

			resultado = new ArrayList<ProgramaNovios>();
			ProgramaNovios programaNovios2 = null;
			while (rs.next()) {
				programaNovios2 = new ProgramaNovios();
				programaNovios2.setCodigoEntero(UtilJdbc
						.obtenerNumero(rs, "id"));
				programaNovios2.setCodigoNovios(UtilJdbc.obtenerCadena(rs,
						"codigonovios"));
				programaNovios2.getNovia().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idnovia"));
				programaNovios2.getNovia().setNombres(
						UtilJdbc.obtenerCadena(rs, "nomnovia"));
				programaNovios2.getNovia().setApellidoPaterno(
						UtilJdbc.obtenerCadena(rs, "apepatnovia"));
				programaNovios2.getNovia().setApellidoMaterno(
						UtilJdbc.obtenerCadena(rs, "apematnovia"));
				programaNovios2.getNovio().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idnovio"));
				programaNovios2.getNovio().setNombres(
						UtilJdbc.obtenerCadena(rs, "nomnovio"));
				programaNovios2.getNovio().setApellidoPaterno(
						UtilJdbc.obtenerCadena(rs, "apepatnovio"));
				programaNovios2.getNovio().setApellidoMaterno(
						UtilJdbc.obtenerCadena(rs, "apematnovio"));
				programaNovios2.getDestino().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "iddestino"));
				programaNovios2.getDestino().setDescripcion(
						UtilJdbc.obtenerCadena(rs, "descdestino"));
				programaNovios2.getDestino().setCodigoIATA(
						UtilJdbc.obtenerCadena(rs, "codigoiata"));
				programaNovios2.getDestino().getPais()
						.setDescripcion(UtilJdbc.obtenerCadena(rs, "descpais"));
				programaNovios2.setFechaBoda(UtilJdbc.obtenerFecha(rs,
						"fechaboda"));
				programaNovios2.setFechaViaje(UtilJdbc.obtenerFecha(rs,
						"fechaviaje"));
				programaNovios2.getMoneda().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idmoneda"));
				programaNovios2.setCuotaInicial(UtilJdbc.obtenerBigDecimal(rs,
						"cuotainicial"));
				programaNovios2.setNroDias(UtilJdbc.obtenerNumero(rs, "dias"));
				programaNovios2.setNroNoches(UtilJdbc.obtenerNumero(rs,
						"noches"));
				programaNovios2.setFechaShower(UtilJdbc.obtenerFecha(rs,
						"fechashower"));
				programaNovios2.setObservaciones(UtilJdbc.obtenerCadena(rs,
						"observaciones"));
				programaNovios2.getUsuarioCreacion().setCodigoEntero(UtilJdbc.obtenerNumero(rs,
						"usuariocreacion"));
				programaNovios2.setFechaCreacion(UtilJdbc.obtenerFecha(rs,
						"fechacreacion"));
				programaNovios2.setIpCreacion(UtilJdbc.obtenerCadena(rs,
						"ipcreacion"));
				programaNovios2.setCantidadInvitados(UtilJdbc.obtenerNumero(rs,
						"cantidadInvitados"));

				resultado.add(programaNovios2);
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
	public List<ProgramaNovios> consultarNovios(ProgramaNovios programaNovios,
			Connection conn) throws SQLException {
		List<ProgramaNovios> resultado = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "{ ? = call negocio.fn_consultarnovios(?,?,?,?)}";

		try {
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.OTHER);
			cs.setInt(i++, idEmpresa);
			if (programaNovios.getCodigoEntero() != null
					&& programaNovios.getCodigoEntero().intValue() != 0) {
				cs.setInt(i++, programaNovios.getCodigoEntero().intValue());
			} else {
				cs.setNull(i++, Types.INTEGER);
			}
			if (StringUtils.isNotBlank(programaNovios.getCodigoNovios())) {
				cs.setString(i++, programaNovios.getCodigoNovios());
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			if (programaNovios.getNovia().getCodigoEntero() != null
					&& programaNovios.getNovia().getCodigoEntero().intValue() != 0) {
				cs.setInt(i++, programaNovios.getNovia().getCodigoEntero()
						.intValue());
			} else {
				cs.setNull(i++, Types.INTEGER);
			}
			if (programaNovios.getNovio().getCodigoEntero() != null
					&& programaNovios.getNovio().getCodigoEntero().intValue() != 0) {
				cs.setInt(i++, programaNovios.getNovio().getCodigoEntero()
						.intValue());
			} else {
				cs.setNull(i++, Types.INTEGER);
			}

			cs.execute();
			rs = (ResultSet) cs.getObject(1);

			resultado = new ArrayList<ProgramaNovios>();
			ProgramaNovios programaNovios2 = null;
			while (rs.next()) {
				programaNovios2 = new ProgramaNovios();
				programaNovios2.setCodigoEntero(UtilJdbc
						.obtenerNumero(rs, "id"));
				programaNovios2.setCodigoNovios(UtilJdbc.obtenerCadena(rs,
						"codigonovios"));
				programaNovios2.getNovia().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idnovia"));
				programaNovios2
						.getNovia()
						.getDocumentoIdentidad()
						.getTipoDocumento()
						.setCodigoEntero(
								UtilJdbc.obtenerNumero(rs, "tipodocnovia"));
				programaNovios2
						.getNovia()
						.getDocumentoIdentidad()
						.setNumeroDocumento(
								UtilJdbc.obtenerCadena(rs, "numdocnovia"));
				programaNovios2.getNovia().setNombres(
						UtilJdbc.obtenerCadena(rs, "nomnovia"));
				programaNovios2.getNovia().setApellidoPaterno(
						UtilJdbc.obtenerCadena(rs, "apepatnovia"));
				programaNovios2.getNovia().setApellidoMaterno(
						UtilJdbc.obtenerCadena(rs, "apematnovia"));
				programaNovios2.getNovio().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idnovio"));
				programaNovios2
						.getNovio()
						.getDocumentoIdentidad()
						.getTipoDocumento()
						.setCodigoEntero(
								UtilJdbc.obtenerNumero(rs, "tipodocnovio"));
				programaNovios2
						.getNovio()
						.getDocumentoIdentidad()
						.setNumeroDocumento(
								UtilJdbc.obtenerCadena(rs, "numdocnovio"));
				programaNovios2.getNovio().setNombres(
						UtilJdbc.obtenerCadena(rs, "nomnovio"));
				programaNovios2.getNovio().setApellidoPaterno(
						UtilJdbc.obtenerCadena(rs, "apepatnovio"));
				programaNovios2.getNovio().setApellidoMaterno(
						UtilJdbc.obtenerCadena(rs, "apematnovio"));
				programaNovios2.getDestino().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "iddestino"));
				programaNovios2.getDestino().setDescripcion(
						UtilJdbc.obtenerCadena(rs, "descdestino"));
				programaNovios2.getDestino().setCodigoIATA(
						UtilJdbc.obtenerCadena(rs, "codigoiata"));
				programaNovios2.getDestino().getPais()
						.setDescripcion(UtilJdbc.obtenerCadena(rs, "descpais"));
				programaNovios2.setFechaBoda(UtilJdbc.obtenerFecha(rs,
						"fechaboda"));
				programaNovios2.setFechaViaje(UtilJdbc.obtenerFecha(rs,
						"fechaviaje"));
				programaNovios2.getMoneda().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idmoneda"));
				programaNovios2.setCuotaInicial(UtilJdbc.obtenerBigDecimal(rs,
						"cuotainicial"));
				programaNovios2.setNroDias(UtilJdbc.obtenerNumero(rs, "dias"));
				programaNovios2.setNroNoches(UtilJdbc.obtenerNumero(rs,
						"noches"));
				programaNovios2.setFechaShower(UtilJdbc.obtenerFecha(rs,
						"fechashower"));
				programaNovios2.setObservaciones(UtilJdbc.obtenerCadena(rs,
						"observaciones"));
				programaNovios2.getUsuarioCreacion().setCodigoEntero(UtilJdbc.obtenerNumero(rs,
						"usuariocreacion"));
				programaNovios2.setFechaCreacion(UtilJdbc.obtenerFecha(rs,
						"fechacreacion"));
				programaNovios2.setIpCreacion(UtilJdbc.obtenerCadena(rs,
						"ipcreacion"));
				programaNovios2.setCantidadInvitados(UtilJdbc.obtenerNumero(rs,
						"cantidadInvitados"));
				programaNovios2.setIdServicio(UtilJdbc.obtenerNumero(rs,
						"idservicio"));
				programaNovios2.getVendedor().setCodigoEntero(
						UtilJdbc.obtenerNumero(rs, "idvendedor"));
				String nombre = UtilJdbc.obtenerCadena(rs, "nomvendedor") + " "
						+ UtilJdbc.obtenerCadena(rs, "apepatvendedor") + " "
						+ UtilJdbc.obtenerCadena(rs, "apematvendedor");
				programaNovios2.getVendedor().setNombre(nombre);
				programaNovios2.setMontoTotalComision(UtilJdbc
						.obtenerBigDecimal(rs, "montocomisiontotal"));
				programaNovios2.setMontoTotalServicios(UtilJdbc
						.obtenerBigDecimal(rs, "montototal"));
				programaNovios2.setMontoTotalFee(UtilJdbc.obtenerBigDecimal(rs,
						"montototalfee"));
				resultado.add(programaNovios2);
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
	public boolean ingresarServicioNovios(ServicioNovios servicioNovios,
			int idnovios, Connection conexion) throws SQLException {
		boolean resultado = false;
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_ingresarservicionovios(?,?,?,?,?,?,?,?,?) }";

		try {
			cs = conexion.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.BOOLEAN);
			cs.setInt(i++, idEmpresa);
			cs.setInt(i++, idnovios);
			cs.setInt(i++, servicioNovios.getTipoServicio().getCodigoEntero()
					.intValue());
			cs.setString(i++, servicioNovios.getDescripcionServicio());
			cs.setInt(i++, servicioNovios.getCantidad());
			cs.setBigDecimal(i++, servicioNovios.getPrecioUnitario());
			cs.setBigDecimal(i++, servicioNovios.getTotalServicio());
			cs.setInt(i++, servicioNovios.getUsuarioCreacion().getCodigoEntero().intValue());
			cs.setString(i++, servicioNovios.getIpCreacion());
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
	public List<Cliente> consultarInvitasosNovios(int idnovios,
			Connection conexion) throws SQLException {
		List<Cliente> resultado = null;
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_consultarinvitadosnovios(?,?) }";
		ResultSet rs = null;
		try {
			cs = conexion.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.OTHER);
			cs.setInt(i++, idEmpresa);
			cs.setInt(i++, idnovios);
			cs.execute();

			rs = (ResultSet) cs.getObject(1);
			resultado = new ArrayList<Cliente>();
			Cliente invitado = null;
			while (rs.next()) {
				invitado = new Cliente();
				invitado.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				invitado.setNombres(UtilJdbc.obtenerCadena(rs, "nombres"));
				invitado.setApellidoPaterno(UtilJdbc.obtenerCadena(rs,
						"apellidopaterno"));
				invitado.setApellidoMaterno(UtilJdbc.obtenerCadena(rs,
						"apellidomaterno"));
				invitado.setTelefonoInvitadoNovios(UtilJdbc.obtenerCadena(rs,
						"telefono"));
				invitado.setCorreoElectronico(UtilJdbc.obtenerCadena(rs,
						"correoelectronico"));
				resultado.add(invitado);
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
	public Integer actualizarNovios(ProgramaNovios programaNovios,
			Connection conn) throws SQLException, Exception {
		Integer codigoNovios = 0;
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_actualizarprogramanovios(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) }";
		try {
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.INTEGER);
			cs.setInt(i++, idEmpresa);
			cs.setInt(i++, programaNovios.getCodigoEntero().intValue());
			cs.setInt(i++, programaNovios.getDestino().getCodigoEntero());
			cs.setDate(i++, UtilJdbc.convertirUtilDateSQLDate(programaNovios
					.getFechaBoda()));
			cs.setDate(i++, UtilJdbc.convertirUtilDateSQLDate(programaNovios
					.getFechaViaje()));
			cs.setInt(i++, programaNovios.getMoneda().getCodigoEntero());
			cs.setBigDecimal(i++, programaNovios.getCuotaInicial());
			cs.setInt(i++, programaNovios.getNroDias());
			cs.setInt(i++, programaNovios.getNroNoches());
			cs.setDate(i++, UtilJdbc.convertirUtilDateSQLDate(programaNovios
					.getFechaShower()));
			if (StringUtils.isNotBlank(programaNovios.getObservaciones())) {
				cs.setString(i++, UtilJdbc.convertirMayuscula(programaNovios
						.getObservaciones()));
			} else {
				cs.setNull(i++, Types.VARCHAR);
			}
			cs.setBigDecimal(i++,
					programaNovios.getMontoTotalServiciosPrograma());
			cs.setInt(i++, programaNovios.getIdServicio());
			cs.setInt(i++, programaNovios.getUsuarioModificacion().getCodigoEntero().intValue());
			cs.setString(i++, programaNovios.getIpModificacion());
			cs.execute();

			codigoNovios = cs.getInt(1);
		} catch (SQLException e) {
			codigoNovios = 0;
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

		return codigoNovios;
	}

	@Override
	public boolean eliminarInvitadosNovios(ProgramaNovios programaNovios,
			Connection conn) throws SQLException, Exception {
		boolean resultado = false;
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_eliminarinvitadosnovios(?,?,?,?) }";
		try {
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.BOOLEAN);
			cs.setInt(i++, idEmpresa);
			cs.setInt(i++, programaNovios.getCodigoEntero().intValue());
			cs.setInt(i++, programaNovios.getUsuarioModificacion().getCodigoEntero().intValue());
			cs.setString(i++, programaNovios.getIpModificacion());
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
}
