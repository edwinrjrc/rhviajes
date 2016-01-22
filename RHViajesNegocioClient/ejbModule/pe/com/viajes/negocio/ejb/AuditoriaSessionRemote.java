package pe.com.viajes.negocio.ejb;

import java.util.Date;
import java.util.List;

import javax.ejb.Remote;

import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.bean.recursoshumanos.UsuarioAsistencia;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;
import pe.com.viajes.negocio.exception.ErrorRegistroDataException;

@Remote
public interface AuditoriaSessionRemote {

	void registrarEventoInicioSession(Usuario usuario)
			throws ErrorRegistroDataException;

	List<UsuarioAsistencia> consultaHorariosEntrada(Date fecha,
			Integer idEmpresa) throws ErrorConsultaDataException;
}
