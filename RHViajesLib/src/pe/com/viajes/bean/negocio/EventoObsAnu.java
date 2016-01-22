/**
 * 
 */
package pe.com.viajes.bean.negocio;

import pe.com.viajes.bean.base.BaseNegocio;
import pe.com.viajes.bean.base.BaseVO;

/**
 * @author Edwin
 *
 */
public class EventoObsAnu extends BaseNegocio {

	private BaseVO tipoEvento;
	private String comentario;
	private Integer idServicio;
	/**
	 * 
	 */
	private static final long serialVersionUID = -5487728746049594208L;

	public static final Integer EVENTO_OBS = 1;
	public static final Integer EVENTO_ANU = 2;

	/**
	 * 
	 */
	public EventoObsAnu() {
		// TODO Auto-generated constructor stub
	}

	/**
	 * @return the tipoEvento
	 */
	public BaseVO getTipoEvento() {
		if (tipoEvento == null) {
			tipoEvento = new BaseVO();
		}
		return tipoEvento;
	}

	/**
	 * @param tipoEvento
	 *            the tipoEvento to set
	 */
	public void setTipoEvento(BaseVO tipoEvento) {
		this.tipoEvento = tipoEvento;
	}

	/**
	 * @return the comentario
	 */
	public String getComentario() {
		return comentario;
	}

	/**
	 * @param comentario
	 *            the comentario to set
	 */
	public void setComentario(String comentario) {
		this.comentario = comentario;
	}

	/**
	 * @return the idServicio
	 */
	public Integer getIdServicio() {
		return idServicio;
	}

	/**
	 * @param idServicio
	 *            the idServicio to set
	 */
	public void setIdServicio(Integer idServicio) {
		this.idServicio = idServicio;
	}

}
