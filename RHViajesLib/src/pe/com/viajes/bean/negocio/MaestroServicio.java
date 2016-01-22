/**
 * 
 */
package pe.com.viajes.bean.negocio;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import pe.com.viajes.bean.base.BaseNegocio;
import pe.com.viajes.bean.base.BaseVO;

/**
 * @author edwreb
 *
 */
public class MaestroServicio extends BaseNegocio {
	/**
	 * 
	 */
	private static final long serialVersionUID = 499125844585986995L;

	private String nombre;
	private String descripcionCorta;
	private String descripcion;
	private boolean requiereFee;
	private BaseVO servicioFee;
	private BaseVO imptoIgv;
	private boolean pagaImpto;
	private boolean pagaIgv;
	private BaseVO servicioImpto;
	private boolean cargaComision;
	private boolean cargaIgv;
	private boolean comisionPorcentaje;
	private BigDecimal valorComision;

	private boolean esImpuesto;
	private boolean esFee;
	private boolean visible;
	private boolean servicioPadre;

	private List<BaseVO> listaServicioDepende;
	private BaseVO parametroAsociado;
	private String valorParametro;

	/**
	 * 
	 */
	public MaestroServicio() {
		// TODO Auto-generated constructor stub
	}

	/**
	 * @return the nombre
	 */
	public String getNombre() {
		return nombre;
	}

	/**
	 * @param nombre
	 *            the nombre to set
	 */
	public void setNombre(String nombre) {
		this.nombre = nombre;
	}

	/**
	 * @return the descripcion
	 */
	public String getDescripcion() {
		return descripcion;
	}

	/**
	 * @param descripcion
	 *            the descripcion to set
	 */
	public void setDescripcion(String descripcion) {
		this.descripcion = descripcion;
	}

	/**
	 * @return the requiereFee
	 */
	public boolean isRequiereFee() {
		return requiereFee;
	}

	/**
	 * @param requiereFee
	 *            the requiereFee to set
	 */
	public void setRequiereFee(boolean requiereFee) {
		this.requiereFee = requiereFee;
	}

	/**
	 * @return the pagaImpto
	 */
	public boolean isPagaImpto() {
		return pagaImpto;
	}

	/**
	 * @param pagaImpto
	 *            the pagaImpto to set
	 */
	public void setPagaImpto(boolean pagaImpto) {
		this.pagaImpto = pagaImpto;
	}

	/**
	 * @return the cargaComision
	 */
	public boolean isCargaComision() {
		return cargaComision;
	}

	/**
	 * @param cargaComision
	 *            the cargaComision to set
	 */
	public void setCargaComision(boolean cargaComision) {
		this.cargaComision = cargaComision;
	}

	/**
	 * @return the comisionPorcentaje
	 */
	public boolean isComisionPorcentaje() {
		return comisionPorcentaje;
	}

	/**
	 * @param comisionPorcentaje
	 *            the comisionPorcentaje to set
	 */
	public void setComisionPorcentaje(boolean comisionPorcentaje) {
		this.comisionPorcentaje = comisionPorcentaje;
	}

	/**
	 * @return the valorComision
	 */
	public BigDecimal getValorComision() {
		return valorComision;
	}

	/**
	 * @param valorComision
	 *            the valorComision to set
	 */
	public void setValorComision(BigDecimal valorComision) {
		this.valorComision = valorComision;
	}

	/**
	 * @return the esImpuesto
	 */
	public boolean isEsImpuesto() {
		return esImpuesto;
	}

	/**
	 * @param esImpuesto
	 *            the esImpuesto to set
	 */
	public void setEsImpuesto(boolean esImpuesto) {
		this.esImpuesto = esImpuesto;
	}

	/**
	 * @return the esFee
	 */
	public boolean isEsFee() {
		return esFee;
	}

	/**
	 * @param esFee
	 *            the esFee to set
	 */
	public void setEsFee(boolean esFee) {
		this.esFee = esFee;
	}

	/**
	 * @return the descripcionCorta
	 */
	public String getDescripcionCorta() {
		return descripcionCorta;
	}

	/**
	 * @param descripcionCorta
	 *            the descripcionCorta to set
	 */
	public void setDescripcionCorta(String descripcionCorta) {
		this.descripcionCorta = descripcionCorta;
	}

	/**
	 * @return the servicioFee
	 */
	public BaseVO getServicioFee() {
		if (servicioFee == null) {
			servicioFee = new BaseVO();
		}
		return servicioFee;
	}

	/**
	 * @param servicioFee
	 *            the servicioFee to set
	 */
	public void setServicioFee(BaseVO servicioFee) {
		this.servicioFee = servicioFee;
	}

	/**
	 * @return the servicioImpto
	 */
	public BaseVO getServicioImpto() {
		if (servicioImpto == null) {
			servicioImpto = new BaseVO();
		}
		return servicioImpto;
	}

	/**
	 * @param servicioImpto
	 *            the servicioImpto to set
	 */
	public void setServicioImpto(BaseVO servicioImpto) {
		this.servicioImpto = servicioImpto;
	}

	/**
	 * @return the cargaIgv
	 */
	public boolean isCargaIgv() {
		return cargaIgv;
	}

	/**
	 * @param cargaIgv
	 *            the cargaIgv to set
	 */
	public void setCargaIgv(boolean cargaIgv) {
		this.cargaIgv = cargaIgv;
	}

	/**
	 * @return the pagaIgv
	 */
	public boolean isPagaIgv() {
		return pagaIgv;
	}

	/**
	 * @param pagaIgv
	 *            the pagaIgv to set
	 */
	public void setPagaIgv(boolean pagaIgv) {
		this.pagaIgv = pagaIgv;
	}

	/**
	 * @return the imptoIgv
	 */
	public BaseVO getImptoIgv() {
		if (imptoIgv == null) {
			imptoIgv = new BaseVO();
		}
		return imptoIgv;
	}

	/**
	 * @param imptoIgv
	 *            the imptoIgv to set
	 */
	public void setImptoIgv(BaseVO imptoIgv) {
		this.imptoIgv = imptoIgv;
	}

	/**
	 * @return the listaServicioDepende
	 */
	public List<BaseVO> getListaServicioDepende() {
		if (listaServicioDepende == null) {
			listaServicioDepende = new ArrayList<BaseVO>();
		}
		return listaServicioDepende;
	}

	/**
	 * @param listaServicioDepende
	 *            the listaServicioDepende to set
	 */
	public void setListaServicioDepende(List<BaseVO> listaServicioDepende) {
		this.listaServicioDepende = listaServicioDepende;
	}

	/**
	 * @return the parametroAsociado
	 */
	public BaseVO getParametroAsociado() {
		if (parametroAsociado == null) {
			parametroAsociado = new BaseVO();
		}
		return parametroAsociado;
	}

	/**
	 * @param parametroAsociado
	 *            the parametroAsociado to set
	 */
	public void setParametroAsociado(BaseVO parametroAsociado) {
		this.parametroAsociado = parametroAsociado;
	}

	/**
	 * @return the visible
	 */
	public boolean isVisible() {
		return visible;
	}

	/**
	 * @param visible
	 *            the visible to set
	 */
	public void setVisible(boolean visible) {
		this.visible = visible;
	}

	/**
	 * @return the valorParametro
	 */
	public String getValorParametro() {
		return valorParametro;
	}

	/**
	 * @param valorParametro
	 *            the valorParametro to set
	 */
	public void setValorParametro(String valorParametro) {
		this.valorParametro = valorParametro;
	}

	/**
	 * @return the servicioPadre
	 */
	public boolean isServicioPadre() {
		return servicioPadre;
	}

	/**
	 * @param servicioPadre
	 *            the servicioPadre to set
	 */
	public void setServicioPadre(boolean servicioPadre) {
		this.servicioPadre = servicioPadre;
	}

}
