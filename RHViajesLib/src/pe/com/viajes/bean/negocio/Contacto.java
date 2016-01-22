package pe.com.viajes.bean.negocio;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.base.CorreoElectronico;
import pe.com.viajes.bean.base.Persona;

/**
 * @author Edwin
 * @version 1.0
 * @created 14-dic-2013 01:14:34 p.m.
 */
public class Contacto extends Persona {

	/**
	 * 
	 */
	private static final long serialVersionUID = 4988270415170041781L;
	private List<CorreoElectronico> listaCorreos;
	private List<Telefono> listaTelefonos;
	private String anexo;
	private BaseVO area;

	public Contacto() {

	}

	public void finalize() throws Throwable {
		super.finalize();
	}

	/**
	 * @return the listaCorreos
	 */
	public List<CorreoElectronico> getListaCorreos() {
		if (listaCorreos == null) {
			listaCorreos = new ArrayList<CorreoElectronico>();
		}
		return listaCorreos;
	}

	/**
	 * @param listaCorreos
	 *            the listaCorreos to set
	 */
	public void setListaCorreos(List<CorreoElectronico> listaCorreos) {
		this.listaCorreos = listaCorreos;
	}

	/**
	 * @return the listaTelefonos
	 */
	public List<Telefono> getListaTelefonos() {
		if (listaTelefonos == null) {
			listaTelefonos = new ArrayList<Telefono>();
		}
		return listaTelefonos;
	}

	/**
	 * @param listaTelefonos
	 *            the listaTelefonos to set
	 */
	public void setListaTelefonos(List<Telefono> listaTelefonos) {
		this.listaTelefonos = listaTelefonos;
	}

	/**
	 * @return the anexo
	 */
	public String getAnexo() {
		return anexo;
	}

	/**
	 * @param anexo
	 *            the anexo to set
	 */
	public void setAnexo(String anexo) {
		this.anexo = anexo;
	}

	/**
	 * @return the area
	 */
	public BaseVO getArea() {
		if (area == null) {
			area = new BaseVO();
		}
		return area;
	}

	/**
	 * @param area
	 *            the area to set
	 */
	public void setArea(BaseVO area) {
		this.area = area;
	}

	public String getNombreCompleto() {
		String nomCompleto = "";

		nomCompleto = getNombres() + " " + getApellidoPaterno() + " "
				+ getApellidoMaterno();
		nomCompleto = StringUtils.normalizeSpace(nomCompleto);

		return nomCompleto;
	}
}