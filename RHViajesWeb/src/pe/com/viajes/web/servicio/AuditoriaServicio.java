/**
 * 
 */
package pe.com.viajes.web.servicio;

import java.util.Date;
import java.util.List;

import pe.com.viajes.bean.recursoshumanos.UsuarioAsistencia;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;

/**
 * @author EDWREB
 *
 */
public interface AuditoriaServicio {

	/**
	 * 
	 * @param fecha
	 * @param idEmpresa
	 * @return
	 * @throws ErrorConsultaDataException
	 */
	List<UsuarioAsistencia> consultarHorarioAsistenciaXDia(Date fecha,
			int idEmpresa) throws ErrorConsultaDataException;
}
