/**
 * 
 */
package pe.com.viajes.bean.negocio;

import pe.com.viajes.bean.base.Base;
import pe.com.viajes.bean.base.BaseVO;

/**
 * @author Edwin
 * 
 */
public class DocumentoIdentidad extends Base {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private String numeroDocumento;
	private BaseVO tipoDocumento;

	/**
	 * 
	 */
	public DocumentoIdentidad() {
		// TODO Auto-generated constructor stub
	}

	/**
	 * @return the numeroDocumento
	 */
	public String getNumeroDocumento() {
		return numeroDocumento;
	}

	/**
	 * @param numeroDocumento
	 *            the numeroDocumento to set
	 */
	public void setNumeroDocumento(String numeroDocumento) {
		this.numeroDocumento = numeroDocumento;
	}

	/**
	 * @return the tipoDocumento
	 */
	public BaseVO getTipoDocumento() {
		if (tipoDocumento == null) {
			tipoDocumento = new BaseVO();
		}
		return tipoDocumento;
	}

	/**
	 * @param tipoDocumento
	 *            the tipoDocumento to set
	 */
	public void setTipoDocumento(BaseVO tipoDocumento) {
		this.tipoDocumento = tipoDocumento;
	}

}
