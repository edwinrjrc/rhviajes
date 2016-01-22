/**
 * 
 */
package pe.com.viajes.bean.licencia;

import pe.com.viajes.bean.base.Base;
import pe.com.viajes.bean.negocio.DocumentoIdentidad;
import pe.com.viajes.bean.negocio.Ubigeo;

/**
 * @author Edwin
 *
 */
public class EmpresaLicencia extends Base {

	private static final long serialVersionUID = 1074028315629705486L;
	
	private DocumentoIdentidad documentoIdentidad;
	private String razonSocial;
	private String nombreComercial;
	private String direccion;
	private Ubigeo ubigeo;
	private String nombreDominio;
	
	
	/**
	 * @return the documentoIdentidad
	 */
	public DocumentoIdentidad getDocumentoIdentidad() {
		return documentoIdentidad;
	}
	/**
	 * @param documentoIdentidad the documentoIdentidad to set
	 */
	public void setDocumentoIdentidad(DocumentoIdentidad documentoIdentidad) {
		this.documentoIdentidad = documentoIdentidad;
	}
	/**
	 * @return the razonSocial
	 */
	public String getRazonSocial() {
		return razonSocial;
	}
	/**
	 * @param razonSocial the razonSocial to set
	 */
	public void setRazonSocial(String razonSocial) {
		this.razonSocial = razonSocial;
	}
	/**
	 * @return the nombreComercial
	 */
	public String getNombreComercial() {
		return nombreComercial;
	}
	/**
	 * @param nombreComercial the nombreComercial to set
	 */
	public void setNombreComercial(String nombreComercial) {
		this.nombreComercial = nombreComercial;
	}
	/**
	 * @return the direccion
	 */
	public String getDireccion() {
		return direccion;
	}
	/**
	 * @param direccion the direccion to set
	 */
	public void setDireccion(String direccion) {
		this.direccion = direccion;
	}
	/**
	 * @return the ubigeo
	 */
	public Ubigeo getUbigeo() {
		return ubigeo;
	}
	/**
	 * @param ubigeo the ubigeo to set
	 */
	public void setUbigeo(Ubigeo ubigeo) {
		this.ubigeo = ubigeo;
	}
	/**
	 * @return the nombreDominio
	 */
	public String getNombreDominio() {
		return nombreDominio;
	}
	/**
	 * @param nombreDominio the nombreDominio to set
	 */
	public void setNombreDominio(String nombreDominio) {
		this.nombreDominio = nombreDominio;
	}
	
	
}
