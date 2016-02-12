/**
 * 
 */
package pe.com.viajes.bean.licencia;

import pe.com.viajes.bean.base.Base;
import pe.com.viajes.bean.negocio.DocumentoIdentidad;

/**
 * @author EDWREB
 *
 */
public class EmpresaAgenciaViajes extends Base {

	private static final long serialVersionUID = 576956339617233893L;
	
	private String razonSocial;
	private String nombreComercial;
	private String nombreDominio;
	private DocumentoIdentidad documentoIdentidad;
	private String nombreContacto;
	private String correoContacto;


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

	/**
	 * @return the documentoIdentidad
	 */
	public DocumentoIdentidad getDocumentoIdentidad() {
		if (documentoIdentidad == null){
			documentoIdentidad = new DocumentoIdentidad();
		}
		return documentoIdentidad;
	}

	/**
	 * @param documentoIdentidad the documentoIdentidad to set
	 */
	public void setDocumentoIdentidad(DocumentoIdentidad documentoIdentidad) {
		this.documentoIdentidad = documentoIdentidad;
	}

	/**
	 * @return the nombreContacto
	 */
	public String getNombreContacto() {
		return nombreContacto;
	}

	/**
	 * @param nombreContacto the nombreContacto to set
	 */
	public void setNombreContacto(String nombreContacto) {
		this.nombreContacto = nombreContacto;
	}

	/**
	 * @return the correocontacto
	 */
	public String getCorreoContacto() {
		return correoContacto;
	}

	/**
	 * @param correocontacto the correocontacto to set
	 */
	public void setCorreoContacto(String correocontacto) {
		this.correoContacto = correocontacto;
	}
	
	

}
