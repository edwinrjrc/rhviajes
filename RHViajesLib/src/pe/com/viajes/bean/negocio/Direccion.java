package pe.com.viajes.bean.negocio;

import java.util.ArrayList;
import java.util.List;

import pe.com.viajes.bean.base.BaseNegocio;
import pe.com.viajes.bean.base.BaseVO;

/**
 * @author Edwin
 * @version 1.0
 * @created 14-dic-2013 01:14:34 p.m.
 */
public class Direccion extends BaseNegocio {

	/**
	 * 
	 */
	private static final long serialVersionUID = 452591329561802664L;

	private String direccion;
	private String interior;
	private String nombreVia;
	private String nombreZona;
	private String numero;
	private String observaciones;
	private String referencia;
	private List<Telefono> telefonos;
	private BaseVO tipoDireccion;
	private Pais pais;
	private Ubigeo ubigeo;
	private BaseVO via;
	private BaseVO zona;
	private String manzana;
	private String lote;
	
	private boolean nacional;

	private boolean principal;

	public Direccion() {

	}

	public void finalize() throws Throwable {
		super.finalize();
	}

	/**
	 * @return the direccion
	 */
	public String getDireccion() {
		return direccion;
	}

	/**
	 * @param direccion
	 *            the direccion to set
	 */
	public void setDireccion(String direccion) {
		this.direccion = direccion;
	}

	/**
	 * @return the interior
	 */
	public String getInterior() {
		return interior;
	}

	/**
	 * @param interior
	 *            the interior to set
	 */
	public void setInterior(String interior) {
		this.interior = interior;
	}

	/**
	 * @return the nombreVia
	 */
	public String getNombreVia() {
		return nombreVia;
	}

	/**
	 * @param nombreVia
	 *            the nombreVia to set
	 */
	public void setNombreVia(String nombreVia) {
		this.nombreVia = nombreVia;
	}

	/**
	 * @return the nombreZona
	 */
	public String getNombreZona() {
		return nombreZona;
	}

	/**
	 * @param nombreZona
	 *            the nombreZona to set
	 */
	public void setNombreZona(String nombreZona) {
		this.nombreZona = nombreZona;
	}

	/**
	 * @return the numero
	 */
	public String getNumero() {
		return numero;
	}

	/**
	 * @param numero
	 *            the numero to set
	 */
	public void setNumero(String numero) {
		this.numero = numero;
	}

	/**
	 * @return the observaciones
	 */
	public String getObservaciones() {
		return observaciones;
	}

	/**
	 * @param observaciones
	 *            the observaciones to set
	 */
	public void setObservaciones(String observaciones) {
		this.observaciones = observaciones;
	}

	/**
	 * @return the referencia
	 */
	public String getReferencia() {
		return referencia;
	}

	/**
	 * @param referencia
	 *            the referencia to set
	 */
	public void setReferencia(String referencia) {
		this.referencia = referencia;
	}

	/**
	 * @return the telefonos
	 */
	public List<Telefono> getTelefonos() {
		if (telefonos == null) {
			telefonos = new ArrayList<Telefono>();
		}
		return telefonos;
	}

	/**
	 * @param telefonos
	 *            the telefonos to set
	 */
	public void setTelefonos(List<Telefono> telefonos) {
		this.telefonos = telefonos;
	}

	/**
	 * @return the tipoDireccion
	 */
	public BaseVO getTipoDireccion() {
		if (tipoDireccion == null) {
			tipoDireccion = new BaseVO();
		}
		return tipoDireccion;
	}

	/**
	 * @param tipoDireccion
	 *            the tipoDireccion to set
	 */
	public void setTipoDireccion(BaseVO tipoDireccion) {
		this.tipoDireccion = tipoDireccion;
	}

	/**
	 * @return the ubigeo
	 */
	public Ubigeo getUbigeo() {
		if (ubigeo == null) {
			ubigeo = new Ubigeo();
		}
		return ubigeo;
	}

	/**
	 * @param ubigeo
	 *            the ubigeo to set
	 */
	public void setUbigeo(Ubigeo ubigeo) {
		this.ubigeo = ubigeo;
	}

	/**
	 * @return the via
	 */
	public BaseVO getVia() {
		if (via == null) {
			via = new BaseVO();
		}
		return via;
	}

	/**
	 * @param via
	 *            the via to set
	 */
	public void setVia(BaseVO via) {
		this.via = via;
	}

	/**
	 * @return the zona
	 */
	public BaseVO getZona() {
		if (zona == null) {
			zona = new BaseVO();
		}
		return zona;
	}

	/**
	 * @param zona
	 *            the zona to set
	 */
	public void setZona(BaseVO zona) {
		this.zona = zona;
	}

	/**
	 * @return the manzana
	 */
	public String getManzana() {
		return manzana;
	}

	/**
	 * @param manzana
	 *            the manzana to set
	 */
	public void setManzana(String manzana) {
		this.manzana = manzana;
	}

	/**
	 * @return the lote
	 */
	public String getLote() {
		return lote;
	}

	/**
	 * @param lote
	 *            the lote to set
	 */
	public void setLote(String lote) {
		this.lote = lote;
	}

	/**
	 * @return the principal
	 */
	public boolean isPrincipal() {
		return principal;
	}

	/**
	 * @param principal
	 *            the principal to set
	 */
	public void setPrincipal(boolean principal) {
		this.principal = principal;
	}

	/**
	 * @return the pais
	 */
	public Pais getPais() {
		if (pais == null){
			pais = new Pais();
		}
		return pais;
	}

	/**
	 * @param pais the pais to set
	 */
	public void setPais(Pais pais) {
		this.pais = pais;
	}

	/**
	 * @return the nacional
	 */
	public boolean isNacional() {
		return nacional;
	}

	/**
	 * @param nacional the nacional to set
	 */
	public void setNacional(boolean nacional) {
		this.nacional = nacional;
	}

}