/**
 * 
 */
package pe.com.viajes.bean.negocio;

import java.util.List;

import pe.com.viajes.bean.base.BaseNegocio;
import pe.com.viajes.bean.base.BaseVO;

/**
 * @author Edwin
 *
 */
public class CorreoMasivo extends BaseNegocio {

	/**
	 * 
	 */
	private static final long serialVersionUID = -4117981273205473003L;

	private String cuentaEnvio;
	private String asunto;
	private BaseVO plantillaCorreo;
	private String contenidoCorreo;

	private List<CorreoClienteMasivo> listaCorreoMasivo;

	private ArchivoAdjunto archivoAdjunto;
	private byte[] buffer;

	private boolean archivoCargado;

	/**
	 * 
	 */
	public CorreoMasivo() {
		// TODO Auto-generated constructor stub
	}

	/**
	 * @return the cuentaEnvio
	 */
	public String getCuentaEnvio() {
		return cuentaEnvio;
	}

	/**
	 * @param cuentaEnvio
	 *            the cuentaEnvio to set
	 */
	public void setCuentaEnvio(String cuentaEnvio) {
		this.cuentaEnvio = cuentaEnvio;
	}

	/**
	 * @return the asunto
	 */
	public String getAsunto() {
		return asunto;
	}

	/**
	 * @param asunto
	 *            the asunto to set
	 */
	public void setAsunto(String asunto) {
		this.asunto = asunto;
	}

	/**
	 * @return the plantillaCorreo
	 */
	public BaseVO getPlantillaCorreo() {
		return plantillaCorreo;
	}

	/**
	 * @param plantillaCorreo
	 *            the plantillaCorreo to set
	 */
	public void setPlantillaCorreo(BaseVO plantillaCorreo) {
		this.plantillaCorreo = plantillaCorreo;
	}

	/**
	 * @return the contenidoCorreo
	 */
	public String getContenidoCorreo() {
		return contenidoCorreo;
	}

	/**
	 * @param contenidoCorreo
	 *            the contenidoCorreo to set
	 */
	public void setContenidoCorreo(String contenidoCorreo) {
		this.contenidoCorreo = contenidoCorreo;
	}

	/**
	 * @return the listaCorreoMasivo
	 */
	public List<CorreoClienteMasivo> getListaCorreoMasivo() {
		return listaCorreoMasivo;
	}

	/**
	 * @param listaCorreoMasivo
	 *            the listaCorreoMasivo to set
	 */
	public void setListaCorreoMasivo(List<CorreoClienteMasivo> listaCorreoMasivo) {
		this.listaCorreoMasivo = listaCorreoMasivo;
	}

	/**
	 * @return the buffer
	 */
	public byte[] getBuffer() {
		return buffer;
	}

	/**
	 * @param buffer
	 *            the buffer to set
	 */
	public void setBuffer(byte[] buffer) {
		this.buffer = buffer;
	}

	/**
	 * @return the archivoCargado
	 */
	public boolean isArchivoCargado() {
		return archivoCargado;
	}

	/**
	 * @param archivoCargado
	 *            the archivoCargado to set
	 */
	public void setArchivoCargado(boolean archivoCargado) {
		this.archivoCargado = archivoCargado;
	}

	/**
	 * @return the archivoAdjunto
	 */
	public ArchivoAdjunto getArchivoAdjunto() {
		return archivoAdjunto;
	}

	/**
	 * @param archivoAdjunto
	 *            the archivoAdjunto to set
	 */
	public void setArchivoAdjunto(ArchivoAdjunto archivoAdjunto) {
		this.archivoAdjunto = archivoAdjunto;
	}

}
