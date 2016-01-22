/**
 * 
 */
package pe.com.viajes.bean.negocio;

import java.io.InputStream;

import pe.com.viajes.bean.base.Base;

/**
 * @author Edwin
 *
 */
public class ArchivoAdjunto extends Base {

	/**
	 * 
	 */
	private static final long serialVersionUID = -6843568135765114678L;

	private InputStream stream;
	private String nombreArchivo;
	private String tipoContenido;
	private String content;
	private byte[] datos;
	private String extensionArchivo;

	public ArchivoAdjunto() {
		// TODO Auto-generated constructor stub
	}

	public ArchivoAdjunto(String nombre) {
		this.nombreArchivo = nombre;
	}

	/**
	 * @return the stream
	 */
	public InputStream getStream() {
		return stream;
	}

	/**
	 * @param stream
	 *            the stream to set
	 */
	public void setStream(InputStream stream) {
		this.stream = stream;
	}

	/**
	 * @return the nombreArchivo
	 */
	public String getNombreArchivo() {
		return nombreArchivo;
	}

	/**
	 * @param nombreArchivo
	 *            the nombreArchivo to set
	 */
	public void setNombreArchivo(String nombreArchivo) {
		this.nombreArchivo = nombreArchivo;
	}

	/**
	 * @return the tipoContenido
	 */
	public String getTipoContenido() {
		return tipoContenido;
	}

	/**
	 * @param tipoContenido
	 *            the tipoContenido to set
	 */
	public void setTipoContenido(String tipoContenido) {
		this.tipoContenido = tipoContenido;
	}

	/**
	 * @return the datos
	 */
	public byte[] getDatos() {
		return datos;
	}

	/**
	 * @param datos
	 *            the datos to set
	 */
	public void setDatos(byte[] datos) {
		this.datos = datos;
	}

	/**
	 * @return the content
	 */
	public String getContent() {
		return content;
	}

	/**
	 * @param content
	 *            the content to set
	 */
	public void setContent(String content) {
		this.content = content;
	}

	/**
	 * @return the extensionArchivo
	 */
	public String getExtensionArchivo() {
		return extensionArchivo;
	}

	/**
	 * @param extensionArchivo
	 *            the extensionArchivo to set
	 */
	public void setExtensionArchivo(String extensionArchivo) {
		this.extensionArchivo = extensionArchivo;
	}

}
