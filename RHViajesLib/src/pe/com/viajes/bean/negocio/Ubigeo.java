package pe.com.viajes.bean.negocio;

import pe.com.viajes.bean.base.BaseVO;

/**
 * @author Edwin
 * @version 1.0
 * @created 14-dic-2013 01:14:34 p.m.
 */
public class Ubigeo extends BaseVO {

	/**
	 * 
	 */
	private static final long serialVersionUID = 2851176289742680243L;
	private String codigoPostal;
	private BaseVO departamento;
	private BaseVO distrito;
	private BaseVO provincia;

	public Ubigeo() {

	}

	public void finalize() throws Throwable {
		super.finalize();
	}

	/**
	 * @return the codigoPostal
	 */
	public String getCodigoPostal() {
		return codigoPostal;
	}

	/**
	 * @param codigoPostal
	 *            the codigoPostal to set
	 */
	public void setCodigoPostal(String codigoPostal) {
		this.codigoPostal = codigoPostal;
	}

	/**
	 * @return the departamento
	 */
	public BaseVO getDepartamento() {
		if (departamento == null) {
			departamento = new BaseVO();
		}
		return departamento;
	}

	/**
	 * @param departamento
	 *            the departamento to set
	 */
	public void setDepartamento(BaseVO departamento) {
		this.departamento = departamento;
	}

	/**
	 * @return the distrito
	 */
	public BaseVO getDistrito() {
		if (distrito == null) {
			distrito = new BaseVO();
		}
		return distrito;
	}

	/**
	 * @param distrito
	 *            the distrito to set
	 */
	public void setDistrito(BaseVO distrito) {
		this.distrito = distrito;
	}

	/**
	 * @return the provincia
	 */
	public BaseVO getProvincia() {
		if (provincia == null) {
			provincia = new BaseVO();
		}
		return provincia;
	}

	/**
	 * @param provincia
	 *            the provincia to set
	 */
	public void setProvincia(BaseVO provincia) {
		this.provincia = provincia;
	}

}