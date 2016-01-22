package pe.com.viajes.bean.base;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.commons.lang3.StringUtils;

import pe.com.viajes.bean.negocio.Direccion;
import pe.com.viajes.bean.negocio.DocumentoIdentidad;
import pe.com.viajes.bean.negocio.Pais;
import pe.com.viajes.bean.negocio.Telefono;
import pe.com.viajes.bean.util.UtilParse;

/**
 * @author Edwin
 * @version 1.0
 * @created 14-dic-2013 01:14:34 p.m.
 */
public abstract class Persona extends BaseNegocio {

	/**
	 * 
	 */
	private static final long serialVersionUID = 4643534946632179203L;
	private String apellidoMaterno;
	private String apellidoPaterno;
	private Direccion direccion;
	private Telefono telefonoMovil;
	private DocumentoIdentidad documentoIdentidad;
	private BaseVO estadoCivil;
	private BaseVO genero;
	private String nombres;
	private String razonSocial;
	private List<Direccion> listaDirecciones;
	private Date fechaNacimiento;

	private int tipoPersona;
	private BaseVO rubro;

	private String nroPasaporte;
	private Date fechaVctoPasaporte;
	private Pais nacionalidad;

	public Persona() {

	}

	public void finalize() throws Throwable {
		super.finalize();
	}

	/**
	 * @return the apellidoMaterno
	 */
	public String getApellidoMaterno() {
		return apellidoMaterno;
	}

	/**
	 * @param apellidoMaterno
	 *            the apellidoMaterno to set
	 */
	public void setApellidoMaterno(String apellidoMaterno) {
		this.apellidoMaterno = apellidoMaterno;
	}

	/**
	 * @return the apellidoPaterno
	 */
	public String getApellidoPaterno() {
		return apellidoPaterno;
	}

	/**
	 * @param apellidoPaterno
	 *            the apellidoPaterno to set
	 */
	public void setApellidoPaterno(String apellidoPaterno) {
		this.apellidoPaterno = apellidoPaterno;
	}

	/**
	 * @return the direccion
	 */
	public Direccion getDireccion() {
		if (direccion == null) {
			direccion = new Direccion();
		}
		return direccion;
	}

	/**
	 * @param direccion
	 *            the direccion to set
	 */
	public void setDireccion(Direccion direccion) {
		this.direccion = direccion;
	}

	/**
	 * @return the documentoIdentidad
	 */
	public DocumentoIdentidad getDocumentoIdentidad() {
		if (documentoIdentidad == null) {
			documentoIdentidad = new DocumentoIdentidad();
		}
		return documentoIdentidad;
	}

	/**
	 * @param documentoIdentidad
	 *            the documentoIdentidad to set
	 */
	public void setDocumentoIdentidad(DocumentoIdentidad documentoIdentidad) {
		this.documentoIdentidad = documentoIdentidad;
	}

	/**
	 * @return the estadoCivil
	 */
	public BaseVO getEstadoCivil() {
		if (estadoCivil == null) {
			estadoCivil = new BaseVO();
		}
		return estadoCivil;
	}

	/**
	 * @param estadoCivil
	 *            the estadoCivil to set
	 */
	public void setEstadoCivil(BaseVO estadoCivil) {
		this.estadoCivil = estadoCivil;
	}

	/**
	 * @return the genero
	 */
	public BaseVO getGenero() {
		if (genero == null) {
			genero = new BaseVO();
		}
		return genero;
	}

	/**
	 * @param genero
	 *            the genero to set
	 */
	public void setGenero(BaseVO genero) {
		this.genero = genero;
	}

	/**
	 * @return the nombres
	 */
	public String getNombres() {
		return nombres;
	}

	/**
	 * @param nombres
	 *            the nombres to set
	 */
	public void setNombres(String nombres) {
		this.nombres = nombres;
	}

	/**
	 * @return the razonSocial
	 */
	public String getRazonSocial() {
		return razonSocial;
	}

	/**
	 * @param razonSocial
	 *            the razonSocial to set
	 */
	public void setRazonSocial(String razonSocial) {
		this.razonSocial = razonSocial;
	}

	/**
	 * @return the tipoPersona
	 */
	public int getTipoPersona() {
		return tipoPersona;
	}

	/**
	 * @param tipoPersona
	 *            the tipoPersona to set
	 */
	public void setTipoPersona(int tipoPersona) {
		this.tipoPersona = tipoPersona;
	}

	/**
	 * @return the listaDirecciones
	 */
	public List<Direccion> getListaDirecciones() {
		if (listaDirecciones == null) {
			listaDirecciones = new ArrayList<Direccion>();
		}
		return listaDirecciones;
	}

	/**
	 * @param listaDirecciones
	 *            the listaDirecciones to set
	 */
	public void setListaDirecciones(List<Direccion> listaDirecciones) {
		this.listaDirecciones = listaDirecciones;
	}

	public String getNombreCompleto() {
		String nombreCompleto = "";

		nombreCompleto = UtilParse.parseCadena(getNombres()) + " "
				+ UtilParse.parseCadena(getApellidoPaterno()) + " "
				+ UtilParse.parseCadena(getApellidoMaterno());
		nombreCompleto = StringUtils.normalizeSpace(nombreCompleto);

		return nombreCompleto;
	}

	/**
	 * @return the fechaNacimiento
	 */
	public Date getFechaNacimiento() {
		return fechaNacimiento;
	}

	/**
	 * @param fechaNacimiento
	 *            the fechaNacimiento to set
	 */
	public void setFechaNacimiento(Date fechaNacimiento) {
		this.fechaNacimiento = fechaNacimiento;
	}

	/**
	 * @return the rubro
	 */
	public BaseVO getRubro() {
		if (rubro == null) {
			rubro = new BaseVO();
		}
		return rubro;
	}

	/**
	 * @param rubro
	 *            the rubro to set
	 */
	public void setRubro(BaseVO rubro) {
		this.rubro = rubro;
	}

	/**
	 * @return the telefonoMovil
	 */
	public Telefono getTelefonoMovil() {
		return telefonoMovil;
	}

	/**
	 * @param telefonoMovil
	 *            the telefonoMovil to set
	 */
	public void setTelefonoMovil(Telefono telefonoMovil) {
		this.telefonoMovil = telefonoMovil;
	}

	/**
	 * @return the nroPasaporte
	 */
	public String getNroPasaporte() {
		return nroPasaporte;
	}

	/**
	 * @param nroPasaporte
	 *            the nroPasaporte to set
	 */
	public void setNroPasaporte(String nroPasaporte) {
		this.nroPasaporte = nroPasaporte;
	}

	/**
	 * @return the fechaVctoPasaporte
	 */
	public Date getFechaVctoPasaporte() {
		return fechaVctoPasaporte;
	}

	/**
	 * @param fechaVctoPasaporte
	 *            the fechaVctoPasaporte to set
	 */
	public void setFechaVctoPasaporte(Date fechaVctoPasaporte) {
		this.fechaVctoPasaporte = fechaVctoPasaporte;
	}

	/**
	 * @return the nacionalidad
	 */
	public Pais getNacionalidad() {
		if (nacionalidad == null){
			nacionalidad = new Pais();
		}
		return nacionalidad;
	}

	/**
	 * @param nacionalidad the nacionalidad to set
	 */
	public void setNacionalidad(Pais nacionalidad) {
		this.nacionalidad = nacionalidad;
	}

}