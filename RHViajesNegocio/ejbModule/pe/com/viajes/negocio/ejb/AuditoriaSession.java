package pe.com.viajes.negocio.ejb;

import java.sql.SQLException;
import java.util.Date;
import java.util.List;

import javax.ejb.Stateless;

import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.bean.recursoshumanos.UsuarioAsistencia;
import pe.com.viajes.negocio.dao.AuditoriaDao;
import pe.com.viajes.negocio.dao.impl.AuditoriaDaoImpl;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;
import pe.com.viajes.negocio.exception.ErrorRegistroDataException;

/**
 * Session Bean implementation class AuditoriaSession
 */
@Stateless(name = "AuditoriaSession", mappedName = "AuditoriaSession")
public class AuditoriaSession implements AuditoriaSessionRemote,
		AuditoriaSessionLocal {

	@Override
	public void registrarEventoInicioSession(Usuario usuario)
			throws ErrorRegistroDataException {
		try {
			AuditoriaDao auditoriaDao = new AuditoriaDaoImpl();
			auditoriaDao.registrarEventoSesion(usuario, 1);
		} catch (SQLException e) {
			throw new ErrorRegistroDataException(e);
		}
	}

	@Override
	public List<UsuarioAsistencia> consultaHorariosEntrada(Date fecha, Integer idEmpresa)
			throws ErrorConsultaDataException {
		try {
			AuditoriaDao auditoriaDao = new AuditoriaDaoImpl();
			return auditoriaDao.listarHoraEntradaXDia(fecha,idEmpresa);
		} catch (SQLException e) {
			throw new ErrorConsultaDataException(e);
		}
	}
}
