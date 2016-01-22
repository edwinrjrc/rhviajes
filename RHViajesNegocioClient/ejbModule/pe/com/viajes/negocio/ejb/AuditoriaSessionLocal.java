package pe.com.viajes.negocio.ejb;

import java.util.Date;
import java.util.List;

import javax.ejb.Local;

import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.bean.recursoshumanos.UsuarioAsistencia;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;
import pe.com.viajes.negocio.exception.ErrorRegistroDataException;

@Local
public interface AuditoriaSessionLocal {

	void registrarEventoInicioSession(Usuario usuario)
			throws ErrorRegistroDataException;

	List<UsuarioAsistencia> consultaHorariosEntrada(Date fecha,
			Integer idEmpresa) throws ErrorConsultaDataException;
}
