/**
 * 
 */
package pe.com.viajes.web.faces;

import java.sql.SQLException;
import java.util.List;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;
import javax.naming.NamingException;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;

import pe.com.viajes.bean.negocio.DetalleServicioAgencia;
import pe.com.viajes.bean.negocio.ServicioAgencia;
import pe.com.viajes.bean.negocio.Tramo;
import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.bean.reportes.CheckIn;
import pe.com.viajes.web.servicio.ConsultaNegocioServicio;
import pe.com.viajes.web.servicio.impl.ConsultaNegocioServicioImpl;

/**
 * @author Edwin
 *
 */
@ManagedBean(name = "inicioMBean")
@SessionScoped()
public class InicioMBean extends BaseMBean {

	private final static Logger logger = Logger.getLogger(InicioMBean.class);

	private static final long serialVersionUID = 8033623856852260300L;

	private ServicioAgencia servicioAgencia;
	private CheckIn checkIn;
	private DetalleServicioAgencia detalleServicioAgencia;
	private ConsultaNegocioServicio consultaNegocioServicio;

	private List<CheckIn> checkInPendientes;

	public InicioMBean() {
		try {
			ServletContext servletContext = (ServletContext) FacesContext
					.getCurrentInstance().getExternalContext().getContext();
			consultaNegocioServicio = new ConsultaNegocioServicioImpl(
					servletContext);
		} catch (NamingException e) {
			logger.error(e.getMessage(), e);
		}
	}

	public void verDetalle(CheckIn fila) {
		try {
			this.setCheckIn(fila);
			
			this.setDetalleServicioAgencia(consultaNegocioServicio
					.consultarDetalleServicioDetalle(fila.getIdServicio(),
							fila.getIdServicioDetalle(), this.obtenerIdEmpresa()));
			for (Tramo tramo : this.getDetalleServicioAgencia().getRuta().getTramos()){
				if (tramo.getCodigoEntero().intValue() == fila.getIdTramo().intValue()){
					this.getDetalleServicioAgencia().getRuta().setTramo(tramo);
					break;
				}
			}
			
			
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
		}
	}

	/**
	 * @return the checkInPendientes
	 */
	public List<CheckIn> getCheckInPendientes() {
		try {
			
			HttpSession session = obtenerSession(false);
			Usuario usuario = (Usuario) session
					.getAttribute("usuarioSession");
					usuario.getUsuario();
					
			checkInPendientes = consultaNegocioServicio
					.consultarCheckInPendiente(usuario);

		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
		}

		return checkInPendientes;
	}

	/**
	 * @param checkInPendientes
	 *            the checkInPendientes to set
	 */
	public void setCheckInPendientes(List<CheckIn> checkInPendientes) {
		this.checkInPendientes = checkInPendientes;
	}

	/**
	 * @return the servicioAgencia
	 */
	public ServicioAgencia getServicioAgencia() {
		if (servicioAgencia == null) {
			servicioAgencia = new ServicioAgencia();
		}
		return servicioAgencia;
	}

	/**
	 * @param servicioAgencia
	 *            the servicioAgencia to set
	 */
	public void setServicioAgencia(ServicioAgencia servicioAgencia) {
		this.servicioAgencia = servicioAgencia;
	}

	/**
	 * @return the detalleServicioAgencia
	 */
	public DetalleServicioAgencia getDetalleServicioAgencia() {
		if (detalleServicioAgencia == null) {
			detalleServicioAgencia = new DetalleServicioAgencia();
		}
		return detalleServicioAgencia;
	}

	/**
	 * @param detalleServicioAgencia
	 *            the detalleServicioAgencia to set
	 */
	public void setDetalleServicioAgencia(
			DetalleServicioAgencia detalleServicioAgencia) {
		this.detalleServicioAgencia = detalleServicioAgencia;
	}

	/**
	 * @return the checkIn
	 */
	public CheckIn getCheckIn() {
		if (checkIn == null) {
			checkIn = new CheckIn();
		}
		return checkIn;
	}

	/**
	 * @param checkIn
	 *            the checkIn to set
	 */
	public void setCheckIn(CheckIn checkIn) {
		this.checkIn = checkIn;
	}

}
